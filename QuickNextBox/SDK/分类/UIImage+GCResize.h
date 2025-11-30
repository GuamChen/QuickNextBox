//
//  UIImage.h
//  QuickNextBox
//
//  Created by lgc on 2025/11/30.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GCImageResizeMode) {
    /// 拉伸填满（可能变形）
    GCImageResizeModeScaleToFill,
    /// 等比适配（可能有空白）
    GCImageResizeModeAspectFit,
    /// 等比填充（超出裁剪）
    GCImageResizeModeAspectFill
};

@interface UIImage (GCResize)

/// 图片缩放工具方法（生产级推荐）
///
/// @param size 目标尺寸
/// @param mode 缩放模式（Fill / Fit / Fill裁剪）
/// @return 新图
- (UIImage *)gc_resizeToSize:(CGSize)size
                        mode:(GCImageResizeMode)mode;

@end

NS_ASSUME_NONNULL_END
