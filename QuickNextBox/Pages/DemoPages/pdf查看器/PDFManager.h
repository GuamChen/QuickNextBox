//
//  LR126RCX.h
//  QuickNextBox
//
//  Created by lgc on 2025/11/12.
//


// LR126RCX_PDFManager.h
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDFManager : NSObject

+ (instancetype)sharedManager;

// 生成PDF文件
- (BOOL)makeAIPDF:(NSString *)filePath
          logoImg:(UIImage *)logoImg
        chatItems:(NSArray<NSDictionary *> *)chatItems
          bgImage:(UIImage *)img_bg
        titleText:(NSString *)titleText;

// 获取PDF文件路径
- (NSString *)getPDFFilePath:(NSString *)fileName;

// 删除PDF文件
- (BOOL)deletePDFFile:(NSString *)filePath;

// 检查PDF文件是否存在
- (BOOL)pdfFileExists:(NSString *)filePath;

// 获取PDF文档
- (NSData *)getPDFDataFromFile:(NSString *)filePath;

@end

NS_ASSUME_NONNULL_END
