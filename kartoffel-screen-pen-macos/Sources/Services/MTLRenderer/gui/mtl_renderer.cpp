#include "mtl_renderer.hpp"

#include "layout/vertex.hpp"
#include "mtl_buffer_manager.hpp"

#include <simd/simd.h>
#include <iostream>

namespace gui {

static gui::mtl_buffer_manager_t buffer_manager;

mtl_renderer_t::mtl_renderer_t(MTL::Device* device)
    : _device{device},
      _command_queue{nullptr, [](MTL::CommandQueue *ptr) { if (ptr) ptr->release(); }},
      _render_pipeline{nullptr, [](MTL::RenderPipelineState *ptr) { if (ptr) ptr->release(); }},
      _depth_stencil{nullptr, [](MTL::DepthStencilState *ptr) { if (ptr) ptr->release(); }},
      _texture{nullptr, [](MTL::Texture *ptr) { if (ptr) ptr->release(); }},
      _surface{nullptr},
      _display_scale{},
      _command_buffer{nullptr},
      _encoder{nullptr}
{
    _command_queue.reset(_device->newCommandQueue());
    
    setup_render_pipeline();
    setup_depth_stencil();
    setup_default_texture();
}

mtl_renderer_t::~mtl_renderer_t()
{
}

void mtl_renderer_t::begin_draw(const gui::context_t &ctx)
{
    _surface = reinterpret_cast<CA::MetalDrawable *>(ctx.surface_handle);
    _display_scale = ctx.display_scale;
    
    _command_buffer = _command_queue->commandBuffer();
    MTL::RenderPassDescriptor *desc = MTL::RenderPassDescriptor::alloc()->init();

    desc->colorAttachments()->object(0)->setTexture(_surface->texture());
    desc->colorAttachments()->object(0)->setLoadAction(MTL::LoadActionClear);
    desc->colorAttachments()->object(0)->setClearColor(MTL::ClearColor::Make(0.0f, 0.0f, 0.0f, 0.0f));
    
    _encoder = _command_buffer->renderCommandEncoder(desc);
    desc->release();
    
    _encoder->pushDebugGroup(NS::String::string("Boden Gui rendering",
                                               NS::StringEncoding::UTF8StringEncoding));
    
    _encoder->setCullMode(MTL::CullModeNone);
    _encoder->setDepthStencilState(_depth_stencil.get());
    _encoder->setRenderPipelineState(_render_pipeline.get());
    
    MTL::Viewport viewport =
    {
        .originX = 0.0,
        .originY = 0.0,
        .width = (double)(ctx.display_size.width * ctx.display_scale.x),
        .height = (double)(ctx.display_size.height * ctx.display_scale.y),
        .znear = 0.0,
        .zfar = 1.0
    };
    
    float L = 0;
    float R = ctx.display_size.width * ctx.display_scale.x;
    float T = 0;
    float B = ctx.display_size.height * ctx.display_scale.y;
    float N = (float)viewport.znear;
    float F = (float)viewport.zfar;
    float X = ctx.display_scale.x;
    float Y = ctx.display_scale.y;
    
    const float ortho_projection[4][4] =
    {
        { (2.0f * X)/(R-L),   0.0f,                 0.0f,   0.0f },
        { 0.0f,               (2.0f * Y)/(T-B),     0.0f,   0.0f },
        { 0.0f,               0.0f,                 1/(F-N),   0.0f },
        { (R+L)/(L-R),        (T+B)/(B-T),          N/(F-N),   1.0f },
    };
    
    _encoder->setViewport(viewport);
    _encoder->setVertexBytes(&ortho_projection, sizeof(ortho_projection), 1);
}

void mtl_renderer_t::end_draw()
{
    if(builder.indices.size() == 0 || builder.vertices.size() == 0)
    {
        _encoder->popDebugGroup();
        _encoder->endEncoding();
        return;
    }
    
    mtl_buffer_ref_t vertex_buffer = buffer_manager.dequeueReusableBuffer(_device,
                                                                          builder.vertices.size() * sizeof(gui::layout::vertex_t));
    
    mtl_buffer_ref_t index_buffer = buffer_manager.dequeueReusableBuffer(_device,
                                                                         builder.indices.size() * sizeof(gui::layout::index_t));

    _encoder->setVertexBuffer(vertex_buffer->get_buffer(), 0, 0);
    
    memcpy((char*)vertex_buffer->get_buffer()->contents(),
           builder.vertices.data(),
           builder.vertices.size() * sizeof(gui::layout::vertex_t));
    
    memcpy((char*)index_buffer->get_buffer()->contents(),
           builder.indices.data(),
           builder.indices.size() * sizeof(gui::layout::index_t));

    for(const gui::command_t &command : builder.commands)
    {
        MTL::ScissorRect scissorRect =
        {
            .x = (NS::UInteger)(command.clip_rect.origin.x * _display_scale.x),
            .y = (NS::UInteger)(command.clip_rect.origin.y * _display_scale.y),
            .width = (NS::UInteger)(command.clip_rect.size.width * _display_scale.x),
            .height = (NS::UInteger)(command.clip_rect.size.height * _display_scale.y)
        };
        _encoder->setScissorRect(scissorRect);

        _encoder->setFragmentTexture(_texture.get(), 0);
        
        _encoder->drawIndexedPrimitives(MTL::PrimitiveTypeTriangleStrip,
                                       command.count,
                                       MTL::IndexTypeUInt32,
                                       index_buffer->get_buffer(),
                                       command.index_buffer_offset * sizeof(gui::layout::index_t));
    }

    _command_buffer->addCompletedHandler([vertex_buffer, index_buffer](MTL::CommandBuffer* buffer)
    {
        buffer_manager.queueReusableBuffer(vertex_buffer);
        buffer_manager.queueReusableBuffer(index_buffer);
    });
    
    _encoder->popDebugGroup();
    _encoder->endEncoding();
    
    _command_buffer->presentDrawable(_surface);
    _command_buffer->commit();
}

void mtl_renderer_t::setup_depth_stencil()
{
    MTL::DepthStencilDescriptor *desc = MTL::DepthStencilDescriptor::alloc()->init();
    desc->setDepthCompareFunction(MTL::CompareFunctionAlways);
    desc->setDepthWriteEnabled(false);
    _depth_stencil.reset(_device->newDepthStencilState(desc));
}

void mtl_renderer_t::setup_default_texture()
{
    MTL::TextureDescriptor *desc = MTL::TextureDescriptor::alloc()->init();
    desc->setPixelFormat(MTL::PixelFormatRGBA8Unorm);
    desc->setWidth(1);
    desc->setHeight(1);
    desc->setUsage(MTL::TextureUsageShaderRead);
    _texture.reset(_device->newTexture(desc));
    uint8_t whitePixel[4] = {255, 255, 255, 255};
    MTL::Region region = MTL::Region::Make3D(0, 0, 0, 1, 1, 1);
    _texture->replaceRegion(region, 0, whitePixel, 4);
}

void mtl_renderer_t::setup_render_pipeline()
{
    NS::String *source = NS::String::alloc()->init(R"(
    #include <metal_stdlib>
    using namespace metal;
    
    struct Uniforms 
    {
        float4x4 projectionMatrix;
    };
    
    struct VertexIn 
    {
        float2 position  [[attribute(0)]];
        float2 texCoords [[attribute(1)]];
        uchar4 color     [[attribute(2)]];
    };
    
    struct VertexOut 
    {
        float4 position [[position]];
        float2 texCoords;
        float4 color;
    };
    
    vertex VertexOut vertex_main(VertexIn in [[stage_in]],
                                 constant Uniforms &uniforms [[buffer(1)]]) 
    {
        VertexOut out;
        out.position = uniforms.projectionMatrix * float4(in.position, 0, 1);
        out.texCoords = in.texCoords;
        out.color = float4(in.color) / float4(255.0);
        return out;
    }

    fragment half4 fragment_main(VertexOut in [[stage_in]],
                                 texture2d<half, access::sample> texture [[texture(0)]]) 
    {
        constexpr sampler linearSampler(coord::normalized, min_filter::linear, mag_filter::linear, mip_filter::linear);
        half4 texColor = texture.sample(linearSampler, in.texCoords);
    
        return half4(in.color) * texColor;
    }
    )", NS::StringEncoding::UTF8StringEncoding);
    
    NS::Error *error = nullptr;
    MTL::Library *library = _device->newLibrary(source, nullptr, &error);
    if(library == nullptr)
    {
        std::cout << "Error: failed to create Metal library: " << error << std::endl;
        return;
    }
    
    MTL::Function *vertex_func = library->newFunction(NS::String::string("vertex_main", NS::UTF8StringEncoding));
    MTL::Function *fragment_func = library->newFunction(NS::String::string("fragment_main", NS::UTF8StringEncoding));
    if(vertex_func == nullptr || fragment_func == nullptr)
    {
        std::cout << "Error: failed to find Metal shader functions in library: " << error << std::endl;
        if(vertex_func) vertex_func->release();
        if(fragment_func) fragment_func->release();
        library->release();
        return;
    }
    
    MTL::VertexDescriptor *vertex_desc = MTL::VertexDescriptor::alloc()->init();
    vertex_desc->attributes()->object(0)->setOffset(offsetof(gui::layout::vertex_t, position));
    vertex_desc->attributes()->object(0)->setFormat(MTL::VertexFormatFloat2);
    vertex_desc->attributes()->object(0)->setBufferIndex(0);
    vertex_desc->attributes()->object(1)->setOffset(offsetof(gui::layout::vertex_t, uv));
    vertex_desc->attributes()->object(1)->setFormat(MTL::VertexFormatFloat2);
    vertex_desc->attributes()->object(1)->setBufferIndex(0);
    vertex_desc->attributes()->object(2)->setOffset(offsetof(gui::layout::vertex_t, color));
    vertex_desc->attributes()->object(2)->setFormat(MTL::VertexFormatUChar4);
    vertex_desc->attributes()->object(2)->setBufferIndex(0);
    vertex_desc->layouts()->object(0)->setStepRate(1);
    vertex_desc->layouts()->object(0)->setStepFunction(MTL::VertexStepFunctionPerVertex);
    vertex_desc->layouts()->object(0)->setStride(sizeof(gui::layout::vertex_t));

    MTL::RenderPipelineDescriptor *pipeline_desc = MTL::RenderPipelineDescriptor::alloc()->init();
    pipeline_desc->setVertexFunction(vertex_func);
    pipeline_desc->setFragmentFunction(fragment_func);
    pipeline_desc->setVertexDescriptor(vertex_desc);
    pipeline_desc->setRasterSampleCount(1);
    pipeline_desc->colorAttachments()->object(0)->setPixelFormat(MTL::PixelFormatBGRA8Unorm);
    
    pipeline_desc->colorAttachments()->object(0)->setBlendingEnabled(true);
    pipeline_desc->colorAttachments()->object(0)->setRgbBlendOperation(MTL::BlendOperationAdd);
    pipeline_desc->colorAttachments()->object(0)->setSourceRGBBlendFactor(MTL::BlendFactorSourceAlpha);
    pipeline_desc->colorAttachments()->object(0)->setDestinationRGBBlendFactor(MTL::BlendFactorOneMinusSourceAlpha);
    pipeline_desc->colorAttachments()->object(0)->setAlphaBlendOperation(MTL::BlendOperationAdd);
    pipeline_desc->colorAttachments()->object(0)->setSourceAlphaBlendFactor(MTL::BlendFactorOne);
    pipeline_desc->colorAttachments()->object(0)->setDestinationAlphaBlendFactor(MTL::BlendFactorOneMinusSourceAlpha);
    pipeline_desc->setDepthAttachmentPixelFormat(MTL::PixelFormatInvalid);
    pipeline_desc->setStencilAttachmentPixelFormat(MTL::PixelFormatInvalid);
    
    _render_pipeline.reset(_device->newRenderPipelineState(pipeline_desc, &error));
    if(_render_pipeline == nullptr)
    {
        std::cout << "Error: failed to create Metal pipeline state: " << error << std::endl;
        if(vertex_desc) vertex_desc->release();
        if(pipeline_desc) pipeline_desc->release();
        vertex_func->release();
        fragment_func->release();
        library->release();
        return;
    }
    
    vertex_desc->release();
    pipeline_desc->release();
    vertex_func->release();
    fragment_func->release();
    library->release();
}

} // gui
