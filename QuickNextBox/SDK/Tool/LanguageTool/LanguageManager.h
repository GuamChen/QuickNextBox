//
//  LanguageManager.h
//  Muren
//
//  Created by lgc on 2025/10/30.
//


// LanguageManager.h
#import <Foundation/Foundation.h>



NS_ASSUME_NONNULL_BEGIN

// 支持的语言类型
typedef NS_ENUM(NSInteger, AppLanguage) {
    AppLanguageSystem,    // 系统语言
    AppLanguageEnglish,   // 英语
    AppLanguageChinese    // 中文
};

// 语言改变通知
extern NSString *const kLanguageDidChangeNotification;

@interface LanguageManager : NSObject

/// 单例
+ (instancetype)sharedManager;

/// 当前语言
@property (nonatomic, assign, readonly) AppLanguage currentLanguage;

/// 可用的语言列表
@property (nonatomic, strong, readonly) NSArray<NSString *> *availableLanguages;

/// 切换语言
/// @param language 目标语言
- (void)switchToLanguage:(AppLanguage)language;

/// 获取当前语言的显示名称
/// @param language 语言类型
- (NSString *)displayNameForLanguage:(AppLanguage)language;

/// 获取本地化字符串
/// @param key 键
/// @param comment 注释
- (NSString *)localizedStringForKey:(NSString *)key comment:(NSString *)comment;

@end

NS_ASSUME_NONNULL_END
