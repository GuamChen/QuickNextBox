//
//  GCAlertManager.m
//  QuickNextBox
//
//  Created by lgc on 2025/11/9.
//

#import "GCAlertManager.h"

@implementation GCAlertManager



/// 显示提示框
+ (void)showAlertInView:(UIViewController*) viewController WithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    
    NSLog(@"___showAlert___title: %@ \n msg: %@\n",title,message);
    [viewController presentViewController:alert animated:YES completion:nil];
}


#pragma mark + Helper Methods

+ (void)showHUDWithMessage:(NSString *)message {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kWindow animated:YES];
    hud.label.text = message;
    hud.mode = MBProgressHUDModeIndeterminate;
}

+ (void)hideHUD {
    [MBProgressHUD hideHUDForView:kWindow animated:YES];
}

+ (void)showTemporaryMessage:(NSString *)message {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kWindow animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = message;
    hud.offset = CGPointMake(0, 150);
    [hud hideAnimated:YES afterDelay:1.5];
}

@end
