//
//  MD5Tool.m
//  QuickNextBox
//
//  Created by lgc on 2025/11/8.
//

#import "MD5Tool.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation MD5Tool


#pragma mark -------- MD5 Tool code
+ (NSString *)md5HashOfPath:(NSString *)path
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

+ (NSString *)md5HashOfPath2:(NSString *)path
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
