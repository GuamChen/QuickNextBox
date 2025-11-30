//
//  CustomButton 2.h
//  QuickNextBox
//
//  Created by lgc on 2025/11/30.
//


#import "CustomButton.h"

@interface CustomButton ()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UIImage *> *imagesByState;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSString *> *titlesByState;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UIColor *> *titleColorsByState;

@end

@implementation CustomButton
- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:CGRectMake(0, 0, 100, 44) LayoutStyle:CVButtonLayoutStyleImageLeft];
}

- (instancetype)initWithFrame:(CGRect)frame LayoutStyle:(CVButtonLayoutStyle)layoutStyle{
    self = [super initWithFrame:frame];
    if (self) {
        
        _layoutStyle = CVButtonLayoutStyleImageLeft;
        _imageScale = 0.36;
        _spacing = 6.0;

        _imagesByState = [NSMutableDictionary dictionary];
        _titlesByState = [NSMutableDictionary dictionary];
        _titleColorsByState = [NSMutableDictionary dictionary];

        // Important: this class implements UIControl-like behaviours
        self.userInteractionEnabled = YES;

        // Subviews
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        _iconImageView.userInteractionEnabled = NO;
        [self addSubview:_iconImageView];

        _customTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _customTitleLabel.textAlignment = NSTextAlignmentCenter;
        _customTitleLabel.font = [UIFont systemFontOfSize:16];
        _customTitleLabel.adjustsFontSizeToFitWidth = YES;
        _customTitleLabel.minimumScaleFactor = 0.5;
        _customTitleLabel.userInteractionEnabled = NO;
        [self addSubview:_customTitleLabel];

        // Accessibility
        self.isAccessibilityElement = YES;
        self.accessibilityTraits = UIAccessibilityTraitButton;

        // Default colors
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];


        // Track touch events to update highlight state
        [self addTarget:self action:@selector(didTouchDown) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(didTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(didTouchUpOutsideOrCancel) forControlEvents:UIControlEventTouchUpOutside];
        [self addTarget:self action:@selector(didTouchUpOutsideOrCancel) forControlEvents:UIControlEventTouchCancel];

        
        [self setupConstraints];
        [self updateAppearance];
    }
    return self;
}



#pragma mark - Public API
- (void)setImageNamed:(NSString *)imageName forState:(UIControlState)state {
    UIImage *img = imageName ? [UIImage imageNamed:imageName] : nil;
    [self setImage:img forState:state];
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    if (image) {
        self.imagesByState[@(state)] = image;
    } else {
        [self.imagesByState removeObjectForKey:@(state)];
    }
    [self updateAppearance];
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    if (title) {
        self.titlesByState[@(state)] = title;
    } else {
        [self.titlesByState removeObjectForKey:@(state)];
    }
    [self updateAppearance];
}

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    if (color) {
        self.titleColorsByState[@(state)] = color;
    } else {
        [self.titleColorsByState removeObjectForKey:@(state)];
    }
    [self updateAppearance];
}

- (NSString *)accessibilityLabel {
    NSString *title = [self valueForState:self.state inDict:self.titlesByState] ?: _customTitleLabel.text;
    return title ?: [super accessibilityLabel];
}

#pragma mark - State helpers

- (id)valueForState:(UIControlState)state inDict:(NSDictionary *)dict {
    // Priority-based lookup: exact -> combined flags -> individual flags -> disabled -> normal
    id v = dict[@(state)];
    if (v) return v;

    // Check common composite states
    if ((state & UIControlStateSelected) && dict[@(UIControlStateSelected)]) return dict[@(UIControlStateSelected)];
    if ((state & UIControlStateHighlighted) && dict[@(UIControlStateHighlighted)]) return dict[@(UIControlStateHighlighted)];
    if ((state & UIControlStateDisabled) && dict[@(UIControlStateDisabled)]) return dict[@(UIControlStateDisabled)];

    // Fallback
    return dict[@(UIControlStateNormal)];
}

- (void)updateAppearance {
    // Update current control state
    UIControlState st = 0;
    if (!self.enabled) st |= UIControlStateDisabled;
    if (self.selected) st |= UIControlStateSelected;
    if (self.highlighted) st |= UIControlStateHighlighted;

    UIImage *img = [self valueForState:st inDict:self.imagesByState];
    NSString *title = [self valueForState:st inDict:self.titlesByState];
    UIColor *titleColor = [self valueForState:st inDict:self.titleColorsByState];

    // Apply
    _iconImageView.image = img;
    _customTitleLabel.text = title;
    if (titleColor) {
        _customTitleLabel.textColor = titleColor;
    }

    // Accessibility
    self.accessibilityLabel = _customTitleLabel.text ?: nil;

    [self setNeedsLayout];
}

#pragma mark - Touch tracking

- (void)didTouchDown {
    self.highlighted = YES;
}

- (void)didTouchUpInside {
    self.highlighted = NO;
    // send primary action
    [self sendActionsForControlEvents:UIControlEventPrimaryActionTriggered];
}

- (void)didTouchUpOutsideOrCancel {
    self.highlighted = NO;
}

#pragma mark - Overrides
- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self updateAppearance];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self updateAppearance];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    [self updateAppearance];
}

#pragma mark - Layout

// 需要根据项目做布局约束

- (void)setupConstraints {
    CGRect bounds = self.bounds;
    CGFloat w = CGRectGetWidth(bounds);
    CGFloat h = CGRectGetHeight(bounds);
    
    if (self.layoutStyle == CVButtonLayoutStyleImageLeft) {
        // 横向排布 - 图片在左，文字在右
        CGFloat img_h = 30;
        
//        CGRect rect = [self.customTitleLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX,200 )
//                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
//                                      attributes:@{NSFontAttributeName: self.customTitleLabel.font}
//                                         context:nil];
        
        [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).multipliedBy(0.36);
            make.centerY.mas_equalTo(0);
            make.height.mas_equalTo(img_h);
            make.width.equalTo(_iconImageView.mas_height).multipliedBy(1); // 真正需要等比缩放: 用 imageView.contentMode = AspectFit 就够了
        }];
        
        [_customTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_right).multipliedBy(0.43);
            make.right.equalTo(self.mas_right).multipliedBy(0.95);
            make.centerY.mas_equalTo(0);
        }];
    } else {
        // 纵向排布 - 图片在上，文字在下
        [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(self).offset(-8);
            make.width.height.lessThanOrEqualTo(self);
        }];
        
        [_customTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_iconImageView.mas_bottom).offset(5);
            make.centerX.equalTo(self);
            make.left.right.equalTo(self);
            make.height.mas_equalTo(20);
        }];
    }
}

//- (void)layoutSubviews {
//    [super layoutSubviews];
//
//    CGRect bounds = self.bounds;
//    CGFloat w = CGRectGetWidth(bounds);
//    CGFloat h = CGRectGetHeight(bounds);
//
//    // guard
//    if (w <= 0 || h <= 0) return;
//
//    CGSize imageAvailableSize = CGSizeZero;
//    CGRect imgFrame = CGRectZero;
//    CGRect titleFrame = CGRectZero;
//
//    // Preferred image size depends on layoutStyle
//    if (self.layoutStyle == CVButtonLayoutStyleImageTop || self.layoutStyle == CVButtonLayoutStyleImageBottom) {
//        CGFloat imageH = floor(h * self.imageScale);
//        CGFloat titleH = 0;
//        if (self.customTitleLabel.text.length > 0) {
//            // estimate title height
//            CGSize constraint = CGSizeMake(w, CGFLOAT_MAX);
//            CGRect r = [self.customTitleLabel.text boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.customTitleLabel.font} context:nil];
//            titleH = ceil(MIN(r.size.height, 44));
//        }
//        CGFloat totalH = imageH + (self.customTitleLabel.text.length ? (self.spacing + titleH) : 0);
//        CGFloat startY = (h - totalH) / 2.0;
//
//        if (self.layoutStyle == CVButtonLayoutStyleImageTop) {
//            imgFrame = CGRectMake((w - imageH)/2.0, startY, imageH, imageH);
//            titleFrame = CGRectMake(0, CGRectGetMaxY(imgFrame) + self.spacing, w, titleH);
//        } else {
//            // image bottom
//            titleFrame = CGRectMake(0, startY, w, titleH);
//            imgFrame = CGRectMake((w - imageH)/2.0, CGRectGetMaxY(titleFrame) + self.spacing, imageH, imageH);
//        }
//    } else {
//        // horizontal layouts
//        CGFloat imageW = floor(w * self.imageScale);
//        CGFloat titleW = 0;
//        if (self.customTitleLabel.text.length > 0) {
//            CGSize constraint = CGSizeMake(w - imageW - self.spacing - 8, CGFLOAT_MAX);
//            CGRect r = [self.customTitleLabel.text boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.customTitleLabel.font} context:nil];
//            titleW = ceil(MIN(r.size.width, w - imageW - self.spacing - 8));
//        }
//
//        CGFloat totalW = imageW + (self.customTitleLabel.text.length ? (self.spacing + titleW) : 0);
//        CGFloat startX = (w - totalW) / 2.0;
//
//        if (self.layoutStyle == CVButtonLayoutStyleImageLeft) {
//            imgFrame = CGRectMake(startX, (h - imageW)/2.0, imageW, imageW);
//            titleFrame = CGRectMake(CGRectGetMaxX(imgFrame) + self.spacing, 0, titleW, h);
//        } else {
//            // image right
//            titleFrame = CGRectMake(startX, 0, titleW, h);
//            imgFrame = CGRectMake(CGRectGetMaxX(titleFrame) + self.spacing, (h - imageW)/2.0, imageW, imageW);
//        }
//    }
//
//    // apply frames
//    _iconImageView.frame = imgFrame;
//    _customTitleLabel.frame = titleFrame;
//}


@end


