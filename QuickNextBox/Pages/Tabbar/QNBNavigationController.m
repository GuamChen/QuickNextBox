//
//  QNBNavigationController.m
//  QuickNextBox
//

#import "QNBNavigationController.h"

@implementation QNBNavigationController

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 非根控制器时自动隐藏底部 TabBar
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}

@end
