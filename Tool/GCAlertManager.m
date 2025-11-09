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

@end
