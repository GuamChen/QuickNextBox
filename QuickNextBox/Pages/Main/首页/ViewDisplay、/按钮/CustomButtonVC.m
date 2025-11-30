//
//  CustomButtonVC.m
//  QuickNextBox
//
//  Created by lgc on 2025/11/30.
//

#import "CustomButtonVC.h"
#import "ButtonDisplayVC.h"
#import "CustomButton.h"

@interface CustomButtonVC ()

@end

@implementation CustomButtonVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    /**
     默认按钮图片难用。
     1、设置图片后不能调节大小！举例，我给按钮设置 200*200的图片，按钮大小也是200*200，结果图片就占据整个按钮了，文本直接不见了。
     2、默认的图片文本是水平对齐的。 我不知道如何自定义的调整图片的位置、文本位置。比如图文上下对齐，图片在左上角、文字居中。
     3、看了源码有UIButtonType 和UIButtonRole ，不理解含义
     4、UIButtonConfiguration是什么？
     5、btn3 我直接改按钮的约束也没有效果哦，图片宽度变成50了，但是高度还是200，很奇怪。
     
     */
    
    /*
     简单的就用系统的，否者用自定义的
     */
    
    CustomButton * btn = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 180, 44) LayoutStyle:CVButtonLayoutStyleImageLeft];
    [btn setImage:[UIImage imageNamed:@"jixiaomubiao"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"helanzhu"] forState:UIControlStateHighlighted];
    [btn setTitle:@"jixiaomubiao" forState:UIControlStateNormal];
    [btn setTitle:@"helanzhu" forState:UIControlStateHighlighted];
    [self.view addSubview: btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(200, 40));
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(40);
    }];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
