//
//  LR126RCX.m
//  QuickNextBox
//
//  Created by lgc on 2025/11/12.
//


// LR126RCX_PDFManager.m
#import "PDFManager.h"

@implementation PDFManager

+ (instancetype)sharedManager {
    static PDFManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}



- (NSString *)getPDFFilePath:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths firstObject];
    NSString *pdfDirectory = [documentsPath stringByAppendingPathComponent:@"PDFFiles"];
    
    // 创建PDF目录
    if (![[NSFileManager defaultManager] fileExistsAtPath:pdfDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:pdfDirectory 
                                  withIntermediateDirectories:YES 
                                                   attributes:nil 
                                                        error:nil];
    }
    
    return [pdfDirectory stringByAppendingPathComponent:fileName];
}

- (BOOL)deletePDFFile:(NSString *)filePath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    return YES;
}

- (BOOL)pdfFileExists:(NSString *)filePath {
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

- (NSData *)getPDFDataFromFile:(NSString *)filePath {
    return [NSData dataWithContentsOfFile:filePath];
}

- (NSString *)getCurrentTimestamp {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd_HHmmss"];
    return [formatter stringFromDate:[NSDate date]];
}

/*
 // 生成文件名
 NSString *fileName = [NSString stringWithFormat:@"%@_%@.pdf", title, [self getCurrentTimestamp]];
 NSString *filePath = [self getPDFFilePath:fileName];
 
 // 先删除已存在的文件
 [self deletePDFFile:filePath];
 */
#pragma mark - AI 对话分享 PDF（带分页与文本分段）
- (BOOL)makeAIPDF:(NSString *)filePath
          logoImg:(UIImage *)logoImg
        chatItems:(NSArray<NSDictionary *> *)chatItems
          bgImage:(UIImage *)img_bg
        titleText:(NSString *)titleText {
    
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    
    CGSize pageSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
    CGFloat pageTopMargin = 20;
    CGFloat pageBottomMargin = 20;
    CGFloat pageLeftMargin = 20;
    CGFloat pageRightMargin = 20;
    CGFloat contentWidth = pageSize.width - pageLeftMargin - pageRightMargin;
    CGFloat contentMaxHeight = pageSize.height - pageTopMargin - pageBottomMargin;
    CGFloat gap = 12;
    CGFloat tolerance = 20.0; // 你允许的微小高度变化
    
    BOOL createFile = UIGraphicsBeginPDFContextToFile(filePath, CGRectZero, nil);
    if (!createFile) return NO;
    
    __block CGFloat y_current = pageTopMargin;
    
    // 字体与段落样式
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineSpacing = 4;
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary *baseTextAttributes = @{
        NSFontAttributeName: [UIFont systemFontOfSize:16],
        NSParagraphStyleAttributeName: paragraph,
        NSForegroundColorAttributeName: UIColor.blackColor
    };
    
    // Helper: 新开一页（会重绘背景），并把 y_current 设置为内容起点
    void (^startNewPage)(void) = ^{
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pageSize.width, pageSize.height), nil);
        if (img_bg) {
            // 背景始终绘制在页顶
            [img_bg drawInRect:CGRectMake(0, 0, pageSize.width, pageSize.width * img_bg.size.height / img_bg.size.width)];
        }
        // 在新页开头保留顶部边距
        y_current = pageTopMargin;
        
        // 在页头绘制 logo 与 title（可自定义是否每页都显示）
        if (logoImg) {
            CGFloat h_logo = 40;
            CGFloat w_logo = h_logo * (logoImg.size.width / logoImg.size.height);
            CGRect rectLogo = CGRectMake(pageLeftMargin, y_current, w_logo, h_logo);
            [logoImg drawInRect:rectLogo];
            y_current = CGRectGetMaxY(rectLogo) + gap;
        }
        if (titleText.length) {
            NSDictionary *attTitle = @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:20], NSForegroundColorAttributeName: UIColor.blackColor };
            CGSize titleSize = [titleText boundingRectWithSize:CGSizeMake(contentWidth, CGFLOAT_MAX)
                                                       options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                    attributes:attTitle context:nil].size;
            CGRect rectTitle = CGRectMake(pageLeftMargin, y_current, titleSize.width, titleSize.height);
            [titleText drawInRect:rectTitle withAttributes:attTitle];
            y_current = CGRectGetMaxY(rectTitle) + gap/2.0;
        }
        
        // 绘制时间戳（页头或仅在第一页显示；这里在每页显示）
        NSString *timeStr = [NSString stringWithFormat:@"生成时间：%@", [NSDate.date descriptionWithLocale:[NSLocale currentLocale]]];
        NSDictionary *attTime = @{ NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: UIColor.grayColor };
        CGSize timeSize = [timeStr boundingRectWithSize:CGSizeMake(contentWidth, CGFLOAT_MAX)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:attTime context:nil].size;
        CGRect rectTime = CGRectMake(pageLeftMargin, y_current, timeSize.width, timeSize.height);
        [timeStr drawInRect:rectTime withAttributes:attTime];
        y_current = CGRectGetMaxY(rectTime) + gap;
    };
    
    // Helper: 获取剩余可用高度
    __block CGFloat (^remainingHeight)(void) = ^CGFloat{
        return pageSize.height - pageBottomMargin - y_current;
    };
    
    // Helper: 将普通字符串转换为处理加粗 **text** 的 attributedString（与 cell 保持一致）
    NSAttributedString* (^attributedStringFromPlainText)(NSString *) = ^NSAttributedString* (NSString *plain) {
        if (!plain) plain = @"";
        NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
        ps.lineSpacing = paragraph.lineSpacing;
        ps.lineBreakMode = paragraph.lineBreakMode;
        NSMutableDictionary *attrs = [@{ NSFontAttributeName: [UIFont systemFontOfSize:16], NSParagraphStyleAttributeName: ps, NSForegroundColorAttributeName: UIColor.blackColor } mutableCopy];
        NSMutableAttributedString *mas = [[NSMutableAttributedString alloc] initWithString:plain attributes:attrs];
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\*\\*(.*?)\\*\\*" options:0 error:&error];
        if (!error && plain.length) {
            NSArray<NSTextCheckingResult*> *matches = [regex matchesInString:plain options:0 range:NSMakeRange(0, plain.length)];
            // 反向遍历以便安全删除 **
            for (NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {
                NSRange inner = [match rangeAtIndex:1];
                if (inner.location != NSNotFound && inner.length > 0) {
                    [mas addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:inner];
                    // 删除两端的 ** 标记（先删除后面的）
                    NSRange rangeAfter = NSMakeRange(match.range.location + inner.length + 2, 2);
                    if (NSMaxRange(rangeAfter) <= mas.length) [mas replaceCharactersInRange:rangeAfter withString:@""];
                    NSRange rangeBefore = NSMakeRange(match.range.location, 2);
                    if (NSMaxRange(rangeBefore) <= mas.length) [mas replaceCharactersInRange:rangeBefore withString:@""];
                }
            }
        }
        return mas;
    };
    
    // Helper: 通过二分法找到 attrStr 在指定宽度与高度内能容纳的最大字符数（返回 NSRange.location=0, length=fitLength）
    NSRange (^fittingRangeForAttributedStringWithMaxHeight)(NSAttributedString*, CGFloat, CGFloat) = ^NSRange (NSAttributedString *attrStr, CGFloat maxWidth, CGFloat maxHeight) {
        if (!attrStr || attrStr.length == 0) return NSMakeRange(0, 0);
        NSInteger lo = 0;
        NSInteger hi = attrStr.length;
        NSInteger best = 0;
        while (lo <= hi) {
            NSInteger mid = (lo + hi) / 2;
            NSAttributedString *sub = [attrStr attributedSubstringFromRange:NSMakeRange(0, mid)];
            CGRect r = [sub boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                         context:nil];
            if (r.size.height <= maxHeight) {
                best = mid;
                lo = mid + 1;
            } else {
                hi = mid - 1;
            }
        }
        return NSMakeRange(0, best);
    };
    
    // 开始第一页
    startNewPage();
    
    // 遍历每个消息，逐个绘制（文本与图片）
    for (NSDictionary *msg in chatItems) {
        // 每次循环开始，先检查剩余空间是否太窄（比如 < 60），如果太窄就开新页
        if (remainingHeight() < 60) {
            startNewPage();
        }
        
        // 绘制角色标签（用户/AI）
        NSString *roleText = ([msg[@"messageType"]  isEqual: @"user"]) ? @"用户：" : @"AI：";
        NSDictionary *attRole = @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:15],
                                   NSForegroundColorAttributeName: ([msg[@"messageType"]  isEqual: @"user"] ? UIColor.systemBlueColor : UIColor.systemGreenColor) };
        CGSize roleSize = [roleText boundingRectWithSize:CGSizeMake(contentWidth, CGFLOAT_MAX)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:attRole context:nil].size;
        // 如果标签高度就已经导致溢出，则新页
        if (roleSize.height > remainingHeight() - tolerance) {
            startNewPage();
        }
        CGRect roleRect = CGRectMake(pageLeftMargin, y_current, roleSize.width, roleSize.height);
        [roleText drawInRect:roleRect withAttributes:attRole];
        CGFloat textStartX = pageLeftMargin + roleSize.width + 6;
        CGFloat textAvailWidth = pageSize.width - textStartX - pageRightMargin;
        
        y_current = CGRectGetMaxY(roleRect); // 文本从下一行开始更稳妥（也可以同一行）
        y_current += 4;
        
        // ---------- 文本处理（可能分段分页） ----------
        NSAttributedString *attrContent = attributedStringFromPlainText(msg[@"content"]);
        NSInteger remainingLocation = 0;
        while (remainingLocation < attrContent.length) {
            // 计算剩余可放高度
            CGFloat availH = remainingHeight();
            if (availH < 60) {
                startNewPage();
                availH = remainingHeight();
            }
            
            // 测量剩余全部文本高度
            NSAttributedString *subAll = [attrContent attributedSubstringFromRange:NSMakeRange(remainingLocation, attrContent.length - remainingLocation)];
            CGRect allRect = [subAll boundingRectWithSize:CGSizeMake(textAvailWidth, CGFLOAT_MAX)
                                                  options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                  context:nil];
            if (allRect.size.height <= availH + tolerance) {
                // 整段文本可以完全放下，直接绘制并退出循环
                CGRect drawRect = CGRectMake(textStartX, y_current, textAvailWidth, ceil(allRect.size.height));
                [subAll drawInRect:drawRect];
                y_current = CGRectGetMaxY(drawRect) + gap;
                remainingLocation = attrContent.length; // 完成
            } else {
                // 整段放不下，尝试找到当前页能放下的子长度
                NSRange fitRange = fittingRangeForAttributedStringWithMaxHeight(subAll, textAvailWidth, availH - 4.0); // 留点余量
                if (fitRange.length == 0) {
                    // 当前页几乎没空间放文本，直接分页再试
                    startNewPage();
                    // 注意：如果新页仍然 fitRange.length == 0，说明单行最大高度可能比整页可用高度还大（罕见），为了保险直接把一小段文字放入（比如 200 字）以避免死循环
                    // 取一个保守的最小写入量（200 或剩余长度）
                    NSInteger fallbackLen = MIN(200, subAll.length);
                    NSAttributedString *fallbackSub = [subAll attributedSubstringFromRange:NSMakeRange(0, fallbackLen)];
                    CGRect fallbackRect = [fallbackSub boundingRectWithSize:CGSizeMake(textAvailWidth, CGFLOAT_MAX)
                                                                    options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil];
                    CGRect drawRect = CGRectMake(textStartX, y_current, textAvailWidth, ceil(fallbackRect.size.height));
                    [fallbackSub drawInRect:drawRect];
                    y_current = CGRectGetMaxY(drawRect) + gap;
                    remainingLocation += fallbackLen;
                } else {
                    // 绘制 fitRange 长度的子串
                    NSAttributedString *toDraw = [subAll attributedSubstringFromRange:fitRange];
                    CGRect drawRect = [toDraw boundingRectWithSize:CGSizeMake(textAvailWidth, CGFLOAT_MAX)
                                                           options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                           context:nil];
                    CGRect actualRect = CGRectMake(textStartX, y_current, textAvailWidth, ceil(drawRect.size.height));
                    [toDraw drawInRect:actualRect];
                    y_current = CGRectGetMaxY(actualRect) + gap;
                    remainingLocation += fitRange.length;
                    
                    // 新页准备（如果仍有剩余文本）
                    if (remainingLocation < attrContent.length) {
                        startNewPage();
                    }
                }
            }
        } // end while text segments
        
        // ---------- 图片处理 ----------
        if (msg[@"image"]) {
            // 先按内容宽度缩放图片
            UIImage * img = [UIImage imageNamed:msg[@"image"]];
            CGFloat imgMaxWidth = contentWidth;
            CGFloat imgW = MIN(img.size.width, imgMaxWidth);
            CGFloat scale = imgW / img.size.width;
            CGFloat imgH = img.size.height * scale;
            
            // 若图片高度超过整页可用高度，进一步缩放到整页可用高度
            if (imgH > contentMaxHeight - 40) {
                CGFloat scale2 = (contentMaxHeight - 40) / imgH;
                imgH = imgH * scale2;
                imgW = imgW * scale2;
            }
            
            // 若当前剩余空间不足以放下图片（带容忍度），则分页
            if (imgH > remainingHeight() - tolerance) {
                startNewPage();
            }
            
            // 最后如果图片仍超过剩余空间（理论上不会），再新页强制绘制
            if (imgH > remainingHeight() - tolerance) {
                startNewPage();
            }
            
            CGRect imgRect = CGRectMake(pageLeftMargin, y_current, imgW, imgH);
            [img drawInRect:imgRect];
            y_current = CGRectGetMaxY(imgRect) + gap;
        }
    } // end for each message
    
    UIGraphicsEndPDFContext();
    return createFile;
}

@end
