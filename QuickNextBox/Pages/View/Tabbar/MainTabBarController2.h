//
//  MainTabBarController.h
//  helloworld
//
//  Created by lgc on 2025/10/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MainTabBarController2 : UITabBarController

- (void)updateBadgeValue:(NSInteger)badge itemBarIndex:(NSInteger)index;
- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
