//
//  DeviceListViewController.m
//  QuickNextBox
//
//  Created by lgc on 2025/12/30.
//

#import "DeviceListViewController.h"
#import "DeviceUnaddedCell.h"
#import "AddedDeviceCell.h"

@interface DeviceListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL didSelectDevice;

@end

@implementation DeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Devices";
    self.view.backgroundColor = [UIColor whiteColor];
    self.didSelectDevice = NO;
    [self setupTableView];
}

#pragma mark - UI

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                                  style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    
    
    [self.tableView registerClass:[DeviceUnaddedCell class]
           forCellReuseIdentifier:@"UnAddedDeviceCell"];
    [self.tableView registerClass:[AddedDeviceCell class]
           forCellReuseIdentifier:@"AddedDeviceCell"];

    
    [self.view addSubview:self.tableView];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.didSelectDevice ? 3 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

#pragma mark - Header

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (!self.didSelectDevice) {
        return section == 0 ? 160 : 0;
    }
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (!self.didSelectDevice) {
        // Header1 - Searching
        UIView *header = [[UIView alloc] init];
        
        UIActivityIndicatorView *indicator =
        [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        indicator.center = CGPointMake(self.view.bounds.size.width / 2, 60);
        [indicator startAnimating];
        [header addSubview:indicator];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 20)];
        label.text = @"正在查找设备...";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor grayColor];
        [header addSubview:label];
        
        return header;
    }
    
    UIView *header = [[UIView alloc] init];
    UILabel *title = [UILabel new];
    title.font = [UIFont boldSystemFontOfSize:16];
    title.textAlignment = NSTextAlignmentCenter;
    if (section == 1) {
        title.text = @"My Devices";
    } else if (section == 2) {
        title.text = @"Connection";
    }
        
    [header addSubview:title];
    return header;
}

#pragma mark - Footer (Spacing)

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 50;
}

#pragma mark - Cell

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.didSelectDevice) {
        DeviceUnaddedCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"UnAddedDeviceCell"];
        [cell configWithName:@"Bluetooth Device"];
        return cell;
    } else {
        AddedDeviceCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"AddedDeviceCell"];
        [cell configWithName:@"Bluetooth Device" connected:YES];
        return cell;
    }
}


#pragma mark - Button Factory

- (UIButton *)capsuleButton:(NSString *)title
                    bgColor:(UIColor *)bgColor
                  textColor:(UIColor *)textColor {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.layer.cornerRadius = 12.5;
    btn.backgroundColor = bgColor;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:textColor forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:13];
    return btn;
}



@end


/*
 设置collectionview或者tableview，动态显示已添加和未添加设备。
 
 未添设备cell1样式：cell高度100，左边图片，居中显示蓝牙设备名称，右侧connect按钮（黑底白字）
 
 已添设备cell2样式：cell高度100，左边图片，中上显示蓝牙设备名称和编辑名称icon按钮，中下显示删除Delete按钮（黑圈白底红字），右下显示连接按钮/已连接按钮，connect按钮（黑底白字）connected按钮（蓝底白字）
 按钮都是胶囊型，高度25.
 
 
 在第一次进入界面时，处于未连接样式，所以显示cell1。需要添加居中header1：旋转菊花和提示词正在查找设备。。。。 header高度 160.
 用户点击设备后，header1不出现。出现header2（My Devices）和 header3（Connection）。header2、3高度44.
 header与cell间隔10，cell间隔10， section间隔50.
 
 为我写出可运行界面。
 */
