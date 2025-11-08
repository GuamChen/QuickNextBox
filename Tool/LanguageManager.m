//
//  LanguageManager.m
//  Muren
//
//  Created by lgc on 2025/10/30.
//


// LanguageManager.m
#import "LanguageManager.h"

NSString *const kLanguageDidChangeNotification = @"kLanguageDidChangeNotification";

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
    
    NSString *languageCode = [self languageCodeForType:language];
    [[NSUserDefaults standardUserDefaults] setObject:languageCode forKey:@"AppSelectedLanguage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _currentLanguage = language;
    
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
    // 获取当前使用的语言bundle
    NSBundle *bundle = [self currentLanguageBundle];
    if (!bundle) {
        bundle = [NSBundle mainBundle];
    }
    
    NSString *result = [bundle localizedStringForKey:key value:@"" table:nil];
    return result ?: key;
}

#pragma mark - Private Methods

- (void)setupInitialLanguage {
    NSString *savedLanguage = [[NSUserDefaults standardUserDefaults] stringForKey:@"AppSelectedLanguage"];
    
    if (savedLanguage) {
        _currentLanguage = [self languageTypeForCode:savedLanguage];
    } else {
        _currentLanguage = AppLanguageSystem;
    }
}

- (NSBundle *)currentLanguageBundle {
    NSString *languageCode = [self languageCodeForType:self.currentLanguage];
    
    if (self.currentLanguage == AppLanguageSystem) {
        // 使用系统语言
        NSArray *preferredLanguages = [NSLocale preferredLanguages];
        if (preferredLanguages.count > 0) {
            languageCode = preferredLanguages.firstObject;
        }
    }
    
    // 获取语言包路径
    NSString *path = [[NSBundle mainBundle] pathForResource:languageCode ofType:@"lproj"];
    return path ? [NSBundle bundleWithPath:path] : [NSBundle mainBundle];
}

- (NSString *)languageCodeForType:(AppLanguage)type {
    switch (type) {
        case AppLanguageEnglish:
            return @"en";
        case AppLanguageChinese:
            return @"zh-Hans";
        case AppLanguageSystem:
        default:
            return [[NSLocale preferredLanguages] firstObject] ?: @"en";
    }
}

- (AppLanguage)languageTypeForCode:(NSString *)code {
    if ([code hasPrefix:@"zh"]) {
        return AppLanguageChinese;
    } else if ([code hasPrefix:@"en"]) {
        return AppLanguageEnglish;
    } else {
        return AppLanguageSystem;
    }
}

- (NSArray<NSString *> *)availableLanguages {
    return @[@"en", @"zh-Hans"];
}

@end
