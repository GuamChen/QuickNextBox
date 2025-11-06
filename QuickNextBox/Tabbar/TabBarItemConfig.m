//
//  TabBarItemConfig.m
//  helloworld
//
//  Created by lgc on 2025/10/28.
//


// TabBarItemConfig.m
#import "TabBarItemConfig.h"

@implementation TabBarItemConfig

+ (instancetype)configWithType:(TabBarItemType)type
                         title:(NSString *)title
                   normalImage:(NSString *)normalImage
                 selectedImage:(NSString *)selectedImage
              viewController:(UIViewController *)viewController {
    
    TabBarItemConfig *config = [[TabBarItemConfig alloc] init];
    config.type = type;
    config.title = title;
    config.normalImage = normalImage;
    config.selectedImage = selectedImage;
    config.viewController = viewController;
    return config;
}

@end
