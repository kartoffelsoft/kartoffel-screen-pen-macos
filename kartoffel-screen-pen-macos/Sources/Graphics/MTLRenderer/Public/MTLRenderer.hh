#import <Foundation/Foundation.h>

#include <MetalKit/MetalKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTLRenderer : NSObject

- (instancetype)initWithDevice:(nullable id<MTLDevice>)device;

- (void)beginDrawOnDrawable:(id<CAMetalDrawable>)drawable
                      width:(CGFloat)width
                     height:(CGFloat)height
                      scale:(CGFloat)scale
  NS_SWIFT_NAME(beginDraw(onDrawable:width:height:scale:));

- (void)beginDrawOnTexture:(id<MTLTexture>)handle
                     width:(CGFloat)width
                    height:(CGFloat)height
                     scale:(CGFloat)scale
  NS_SWIFT_NAME(beginDraw(onTexture:width:height:scale:));

- (void)endDraw;

- (void)addPolylineWithPath:(const CGPoint *)path
                      count:(NSInteger)count
                      color:(NSColor *)color
                  thickness:(CGFloat)thickness;

- (void)pushClipRect:(CGRect)rect;
- (void)popClipRect;

@end

NS_ASSUME_NONNULL_END
