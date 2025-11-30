//
//  MotionManager 2.h
//  QuickNextBox
//
//  Created by lgc on 2025/11/8.
//


// MotionManager.m
#import "MotionManager.h"

@interface MotionManager ()
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) AccelerationHandler accelerationHandler;
@property (nonatomic, strong) DeviceMotionHandler deviceMotionHandler;
@property (nonatomic, strong) GyroHandler gyroHandler;
@property (nonatomic, strong) MagnetometerHandler magnetometerHandler;
@end

@implementation MotionManager

+ (instancetype)sharedManager {
    static MotionManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    return self;
}

- (void) setMotionmanagerDisable{
    [self stopAccelerometerUpdates];
    [self stopGyroUpdates];
    [self stopMagnetometerUpdates];
    [self stopDeviceMotionUpdates];
}

#pragma mark - 加速度计
- (BOOL)startAccelerometerUpdatesWithInterval:(NSTimeInterval)interval
                                     handler:(AccelerationHandler)handler {
    if (!self.motionManager.accelerometerAvailable) {
        return NO;
    }
    
    self.accelerationHandler = handler;
    self.motionManager.accelerometerUpdateInterval = interval;
    
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue]
                                             withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        if (error) {
            NSLog(@"加速度计错误: %@", error);
            return;
        }
        
        if (self.accelerationHandler) {
            self.accelerationHandler(accelerometerData.acceleration, accelerometerData.timestamp);
        }
    }];
    
    return YES;
}

- (void)stopAccelerometerUpdates {
    [self.motionManager stopAccelerometerUpdates];
    self.accelerationHandler = nil;
}

#pragma mark - 设备运动
- (BOOL)startDeviceMotionUpdatesWithInterval:(NSTimeInterval)interval
                                    handler:(DeviceMotionHandler)handler {
    if (!self.motionManager.deviceMotionAvailable) {
        return NO;
    }
    
    self.deviceMotionHandler = handler;
    self.motionManager.deviceMotionUpdateInterval = interval;
    
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                            withHandler:^(CMDeviceMotion *motion, NSError *error) {
        if (error) {
            NSLog(@"设备运动错误: %@", error);
            return;
        }
        
        if (self.deviceMotionHandler) {
            self.deviceMotionHandler(motion);
        }
    }];
    
    return YES;
}

- (void)stopDeviceMotionUpdates {
    [self.motionManager stopDeviceMotionUpdates];
    self.deviceMotionHandler = nil;
}




#pragma mark - 手机陀螺仪检测
- (BOOL)startGyroUpdatesWithInterval:(NSTimeInterval)interval
                             handler:(GyroHandler)handler {
    if (!self.motionManager.gyroAvailable) {
        return NO;
    }
    self.gyroHandler = handler;
    self.motionManager.gyroUpdateInterval = interval;
    
    [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue mainQueue]
                                    withHandler:^(CMGyroData *gyroData, NSError *error) {
        if (error) {
            NSLog(@"陀螺仪错误: %@", error);
            return;
        }
        
        CMRotationRate rotationRate = gyroData.rotationRate;
        NSLog(@"陀螺仪 - X: %.2f, Y: %.2f, Z: %.2f", rotationRate.x, rotationRate.y, rotationRate.z);
        
        if (self.gyroHandler) {
            self.gyroHandler(gyroData);
        }
    }];
    
    return YES;
}

- (void)stopGyroUpdates {
    [self.motionManager stopGyroUpdates];
    self.gyroHandler = nil;
}


#pragma mark - 磁力计检测
- (BOOL)starMagnetometerUpdateWithInterval:(NSTimeInterval)interval handle:(MagnetometerHandler)handler {
    if(!self.motionManager.magnetometerAvailable){
        return NO;
    }
    self.magnetometerHandler = handler;
    self.motionManager.magnetometerUpdateInterval = interval;
    
    [self.motionManager startMagnetometerUpdatesToQueue:[NSOperationQueue mainQueue]
                                            withHandler:^(CMMagnetometerData * _Nullable magnetometerData, NSError * _Nullable error) {
        if(error) return;
        
        if( self.magnetometerHandler) self.magnetometerHandler(magnetometerData);
    }];
    
    return YES;
}

- (void)stopMagnetometerUpdates {
    [self.motionManager stopMagnetometerUpdates];
    self.magnetometerHandler = nil;
}


/**

- (void)startDeviceMotionUpdates {
    if (!self.motionManager.deviceMotionAvailable) {
        NSLog(@"设备运动数据不可用");
        return;
    }
    
    self.motionManager.deviceMotionUpdateInterval = 0.1;
    
    // 使用参考坐标系
    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical
                                                            toQueue:[NSOperationQueue mainQueue]
                                                        withHandler:^(CMDeviceMotion *motion, NSError *error) {
        if (error) {
            NSLog(@"设备运动错误: %@", error);
            return;
        }
        
        // 加速度数据（包含重力）
        CMAcceleration gravity = motion.gravity;
        // 用户加速度（去除重力）
        CMAcceleration userAcceleration = motion.userAcceleration;
        // 旋转速率
        CMRotationRate rotationRate = motion.rotationRate;
        // 设备姿态
        CMAttitude *attitude = motion.attitude;
        
        NSLog(@"重力 - X: %.2f, Y: %.2f, Z: %.2f", gravity.x, gravity.y, gravity.z);
        NSLog(@"用户加速度 - X: %.2f, Y: %.2f, Z: %.2f", userAcceleration.x, userAcceleration.y, userAcceleration.z);
        NSLog(@"姿态 - 横滚: %.2f°, 俯仰: %.2f°, 偏航: %.2f°",
              attitude.roll * 180.0 / M_PI,
              attitude.pitch * 180.0 / M_PI,
              attitude.yaw * 180.0 / M_PI);
    }];
}
 - (void)demonstrateDifferentReferenceFrames {
 // 1. 游戏开发 - 任意方向，只需相对运动
 CMAttitudeReferenceFrameXArbitraryZVertical;
 // 应用：赛车游戏、飞行游戏
 
 // 2. 增强现实 - 需要更精确的方向
 CMAttitudeReferenceFrameXArbitraryCorrectedZVertical;
 // 应用：AR应用、虚拟试衣
 
 // 3. 导航应用 - 需要绝对方向
 CMAttitudeReferenceFrameXMagneticNorthZVertical;
 // 应用：指南针、地图导航
 
 // 4. 高精度导航 - 需要真北方向
 CMAttitudeReferenceFrameXTrueNorthZVertical;
 // 应用：专业导航、测量工具
 }
 */

#pragma mark - 可用性检查
- (BOOL)isAccelerometerAvailable {
    return self.motionManager.accelerometerAvailable;
}

- (BOOL)isGyroAvailable {
    return self.motionManager.gyroAvailable;
}

- (BOOL)isDeviceMotionAvailable {
    return self.motionManager.deviceMotionAvailable;
}
- (BOOL)isMagnetometerAvailable {
    return self.motionManager.magnetometerAvailable;
}

@end
