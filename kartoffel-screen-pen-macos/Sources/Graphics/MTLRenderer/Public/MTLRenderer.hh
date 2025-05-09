#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTLRenderer : NSObject

- (instancetype)initWithDevice:(nullable id<MTLDevice>)device;

@end

NS_ASSUME_NONNULL_END
