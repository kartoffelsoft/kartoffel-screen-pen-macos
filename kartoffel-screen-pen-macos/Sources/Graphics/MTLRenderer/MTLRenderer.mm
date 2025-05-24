#import "MTLRenderer.hh"

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

- (void)beginDrawWithSurfaceHandle:(id<CAMetalDrawable>)handle
                             width:(CGFloat)width
                            height:(CGFloat)height
                             scale:(CGFloat)scale {
    gui::context_t context;
    context.surface_handle = (gui::surface_handle_t)(__bridge CA::MetalDrawable *)handle;
    
    context.display_size = gui::layout::size_t{(float)width, (float)height};
    context.display_scale = gui::layout::vec2_t{(float)scale, (float)scale};

    _renderer->begin_draw(context);
}

- (void)endDraw {
    _renderer->end_draw();
}

- (void)addPolylineWithPath:(const CGPoint *)path
                      count:(NSInteger)count
                      color:(NSColor *)color
                  thickness:(CGFloat)thickness {
    std::vector<gui::layout::vec2_t> newPath;
    newPath.reserve(count);

    for(NSInteger i = 0; i < count; ++i) {
        gui::layout::vec2_t vec;
        vec.x = path[i].x;
        vec.y = path[i].y;
        newPath.emplace_back(path[i].x, path[i].y);
    }
    
    _renderer->builder.add_polyline(newPath, {0xFF, 0xFF, 0x00, 0xFF}, thickness);
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
