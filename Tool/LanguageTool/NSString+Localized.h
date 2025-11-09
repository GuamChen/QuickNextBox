//
//  NSString.h
//  Muren
//
//  Created by lgc on 2025/10/30.
//


// NSString+Localized.h
#import <Foundation/Foundation.h>


// 快捷宏
#define Localized(key) [key localized]
#define LocalizedWithComment(key, comment) [key localizedWithComment:comment]

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Localized)

/// 本地化字符串快捷方法
- (NSString *)localized;

/// 带注释的本地化
/// @param comment 注释
- (NSString *)localizedWithComment:(NSString *)comment;

@end

NS_ASSUME_NONNULL_END
