#pragma once

#include "builder.hpp"
#include "context.hpp"

#include <Metal/Metal.hpp>
#include <QuartzCore/CAMetalDrawable.hpp>

namespace gui {

using command_queue_ref_t = std::unique_ptr<MTL::CommandQueue, void(*)(MTL::CommandQueue *)>;
using pipeline_ref_t = std::unique_ptr<MTL::RenderPipelineState, void(*)(MTL::RenderPipelineState *)>;
using depth_stencil_ref_t = std::unique_ptr<MTL::DepthStencilState, void(*)(MTL::DepthStencilState *)>;
using texture_ref_t = std::unique_ptr<MTL::Texture, void(*)(MTL::Texture *)>;

class mtl_renderer_t
{
public:
    mtl_renderer_t(MTL::Device* device);
    ~mtl_renderer_t();
    
    void begin_draw(const gui::context_t &context);
    void end_draw();
    
    gui::builder_t builder;

private:
    void setup_depth_stencil();
    void setup_render_pipeline();
    void setup_default_texture();

    MTL::Device *_device;
    
    command_queue_ref_t _command_queue;
    pipeline_ref_t _render_pipeline;
    depth_stencil_ref_t _depth_stencil;
    texture_ref_t _texture;
    

    CA::MetalDrawable *_surface;
    gui::layout::vec2_t _display_scale;
    MTL::CommandBuffer *_command_buffer;
    MTL::RenderCommandEncoder *_encoder;
};

} // gui
