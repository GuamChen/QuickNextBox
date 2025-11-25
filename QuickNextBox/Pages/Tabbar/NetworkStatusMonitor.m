//
//  NetworkStatusMonitor 2.h
//  QuickNextBox
//
//  Created by lgc on 2025/11/25.
//


#import "NetworkStatusMonitor.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
#import <Network/Network.h>

@interface NetworkStatusMonitor ()
@property (nonatomic, assign) nw_path_monitor_t pathMonitor;

@property (nonatomic, assign) SCNetworkReachabilityRef reachabilityRef;
@end

@implementation NetworkStatusMonitor

+ (instancetype)shared {
    static NetworkStatusMonitor *s;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s = [[NetworkStatusMonitor alloc] init];
    });
    return s;
}

#pragma mark - Start

- (void)startMonitoring {
    if (@available(iOS 12.0, *)) {
        [self startNWPathMonitor];
    } else {
        [self startReachability];
    }
}

- (void)stopMonitoring {
    if (@available(iOS 12.0, *)) {
        if (self.pathMonitor) {
            nw_path_monitor_cancel(self.pathMonitor);  // <-- 正确取消
            self.pathMonitor = nil;
        }
    } else {
        if (self.reachabilityRef) {
            SCNetworkReachabilityUnscheduleFromRunLoop(self.reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
            CFRelease(self.reachabilityRef);
            self.reachabilityRef = nil;
        }
    }
}

#pragma mark - iOS12+ NWPathMonitor

- (void)startNWPathMonitor API_AVAILABLE(ios(12.0)){
    nw_path_monitor_t monitor = nw_path_monitor_create();
    self.pathMonitor = monitor;

    nw_path_monitor_set_update_handler(monitor, ^(nw_path_t path) {
        GCNetworkType type = GCNetworkTypeNone;

        if (nw_path_get_status(path) == nw_path_status_satisfied) { 
            if (nw_path_uses_interface_type(path, nw_interface_type_wifi)) {
                type = GCNetworkTypeWiFi;
            } else if (nw_path_uses_interface_type(path, nw_interface_type_cellular)) {
                type = GCNetworkTypeCellular;
            }
        }

        if (self.networkChangedBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.networkChangedBlock(type);
            });
        }
    });

    dispatch_queue_t queue = dispatch_queue_create("wifi.monitor.queue", DISPATCH_QUEUE_CONCURRENT);
    
    nw_path_monitor_set_queue(monitor, queue); // <-- 正确设置队列
    nw_path_monitor_start(monitor);            // <-- 只传一个参数

}

#pragma mark - iOS10–11 Reachability

static void ReachabilityCallback(SCNetworkReachabilityRef target,
                                 SCNetworkReachabilityFlags flags,
                                 void *info)
{
    NetworkStatusMonitor *self = (__bridge NetworkStatusMonitor *)info;

    BOOL reachable = flags & kSCNetworkReachabilityFlagsReachable;
    BOOL isWWAN = flags & kSCNetworkReachabilityFlagsIsWWAN;

    GCNetworkType type = GCNetworkTypeNone;
    if (reachable) {
        type = isWWAN ? GCNetworkTypeCellular : GCNetworkTypeWiFi;
    }

    if (self.networkChangedBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.networkChangedBlock(type);
        });
    }
}

- (void)startReachability {
    struct sockaddr_in address;
    bzero(&address, sizeof(address));
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;

    self.reachabilityRef = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&address);

    SCNetworkReachabilityContext context = {0, (__bridge void *)self, NULL, NULL, NULL};
    SCNetworkReachabilitySetCallback(self.reachabilityRef, ReachabilityCallback, &context);
    SCNetworkReachabilityScheduleWithRunLoop(self.reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
}







//+ (NSString *)currentSSID {
//    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
//    for (NSString *ifname in ifs) {
//        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifname);
//        if (info[@"SSID"]) return info[@"SSID"];
//    }
//    return nil;
//}


@end
