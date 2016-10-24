//
//  HCountdownButtonManager.m
//  HXBank
//
//  Created by 侯荡荡 on 16/9/21.
//  Copyright © 2016年 Hou. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "HCountdownButtonManager.h"

@interface HCountdownTask : NSOperation

/**
 *  计时中回调
 */
@property (copy, nonatomic) void (^countingDownBlcok)(NSTimeInterval timeInterval);
/**
 *  计时结束后回调
 */
@property (copy, nonatomic) void (^finishedBlcok)(NSTimeInterval timeInterval);
/**
 *  计时剩余时间
 */
@property (assign, nonatomic) NSTimeInterval leftTimeInterval;
/**
 *  后台任务标识，确保程序进入后台依然能够计时
 */
@property (assign, nonatomic) UIBackgroundTaskIdentifier taskIdentifier;

/**
 *  `NSOperation`的`name`属性只在iOS8+中存在，这里定义一个属性，用来兼容 iOS7
 */
@property (copy, nonatomic) NSString *operationName;
/**
 *  标记是否已经取消倒计时
 */
@property (assign, nonatomic) BOOL isInvalidate;

@end


@implementation HCountdownTask

- (void)dealloc {
    _countingDownBlcok = nil;
    _finishedBlcok     = nil;
}

- (void)main {
    self.taskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    
    while (--_leftTimeInterval > 0) {
        
        if (self.isInvalidate) break;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_countingDownBlcok) _countingDownBlcok(_leftTimeInterval);
        });
        
        [NSThread sleepForTimeInterval:1];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_finishedBlcok) {
            _finishedBlcok(0);
        }
    });
    
    if (self.taskIdentifier != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.taskIdentifier];
        self.taskIdentifier = UIBackgroundTaskInvalid;
    }
}


@end




@interface HCountdownButtonManager ()

@property (nonatomic, strong) NSOperationQueue *pool;

@end

@implementation HCountdownButtonManager

+ (instancetype)defaultManager {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self _alloc] _init];
    });
    
    if ([instance class] != [HCountdownButtonManager class]) {
        NSCAssert(NO, @"该类不允许被继承");
    }
    
    return instance;
}

+ (instancetype)alloc {
    NSCAssert(NO, @"请使用`+defaultManager`方法获取实例");
    return nil;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    NSCAssert(NO, @"请使用`+defaultManager`方法获取实例");
    return nil;
}

+ (instancetype)_alloc {
    return [super allocWithZone:NSDefaultMallocZone()];
}

- (instancetype)init {
    NSCAssert(NO, @"请使用`+defaultManager`方法获取实例");
    return nil;
}

- (instancetype)_init {
    if (self = [super init]) {
        _pool = [[NSOperationQueue alloc] init];
    }
    
    return self;
}


- (void)scheduledCountDownWithKey:(NSString *)aKey
                     timeInterval:(NSTimeInterval)timeInterval
                     countingDown:(void (^)(NSTimeInterval))countingDown
                         finished:(void (^)(NSTimeInterval))finished
{
    if (timeInterval > 120) {
        NSCAssert(NO, @"受操作系统后台时间限制，倒计时时间规定不得大于 120 秒.");
    }
    
    if (_pool.operations.count >= 20)  // 最多 20 个并发线程
        return;
    
    HCountdownTask *task = nil;
    if ([self countdownTaskExistWithKey:aKey task:&task]) {
        task.countingDownBlcok = countingDown;
        task.finishedBlcok     = finished;
        if (countingDown) {
            countingDown(task.leftTimeInterval);
        }
    } else {
        task                   = [[HCountdownTask alloc] init];
        task.leftTimeInterval  = timeInterval;
        task.countingDownBlcok = countingDown;
        task.finishedBlcok     = finished;
        
        if ([@([UIDevice currentDevice].systemVersion.doubleValue) compare:@(8)] == NSOrderedAscending) {
            task.operationName = aKey;
        }
        else {
            task.name = aKey;
        }
        
        [_pool addOperation:task];
    }
}


- (BOOL)countdownTaskExistWithKey:(NSString *)akey
                             task:(HCountdownTask *__autoreleasing  _Nullable *)task
{
    __block BOOL taskExist = NO;
    
    if ([@([UIDevice currentDevice].systemVersion.doubleValue) compare:@(8)] == NSOrderedAscending) {
        [_pool.operations enumerateObjectsUsingBlock:^(__kindof HCountdownTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.operationName isEqualToString:akey]) {
                if (task) *task = obj;
                taskExist = YES;
                *stop     = YES;
            }
        }];
    }
    else {
        [_pool.operations enumerateObjectsUsingBlock:^(__kindof HCountdownTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.name isEqualToString:akey]) {
                if (task) *task = obj;
                taskExist = YES;
                *stop     = YES;
            }
        }];
    }
    
    return taskExist;
}


- (void)stopCountDownWithKey:(NSString *)akey{
    
    __block HCountdownTask *task = nil;
    
    if ([@([UIDevice currentDevice].systemVersion.doubleValue) compare:@(8)] == NSOrderedAscending) {
        [_pool.operations enumerateObjectsUsingBlock:^(__kindof HCountdownTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.operationName isEqualToString:akey]) {
                task = (HCountdownTask *)obj;
                *stop     = YES;
            }
        }];
    }
    else {
        [_pool.operations enumerateObjectsUsingBlock:^(__kindof HCountdownTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.name isEqualToString:akey]) {
                task = (HCountdownTask *)obj;
                *stop     = YES;
            }
        }];
    }
    if (task) {
        task.isInvalidate = YES;
        [task cancel];
    }
    
    
}

@end
