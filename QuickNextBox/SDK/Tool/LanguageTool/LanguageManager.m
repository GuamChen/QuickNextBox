//
//  LanguageManager.m
//  Muren
//
//  Created by lgc on 2025/10/30.
//


// LanguageManager.m
#import "LanguageManager.h"

NSString *const kLanguageDidChangeNotification = @"kLanguageDidChangeNotification";

@interface LanguageManager()
@property (nonatomic, strong) NSBundle *currentBundle;
@end

@implementation LanguageManager

+ (instancetype)sharedManager {
    static LanguageManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LanguageManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupInitialLanguage];
    }
    return self;
}

#pragma mark - Public Methods

- (void)switchToLanguage:(AppLanguage)language {
    if (self.currentLanguage == language) {
        return;
    }
    
    // 保存语言设置
    NSString *languageCode = [self preferredLanguageCodeForType:language];
    [[NSUserDefaults standardUserDefaults] setObject:languageCode forKey:@"AppSelectedLanguage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _currentLanguage = language;
    [self updateCurrentBundle];
    
    // 发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kLanguageDidChangeNotification object:nil];
}

- (NSString *)displayNameForLanguage:(AppLanguage)language {
    switch (language) {
        case AppLanguageSystem:
            return [self localizedStringForKey:@"language_system" comment:@"系统语言"];
        case AppLanguageEnglish:
            return @"English";
        case AppLanguageChinese:
            return @"中文";
        default:
            return @"Unknown";
    }
}

- (NSString *)localizedStringForKey:(NSString *)key comment:(NSString *)comment {
    if (self.currentBundle) {
        NSString *result = [self.currentBundle localizedStringForKey:key value:key table:nil];
        return result;
    }
    
    // 回退到主bundle
    return [[NSBundle mainBundle] localizedStringForKey:key value:key table:nil];
}

#pragma mark - Private Methods

- (void)setupInitialLanguage {
    NSString *savedLanguage = [[NSUserDefaults standardUserDefaults] stringForKey:@"AppSelectedLanguage"];
    
    if (savedLanguage) {
        _currentLanguage = [self languageTypeForCode:savedLanguage];
    } else {
        _currentLanguage = AppLanguageSystem;
    }
    
    [self updateCurrentBundle];
}

- (void)updateCurrentBundle {
    NSString *languageCode = [self preferredLanguageCodeForType:self.currentLanguage];
    
    // 获取可用的本地化资源
    NSString *path = [[NSBundle mainBundle] pathForResource:languageCode ofType:@"lproj"];
    if (path) {
        self.currentBundle = [NSBundle bundleWithPath:path];
    } else {
        // 如果找不到精确匹配，尝试基础语言代码
        NSString *baseLanguage = [self baseLanguageCode:languageCode];
        if (baseLanguage) {
            path = [[NSBundle mainBundle] pathForResource:baseLanguage ofType:@"lproj"];
            self.currentBundle = path ? [NSBundle bundleWithPath:path] : [NSBundle mainBundle];
        } else {
            self.currentBundle = [NSBundle mainBundle];
        }
    }
}

- (NSString *)preferredLanguageCodeForType:(AppLanguage)type {
    switch (type) {
        case AppLanguageEnglish:
            return @"en";
        case AppLanguageChinese:
            return @"zh-Hans";
        case AppLanguageSystem:
        default:
            return [NSLocale preferredLanguages].firstObject ?: @"en";
    }
}

- (AppLanguage)languageTypeForCode:(NSString *)code {
    // 处理完整的语言标识
    if ([code hasPrefix:@"zh-Hans"] || [code hasPrefix:@"zh-Hant"] || [code isEqualToString:@"zh"]) {
        return AppLanguageChinese;
    } else if ([code hasPrefix:@"en"]) {
        return AppLanguageEnglish;
    } else {
        return AppLanguageSystem;
    }
}

- (NSString *)baseLanguageCode:(NSString *)fullLanguageCode {
    // 从 "zh-Hans-CN" 中提取 "zh-Hans"
    NSArray *components = [fullLanguageCode componentsSeparatedByString:@"-"];
    if (components.count >= 2) {
        return [NSString stringWithFormat:@"%@-%@", components[0], components[1]];
    } else if (components.count == 1) {
        return components[0];
    }
    return nil;
}

- (NSArray<NSString *> *)availableLanguages {
    return @[@"en", @"zh-Hans"];
}

@end
