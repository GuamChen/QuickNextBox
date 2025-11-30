//
//  MainTabBarController2.h
//  QuickNextBox
//
//  Created by lgc on 2025/11/28.
//


#import "MainTabBarController2.h"
#import "CustomTabBar.h"

// 子控制器
#import "QNBNavigationController.h"
//#import "RVL25_SettingVC.h"
//#import "HomeVC.h"

@interface MainTabBarController2 ()<UITabBarControllerDelegate>
@end

@implementation MainTabBarController2

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 用自定义 tabbar 替换系统 tabbar（以调整高度）
    CustomTabBar *customBar = [[CustomTabBar alloc] init];
    // 使用 KVC 替换系统 tabBar（常见做法）
    [self setValue:customBar forKey:@"tabBar"];
    
    [self setupViewControllers];
    [self customizeTabBarAppearance];
    
    self.delegate = self; // 设置代理
}

#pragma mark - Setup
- (void)setupViewControllers {
    // 1. 首页
//    HomeVC *homeVC = [[HomeVC alloc] init];
//    RVL25_NavigationController *homeNav = [[RVL25_NavigationController alloc] initWithRootViewController:homeVC];
//    homeNav.tabBarItem = [self createTabBarItemWithTitle:@"Passenger Side"
//                                             normalImage:@"方位P"
//                                           selectedImage:@"方位P"];
//    
//    // 2. 发现/设置
//    RVL25_SettingVC *settingVC = [[RVL25_SettingVC alloc] init];
//    RVL25_NavigationController *discoverNav = [[RVL25_NavigationController alloc] initWithRootViewController:settingVC];
//    discoverNav.tabBarItem = [self createTabBarItemWithTitle:@"Settings"
//                                                 normalImage:@"设置"
//                                               selectedImage:@"设置"];
//    
//    // 设置 viewControllers
//    self.viewControllers = @[homeNav, discoverNav];
    // 默认选中首页（index 0）
    self.selectedIndex = 0;
}

#pragma mark - Helpers

// 缩放普通图片到指定尺寸（用于非 SF Symbol 图片）
- (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size {
    if (!image) return nil;
    UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resized;
}

- (UITabBarItem *)createTabBarItemWithTitle:(NSString *)title
                                normalImage:(NSString *)normalImage
                              selectedImage:(NSString *)selectedImage {
    UIImage *normalIcon = nil;
    UIImage *selectedIcon = nil;
    
    // 目标图标尺寸（根据需要调整），这里使用 24pt 图标
    CGFloat iconPointSize = 24.0;
    
    // 先尝试 SF Symbol
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:iconPointSize weight:UIImageSymbolWeightRegular];
        UIImage *sysNormal = [UIImage systemImageNamed:normalImage withConfiguration:config];
        UIImage *sysSelected = [UIImage systemImageNamed:selectedImage withConfiguration:config];
        
        if (sysNormal) {
            normalIcon = sysNormal;
        }
        if (sysSelected) {
            selectedIcon = sysSelected;
        }
    }
    
    // 若不是 SF Symbol 或上面没拿到，则尝试从 Assets 拉取并缩放
    if (!normalIcon) {
        UIImage *img = [UIImage imageNamed:normalImage];
        if (img) {
            normalIcon = [self resizeImage:img toSize:CGSizeMake(iconPointSize, iconPointSize)];
        }
    }
    if (!selectedIcon) {
        UIImage *img = [UIImage imageNamed:selectedImage];
        if (img) {
            selectedIcon = [self resizeImage:img toSize:CGSizeMake(iconPointSize, iconPointSize)];
        }
    }
    
    // 如果仍为 nil，避免崩溃，使用空图片占位
    if (!normalIcon) normalIcon = [[UIImage alloc] init];
    if (!selectedIcon) selectedIcon = normalIcon;
    
    // 为了使用 tabBar 的 tintColor/ unselectedItemTintColor，使用 template 渲染模式
    normalIcon = [normalIcon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    selectedIcon = [selectedIcon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:normalIcon selectedImage:selectedIcon];
    
    // 图片在上，文字在下 —— 调整 imageInsets 和 titlePositionAdjustment
    // 这里的数值可根据 icon 大小细调
    tabBarItem.imageInsets = UIEdgeInsetsMake(-6, 0, 6, 0);
    tabBarItem.titlePositionAdjustment = UIOffsetMake(0, 6);
    
    // 设置文字颜色（为了兼容 iOS 13+ 的 appearance，也在 appearance 设置里重复）
    [tabBarItem setTitleTextAttributes:@{
        NSForegroundColorAttributeName: [UIColor grayColor],
        NSFontAttributeName: [UIFont systemFontOfSize:11]
    } forState:UIControlStateNormal];
    
    [tabBarItem setTitleTextAttributes:@{
        NSForegroundColorAttributeName: [self colorFromHexString:@"#005B99"],
        NSFontAttributeName: [UIFont systemFontOfSize:11]
    } forState:UIControlStateSelected];
    
    return tabBarItem;
}

// 颜色工具：#RRGGBB -> UIColor
- (UIColor *)colorFromHexString:(NSString *)hexStr {
    NSString *hex = [hexStr stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if (hex.length != 6) return [UIColor blackColor];
    unsigned int r, g, b;
    NSScanner *scanner = [NSScanner scannerWithString:[hex substringWithRange:NSMakeRange(0, 2)]];
    [scanner scanHexInt:&r];
    scanner = [NSScanner scannerWithString:[hex substringWithRange:NSMakeRange(2, 2)]];
    [scanner scanHexInt:&g];
    scanner = [NSScanner scannerWithString:[hex substringWithRange:NSMakeRange(4, 2)]];
    [scanner scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f)
                           green:((float)g / 255.0f)
                            blue:((float)b / 255.0f)
                           alpha:1.0f];
}

#pragma mark - Custom Appearance

- (void)customizeTabBarAppearance {
    UIColor *selectedColor = [self colorFromHexString:@"#005B99"];
    UIColor *unselectedColor = [UIColor grayColor];
    
    // iOS 13+ 使用 UITabBarAppearance 精细控制
    if (@available(iOS 13.0, *)) {
        UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor systemBackgroundColor];
        
        // 去掉默认顶部分隔线（或按需自定义）
        appearance.shadowColor = [UIColor clearColor];
        
        // 标题样式（正常和选中）
        NSDictionary *normalAttrs = @{
            NSForegroundColorAttributeName: unselectedColor,
            NSFontAttributeName: [UIFont systemFontOfSize:11]
        };
        NSDictionary *selectedAttrs = @{
            NSForegroundColorAttributeName: selectedColor,
            NSFontAttributeName: [UIFont systemFontOfSize:11]
        };
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttrs;
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttrs;
        
        // 图片也遵循 tint（rendering mode 为 template）
        appearance.stackedLayoutAppearance.normal.iconColor = unselectedColor;
        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor;
        
        self.tabBar.standardAppearance = appearance;
        if (@available(iOS 15.0, *)) {
            self.tabBar.scrollEdgeAppearance = appearance;
        }
    } else {
        // iOS 13 以下的适配
        self.tabBar.barTintColor = [UIColor whiteColor];
    }
    
    // 设置 tint
    self.tabBar.tintColor = selectedColor;
    if (@available(iOS 10.0, *)) {
        self.tabBar.unselectedItemTintColor = unselectedColor;
    }
    
    // 关闭透明效果，使背景不透明
    self.tabBar.translucent = NO;
}

#pragma mark - Public Methods
- (void)updateBadgeValue:(NSInteger)badge itemBarIndex:(NSInteger)index {
    if (index < 0 || index >= self.viewControllers.count) return;
    UIViewController *vc = self.viewControllers[index];
    if (badge > 0) {
        vc.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld", (long)badge];
        
        if (@available(iOS 10.0, *)) {
            vc.tabBarItem.badgeColor = [UIColor systemRedColor];
            [vc.tabBarItem setBadgeTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}
                                         forState:UIControlStateNormal];
        }
    } else {
        vc.tabBarItem.badgeValue = nil;
    }
}

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            self.tabBar.alpha = hidden ? 0.0 : 1.0;
        } completion:^(BOOL finished) {
            self.tabBar.hidden = hidden;
        }];
    } else {
        self.tabBar.hidden = hidden;
    }
}

#pragma mark - UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    NSInteger newIndex = [self.viewControllers indexOfObject:viewController];
    NSLog(@"切换到第 %ld 个 tab", (long)newIndex);
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    NSLog(@"已切换到: %@", viewController.tabBarItem.title);
    [self addBounceAnimationToTabBarItem:tabBarController.tabBar.selectedItem];
}

- (void)addBounceAnimationToTabBarItem:(UITabBarItem *)item {
    // valueForKey:@"view" 是私有 API 的访问，但常见做法用于拿到 tabBarButton
    UIView *tabBarButton = [item valueForKey:@"view"];
    if (!tabBarButton) return;
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.values = @[@1.0, @1.1, @0.9, @1.0];
    animation.duration = 0.3;
    animation.calculationMode = kCAAnimationCubic;
    [tabBarButton.layer addAnimation:animation forKey:@"bounce"];
}

@end
