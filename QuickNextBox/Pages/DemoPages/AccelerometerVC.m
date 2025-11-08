//
//  TestVC.m
//  helloworld
//
//  Created by lgc on 2025/10/12.
//

#import "AccelerometerVC.h"
#import "MBHudDemoVC.h"
#import "MotionManager.h"


@interface AccelerometerVC ()
@property(nonatomic,assign) NSTimeInterval lastShakeTime;
@end

@implementation AccelerometerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGB(229, 232, 232);
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"案例内容： 进入MotionManager，学习了检测加速度计、设备运动、磁力计、陀螺仪，并且完成了一个小案例:摇一摇检测";
    titleLabel.numberOfLines = 0;
    titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = [UIColor labelColor];
    titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    // 关键设置
    titleLabel.preferredMaxLayoutWidth = SCREEN_WIDTH * 0.7;
    
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.equalTo(self.view.mas_bottom).multipliedBy(0.15);
        make.width.lessThanOrEqualTo(@(SCREEN_WIDTH * 0.7)); // 设置最大宽度限制
    }];
    

    // 2.1 现代替代方式  CMMotionManager
    [self setupMotionDetection];
}


- (void)setupMotionDetection {
    MotionManager *motionManager = [MotionManager sharedManager];
    
    // 开始加速度监测
    if ([motionManager startAccelerometerUpdatesWithInterval:0.1 handler:^(CMAcceleration acceleration, NSTimeInterval timestamp) {
        // 处理加速度数据
//        [self handleAcceleration:acceleration];
    }]) {
        NSLog(@"加速度监测已启动");
    }
    
    
    // 开始设备运动监测
    if ([motionManager startDeviceMotionUpdatesWithInterval:0.1 handler:^(CMDeviceMotion *motion) {
        // 处理完整的运动数据
        [self handleDeviceMotion:motion];
        [self handleAcceleration:motion.userAcceleration];
    }]) {
        NSLog(@"设备运动监测已启动");
    }
}

- (void)handleAcceleration:(CMAcceleration)acceleration {
    // 实现你的业务逻辑
    // 例如：摇一摇检测、设备方向判断等
    CGFloat totalAcceleration = sqrt(acceleration.x * acceleration.x +
                                     acceleration.y * acceleration.y +
                                     acceleration.z * acceleration.z);
    

    CGFloat threshold = 1.8;     // 摇动阈值（可根据需要调整）
    
    if (totalAcceleration > threshold) {
        NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
        NSLog(@"检测到剧烈晃动");
        
        // 防抖：1秒内不重复检测
        if (currentTime - self.lastShakeTime > 1.0) {
            self.lastShakeTime = currentTime;
            // [self onShakeDetected];
        }
    }
    
}


- (void)handleDeviceMotion:(CMDeviceMotion *)motion {
    // 使用姿态数据
    CGFloat roll = motion.attitude.roll * 180.0 / M_PI;
    CGFloat pitch = motion.attitude.pitch * 180.0 / M_PI;
    
    if (fabs(roll) > 45 || fabs(pitch) > 45) {
        NSLog(@"设备倾斜角度较大");
    }
}





- (void)dealloc {
    [[MotionManager sharedManager] setMotionmanagerDisable];
    
    
}
@end

