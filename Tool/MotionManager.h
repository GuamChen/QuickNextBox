//
//  MotionManager.h
//  QuickNextBox
//
//  Created by lgc on 2025/11/8.
//


// MotionManager.h
#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^AccelerationHandler)(CMAcceleration acceleration, NSTimeInterval timestamp);
typedef void (^DeviceMotionHandler)(CMDeviceMotion *motion);
typedef void (^GyroHandler)(CMGyroData *gyroData);
typedef void (^MagnetometerHandler)(CMMagnetometerData *MagnetometerData);

@interface MotionManager : NSObject

+ (instancetype)sharedManager;

// 开始/停止加速度监测
- (BOOL)startAccelerometerUpdatesWithInterval:(NSTimeInterval)interval
                                    handler:(AccelerationHandler)handler;
- (void)stopAccelerometerUpdates;

// 开始/停止设备运动监测
- (BOOL)startDeviceMotionUpdatesWithInterval:(NSTimeInterval)interval
                                   handler:(DeviceMotionHandler)handler;
- (void)stopDeviceMotionUpdates;


// 开始/停止陀螺仪监测
- (BOOL)startGyroUpdatesWithInterval:(NSTimeInterval)interval
                             handler:(GyroHandler)handler;
- (void)stopGyroUpdates;

// 开始/停止磁力计监测
- (BOOL)starMagnetometerUpdateWithInterval:(NSTimeInterval)interval handle:(MagnetometerHandler)handler;
- (void)stopMagnetometerUpdates;

// 停止 _motionManager 监测工作
- (void) setMotionmanagerDisable;

// 工具方法
- (BOOL)isAccelerometerAvailable;
- (BOOL)isDeviceMotionAvailable;
- (BOOL)isGyroAvailable;
- (BOOL)isMagnetometerAvailable;
@end

NS_ASSUME_NONNULL_END
