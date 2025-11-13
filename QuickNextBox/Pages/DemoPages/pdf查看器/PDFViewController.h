//
//  LR126RCX 2.h
//  QuickNextBox
//
//  Created by lgc on 2025/11/12.
//


// LR126RCX_PDFViewController.h
#import <UIKit/UIKit.h>
#import <PDFKit/PDFKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDFViewController : UIViewController

@property (nonatomic, strong) NSString *pdfFilePath;
@property (nonatomic, strong) NSString *pdfTitle;
@property (nonatomic, assign) BOOL shouldDeleteOnBack; // 返回时是否删除文件

@end

NS_ASSUME_NONNULL_END
