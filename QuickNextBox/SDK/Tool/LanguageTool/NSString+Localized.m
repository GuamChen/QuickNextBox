//
//  NSString.m
//  Muren
//
//  Created by lgc on 2025/10/30.
//


// NSString+Localized.m
#import "NSString+Localized.h"
#import "LanguageManager.h"

@implementation NSString (Localized)

- (NSString *)localized {
    return [[LanguageManager sharedManager] localizedStringForKey:self comment:nil];
}

- (NSString *)localizedWithComment:(NSString *)comment {
    return [[LanguageManager sharedManager] localizedStringForKey:self comment:comment];
}


/**
 usage :
 
 self.navigationItem.title = Localized(@"home_title");
 
 // 方法2：直接使用扩展
 UILabel *label = [[UILabel alloc] init];
 label.text = @"welcome".localized;
 
 UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
 [button setTitle:@"save".localized forState:UIControlStateNormal];
 
 // 方法3：使用管理类
 NSString *text = [[LanguageManager sharedManager] localizedStringForKey:@"home_description" comment:@"首页描述"];
 
 */


@end
