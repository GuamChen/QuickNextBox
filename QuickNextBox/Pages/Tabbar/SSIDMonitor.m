//
//  SSIDMonitor 2.h
//  QuickNextBox
//
//  Created by lgc on 2025/11/26.
//


#import "SSIDMonitor.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CoreLocation/CoreLocation.h>

@interface SSIDMonitor () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, copy) NSString *lastSSID;
@end

@implementation SSIDMonitor

+ (instancetype)shared {
    static SSIDMonitor *s;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ s = [[self alloc] init]; });
    return s;
}

- (instancetype)init {
    if (self = [super init]) {
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
    }
    return self;
}

#pragma mark - Start
/**
 ✔ 允许“定位服务”
 ✔ App 获得 “精确位置” （右上角蓝色箭头）
 ✔ 调用了 requestTemporaryFullAccuracyAuthorization
 ✔ App 在前台
 ✔ 设备连接真实 Wi-Fi（不是热点）
 ✔ 真机测试（不是模拟器）
 */
- (void)startMonitoring {
    if (@available(iOS 13.0, *)) { 
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestTemporaryFullAccuracyAuthorizationWithPurposeKey:@"SSIDAccess"];
    }

    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.5
                                                  target:self
                                                selector:@selector(checkSSID)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)stopMonitoring {
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - SSID

- (void)checkSSID {
    NSString *ssid = [self getCurrentSSID];
    if (![ssid isEqualToString:self.lastSSID]) {
        self.lastSSID = ssid;
        if (self.SSIDChangedBlock) {
            self.SSIDChangedBlock(ssid);
        }
    }
}

- (NSString *)getCurrentSSID {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *ifname in ifs) {
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifname);
        if (info[@"SSID"]) return info[@"SSID"]; 
    }
    return nil;
}

@end
