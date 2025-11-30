//
//  MD5Tool.h
//  QuickNextBox
//
//  Created by lgc on 2025/11/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MD5Tool : NSObject

+ (NSString *)md5HashOfPath:(NSString *)path; // 优化

+ (NSString *)md5HashOfPath2:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
