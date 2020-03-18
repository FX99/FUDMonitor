//
//  FUDUIStuckUtil.m
//  FUDMonitor
//
//  Created by lanfudong on 2020/3/7.
//

#import "FUDUIStuckUtil.h"
#import "BSBacktraceLogger.h"

@interface FUDUIStuckUtil ()

@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, strong) dispatch_queue_t logQueue;
@property (nonatomic, assign) CFRunLoopObserverRef observer;
@property (nonatomic, assign) CFRunLoopActivity activity;
@property (nonatomic, assign) NSInteger count;

@end

@implementation FUDUIStuckUtil

static void runLoopObserverCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    FUDUIStuckUtil *stuckUtil = (__bridge FUDUIStuckUtil *)info;
    stuckUtil->_activity = activity;
    
    dispatch_semaphore_signal(stuckUtil->_semaphore);
}

- (void)start {
    [self registerRunloopObserver];
}

- (void)stop {
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), _observer, kCFRunLoopCommonModes);
    CFRelease(_observer);
}

- (void)registerRunloopObserver {
    if (_logQueue) return;
    _logQueue = dispatch_queue_create("com.fudo.uistuck", DISPATCH_QUEUE_SERIAL);
    CFRunLoopObserverContext context = {0, (__bridge void*)self, NULL, NULL};
    _observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, &runLoopObserverCallback, &context);
    CFRunLoopAddObserver(CFRunLoopGetMain(), _observer, kCFRunLoopCommonModes);
    
    _semaphore = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        while (self->_observer) {
            long st = dispatch_semaphore_wait(self->_semaphore, dispatch_time(DISPATCH_TIME_NOW, 50 * NSEC_PER_MSEC));
            if (st != 0) {
                if (self->_activity == kCFRunLoopBeforeSources || self->_activity == kCFRunLoopAfterWaiting) {
                    self->_count++;
                    if (self->_count > 5) {
                        NSLog(@"FUDUIStuckUtil: UI Stuck just happened!");
                        NSString *log = [BSBacktraceLogger bs_backtraceOfMainThread];
                        dispatch_async(self->_logQueue, ^{
                            [self writeStuckLog:log];
                        });
                    }
                }
            } else {
                self->_count = 0;
            }
        }
    });
}

- (void)writeStuckLog:(NSString *)log {
    if (log.length == 0) return;
    if (_logPath.length == 0) {
        NSString *defaultPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        _logPath = [defaultPath stringByAppendingPathComponent:@"fudstuck.log"];
    }
    
    NSLog(@"%@", _logPath);
    
    NSFileManager *fileManager = NSFileManager.defaultManager;
    if (![fileManager fileExistsAtPath:_logPath]) {
        [fileManager createFileAtPath:_logPath contents:nil attributes:nil];
    }
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:_logPath];
    if (!fileHandle) return;
    NSDate *time = [NSDate date];
    NSString *logString = [[NSString stringWithFormat:@"%@\n", time] stringByAppendingString:log];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[logString dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandle closeFile];
}

@end
