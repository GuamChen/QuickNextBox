//
//  HomeVC 2.h
//  helloworld
//
//  Created by lgc on 2025/10/28.



// HomeVC.m
#import "HomeVC.h"

@interface HomeVC ()

@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = @"首页";
    
    [self setupUI];
}

- (void)setupUI {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"首页内容";
    titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightMedium];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor labelColor];
    
    [self.view addSubview:titleLabel];
    
    // 使用自动布局
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [titleLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [titleLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.view.leadingAnchor constant:20],
        [titleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.view.trailingAnchor constant:-20]
    ]];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(languageDidChange)
                                                 name:kLanguageDidChangeNotification
                                               object:nil];
}


- (void)setupUI2 {
    // 方法1：使用宏
    self.title = L_Welcome;
    self.navigationItem.title = Localized(@"home_title"); 
    
    // 方法2：直接使用扩展
    UILabel *label = [[UILabel alloc] init];
    label.text = @"welcome".localized;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"save".localized forState:UIControlStateNormal];
    
    // 方法3：使用管理类
    NSString *text = [[LanguageManager sharedManager] localizedStringForKey:@"home_description" comment:@"首页描述"];
}


- (void)languageDidChange {
    // 重新设置所有文本
    [self updateTexts];
    
    // 如果需要，重新加载界面
    [self viewDidLoad];
}

- (void)updateTexts {
    self.title = L_Welcome;
    // 更新所有UI元素的文本
}
@end
