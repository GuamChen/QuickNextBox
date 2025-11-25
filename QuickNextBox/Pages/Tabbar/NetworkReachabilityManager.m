//
//  NetworkReachabilityManager.m
//  QuickNextBox
//
//  Created by lgc on 2025/11/25.
//
#import "NetworkReachabilityManager.h"


@implementation NetworkReachabilityManager {
    SCNetworkReachabilityRef _reachabilityRef;
    BOOL _isMonitoring;
}

+ (instancetype)sharedManager {
    static NetworkReachabilityManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _isMonitoring = NO;
    }
    return self;
}

- (void)dealloc {
    [self stopMonitoring];
}

- (void)startMonitoringForHost:(NSString *)host {
    [self stopMonitoring];
    
    if (!host || host.length == 0) {
        return;
    }
    
    _reachabilityRef = SCNetworkReachabilityCreateWithName(NULL, [host UTF8String]);
    
    if (!_reachabilityRef) {
        return;
    }
    
    SCNetworkReachabilityContext context = {
        0,
        (__bridge void *)self,
        NULL,
        NULL,
        NULL
    };
    
    if (SCNetworkReachabilitySetCallback(_reachabilityRef, ReachabilityCallback, &context)) {
        SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, CFRunLoopGetMain(), kCFRunLoopDefaultMode);
        _isMonitoring = YES;
        NSLog(@"开始监控网络可达性: %@", host);
    }
}

- (void)stopMonitoring {
    if (_reachabilityRef) {
        SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef, CFRunLoopGetMain(), kCFRunLoopDefaultMode);
        CFRelease(_reachabilityRef);
        _reachabilityRef = NULL;
    }
    _isMonitoring = NO;
    NSLog(@"停止监控网络可达性");
}

static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info) {
    NetworkReachabilityManager *reachability = (__bridge NetworkReachabilityManager *)info;
    if (reachability.networkStatusChangedBlock) {
        reachability.networkStatusChangedBlock(flags);
    }
}

- (BOOL)isNetworkReachable {
    if (!_reachabilityRef) return NO;
    
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
        BOOL isReachable = (flags & kSCNetworkReachabilityFlagsReachable);
        BOOL connectionRequired = (flags & kSCNetworkReachabilityFlagsConnectionRequired);
        return isReachable && !connectionRequired;
    }
    return NO;
}

- (NSString *)getNetworkStatusDescription {
    if (!_reachabilityRef) return @"未监控";
    
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
        if (!(flags & kSCNetworkReachabilityFlagsReachable)) {
            return @"网络不可达";
        }
        if (flags & kSCNetworkReachabilityFlagsConnectionRequired) {
            return @"需要连接";
        }
        if (flags & kSCNetworkReachabilityFlagsIsWWAN) {
            return @"蜂窝网络";
        }
        return @"WiFi网络就绪";
    }
    return @"状态未知";
}

@end
