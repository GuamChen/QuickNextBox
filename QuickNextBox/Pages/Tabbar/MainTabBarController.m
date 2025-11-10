// MainTabBarController.m
#import "MainTabBarController.h"
#import "TabBarItemConfig.h"

// 子控制器
#import "HomeVC.h"
#import "DiscoverVC.h"
#import "ProfileVC.h"

@interface MainTabBarController ()<UITabBarControllerDelegate>

@property (nonatomic, strong) NSArray<TabBarItemConfig *> *tabConfigs;

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViewControllers];
    [self customizeTabBarAppearance];
    
    self.delegate = self; // 设置代理

}

#pragma mark - Setup


- (void)setupViewControllers {
    // 1. 首页
    HomeVC *homeVC = [[HomeVC alloc] init];
    homeVC.tabBarItem.title = @"首页";
    UINavigationController *homeNav = [[UINavigationController alloc] initWithRootViewController:homeVC];
    homeNav.tabBarItem = [self createTabBarItemWithTitle:@"首页"
                                             normalImage:@"house"
                                           selectedImage:@"house.fill"];
    
    // 2. 发现
    DiscoverVC *discoverVC = [[DiscoverVC alloc] init];
    discoverVC.tabBarItem.title = @"发现";
    UINavigationController *discoverNav = [[UINavigationController alloc] initWithRootViewController:discoverVC];
    discoverNav.tabBarItem = [self createTabBarItemWithTitle:@"发现"
                                                 normalImage:@"magnifyingglass"
                                               selectedImage:@"magnifyingglass"];
    
    // 3. 我的
    ProfileVC *profileVC = [[ProfileVC alloc] init];
    profileVC.tabBarItem.title = @"我的";
    UINavigationController *profileNav = [[UINavigationController alloc] initWithRootViewController:profileVC];
    profileNav.tabBarItem = [self createTabBarItemWithTitle:@"我的"
                                                normalImage:@"person"
                                              selectedImage:@"person.fill"];
    
    // 设置 viewControllers
    self.viewControllers = @[homeNav, discoverNav, profileNav];
    self.selectedIndex = 1; // 默认选中首页
}

- (UITabBarItem *)createTabBarItemWithTitle:(NSString *)title
                                normalImage:(NSString *)normalImage
                              selectedImage:(NSString *)selectedImage {
    
    UIImage *normalIcon = [UIImage systemImageNamed:normalImage] ?: [UIImage imageNamed:normalImage];
    UIImage *selectedIcon = [UIImage systemImageNamed:selectedImage] ?: [UIImage imageNamed:selectedImage];
    
    UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:title
                                                             image:normalIcon
                                                     selectedImage:selectedIcon];
    
    // 设置文字颜色
    [tabBarItem setTitleTextAttributes:@{
        NSForegroundColorAttributeName: [UIColor grayColor],
        NSFontAttributeName: [UIFont systemFontOfSize:11]
    } forState:UIControlStateNormal];
    
    [tabBarItem setTitleTextAttributes:@{
        NSForegroundColorAttributeName: [UIColor systemBlueColor],
        NSFontAttributeName: [UIFont systemFontOfSize:11]
    } forState:UIControlStateSelected];
    
    return tabBarItem;
}


#pragma mark - Custom Appearance

- (void)customizeTabBarAppearance {
    if (@available(iOS 13.0, *)) {
        UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
        
        // 背景色
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor systemBackgroundColor];
        
        // 去掉上边框
        appearance.shadowColor = [UIColor clearColor];
        
        // 设置标准外观
        self.tabBar.standardAppearance = appearance;
        
        if (@available(iOS 15.0, *)) {
            self.tabBar.scrollEdgeAppearance = appearance;
        }
    } else {
        // iOS 13 以下的适配
        self.tabBar.barTintColor = [UIColor whiteColor];
        self.tabBar.shadowImage = [[UIImage alloc] init];
        self.tabBar.backgroundImage = [[UIImage alloc] init];
    }
    
    // 设置不透明
    self.tabBar.translucent = NO;
}

#pragma mark - Public Methods

- (void)updateBadgeValue:(NSInteger)badge forType:(TabBarItemType)type {
    NSInteger index = [self indexForTabType:type];
    if (index >= 0 && index < self.tabConfigs.count) {
        UIViewController *vc = self.viewControllers[index];
        if (badge > 0) {
            vc.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld", (long)badge];
            
            // 自定义 badge 样式 (iOS 10+)
            if (@available(iOS 10.0, *)) {
                vc.tabBarItem.badgeColor = [UIColor systemRedColor];
                [vc.tabBarItem setBadgeTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}
                                             forState:UIControlStateNormal];
            }
        } else {
            vc.tabBarItem.badgeValue = nil;
        }
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

#pragma mark - Helper Methods

- (NSInteger)indexForTabType:(TabBarItemType)type {
    for (NSInteger i = 0; i < self.tabConfigs.count; i++) {
        if (self.tabConfigs[i].type == type) {
            return i;
        }
    }
    return -1;
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    // 可以在这里添加切换前的逻辑，比如权限检查等
    NSInteger newIndex = [self.viewControllers indexOfObject:viewController];
    NSLog(@"切换到第 %ld 个 tab", (long)newIndex);
    
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    // 切换完成后的逻辑
    NSLog(@"已切换到: %@", viewController.tabBarItem.title);
    
    // 可以在这里添加统计、动画效果等
    [self addBounceAnimationToTabBarItem:tabBarController.tabBar.selectedItem];
}

- (void)addBounceAnimationToTabBarItem:(UITabBarItem *)item {
    // 为选中的 tab 添加弹性动画
    UIView *tabBarButton = [item valueForKey:@"view"];
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.values = @[@1.0, @1.1, @0.9, @1.0];
    animation.duration = 0.3;
    animation.calculationMode = kCAAnimationCubic;
    [tabBarButton.layer addAnimation:animation forKey:@"bounce"];
}

@end
