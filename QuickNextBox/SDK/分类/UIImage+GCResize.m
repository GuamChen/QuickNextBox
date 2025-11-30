//
//  UIImage.m
//  QuickNextBox
//
//  Created by lgc on 2025/11/30.
//


#import "UIImage+GCResize.h"

@implementation UIImage (GCResize)

- (UIImage *)gc_resizeToSize:(CGSize)size mode:(GCImageResizeMode)mode {
    if (size.width <= 0 || size.height <= 0 || !self) return nil;

    CGSize imgSize = self.size;
    CGRect drawRect = CGRectMake(0, 0, size.width, size.height);

    CGFloat scaleW = size.width / imgSize.width;
    CGFloat scaleH = size.height / imgSize.height;
    CGFloat scale = 1;

    switch (mode) {
        case GCImageResizeModeScaleToFill:
            drawRect = CGRectMake(0, 0, size.width, size.height);
            break;

        case GCImageResizeModeAspectFit:
            scale = MIN(scaleW, scaleH);
            drawRect.size = CGSizeMake(imgSize.width * scale,
                                       imgSize.height * scale);
            break;

        case GCImageResizeModeAspectFill:
            scale = MAX(scaleW, scaleH);
            drawRect.size = CGSizeMake(imgSize.width * scale,
                                       imgSize.height * scale);
            break;
    }

    // 居中
    drawRect.origin.x = (size.width - drawRect.size.width) * 0.5;
    drawRect.origin.y = (size.height - drawRect.size.height) * 0.5;

    // iOS 10+ 推荐方式：更安全 + 性能更优
    UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat defaultFormat];
    format.scale = UIScreen.mainScreen.scale;
    format.opaque = NO;

    UIGraphicsImageRenderer *renderer =
    [[UIGraphicsImageRenderer alloc] initWithSize:size format:format];

    UIImage *result =
    [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull context) {
        [self drawInRect:drawRect];
    }];

    return result;
}

@end
