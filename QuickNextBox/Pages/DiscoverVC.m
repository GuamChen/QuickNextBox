//
//  DiscoverVC 2.h
//  helloworld
//
//  Created by lgc on 2025/10/28.
//


// DiscoverVC.m
#import "DiscoverVC.h"
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
    titleLabel.text = @"发现内容";
    titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightMedium];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor labelColor];
    
    [self.view addSubview:titleLabel];
    
    // 使用自动布局
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [titleLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [titleLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.view.leadingAnchor constant:20],
        [titleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.view.trailingAnchor constant:-20]
    ]];
    
    [TSUserDefaults getHasLogined];
}
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
