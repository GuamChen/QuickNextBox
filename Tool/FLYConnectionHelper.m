//
//  FLYConnectionHelper.m
//  QuickNextBox
//
//  Created by lgc on 2025/11/12.
//


#import "FLYConnectionHelper.h"

@implementation FLYConnectionHelper

+ (void)raceConnectWithTasks:(NSArray<void(^)(FLYConnectionSuccessBlock success)> *)tasks
                     timeout:(NSTimeInterval)timeout
                successBlock:(FLYConnectionSuccessBlock)successBlock
                failureBlock:(FLYConnectionFailureBlock)failureBlock
{
    if (tasks.count == 0) {
        if (failureBlock) failureBlock();
        return;
    }

    __block BOOL hasSuccess = NO;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    for (void(^task)(FLYConnectionSuccessBlock success) in tasks) {
        dispatch_async(queue, ^{
            task(^(id result) {
                @synchronized (self) {
                    if (!hasSuccess) {
                        hasSuccess = YES;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (successBlock) successBlock(result);
                        });
                    }
                }
            });
        });
    }

    // 超时兜底
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        if (!hasSuccess) {
            hasSuccess = YES;
            if (failureBlock) failureBlock();
        }
    });
}



#pragma mark - 并行收集（等待全部完成）
+ (void)parallelRunWithTasks:(NSArray<FLYParallelTaskBlock> *)tasks
               completeBlock:(FLYParallelCompleteBlock)completeBlock
{
    if (tasks.count == 0) {
        if (completeBlock) completeBlock(@[]);
        return;
    }
    
    dispatch_group_t group = dispatch_group_create();
    __block NSMutableArray *results = [NSMutableArray arrayWithCapacity:tasks.count];
    for (NSUInteger i = 0; i < tasks.count; i++) {
        [results addObject:[NSNull null]];
    }
    
    [tasks enumerateObjectsUsingBlock:^(FLYParallelTaskBlock  _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_group_enter(group);
        task(^(id result){
            @synchronized (results) {
                results[idx] = result ?: [NSNull null];
            }
            dispatch_group_leave(group);
        });
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (completeBlock) completeBlock([results copy]);
    });
}

@end
