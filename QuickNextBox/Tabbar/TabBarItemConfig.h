//
//  TabBarItemConfig.h
//  helloworld
//
//  Created by lgc on 2025/10/28.
//


// TabBarItemConfig.h
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TabBarItemType) {
    TabBarItemTypeHome,
    TabBarItemTypeDiscover,
    TabBarItemTypeProfile
};

@interface TabBarItemConfig : NSObject

@property (nonatomic, assign) TabBarItemType type;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *normalImage;
@property (nonatomic, copy) NSString *selectedImage;
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, assign) NSInteger badgeValue;

+ (instancetype)configWithType:(TabBarItemType)type
                         title:(NSString *)title
                   normalImage:(NSString *)normalImage
                 selectedImage:(NSString *)selectedImage
              viewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
