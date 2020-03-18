//
//  FUDUIStuckUtil.h
//  FUDMonitor
//
//  Created by lanfudong on 2020/3/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FUDUIStuckUtil : NSObject

@property (nonatomic, copy) NSString *logPath;

- (void)start;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
