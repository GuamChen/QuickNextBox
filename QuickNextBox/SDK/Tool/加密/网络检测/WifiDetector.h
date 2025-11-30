//
//  WifiDetector.h
//  QuickNextBox
//
//  Created by lgc on 2025/11/26.
/*
 必须：
 1、Signing & Capabilities → 勾选 Access Wi-Fi Information
 2、<key>NSLocationWhenInUseUsageDescription</key>
 <string>获取 Wi-Fi 名称以提供网络状态</string>
 <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
 <string>获取 Wi-Fi 名称以提供网络状态</string>
 3、CLLocationManager *mgr = [[CLLocationManager alloc] init];
 [mgr requestWhenInUseAuthorization]; // 或 requestAlwaysAuthorization
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const WifiDetectorDidConnectNotification;      // userInfo: @{@"ssid": NSString}
extern NSString * const WifiDetectorDidDisconnectNotification;   // userInfo: nil
extern NSString * const WifiDetectorDidChangeSSIDNotification;   // userInfo: @{@"old": NSString?, @"new": NSString?}

@protocol WifiDetectorDelegate <NSObject>
@optional
- (void)wifiDetectorDidConnectToSSID:(NSString *)ssid;
- (void)wifiDetectorDidDisconnect;
- (void)wifiDetectorDidChangeSSIDFrom:(nullable NSString *)oldSSID to:(nullable NSString *)newSSID;
@end

@interface WifiDetector : NSObject

+ (instancetype)sharedDetector;

/// start/stop monitoring (idempotent)
- (void)startMonitoring;
- (void)stopMonitoring;

/// current known values (may be nil)
@property (nonatomic, readonly, copy, nullable) NSString *currentSSID;
@property (nonatomic, readonly, assign) BOOL isConnectedToWiFi; // whether current path uses Wi-Fi interface

@property (nonatomic, weak, nullable) id<WifiDetectorDelegate> delegate;

/// convenience blocks (optional)
@property (nonatomic, copy, nullable) void (^onConnected)(NSString *ssid);
@property (nonatomic, copy, nullable) void (^onDisconnected)(void);
@property (nonatomic, copy, nullable) void (^onSSIDChanged)(NSString * _Nullable oldSSID, NSString * _Nullable newSSID);

/// optional: polling interval fallback in seconds (default 0 -> disabled). if path changes are missed, set to e.g. 3.0
@property (nonatomic, assign) NSTimeInterval pollingInterval;




+ (void)checkInternetReachable:(void(^)(BOOL isReachable))block;

@end

NS_ASSUME_NONNULL_END
