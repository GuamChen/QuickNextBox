//
//  DiscoverVC 2.h
//  helloworld
//
//  Created by lgc on 2025/10/28.
//


// DiscoverVC.m
#import "DiscoverVC.h"
#import "MBHudDemoVC.h"
#import "AccelerometerVC.h"
#import <CommonCrypto/CommonCrypto.h>

@interface DiscoverVC ()

@end

@implementation DiscoverVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = @"发现";
    
    [self setupUI];
}


- (void)setupUI {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"案例内容";
    titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightMedium];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor labelColor];
    
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.equalTo(self.view.mas_bottom).multipliedBy(0.15);
    }];
    
    UIButton * mbhub_btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [mbhub_btn setTitle: @"MBHudDemo" forState:UIControlStateNormal];
    [self.view addSubview: mbhub_btn];
    [mbhub_btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.equalTo(self.view.mas_bottom).multipliedBy(0.25);
        make.size.mas_equalTo(CGSizeMake(200, 50));
    }];
    
    [mbhub_btn addTarget:self action:@selector(GotoMBHudDemoPage) forControlEvents:UIControlEventTouchUpInside];
    

     
   
    UIButton * acc_btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [acc_btn setTitle: @"GotoAccelerometerVC" forState:UIControlStateNormal];
    [self.view addSubview: acc_btn];
    [acc_btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.equalTo(self.view.mas_bottom).multipliedBy(0.35);
        make.size.mas_equalTo(CGSizeMake(200, 50));
    }];
    
    [acc_btn addTarget:self action:@selector(GotoAccelerometerVC) forControlEvents:UIControlEventTouchUpInside];
    
}


- (void)GotoAccelerometerVC {
    AccelerometerVC *vc =  [AccelerometerVC new];
    
    if (self.navigationController) {
        NSLog(@"NavigationController exists: %@", self.navigationController);
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        NSLog(@"NavigationController is nil!");
        // 尝试 present 方式
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)GotoMBHudDemoPage {
    MBHudDemoVC *vc =  [MBHudDemoVC new];
    
    if (self.navigationController) {
        NSLog(@"NavigationController exists: %@", self.navigationController);
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        NSLog(@"NavigationController is nil!");
        // 尝试 present 方式
        [self presentViewController:vc animated:YES completion:nil];
    }
}

#pragma mark -------- MD5 Tool code
- (NSString *)md5HashOfPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        return @"";
    }
    
    NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:path];
    [inputStream open];
    
    CC_MD5_CTX context;
    CC_MD5_Init(&context);
    
    uint8_t buffer[4096];
    while ([inputStream hasBytesAvailable]) {
        NSInteger bytesRead = [inputStream read:buffer maxLength:4096];
        if (bytesRead > 0) {
            CC_MD5_Update(&context, buffer, (CC_LONG)bytesRead);
        }
    }
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &context);
    [inputStream close];
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

- (NSString *)md5HashOfPath2:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // Make sure the file exists
    if( ![fileManager fileExistsAtPath:path isDirectory:nil] ){
       return @"";
        
    }
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( data.bytes, (CC_LONG)data.length, digest );
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for( int i = 0; i < CC_MD5_DIGEST_LENGTH; i++ )
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}


@end
