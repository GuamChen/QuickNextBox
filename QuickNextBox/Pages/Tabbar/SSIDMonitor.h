//
//  SSIDMonitor.h
//  QuickNextBox
//
//  Created by lgc on 2025/11/26.
//


#import <Foundation/Foundation.h>

@interface SSIDMonitor : NSObject

+ (instancetype)shared;
- (void)startMonitoring;
- (void)stopMonitoring;

@property (nonatomic, copy) void (^SSIDChangedBlock)(NSString *ssid);

@end