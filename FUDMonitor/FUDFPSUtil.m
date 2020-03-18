//
//  FUDFPSUtil.m
//  FUDMonitor
//
//  Created by lanfudong on 2020/3/6.
//

#import "FUDFPSUtil.h"

@interface FUDFPSUtil ()

@property (nonatomic, strong) CADisplayLink *link;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) NSInteger fps;
@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, copy) void (^block)(NSInteger fps);

@end

@implementation FUDFPSUtil

- (void)start {
    if (_link) {
        _link.paused = NO;
    } else {
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(doMonitor:)];
        [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)stop {
    if (_link) {
        _link.paused = YES;
        [_link invalidate];
        _link = nil;
        _count = 0;
        _timestamp = 0;
    }
}

- (void)doMonitor:(CADisplayLink *)link {
    if (_timestamp == 0) {
        _timestamp = link.timestamp;
        return;
    }
    
    _count ++;
    NSTimeInterval delta = link.timestamp - _timestamp;
    if (delta >= 1.f) {
        _fps = ceil(_count / delta);
        _count = 0;
        _timestamp = 0;
        if (_block) {
            _block(_fps);
        }
    }
}

- (void)setCallback:(void(^)(NSInteger fps))block {
    self.block = block;
}

@end
