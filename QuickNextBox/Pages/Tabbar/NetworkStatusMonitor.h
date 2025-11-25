//
//  NetworkStatusMonitor.h
//  QuickNextBox
//
//  Created by lgc on 2025/11/25.
//


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, GCNetworkType) {
    GCNetworkTypeNone,
    GCNetworkTypeWiFi,
    GCNetworkTypeCellular
};

@interface NetworkStatusMonitor : NSObject

+ (instancetype)shared;

- (void)startMonitoring;
- (void)stopMonitoring;

@property (nonatomic, copy) void (^networkChangedBlock)(GCNetworkType type);

@end
