#import <Foundation/Foundation.h>

#include <MetalKit/MetalKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTLRenderer : NSObject

- (instancetype)initWithDevice:(nullable id<MTLDevice>)device;

- (void)beginDrawWithSurfaceHandle:(id<CAMetalDrawable>)handle
                             width:(CGFloat)width
                            height:(CGFloat)height
                             scale:(CGFloat)scale;
- (void)endDraw;

- (void)addPolylineWithPath:(const CGPoint *)path
                      count:(NSInteger)count
                      color:(NSColor *)color
                  thickness:(CGFloat)thickness;

- (void)pushClipRect:(CGRect)rect;
- (void)popClipRect;

@end

NS_ASSUME_NONNULL_END
