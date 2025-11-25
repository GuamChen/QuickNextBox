//
//  HomeVC 2.h
//  helloworld
//
//  Created by lgc on 2025/10/28.



// HomeVC.m
#import "HomeVC.h"
#import "NetworkStatusMonitor.h"
#import "SSIDMonitor.h"



@interface HomeVC ()

@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB(229, 232, 232);
    self.title = @"首页";
    
    [self setupUI];
}

- (void)setupUI {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"网络监控内容".localized;
    titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightMedium];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor labelColor];
    
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
    
    UILabel *netState = [[UILabel alloc] init];
    netState.text = @"网络状态".localized;
    netState.font = [UIFont systemFontOfSize:24 weight:UIFontWeightMedium];
    netState.textAlignment = NSTextAlignmentCenter;
    netState.textColor = [UIColor labelColor];
    
    [self.view addSubview:netState];
    [netState mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo( titleLabel.mas_bottom).offset(30);
        make.centerX.equalTo(self.view);
    }];
    
     UILabel *ssidLabel = [[UILabel alloc] init];
    ssidLabel.text = @"网络状态".localized;
    ssidLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightMedium];
    ssidLabel.textAlignment = NSTextAlignmentCenter;
    ssidLabel.textColor = [UIColor labelColor];
    
    [self.view addSubview:ssidLabel];
    [ssidLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo( titleLabel.mas_bottom).offset(70);
        make.centerX.equalTo(self.view);
    }];
    
    
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

        netState.text = res;
        
    }];
    
    [[NetworkStatusMonitor shared] startMonitoring];

    
    
    [SSIDMonitor shared].SSIDChangedBlock = ^(NSString *ssid) {
        ssidLabel.text = ssid ?: @"未连接 Wi-Fi";
        NSLog(@"当前 SSID: %@", ssid);
    };
    
    [[SSIDMonitor shared] startMonitoring];
    
}




 
@end
