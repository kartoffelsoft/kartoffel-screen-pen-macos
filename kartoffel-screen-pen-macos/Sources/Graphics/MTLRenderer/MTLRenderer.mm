#import "MTLRenderer.hh"

#import "gui/asset/texture_id.hpp"
#import "gui/layout/vec.hpp"
#import "gui/mtl_renderer.hpp"

#include <memory>
#include <vector>

@implementation MTLRenderer {
    std::unique_ptr<gui::mtl_renderer_t> _renderer;
}

- (instancetype)initWithDevice:(nullable id<MTLDevice>)device {
    self = [super init];
    if(self) {
        _renderer = std::make_unique<gui::mtl_renderer_t>((__bridge MTL::Device *)device);
    }
    return self;
}

- (void)beginDrawOnDrawable:(id<CAMetalDrawable>)drawable
                 loadAction:(MTLLoadAction)loadAction
                      width:(CGFloat)width
                     height:(CGFloat)height
                      scale:(CGFloat)scale {
    gui::context_t context;
    
    context.type = gui::context_type_display;
    context.handle = (gui::context_handle_t)(__bridge CA::MetalDrawable *)drawable;
    context.load_action = (gui::context_load_action_t)loadAction;
    
    context.display_size = gui::layout::size_t{(float)width, (float)height};
    context.display_scale = gui::layout::vec2_t{(float)scale, (float)scale};

    _renderer->begin_draw(context);
}

- (void)beginDrawOnTexture:(id<MTLTexture>)texture
                loadAction:(MTLLoadAction)loadAction
                     width:(CGFloat)width
                    height:(CGFloat)height
                     scale:(CGFloat)scale {
    gui::context_t context;
    
    context.type = gui::context_type_texture;
    context.handle = (gui::context_handle_t)(__bridge MTL::Texture *)texture;
    context.load_action = (gui::context_load_action_t)loadAction;
    
    context.display_size = gui::layout::size_t{(float)width, (float)height};
    context.display_scale = gui::layout::vec2_t{(float)scale, (float)scale};

    _renderer->begin_draw(context);
}

- (void)endDraw {
    _renderer->end_draw();
}

- (void)addPolylineWith:(const CGPoint *)path
                  count:(NSInteger)count
                  color:(CGColorRef)color
              thickness:(CGFloat)thickness {
    std::vector<gui::layout::vec2_t> newPath;
    newPath.reserve(count);

    for(NSInteger i = 0; i < count; ++i) {
        gui::layout::vec2_t vec;
        vec.x = path[i].x;
        vec.y = path[i].y;
        newPath.emplace_back(path[i].x, path[i].y);
    }
    
    const CGFloat *c = CGColorGetComponents(color);
    
    _renderer->builder.add_polyline(newPath,
                                    {(uint8_t)(c[0] * 255),
                                     (uint8_t)(c[1] * 255),
                                     (uint8_t)(c[2] * 255),
                                     (uint8_t)(c[3] * 255)},
                                    thickness);
}

- (void)addTextureWith:(id<MTLTexture>)texture
                    p1:(CGPoint)p1
                    p2:(CGPoint)p2
                 color:(CGColorRef)color {
    _renderer->builder.add_texture((gui::asset::texture_id_t)(__bridge void *)texture,
                                   {(float)p1.x, (float)p1.y},
                                   {(float)p2.x, (float)p2.y},
                                   {0xFF, 0xFF, 0xFF, 0xFF});
}

- (void)pushClipRect:(CGRect)rect {
    _renderer->builder.push_clip_rect({
        static_cast<float>(rect.origin.x),
        static_cast<float>(rect.origin.y),
        static_cast<float>(rect.size.width),
        static_cast<float>(rect.size.height)
    });
}

- (void)popClipRect {
    _renderer->builder.pop_clip_rect();
}

@end
