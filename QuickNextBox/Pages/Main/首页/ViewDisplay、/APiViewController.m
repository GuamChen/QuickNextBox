//
//  APiViewController.m
//  QuickNextBox
//
//  Created by lgc on 2025/12/15.
//

#import "APiViewController.h"
#import "GCFileSizeFormatter.h"

@interface APiViewController ()

@end

@implementation APiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     
    NSString *file = [[NSBundle mainBundle] pathForResource:@"草稿纸" ofType:@"txt"];
    NSString *cont = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    long long bytes = 1024*1024*1024;
    
//    NSString *text = [NSByteCountFormatter stringFromByteCount:bytes
//                                                    countStyle:NSByteCountFormatterCountStyleFile];

    NSString *text = [GCFileSizeFormatter fileSizeStringFromBytes:bytes];

    NSString *memory = [GCFileSizeFormatter memorySizeStringFromBytes:bytes];
    
    NSString *binary =
    [GCFileSizeFormatter binarySizeStringFromBytes:bytes];

    NSString *fixed =
    [GCFileSizeFormatter fileSizeStringFromBytes:bytes decimalPlaces:2];


    NSLog(@"%@", text); 

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
