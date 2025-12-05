//
//  GCTranslationViewController.m
//  QuickNextBox
//
//  Created by lgc on 2025/12/4.
//

#import "GCTranslationViewController.h"
#import "DouBaoAPIManager.h"

@interface GCTranslationViewController ()

@end

@implementation GCTranslationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
     NSString *source = [[NSBundle mainBundle] pathForResource:@"Localizable" ofType:@"strings" inDirectory:nil];
     [[DouBaoAPIManager sharedManager] translateLocalizableAtPath:source batchSize:10 completion:^(BOOL success, NSDictionary<NSString *,NSString *> *errorsByLang) {
          if (success) {
              NSLog(@"全部语言翻译并写入完成");
          } else {
              NSLog(@"部分语言失败：%@", errorsByLang);
          }
     }];
}

#pragma mark - 使用示例（可在调用处调用）
//
// 在 UI 层或 elsewhere 调用：

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
