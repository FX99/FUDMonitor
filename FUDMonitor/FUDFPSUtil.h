//
//  FUDFPSUtil.h
//  FUDMonitor
//
//  Created by lanfudong on 2020/3/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FUDFPSUtil : NSObject

- (void)start;
- (void)stop;
- (void)setCallback:(void(^)(NSInteger fps))block;

@end

NS_ASSUME_NONNULL_END
