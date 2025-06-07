#import <Foundation/Foundation.h>

#include <MetalKit/MetalKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTLRenderer : NSObject

- (instancetype)initWithDevice:(nullable id<MTLDevice>)device;

- (void)beginDrawOnDrawable:(id<CAMetalDrawable>)drawable
                 loadAction:(MTLLoadAction)loadAction
                      width:(CGFloat)width
                     height:(CGFloat)height
                      scale:(CGFloat)scale
  NS_SWIFT_NAME(beginDraw(onDrawable:loadAction:width:height:scale:));

- (void)beginDrawOnTexture:(id<MTLTexture>)handle
                loadAction:(MTLLoadAction)loadAction
                     width:(CGFloat)width
                    height:(CGFloat)height
                     scale:(CGFloat)scale
  NS_SWIFT_NAME(beginDraw(onTexture:loadAction:width:height:scale:));

- (void)endDraw;

- (void)addPolylineWith:(const CGPoint *)path
                  count:(NSInteger)count
                  color:(NSColor *)color
              thickness:(CGFloat)thickness;

- (void)addTextureWith:(id<MTLTexture>)texture
                    p1:(CGPoint)p1
                    p2:(CGPoint)p2
                 color:(NSColor *)color;

- (void)pushClipRect:(CGRect)rect;
- (void)popClipRect;

@end

NS_ASSUME_NONNULL_END
