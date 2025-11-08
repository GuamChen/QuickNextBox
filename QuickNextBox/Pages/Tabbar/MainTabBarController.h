//
//  MainTabBarController.h
//  helloworld
//
//  Created by lgc on 2025/10/28.
//


// MainTabBarController.h
#import <UIKit/UIKit.h>
#import "TabBarItemConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface MainTabBarController : UITabBarController

- (void)updateBadgeValue:(NSInteger)badge forType:(TabBarItemType)type;
- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
