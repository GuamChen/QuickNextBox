//
//  NetworkReachabilityManager.h
//  QuickNextBox
//
//  Created by lgc on 2025/11/25.
//


#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

typedef void (^NetworkStatusChangedBlock)(SCNetworkReachabilityFlags flags);

@interface NetworkReachabilityManager : NSObject

@property (nonatomic, copy) NetworkStatusChangedBlock networkStatusChangedBlock;
@property (nonatomic, assign, readonly) BOOL isMonitoring;

+ (instancetype)sharedManager;
- (void)startMonitoringForHost:(NSString *)host;
- (void)stopMonitoring;
- (BOOL)isNetworkReachable;

@end

