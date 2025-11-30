//
//  ButtonDisplayVC 2.h
//  QuickNextBox
//
//  Created by lgc on 2025/11/28.
//


#import "ButtonDisplayVC.h"

@interface ButtonDisplayVC ()

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation ButtonDisplayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Button Display";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupScrollView];
    [self setupButtons];
}

#pragma mark - UI

- (void)setupScrollView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.scrollView];
}

- (void)setupButtons {
    
    CGFloat margin = 20;
    CGFloat buttonHeight = 50;
    CGFloat buttonWidth = self.view.bounds.size.width - margin * 2;
    
    NSArray *titles = @[
        @"普通按钮", @"高亮按钮", @"禁用状态", @"边框按钮", @"圆角按钮",
        @"图文按钮", @"背景图片按钮", @"系统蓝按钮", @"自定义字体按钮", @"圆形按钮",
        
        // —— 新增时尚按钮 ——
        @"渐变按钮", @"玻璃拟态", @"霓虹发光",
        @"荧光描边", @"极简扁平",
        @"悬浮阴影", @"拟物高光",
        @"渐变描边", @"胶囊按钮", @"毛玻璃按钮",
        
        // —— 主流业务按钮 ——
        @"主按钮", @"次按钮", @"危险按钮",
        @"弱按钮", @"纯文字按钮",
        @"左图右文", @"右图左文",
        @"可选中按钮", @"加载中按钮", @"倒计时按钮"

    ];


    UIView *prevView = nil;
    for (int i = 0; i < titles.count; i++) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(margin,
                                  margin + (buttonHeight + margin) * i,
                                  buttonWidth,
                                  buttonHeight);
        
        [button setTitle:titles[i] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        
        [self applyStyleForButton:button index:i];
        
        [button addTarget:self
                   action:@selector(buttonClicked:)
         forControlEvents:UIControlEventTouchUpInside];
        
        [self.scrollView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.scrollView.mas_left).offset(margin);
            
            if(i== 9){
                make.height.mas_equalTo(100);
                make.width.mas_equalTo(100);
            }else{
                make.height.mas_equalTo(buttonHeight);
                make.width.mas_equalTo(buttonWidth);
            }
            
            if (prevView) {
                make.top.equalTo(prevView.mas_bottom).offset(margin);
            } else {
                make.top.equalTo(self.scrollView.mas_top).offset(margin);
            }
        }];
        prevView = button;
    }
    [prevView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.scrollView.mas_bottom).offset(-margin);
    }];

}

#pragma mark - Button Style
-(UIButton *)buttonFactoryForIndex:(NSInteger) index {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    
    [self applyStyleForButton:button index:index];
    
    return button;
}
- (void)applyStyleForButton:(UIButton *)button index:(NSInteger)index {
    
    switch (index) {
        
        case 0: // 普通按钮
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            button.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
            break;
            
        case 1: // 高亮效果
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setBackgroundColor:[UIColor systemGreenColor]];
            break;
            
        case 2: // 禁用状态
            button.enabled = NO;
            button.backgroundColor = [UIColor lightGrayColor];
            break;
            
        case 3: // 边框按钮
            [button setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
            button.layer.borderWidth = 1;
            button.layer.borderColor = [UIColor systemBlueColor].CGColor;
            break;
            
        case 4: // 圆角按钮
            button.backgroundColor = [UIColor systemOrangeColor];
            button.layer.cornerRadius = 10;
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            break;
            
        case 5: // 图文按钮
            [button setImage:[UIImage systemImageNamed:@"star"] forState:UIControlStateNormal];
            button.tintColor = [UIColor systemYellowColor];
            button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
            break;
            
        case 6: // 背景图片按钮
            [button setBackgroundImage:[self imageWithColor:[UIColor systemPinkColor]]
                               forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            break;
            
        case 7: // 系统蓝
            button.backgroundColor = [UIColor systemBlueColor];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            break;
            
        case 8: // 自定义字体
            button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
            button.backgroundColor = [UIColor brownColor];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            break;
            
        case 9: // 圆形按钮
            button.frame = CGRectMake((self.view.bounds.size.width - 100) / 2,
                                      button.frame.origin.y,
                                      100,
                                      100);
            button.layer.cornerRadius = 50;
            button.backgroundColor = [UIColor purpleColor];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            break;
            
            
#pragma mark - Stylish Buttons
        case 10: { // 渐变按钮
            CAGradientLayer *layer = [CAGradientLayer layer];
            layer.frame = button.bounds;
            layer.colors = @[(id)[UIColor systemPinkColor].CGColor,
                             (id)[UIColor systemOrangeColor].CGColor];
            layer.cornerRadius = 10;
            [button.layer insertSublayer:layer atIndex:0];
            [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        }
            break;
            
        case 11: { // 玻璃拟态
            UIVisualEffectView *blur = [[UIVisualEffectView alloc]
                                        initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
            blur.frame = button.bounds;
            blur.layer.cornerRadius = 12;
            blur.clipsToBounds = YES;
            [button insertSubview:blur atIndex:0];
            button.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
            button.layer.borderWidth = 0.5;
            button.layer.borderColor = [UIColor whiteColor].CGColor;
        }
            break;
            
        case 12: { // 霓虹
            button.backgroundColor = UIColor.blackColor;
            [button setTitleColor:UIColor.greenColor forState:UIControlStateNormal];
            button.layer.shadowColor = UIColor.greenColor.CGColor;
            button.layer.shadowRadius = 10;
            button.layer.shadowOpacity = 1;
        }
            break;
            
        case 13: { // 荧光描边
            button.backgroundColor = UIColor.clearColor;
            [button setTitleColor:UIColor.systemPinkColor forState:UIControlStateNormal];
            button.layer.borderWidth = 2;
            button.layer.borderColor = UIColor.greenColor.CGColor;
            button.layer.shadowColor = UIColor.greenColor.CGColor;
            button.layer.shadowRadius = 4;
            button.layer.shadowOpacity = 1;
        }
            break;
            
        case 14: { // 极简扁平
            button.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
            [button setTitleColor:UIColor.darkGrayColor forState:UIControlStateNormal];
        }
            break;
            
        case 15: { // 悬浮阴影
            button.backgroundColor = UIColor.whiteColor;
            button.layer.cornerRadius = 10;
            button.layer.shadowColor = UIColor.blackColor.CGColor;
            button.layer.shadowOffset = CGSizeMake(6, 6);
            button.layer.shadowOpacity = 0.2;
            button.layer.shadowRadius = 8;
        }
            break;
            
        case 16: { // 拟物高光
            CAGradientLayer *light = [CAGradientLayer layer];
            light.frame = button.bounds;
            light.colors = @[(id)UIColor.whiteColor.CGColor,
                             (id)UIColor.systemBlueColor.CGColor];
            light.cornerRadius = 10;
            [button.layer insertSublayer:light atIndex:0];
            [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        }
            break;
            
        case 17: { // 渐变边框
            CAGradientLayer *border = [CAGradientLayer layer];
            border.frame = button.bounds;
            border.colors = @[(id)UIColor.redColor.CGColor,
                              (id)UIColor.blueColor.CGColor];
            CAShapeLayer *mask = [CAShapeLayer layer];
            mask.lineWidth = 3;
            mask.path = [UIBezierPath bezierPathWithRoundedRect:button.bounds cornerRadius:12].CGPath;
            mask.fillColor = UIColor.clearColor.CGColor;
            mask.strokeColor = UIColor.blackColor.CGColor;
            border.mask = mask;
            [button.layer addSublayer:border];
        }
            break;
            
        case 18: { // 胶囊
            button.backgroundColor = UIColor.systemPurpleColor;
            button.layer.cornerRadius = button.bounds.size.height/2;
            [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        }
            break;
            
        case 19: { // 毛玻璃
            [button setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.15]];
            UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];
            UIVisualEffectView *view = [[UIVisualEffectView alloc] initWithEffect:blur];
            view.frame = button.bounds;
            view.userInteractionEnabled = NO;
            view.layer.cornerRadius = 12;
            view.clipsToBounds = YES;
            [button insertSubview:view atIndex:0];
        }
            break;

#pragma mark - 主流按钮
        case 20: {
            button.backgroundColor = UIColor.systemBlueColor;
            [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            button.layer.cornerRadius = 8;
            button.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        }
            break;
        case 21: {
            button.backgroundColor = UIColor.systemGrayColor;
            [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            button.layer.cornerRadius = 8;
        }
            break;
        case 22: {
            button.backgroundColor = UIColor.systemRedColor;
            [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            button.layer.cornerRadius = 8;
        }
            break;
        case 23: {
            [button setTitleColor:UIColor.systemBlueColor forState:UIControlStateNormal];
            button.backgroundColor = UIColor.clearColor;
            button.layer.borderWidth = 1;
            button.layer.borderColor = UIColor.systemBlueColor.CGColor;
            button.layer.cornerRadius = 8;
        }
            break;
        case 24: {
            button.backgroundColor = UIColor.clearColor;
            [button setTitleColor:UIColor.systemBlueColor forState:UIControlStateNormal];
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        }
            break;
        case 25: {
            [button setImage:[UIImage systemImageNamed:@"chevron.left"] forState:UIControlStateNormal];
            button.tintColor = UIColor.systemBlueColor;
            button.imageEdgeInsets = UIEdgeInsetsMake(0, -12, 0, 0);
        }
            break;
        case 26: {
            [button setImage:[UIImage systemImageNamed:@"chevron.right"]
                    forState:UIControlStateNormal];
            button.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
            button.tintColor = UIColor.systemBlueColor;
        }
            break;
        case 27: {
            button.layer.cornerRadius = 8;
            [button setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
            [button setTitleColor:UIColor.systemBlueColor forState:UIControlStateNormal];
            button.backgroundColor = UIColor.systemGray5Color;
            
            [button addAction:[UIAction actionWithHandler:^(__kindof UIAction * _Nonnull action) {
                button.selected = !button.selected;
                button.backgroundColor = button.selected ? UIColor.systemBlueColor : UIColor.systemGray5Color;
            }] forControlEvents:UIControlEventTouchUpInside];
        }
            break;
        case 28: {
            UIActivityIndicatorView *loader =
            [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
            loader.center = CGPointMake(30, button.bounds.size.height/2);
            [loader startAnimating];
            [button addSubview:loader];
            
            [button setTitle:@"加载中..." forState:UIControlStateNormal];
            button.backgroundColor = UIColor.systemGrayColor;
            [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        }
            break;
        case 29: {
            button.backgroundColor = UIColor.systemBlueColor;
            [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            
            __block NSInteger time = 10;
            [button addAction:[UIAction actionWithHandler:^(__kindof UIAction * _Nonnull action) {
                button.enabled = NO;
                __block NSInteger remain = time;
                
                dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                                                 0, 0,
                                                                 dispatch_get_main_queue());
                dispatch_source_set_timer(timer, DISPATCH_TIME_NOW,
                                          1 * NSEC_PER_SEC, 0);
                
                dispatch_source_set_event_handler(timer, ^{
                    if (remain == 0) {
                        dispatch_source_cancel(timer);
                        [button setTitle:@"重新获取" forState:UIControlStateNormal];
                        button.enabled = YES;
                    } else {
                        [button setTitle:[NSString stringWithFormat:@"%lds", (long)remain]
                                forState:UIControlStateNormal];
                        remain--;
                    }
                });
                
                dispatch_resume(timer);
                
            }] forControlEvents:UIControlEventTouchUpInside];
        }
            break;

        default:
            break;
    }
}

#pragma mark - Action

- (void)buttonClicked:(UIButton *)sender {
    NSLog(@"点击了按钮：%@", sender.currentTitle);
}

#pragma mark - Utils

// 生成纯色图片（用于按钮背景）
- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    [color setFill];
    UIRectFill(rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
