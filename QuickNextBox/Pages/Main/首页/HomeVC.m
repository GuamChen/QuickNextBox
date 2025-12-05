//
//  HomeVC 2.h
//  helloworld
//
//  Created by lgc on 2025/10/28.


#import "HomeVC.h"



@interface HomeVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *settingsTableView; // 用于显示功能设置
@property (nonatomic, strong) NSMutableArray *settingsData; // 存储设置项数据的数组

@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"首页";
    NSDictionary * p = @{
        @"":@"",
        @"a":@""
    };
    self.settingsData =[ [NSMutableArray alloc] initWithArray:@[
        @{@"title": @"按钮",
          @"class":@"ButtonDisplayVC"
        },
        @{@"title": @"如何做自定义按钮？",
          @"class":@"CustomButtonVC"
        },
        @{@"title": @"Ai批量翻译",
          @"class":@"GCTranslationViewController"
        },

    ]];
    
    [self setupTableView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSIndexPath  *index = [NSIndexPath indexPathForRow:1 inSection:0];
//        [self tableView:self.settingsTableView didSelectRowAtIndexPath:index];
    });
}




- (void)setupTableView {
    
    self.settingsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.settingsTableView.delegate = self;
    self.settingsTableView.dataSource = self;
    self.settingsTableView.separatorColor = [UIColor colorWithRed:30.0/255.0 green:30.0/255.0 blue:30.0/255.0 alpha:1.0];
    [self.settingsTableView setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 24)];
    
    [self.view addSubview:self.settingsTableView];
    [self.settingsTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(40);
        make.left.right.bottom.equalTo(self.view).inset(0);
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.settingsData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"BasicCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        // 使用 UITableViewCellStyleSubtitle 可以显示标题和副标题
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault; // 禁止选中效果
        cell.backgroundColor = [UIColor clearColor]; // 单元格背景透明
        
        // 添加圆角和阴影
        cell.contentView.layer.cornerRadius = 10;
        cell.contentView.layer.masksToBounds = YES;
        cell.contentView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1]; // 半透明背景
        
        cell.layer.shadowColor = [UIColor blackColor].CGColor;
        cell.layer.shadowOffset = CGSizeMake(0, 2);
        cell.layer.shadowOpacity = 0.2;
        cell.layer.shadowRadius = 4;
        cell.layer.masksToBounds = NO;
    }
    
    NSDictionary *info = self.settingsData[indexPath.row];
    cell.textLabel.text = info[@"title"];
    cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    cell.textLabel.textColor = [UIColor systemBlueColor];
    

    
    // 可以加一个右箭头
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}



#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary* info = self.settingsData[indexPath.row];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Class cla = NSClassFromString( [info valueForKey:@"class"]);
    
    UIViewController *vc = [[cla alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

// 设置行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.settingsTableView) {
        return 60;
    }
    return 0;
}
@end
