//
//  AppDelegate.m
//  Muren
//
//  Created by lgc on 2025/10/28.
//

#import "AppDelegate.h"

#import "MainTabBarController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 创建窗口
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    // 设置主控制器为 TabBarController
    MainTabBarController *tabBarController = [[MainTabBarController alloc] init];
    self.window.rootViewController = tabBarController;
        
    // 设置窗口背景色
    self.window.backgroundColor = [UIColor whiteColor];
    
    // 显示窗口（只需要调用一次）
    [self.window makeKeyAndVisible];
    
    // 可选：设置全局导航栏样式
    [self setupGlobalAppearance];
    
    
    [[LanguageManager sharedManager] currentLanguage];

    
    
    [self setupMonitor];
    return YES;
}

- (void)setupGlobalAppearance {
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor systemBackgroundColor];
        appearance.titleTextAttributes = @{
            NSForegroundColorAttributeName: [UIColor labelColor],
            NSFontAttributeName: [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold]
        };
        
        [UINavigationBar appearance].standardAppearance = appearance;
        [UINavigationBar appearance].scrollEdgeAppearance = appearance;
    } else {
        [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setTitleTextAttributes:@{
            NSForegroundColorAttributeName: [UIColor blackColor],
            NSFontAttributeName: [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold]
        }];
    }
}



- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    // url 是文件路径，例如 file:///private/var/mobile/Containers/Data/...
    if (url && [url isFileURL]) {
        NSString *fileName = url.lastPathComponent;
        
        // 沙盒路径（Documents 或专用目录）
        NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject
                              stringByAppendingPathComponent:fileName];
        
        NSError *error = nil;
        [[NSFileManager defaultManager] copyItemAtURL:url
                                                toURL:[NSURL fileURLWithPath:destPath]
                                                error:&error];
        
        if (error) {
            [GCAlertManager showTemporaryMessage:[NSString stringWithFormat:@"保存文件失败: %@", error]];
        } else {
            [GCAlertManager showTemporaryMessage:[NSString stringWithFormat:@"FIT 文件已保存到: %@", destPath]];
            // 可以在这里发通知，让主界面刷新数据
            [[NSNotificationCenter defaultCenter] postNotificationName:@"FITFileImported"
                                                                object:destPath];
        }
    }
    return YES;
}


-(void)setupMonitor{
    [[NetworkStatusMonitor shared] setNetworkChangedBlock:^(GCNetworkType type) {
        NSString * res = nil;
        switch (type) {
            case GCNetworkTypeWiFi:
                res = @"使用 Wi-Fi";
                break;
            case GCNetworkTypeCellular:
                res = @"使用蜂窝网络" ;
                break;
            case GCNetworkTypeNone:
                res = @"无网络";
                break;
        }
        NSLog(@"当前网络情况: %@", res);
        [GCAlertManager showTemporaryMessage:res];
        
    }];
    
    [[NetworkStatusMonitor shared] startMonitoring];
}
@end
