//
//  WifiDetector.m
//  QuickNextBox
//
//  Created by lgc on 2025/11/26.
//


#import "WifiDetector.h"
#import <Network/Network.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <NetworkExtension/NEHotspotNetwork.h>
#import <CoreLocation/CoreLocation.h>

NSString * const WifiDetectorDidConnectNotification = @"WifiDetectorDidConnectNotification";
NSString * const WifiDetectorDidDisconnectNotification = @"WifiDetectorDidDisconnectNotification";
NSString * const WifiDetectorDidChangeSSIDNotification = @"WifiDetectorDidChangeSSIDNotification";

@interface WifiDetector ()
@property (nonatomic, strong) nw_path_monitor_t monitor;
@property (nonatomic, strong) dispatch_queue_t monitorQueue;

@property (nonatomic, copy, nullable) NSString *currentSSID;
@property (nonatomic, assign) BOOL isConnectedToWiFi;
@property (nonatomic, strong, nullable) NSTimer *pollTimer;

@property (nonatomic, strong, nullable) CLLocationManager *locationManager;

@end

@implementation WifiDetector

+ (instancetype)sharedDetector {
    static WifiDetector *inst;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        inst = [[WifiDetector alloc] initPrivate];
    });
    return inst;
}

- (instancetype)initPrivate {
    if (self = [super init]) {
        _monitorQueue = dispatch_queue_create("com.qnb.WifiDetector.monitor", DISPATCH_QUEUE_SERIAL);
        _pollingInterval = 0.0;
        
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager requestWhenInUseAuthorization];
    }
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[WifiDetector sharedDetector]"
                                 userInfo:nil];
    return nil;
}

- (void)startMonitoring {
    if (self.monitor) return;
    
    CLAuthorizationStatus au =  [CLLocationManager authorizationStatus];
    if( au == kCLAuthorizationStatusDenied || au == kCLAuthorizationStatusNotDetermined){
        [GCAlertManager showTemporaryMessage:@"定位定位未授权"];
       
    }
    
    // create NWPathMonitor to watch for interface type changes
    self.monitor  = nw_path_monitor_create();
    
    nw_path_monitor_set_queue(self.monitor, self.monitorQueue);
    
    __weak typeof(self) wself = self;
    nw_path_monitor_set_update_handler(self.monitor, ^(nw_path_t path) {
        __strong typeof(wself) sself = wself;
        if (!sself) return;
        
        // 判断是否使用 WiFi
        BOOL hasWifi = nw_path_uses_interface_type(path, nw_interface_type_wifi); 
        [sself handlePathWifiState:hasWifi];
    });
    nw_path_monitor_start(self.monitor);
    
    // optionally start polling if pollingInterval > 0
    if (self.pollingInterval > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setupPollTimer];
        });
    }
    
    // run an initial SSID read
    [self readCurrentSSIDAndNotifyIfNeeded];
}

- (void)stopMonitoring {
    if (!self.monitor) return;
    nw_path_monitor_cancel(self.monitor);
    self.monitor = nil;
    [self invalidatePollTimer];
}

#pragma mark - 设置更新定时器
- (void)setupPollTimer {
    [self invalidatePollTimer];
    if (self.pollingInterval <= 0) return;

    self.pollTimer = [NSTimer scheduledTimerWithTimeInterval:self.pollingInterval repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self readCurrentSSIDAndNotifyIfNeeded];
    }];
    
    [[NSRunLoop mainRunLoop] addTimer:self.pollTimer forMode:NSRunLoopCommonModes];
}

- (void)invalidatePollTimer {
    [self.pollTimer invalidate];
    self.pollTimer = nil;
}



#pragma mark - path handling
- (void)handlePathWifiState:(BOOL)hasWifi {
    BOOL previous = self.isConnectedToWiFi;
    self.isConnectedToWiFi = hasWifi;
    if (previous != hasWifi) {
        if (hasWifi) {
            // just switched to Wi-Fi: read SSID
            [self readCurrentSSIDAndNotifyIfNeeded];
        } else {
            // left Wi-Fi -> notify disconnect
            [self updateSSID:nil notifyDisconnect:YES];
        }
    } else {
        // path still wifi -> still read SSID to detect SSID changes
        if (hasWifi) {
            [self readCurrentSSIDAndNotifyIfNeeded];
        }
    }
}

#pragma mark - SSID read & notification
- (void)readCurrentSSIDAndNotifyIfNeeded {
    // Try modern API on iOS 14+ first
    if (@available(iOS 14.0, *)) {
        [NEHotspotNetwork fetchCurrentWithCompletionHandler:^(NEHotspotNetwork * _Nullable currentNetwork) {
            NSString *ssid = currentNetwork.SSID;
            // Note: ssid may be nil if entitlements/permissions missing
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateSSID:ssid notifyDisconnect: (ssid==nil && !self.isConnectedToWiFi)];
            });
        }];
    } else {
        // fallback to CNCopyCurrentNetworkInfo
        NSString *ssid_res = nil;
        
        NSArray *ifs = (__bridge_transfer NSArray *)CNCopySupportedInterfaces();
        for (NSString *ifname in ifs) {
            CFDictionaryRef infoRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifname);
            if (infoRef) {
                NSDictionary *info = (__bridge_transfer NSDictionary *)infoRef;
                NSString *ssid = info[(NSString *)kCNNetworkInfoKeySSID];
                if (ssid && ssid.length > 0) ssid_res =  ssid;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateSSID:ssid_res notifyDisconnect: (ssid_res==nil && !self.isConnectedToWiFi)];
        });
    }
}



- (void)updateSSID:(NSString *)newSSID notifyDisconnect:(BOOL)notifyDisconnect {
    NSString *old = self.currentSSID;
    if ((old == nil && newSSID == nil)) {
        // nothing changed; but possibly a disconnect notification required
        if (notifyDisconnect) {
            [self postDisconnect];
        }
        return;
    }
    if ((old == nil && newSSID != nil) || (old != nil && newSSID == nil) || (old && newSSID && ![old isEqualToString:newSSID])) {
        // SSID changed (including nil -> value or value -> nil)
        self.currentSSID = newSSID;
        // notify change
        [self postSSIDChangeFrom:old to:newSSID];
        if (newSSID) {
            [self postConnectedToSSID:newSSID];
        } else if (notifyDisconnect) {
            [self postDisconnect];
        }
    } else {
        // same SSID, no change
    }
}

#pragma mark - posting
- (void)postConnectedToSSID:(NSString *)ssid {
    // delegate
    if ([self.delegate respondsToSelector:@selector(wifiDetectorDidConnectToSSID:)]) {
        [self.delegate wifiDetectorDidConnectToSSID:ssid];
    }
    if (self.onConnected) self.onConnected(ssid);
    NSDictionary *u = @{@"ssid": ssid};
    [[NSNotificationCenter defaultCenter] postNotificationName:WifiDetectorDidConnectNotification object:self userInfo:u];
}

- (void)postDisconnect {
    if ([self.delegate respondsToSelector:@selector(wifiDetectorDidDisconnect)]) {
        [self.delegate wifiDetectorDidDisconnect];
    }
    if (self.onDisconnected) self.onDisconnected();
    [[NSNotificationCenter defaultCenter] postNotificationName:WifiDetectorDidDisconnectNotification object:self userInfo:nil];
}

- (void)postSSIDChangeFrom:(NSString *)oldSSID to:(NSString *)newSSID {
    if ([self.delegate respondsToSelector:@selector(wifiDetectorDidChangeSSIDFrom:to:)]) {
        [self.delegate wifiDetectorDidChangeSSIDFrom:oldSSID to:newSSID];
    }
    if (self.onSSIDChanged) self.onSSIDChanged(oldSSID, newSSID);
    NSMutableDictionary *u = [NSMutableDictionary dictionary];
    if (oldSSID) u[@"old"] = oldSSID;
    if (newSSID) u[@"new"] = newSSID;
    [[NSNotificationCenter defaultCenter] postNotificationName:WifiDetectorDidChangeSSIDNotification object:self userInfo:u];
}

#pragma mark - public getters
- (NSString *)currentSSID {
    return _currentSSID;
}

- (BOOL)isConnectedToWiFi {
    return _isConnectedToWiFi;
}


+ (void)checkInternetReachable:(void(^)(BOOL isReachable))block {
    
    NSURL *url = [NSURL URLWithString:@"http://captive.apple.com/hotspot-detect.html"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 2;
    
    NSURLSessionDataTask *task =
    [[NSURLSession sharedSession] dataTaskWithRequest:request
                                    completionHandler:^(NSData *data, NSURLResponse *resp, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(error == nil);
        });
    }];
    [task resume];
}
@end
