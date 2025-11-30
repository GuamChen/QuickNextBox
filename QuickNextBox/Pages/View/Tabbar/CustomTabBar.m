//
//  CustomTabBar.m
//  QuickNextBox
//
//  Created by lgc on 2025/11/28.
//


#import "CustomTabBar.h"

@implementation CustomTabBar

// 在这里增加高度 20pt
- (CGSize)sizeThatFits:(CGSize)size {
    CGSize newSize = [super sizeThatFits:size];
    // 增高 20pt
    newSize.height = newSize.height + 20.0;
    return newSize;
}

// 兼容 iOS safe area inset（必要时可调整）
- (UIEdgeInsets)alignmentRectInsets {
    UIEdgeInsets insets = [super alignmentRectInsets];
    return insets;
}

@end
