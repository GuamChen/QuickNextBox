//
//  FLYConnectionHelper.h
//  QuickNextBox
//  hiicam 开发中优化连接速度，把串行http请求，改写成并行抢占式请求，效果不错提炼工具
//  Created by lgc on 2025/11/12.
//

#pragma mark ----- 使用方法
/*
- (void)testParallel {
    void (^task1)(void(^completion)(id)) = ^(void(^completion)(id)){
        [self requestToServerA:^(id response) {
            completion(response);
        }];
    };
    
    void (^task2)(void(^completion)(id)) = ^(void(^completion)(id)){
        [self requestToServerB:^(id response) {
            completion(response);
        }];
    };
    
    [FLYConnectionHelper parallelRunWithTasks:@[task1, task2]
                                completeBlock:^(NSArray *results) {
        id resultA = results[0];
        id resultB = results[1];
        NSLog(@"A: %@, B: %@", resultA, resultB);
        [self handleResultsFromA:resultA andB:resultB];
    }];
}
 **/
#import <Foundation/Foundation.h>

typedef void(^FLYConnectionSuccessBlock)(id result);
typedef void(^FLYConnectionFailureBlock)(void);

typedef void(^FLYParallelTaskBlock)(void(^completion)(id result));
typedef void(^FLYParallelCompleteBlock)(NSArray *results);


@interface FLYConnectionHelper : NSObject

/// 抢占式并行任务执行器
/// @param tasks 任务数组（每个元素是一个 block，内部执行异步回调）
/// @param timeout 超时时间（秒）
/// @param successBlock 任意一个任务成功后立即回调（只回调一次）
/// @param failureBlock 全部失败或超时后回调
+ (void)raceConnectWithTasks:(NSArray<void(^)(FLYConnectionSuccessBlock success)> *)tasks
                     timeout:(NSTimeInterval)timeout
                successBlock:(FLYConnectionSuccessBlock)successBlock
                failureBlock:(FLYConnectionFailureBlock)failureBlock;


/// 并行执行（等待全部完成）
/// @param tasks 并行任务数组，每个任务内部执行 completion(result)
/// @param completeBlock 全部任务完成后的统一回调，results 数组与 tasks 一一对应
+ (void)parallelRunWithTasks:(NSArray<FLYParallelTaskBlock> *)tasks
               completeBlock:(FLYParallelCompleteBlock)completeBlock;




@end
