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

@end
