#import "DiscoverVC.h"
#import "DemoItem.h"
#import <Masonry/Masonry.h>

#pragma mark - 自定义表格单元格实现
// 自定义表格单元格
@interface DemoCell : UITableViewCell
@property (nonatomic, strong) DemoItem *demoItem;
- (void)configureWithDemoItem:(DemoItem *)demoItem;
@end

@interface DiscoverVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<DemoItem *> *demoItems;
@property (nonatomic, strong) NSDictionary *categorizedDemos;
@property (nonatomic, strong) NSArray *categories;

@end

@implementation DiscoverVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB(229, 232, 232);
    self.title = Localized(@"学习案例");
    
    [self loadDemoConfig];
    [self setupUI];
}

#pragma mark - 加载配置文件

- (void)loadDemoConfig {
    // 从 main bundle 加载 JSON 配置文件
    NSString *configPath = [[NSBundle mainBundle] pathForResource:@"demo_config" ofType:@"json"];
    self.demoItems = @[];
    
    if (!configPath) {
        [GCAlertManager showAlertInView:self WithTitle:@"配置文件错误" message:@"未找到演示案例配置文件，请确保 demo_config.json 已添加到项目中"];
        return;
    }
    
    NSError *error = nil;
    NSData *configData = [NSData dataWithContentsOfFile:configPath options:0 error:&error];
    
    if (error) {
        [GCAlertManager showAlertInView:self WithTitle:@"数据错误" message:@"demo_config.json 数据错误"];
        return;
    }
    
    NSDictionary *configDict = [NSJSONSerialization JSONObjectWithData:configData options:0 error:&error];
    
    if (error) {
        [GCAlertManager showAlertInView:self WithTitle:@"解析错误" message:@"demo_config.json 解析错误"];
        return;
    }
    
    // 创建 DemoItem 对象数组
    NSArray *demoArray = configDict[@"demos"];
    self.demoItems = [DemoItem demoItemsFromJSONArray:demoArray];
    
    
    [self categorizeDemos];
    
}

/// 按分类分组演示项目
- (void)categorizeDemos {
    NSMutableDictionary *categories = [NSMutableDictionary dictionary];
    
    for (DemoItem *item in self.demoItems) {
        NSString *category = item.category ?: @"未分类";
        if (!categories[category]) {
            categories[category] = [NSMutableArray array];
        }
        [categories[category] addObject:item];
    }
    
    // 按分类名称排序
    self.categories = [[categories allKeys] sortedArrayUsingSelector:@selector(compare:)];
    self.categorizedDemos = [categories copy];
}

#pragma mark - UI 设置

- (void)setupUI {
    [self setupHeaderView];
    [self setupTableView];
}

- (void)setupHeaderView {
    
    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = [NSString stringWithFormat:@"%ld 个精选案例，点击查看", self.demoItems.count];
    subtitleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
    subtitleLabel.textAlignment = NSTextAlignmentCenter;
    subtitleLabel.textColor = [UIColor secondaryLabelColor];
    
    [self.view addSubview:subtitleLabel];
    
    [subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(20);
    }];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    [self.tableView registerClass:[DemoCell class] forCellReuseIdentifier:@"DemoCell"];
    
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(40);
        make.left.right.bottom.equalTo(self.view);
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.categories.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *category = self.categories[section];
    return [self.categorizedDemos[category] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DemoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DemoCell" forIndexPath:indexPath];
    
    NSString *category = self.categories[indexPath.section];
    DemoItem *demoItem = self.categorizedDemos[category][indexPath.row];
    
    [cell configureWithDemoItem:demoItem];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.categories[section];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *category = self.categories[indexPath.section];
    DemoItem *demoItem = self.categorizedDemos[category][indexPath.row];
    
    [self navigateToDemoCase:demoItem];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

#pragma mark - 动态导航

/// 动态创建并跳转到案例页面
- (void)navigateToDemoCase:(DemoItem *)demoItem {
    NSLog(@"尝试跳转到: %@", demoItem.className);
    
    // 使用 NSClassFromString 动态获取类
    Class targetClass = NSClassFromString(demoItem.className);
    
    if (!targetClass) {
        [GCAlertManager showAlertInView:self WithTitle:@"类未找到"
                                message:[NSString stringWithFormat:@"%@ 类未在运行时找到\n请确保该类已正确编译到项目中", demoItem.className]];
        return;
    }
    
    // 验证是否是 UIViewController 子类
    if (![targetClass isSubclassOfClass:[UIViewController class]]) {
        [GCAlertManager showAlertInView:self WithTitle:@"无效的视图控制器"
                                message:[NSString stringWithFormat:@"%@ 不是有效的视图控制器", demoItem.className]];
        return;
    }
    
    // 动态创建实例
    UIViewController *targetVC = [[targetClass alloc] init];
    if (!targetVC) {
        [GCAlertManager showAlertInView:self WithTitle:@"创建失败"
                                message:[NSString stringWithFormat:@"无法创建 %@ 的实例", demoItem.className]];
        return;
    }
    
    // 设置标题
    targetVC.title = demoItem.title;
    
    // 导航跳转
    [self navigateToViewController:targetVC];
}

/// 执行导航跳转
- (void)navigateToViewController:(UIViewController *)viewController {
    if (self.navigationController) {
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:viewController];
        navVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:navVC animated:YES completion:nil];
    }
}

@end


@implementation DemoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    // 使用系统默认样式，支持 subtitle
}

- (void)configureWithDemoItem:(DemoItem *)demoItem {
    self.demoItem = demoItem;
    
    // 配置文本
    self.textLabel.text = demoItem.title;
    self.textLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    self.textLabel.textColor = [UIColor labelColor];
    self.textLabel.numberOfLines = 1;
    
    self.detailTextLabel.text = demoItem.itemDescription;
    self.detailTextLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    self.detailTextLabel.textColor = [UIColor secondaryLabelColor];
    self.detailTextLabel.numberOfLines = 2;
    
    // 配置图标（使用 SF Symbols）
    UIImage *iconImage = [UIImage systemImageNamed:demoItem.icon];
    if (!iconImage) {
        iconImage = [UIImage systemImageNamed:@"doc"];
    }
    self.imageView.image = iconImage;
    self.imageView.tintColor = [UIColor systemBlueColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 调整图片大小
    CGSize imageSize = CGSizeMake(32, 32);
    self.imageView.frame = CGRectMake(16, (self.contentView.frame.size.height - imageSize.height) / 2, imageSize.width, imageSize.height);
}

@end
