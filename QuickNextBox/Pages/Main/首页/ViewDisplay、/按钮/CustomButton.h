//
//  CustomButton 2.h
//  QuickNextBox
//
//  Created by lgc on 2025/11/30.
//


// CustomButton.h
// Library-ready, enterprise-grade CustomButton
// Created by assistant for user

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CVButtonLayoutStyle) {
    CVButtonLayoutStyleImageLeft,   // image left, title right (horizontal)
    CVButtonLayoutStyleImageRight,  // image right, title left
    CVButtonLayoutStyleImageTop,    // image on top, title below (vertical)
    CVButtonLayoutStyleImageBottom  // image below, title on top
};

@interface CustomButton : UIControl

@property (nonatomic, assign) CVButtonLayoutStyle layoutStyle; // layout style
@property (nonatomic, assign) CGFloat imageScale; // image height (or width for horz) as proportion of control (0..1)
@property (nonatomic, assign) CGFloat spacing; // spacing between image and title
@property (nonatomic, strong, readonly) UIImageView *iconImageView;
@property (nonatomic, strong, readonly) UILabel *customTitleLabel;

// designated initializer
- (instancetype)initWithFrame:(CGRect)frame LayoutStyle:(CVButtonLayoutStyle)layoutStyle;

// convenience setters that mirror UIButton API but accept UIImage
- (void)setImage:(nullable UIImage *)image forState:(UIControlState)state;
- (void)setTitle:(nullable NSString *)title forState:(UIControlState)state;
- (void)setTitleColor:(nullable UIColor *)color forState:(UIControlState)state;

// also support setting images by name for convenience
- (void)setImageNamed:(nullable NSString *)imageName forState:(UIControlState)state;

// Call to refresh appearance (if you mutate state dicts directly)
- (void)updateAppearance;

@end

NS_ASSUME_NONNULL_END
