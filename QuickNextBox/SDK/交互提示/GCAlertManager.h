//
//  GCAlertManager.h
//  QuickNextBox
//
//  Created by lgc on 2025/11/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GCAlertManager : NSObject

+ (void)showAlertInView:(UIViewController*) viewController WithTitle:(NSString *)title message:(NSString *)message;


+ (void)showHUDWithMessage:(NSString *)message;
+ (void)hideHUD;
+ (void)showTemporaryMessage:(NSString *)message;  // 临时显示
@end

NS_ASSUME_NONNULL_END
