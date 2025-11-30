#import "ToolbarDemoVC.h"

@interface ToolbarDemoVC ()

@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UILabel *statusLabel;

@end

@implementation ToolbarDemoVC

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupToolbar];
}

#pragma mark - UI Setup

- (void)setupUI {
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.title = Localized(@"工具栏演示");
    
    // 状态标签
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.text = Localized(@"点击工具栏按钮进行操作");
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.textColor = [UIColor secondaryLabelColor];
    self.statusLabel.font = [UIFont systemFontOfSize:16];
    self.statusLabel.numberOfLines = 0;
    [self.view addSubview:self.statusLabel];
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
}

#pragma mark - Toolbar Setup

- (void)setupToolbar {
    self.toolbar = [[UIToolbar alloc] init];
    self.toolbar.barTintColor = [UIColor systemBackgroundColor];
    self.toolbar.tintColor = [UIColor systemBlueColor];
    
    [self.view addSubview:self.toolbar];
    [self.toolbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.equalTo(self.view).inset(0);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-50);
        make.height.mas_equalTo(44);
    }];
    
    [self updateToolbarItems];
}

- (void)updateToolbarItems {
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = 20;
    
    NSArray *toolbarItems = @[
        [self createToolbarButtonWithType:ToolbarActionTypeSave],
        flexibleSpace,
        [self createToolbarButtonWithType:ToolbarActionTypeShare],
        flexibleSpace,
        [self createToolbarButtonWithType:ToolbarActionTypeEdit],
        flexibleSpace,
        [self createToolbarButtonWithType:ToolbarActionTypeFavorite],
        flexibleSpace,
        [self createToolbarButtonWithType:ToolbarActionTypeDelete]
    ];
    
    [self.toolbar setItems:toolbarItems animated:YES];
}

- (UIBarButtonItem *)createToolbarButtonWithType:(ToolbarActionType)type {
    NSString *title;
    NSString *iconName;
    SEL action;
    
    switch (type) {
        case ToolbarActionTypeSave:
            title = Localized(@"保存");
            iconName = @"square.and.arrow.down";
            action = @selector(saveAction:);
            break;
        case ToolbarActionTypeShare:
            title = Localized(@"分享");
            iconName = @"square.and.arrow.up";
            action = @selector(shareAction:);
            break;
        case ToolbarActionTypeEdit:
            title = Localized(@"编辑");
            iconName = @"pencil";
            action = @selector(editAction:);
            break;
        case ToolbarActionTypeFavorite:
            title = Localized(@"收藏");
            iconName = @"star";
            action = @selector(favoriteAction:);
            break;
        case ToolbarActionTypeDelete:
            title = Localized(@"删除");
            iconName = @"trash";
            action = @selector(deleteAction:);
            break;
    }
    
    UIImage *icon = [UIImage systemImageNamed:iconName];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:icon
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:action];
    
    // 添加可访问性标签
    button.accessibilityLabel = title;
    
    return button;
}

#pragma mark - Toolbar Actions

- (void)saveAction:(UIBarButtonItem *)sender {
    [GCAlertManager showHUDWithMessage:Localized(@"保存中...")];
    
    // 模拟保存操作
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [GCAlertManager hideHUD];
        self.statusLabel.text = Localized(@"保存成功");
        [GCAlertManager showTemporaryMessage:Localized(@"内容已保存")];
    });
}

- (void)shareAction:(UIBarButtonItem *)sender {
    self.statusLabel.text = Localized(@"准备分享内容");
    
    // 模拟分享弹窗
    [GCAlertManager showTemporaryMessage:Localized(@"打开分享面板")];
}

- (void)editAction:(UIBarButtonItem *)sender {
    // 切换编辑模式
    BOOL isCurrentlyEditing = [self.statusLabel.text isEqualToString:Localized(@"编辑模式")];
    
    if (isCurrentlyEditing) {
        self.statusLabel.text = Localized(@"退出编辑模式");
        self.toolbar.tintColor = [UIColor systemBlueColor];
    } else {
        self.statusLabel.text = Localized(@"编辑模式");
        self.toolbar.tintColor = [UIColor systemOrangeColor];
    }
    
    [GCAlertManager showTemporaryMessage:isCurrentlyEditing ? Localized(@"已退出编辑") : Localized(@"进入编辑模式")];
}

- (void)favoriteAction:(UIBarButtonItem *)sender {
    static BOOL isFavorited = NO;
    isFavorited = !isFavorited;
    
    // 更新按钮外观
    NSString *iconName = isFavorited ? @"star.fill" : @"star";
    sender.image = [UIImage systemImageNamed:iconName];
    
    self.statusLabel.text = isFavorited ? Localized(@"已收藏") : Localized(@"取消收藏");
    
    UIColor *color = isFavorited ? [UIColor systemYellowColor] : [UIColor systemBlueColor];
    [UIView animateWithDuration:0.3 animations:^{
        sender.tintColor = color;
    }];
}

- (void)deleteAction:(UIBarButtonItem *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:Localized(@"确认删除")
                                                                   message:Localized(@"此操作不可撤销")
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:Localized(@"删除")
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction * _Nonnull action) {
        [self performDelete];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:Localized(@"取消")
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    
    // 为 iPad 设置弹出位置
    if ([alert respondsToSelector:@selector(popoverPresentationController)]) {
        alert.popoverPresentationController.barButtonItem = sender;
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)performDelete {
    [GCAlertManager showHUDWithMessage:Localized(@"删除中...")];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [GCAlertManager hideHUD];
        self.statusLabel.text = Localized(@"内容已删除");
        [GCAlertManager showTemporaryMessage:Localized(@"删除成功")];
        
        // 禁用工具栏按钮
        for (UIBarButtonItem *item in self.toolbar.items) {
            item.enabled = NO;
        }
    });
}



@end
