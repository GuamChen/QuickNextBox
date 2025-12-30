//
//  GCFileSizeFormatter.h
//  QuickNextBox
//
//  Created by lgc on 2025/12/17.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GCFileSizeFormatter : NSObject

/// 文件大小（推荐：Finder 风格，1000 进制）
/// e.g. 1536 -> 1.5 KB
+ (NSString *)fileSizeStringFromBytes:(long long)bytes;

/// 内存大小（1024 进制）
/// e.g. 1048576 -> 1 MB
+ (NSString *)memorySizeStringFromBytes:(long long)bytes;

/// 二进制单位（KiB / MiB）
/// e.g. 1024 -> 1 KiB
+ (NSString *)binarySizeStringFromBytes:(long long)bytes;

/// 固定小数位（不走 NSByteCountFormatter）
/// e.g. 12345678 -> 11.77 MB
+ (NSString *)fileSizeStringFromBytes:(long long)bytes
                        decimalPlaces:(NSUInteger)places;

@end

NS_ASSUME_NONNULL_END
