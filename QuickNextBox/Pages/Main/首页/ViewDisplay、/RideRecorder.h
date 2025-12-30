////
////  RideRecorder.h
////  QuickNextBox
////
////  Created by lgc on 2025/12/11.
////
//
//
//// RideRecorder.h
//#import <Foundation/Foundation.h>
//#import <CoreLocation/CoreLocation.h>
//
//NS_ASSUME_NONNULL_BEGIN
//
//@interface RideRecorder : NSObject <CLLocationManagerDelegate>
//
//+ (instancetype)sharedRecorder;
//
//// 控制方法
//- (void)startRideRecording;
//- (void)stopRideRecordingWithCompletion:(void(^)(NSURL *fileURL))completion;
//- (BOOL)isRecording;
//
//// 可选：外部注入拍照/蓝牙数据快照回调（必须是线程安全、尽量快的同步方法）
//@property (nonatomic, copy) NSDictionary *(^snapshotDeviceDataBlock)(void);
//
//@end
//
//NS_ASSUME_NONNULL_END
//
//
//// RideRecorder.m
//#import "RideRecorder.h"
//#import <UIKit/UIKit.h>
//
//@interface RideRecorder ()
//@property (nonatomic, strong) CLLocationManager *locationManager;
//@property (nonatomic, strong) dispatch_queue_t writeQueue;
//@property (nonatomic, strong) NSFileHandle *fileHandle;
//@property (nonatomic, strong) NSURL *currentFileURL;
//@property (nonatomic, assign) BOOL hasWrittenFirstRecord;
//@property (nonatomic, assign) BOOL isRecordingFlag;
//@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTask;
//@property (nonatomic, strong) NSDate *rideStartDate;
//@property (nonatomic, strong) NSDate *lastWrittenTimestampDate;
//@end
//
//@implementation RideRecorder
//
//+ (instancetype)sharedRecorder {
//    static RideRecorder *s_instance;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        s_instance = [[RideRecorder alloc] initPrivate];
//    });
//    return s_instance;
//}
//
//- (instancetype)initPrivate {
//    self = [super init];
//    if (self) {
//        _writeQueue = dispatch_queue_create("com.example.riderecorder.write", DISPATCH_QUEUE_SERIAL);
//        _locationManager = [[CLLocationManager alloc] init];
//        _locationManager.delegate = self;
//        // 对于需要 1Hz 后台更新，使用较高精度
//        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//        // 允许后台更新
//        _locationManager.allowsBackgroundLocationUpdates = YES;
//        _locationManager.pausesLocationUpdatesAutomatically = NO; // 不让系统自动暂停（注意电量）
//
//        _bgTask = UIBackgroundTaskInvalid;
//        _hasWrittenFirstRecord = NO;
//
//        // 监听 App 生命周期以在进入后台/前台时处理
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
//    }
//    return self;
//}
//
//- (instancetype)init {
//    @throw [NSException exceptionWithName:@"SingletonException" reason:@"Use +[RideRecorder sharedRecorder]" userInfo:nil];
//}
//
//- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}
//
//#pragma mark - Public
//
//- (BOOL)isRecording { return _isRecordingFlag; }
//
//- (void)startRideRecording {
//    if (self.isRecording) return;
//
//    // 请求权限（调用方应在 UI 侧处理授权弹窗）
//    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
//    if (status == kCLAuthorizationStatusNotDetermined) {
//        [self.locationManager requestAlwaysAuthorization];
//    }
//
//    self.rideStartDate = [NSDate date];
//    self.isRecordingFlag = YES;
//    self.hasWrittenFirstRecord = NO;
//
//    // 文件准备
//    [self prepareFileForNewRide];
//
//    // 启动 location updates
//    [self.locationManager startUpdatingLocation];
//
//    // 保持后台任务 - 仅用于在应用被系统挂起时尝试完成写入
//    [self beginBackgroundTaskIfNeeded];
//}
//
//- (void)stopRideRecordingWithCompletion:(void(^)(NSURL *fileURL))completion {
//    if (!self.isRecording) {
//        if (completion) completion(nil);
//        return;
//    }
//    self.isRecordingFlag = NO;
//
//    // 停止定位
//    [self.locationManager stopUpdatingLocation];
//
//    // 在写队列内完成 JSON 尾部并关闭文件
//    dispatch_async(self.writeQueue, ^{
//        if (self.fileHandle) {
//            // 写入结束 JSON 尾部
//            NSData *tail = [@"\n  }\n}" dataUsingEncoding:NSUTF8StringEncoding];
//            [self.fileHandle writeData:tail];
//            [self.fileHandle synchronizeFile];
//            [self.fileHandle closeFile];
//            self.fileHandle = nil;
//        }
//
//        // 结束后台任务
//        [self endBackgroundTaskIfNeeded];
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (completion) completion(self.currentFileURL);
//        });
//    });
//}
//
//#pragma mark - File handling
//
//- (void)prepareFileForNewRide {
//    dispatch_sync(self.writeQueue, ^{
//        NSString *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
//        NSTimeInterval t = [self.rideStartDate timeIntervalSince1970];
//        NSString *fileName = [NSString stringWithFormat:@"ride_temp_%.0f.json", t];
//        NSString *path = [docs stringByAppendingPathComponent:fileName];
//        NSURL *url = [NSURL fileURLWithPath:path];
//
//        // create file
//        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
//        self.currentFileURL = url;
//        self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
//
//        // 写 header（流式 JSON 的开头，后面会写 timeStamps map）
//        NSString *header = [self generateHeaderJSON];
//        // 移除末尾的闭括号，改为保留时间戳 map 开始
//        NSString *headerTrimmed = [header stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//        if ([headerTrimmed hasSuffix:@"}"]) {
//            headerTrimmed = [headerTrimmed substringToIndex:headerTrimmed.length - 1];
//        }
//        NSString *prefix = [NSString stringWithFormat:@"%@,\n  \"timeStamps\": {\n", headerTrimmed];
//        [self.fileHandle writeData:[prefix dataUsingEncoding:NSUTF8StringEncoding]];
//        [self.fileHandle synchronizeFile];
//    });
//}
//
//- (NSString *)generateHeaderJSON {
//    NSMutableString *header = [NSMutableString stringWithString:@"{
//"];
//
//    UIDevice *d = [UIDevice currentDevice];
//    NSString *model = d.model ?: @"unknown";
//    NSString *sys = d.systemVersion ?: @"unknown";
//    NSString *appv = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: @"0";
//
//    // phone_info
//    [header appendFormat:@"  \"phone_info\": { \"model\": \"%@\", \"system_ver\": \"%@\", \"app_ver\": \"%@\" },
//", model, sys, appv];
//
//    // camera_info — 使用固定占位
//    [header appendString:@"  \"camera_info\": { \"model\": \"无\", \"firm_ver\": \"无\", \"name\": \"无\" },
//"];
//
//    // heart_info
//    [header appendString:@"  \"heart_info\": { \"brand\": \"无\", \"model\": \"无\", \"name\": \"无\" },
//"];
//
//    // cadence_info
//    [header appendString:@"  \"cadence_info\": { \"brand\": \"无\", \"model\": \"无\", \"name\": \"无\" },
//"];
//
//    // power_info
//    [header appendString:@"  \"power_info\": { \"brand\": \"无\", \"model\": \"无\", \"name\": \"无\" }
//"];
//
//    [header appendString:@"}
//"]; // 结尾（prepareFileForNewRide 会去掉 }
//    return header;
//}
//}
//
//#pragma mark - Location delegate (核心)
//
//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
//    if (!self.isRecording) return;
//    CLLocation *loc = locations.lastObject;
//    if (!loc) return;
//
//    // 1) 将系统 location 转换/修正为需要的坐标系（如 GCJ-02），这部分应当尽量快
//    CLLocation *fixed = loc; // 如果需要可在此调用同步转换函数
//
//    // 2) 用这个定位作为“心跳”立即写入一条记录
//    [self writeRecordWithLocation:fixed andTimestampDate:[NSDate date]];
//}
//
//#pragma mark - Writing one record
//
//- (void)writeRecordWithLocation:(CLLocation *)location andTimestampDate:(NSDate *)timestampDate {
//    // 减少频繁创建对象，把 JSON 组装与文件写入放到 writeQueue
//    dispatch_async(self.writeQueue, ^{
//        if (!self.fileHandle) {
//            NSLog(@"[RideRecorder] fileHandle nil when writing record");
//            return;
//        }
//
//        // timestamp 取整到秒（和你导出的一致）
//        NSTimeInterval ts = floor([timestampDate timeIntervalSince1970]);
//        NSString *tsKey = [NSString stringWithFormat:@"\"%.0f\"", ts];
//
//        // 在写入前尝试获取设备快照（由外部 block 提供）
//        NSDictionary *deviceSnapshot = nil;
//        if (self.snapshotDeviceDataBlock) {
//            // snapshotDeviceDataBlock 必须是线程安全的并尽量快
//            deviceSnapshot = self.snapshotDeviceDataBlock();
//        }
//
//        // 准备 gps & sensor JSON（简单字符串拼接，避免 heavy NSDictionary->NSJSONSerialization）
//        NSString *gpsJson = [NSString stringWithFormat:@"{ \"lat\": %.8f, \"lng\": %.8f, \"speed\": %.3f, \"alti\": %.3f, \"course\": %.3f }",
//                             location.coordinate.latitude,
//                             location.coordinate.longitude,
//                             MAX(0, location.speed),
//                             location.altitude,
//                             location.course];
//
//        // 简单处理 sensor 数据，如果没有就写空结构
//        NSString *sensorJson = "{ \"status\": 0, \"value\": 0 }";
//        if (deviceSnapshot) {
//            // 这里以一个简单格式拼装，你可以根据实际 snapshot 字段自定义
//            NSError *err = nil;
//            NSData *d = [NSJSONSerialization dataWithJSONObject:deviceSnapshot options:0 error:&err];
//            if (!err && d) {
//                NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
//                // 直接使用得到的 JSON 作为 sensorJson
//                sensorJson = s;
//            }
//        }
//
//        // 组装 body
//        NSMutableString *entry = [NSMutableString string];
//        // 如果不是第一个 entry，先写逗号换行
//        if (self.hasWrittenFirstRecord) {
//            [entry appendString:@",\n    "]; // 注意缩进
//        } else {
//            [entry appendString:@"    "]; // 首条记录没有逗号
//            self.hasWrittenFirstRecord = YES;
//        }
//        [entry appendFormat:@"%@: { \"gps\": %@, \"sensors\": %@ }", tsKey, gpsJson, sensorJson];
//
//        [self.fileHandle writeData:[entry dataUsingEncoding:NSUTF8StringEncoding]];
//        [self.fileHandle synchronizeFile];
//
//        // 更新 lastWrittenTimestampDate
//        self.lastWrittenTimestampDate = timestampDate;
//    });
//}
//
//#pragma mark - Background task helpers
//
//- (void)beginBackgroundTaskIfNeeded {
//    if (self.bgTask != UIBackgroundTaskInvalid) return;
//    UIApplication *app = [UIApplication sharedApplication];
//    self.bgTask = [app beginBackgroundTaskWithName:@"RideRecorderTask" expirationHandler:^{
//        // 系统即将终止后台任务，在这里尽量收尾
//        [self endBackgroundTaskIfNeeded];
//    }];
//}
//
//- (void)endBackgroundTaskIfNeeded {
//    if (self.bgTask == UIBackgroundTaskInvalid) return;
//    UIApplication *app = [UIApplication sharedApplication];
//    [app endBackgroundTask:self.bgTask];
//    self.bgTask = UIBackgroundTaskInvalid;
//}
//
//#pragma mark - App lifecycle notifications
//
//- (void)applicationWillResignActive:(NSNotification *)note {
//    // 进入后台时确保开始后台任务以完成最后写入
//    if (self.isRecording) {
//        [self beginBackgroundTaskIfNeeded];
//    }
//}
//
//- (void)applicationDidBecomeActive:(NSNotification *)note {
//    // 前台回来可以结束后台任务
//    [self endBackgroundTaskIfNeeded];
//}
//
//#pragma mark - CLLocation Authorization Handling
//
//- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
//    // 可根据授权变化提示用户
//    if (status == kCLAuthorizationStatusAuthorizedAlways) {
//        NSLog(@"RideRecorder: authorized always");
//    }
//}
//
//#pragma mark - Error handling
//
//- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
//    NSLog(@"RideRecorder location error: %@", error.localizedDescription);
//}
//
//@end
//
//
///*
// 注意事项：
// 1. Info.plist 必须包含下面的项：
//    - NSLocationWhenInUseUsageDescription
//    - NSLocationAlwaysAndWhenInUseUsageDescription
//    - UIBackgroundModes: location
// 
// 2. snapshotDeviceDataBlock: 如果你需要将蓝牙数据写进每条记录，务必让该 block 快速、线程安全并尽量不做主线程阻塞动作。
//    推荐：在 BluetoothManager 内维护一份最新数据的轻量级字典（线程安全），snapshotDeviceDataBlock 直接返回拷贝。
//
// 3. 性能：尽量在 writeQueue 中完成字符串拼接和文件写入，避免主线程阻塞。不要在 didUpdateLocations 做 heavy 计算。
//
// 4. GPS：系统会根据电源/信号/温度等调整更新频率，无法 100% 保证每秒回调，但这是 App 在后台能获得最稳定回调的方式。
//
// 5. App 被系统强杀或重启时可能丢失最后几条记录，建议每次写入后立即 synchronizeFile（已包含）。
//*/
