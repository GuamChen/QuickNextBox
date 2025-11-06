//
//  TestVC.m
//  helloworld
//
//  Created by lgc on 2025/10/12.
//

#import "TestVC.h"
#import "MBHudDemoVC.h"


@interface TestVC ()

@end

@implementation TestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = HEXCOLOR(121212);

    
    
    
    UIButton * mbhub_btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [mbhub_btn setTitle: @"MBHudDemo" forState:UIControlStateNormal];
    
    [self.view addSubview: mbhub_btn];
    [mbhub_btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(200, 50));
    }];
    
    [mbhub_btn addTarget:self action:@selector(GotoMBHudDemoPage) forControlEvents:UIControlEventTouchUpInside];
}



- (void)GotoMBHudDemoPage {
    MBHudDemoVC *vc =  [MBHudDemoVC new];
    
    if (self.navigationController) {
        NSLog(@"NavigationController exists: %@", self.navigationController);
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        NSLog(@"NavigationController is nil!");
        // 尝试 present 方式
        [self presentViewController:vc animated:YES completion:nil];
    }
}

@end
