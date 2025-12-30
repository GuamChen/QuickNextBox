//
//  DSKChatViewModel.m
//  QuickNextBox
//
//  Created by lgc on 2025/12/4.
//

#import "DSKChatViewModel.h"
#import "DouBaoAPIManager.h"

@interface DSKChatViewModel ()

@property (nonatomic, strong) NSMutableArray<DSKChatMessage *> *mutableMessages;

@end

@implementation DSKChatViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _mutableMessages = [NSMutableArray array];
        
    }
    return self;
}

- (NSArray<DSKChatMessage *> *)messages {
    return [_mutableMessages copy];
}


- (void)uploadImage:(UIImage *)image withMessage:(NSString *)message completion:(void(^)(NSString *response, NSError *error))completion {
    
    NSString *combinedMessage = message ?: Localized(@"帮我分析这张热成像图片");
    DSKChatMessage *userMessage = [[DSKChatMessage alloc] initWithContent:combinedMessage messageType:DSKMessageTypeUser];
    userMessage.image = image;
    
    
    [self willChangeValueForKey:@"messages"];
    [self.mutableMessages addObject:userMessage];
    
    // 先添加一个空的bot消息用于流式更新
    DSKChatMessage *botMessage = [[DSKChatMessage alloc] initWithContent:@"" messageType:DSKMessageTypeBot];
    [self.mutableMessages addObject:botMessage];
    [self didChangeValueForKey:@"messages"];
    
    BOOL AIType = YES;
    if( AIType ) {
        
        [[DouBaoAPIManager sharedManager] uploadImage: image withMessage: message streamHandler:^(DSKChatStreamResultType type, NSString *content, NSError *error) {
            [self handleHttpBlock:type content:content error:error];
            completion(@"", error);
        }];
        
    }else {
        
    }
    
}


-(void)handleHttpBlock:(DSKChatStreamResultType) type content: (NSString *)content error:(NSError *)error {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger botMessageIndex = self.mutableMessages.count - 1;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (type == DSKChatStreamResultContent) {
            
            // 流式更新内容 - 临时显示效果，简单去除markdown
            [weakSelf willChangeValueForKey:@"messages"];
            DSKChatMessage *currentBotMessage = weakSelf.mutableMessages[botMessageIndex];
            NSString *content_str = [currentBotMessage.content stringByAppendingString:content];
            
            // 流式处理：简单过滤markdown符号
            currentBotMessage.content = [weakSelf filterMarkdownForStreaming:content_str];
            
            [weakSelf didChangeValueForKey:@"messages"];
            
        } else if (type == DSKChatStreamResultFinished) {
            NSLog(@"流式接收完成processedContent： \n%@", content);
            
            [weakSelf willChangeValueForKey:@"messages"];
            DSKChatMessage *currentBotMessage = weakSelf.mutableMessages[botMessageIndex];
            // 完整处理：应用完整的markdown处理和符号转换
            NSString *processedContent = [weakSelf processCompleteResponse:content];
            currentBotMessage.content = processedContent;
            [weakSelf didChangeValueForKey:@"messages"];
            
            currentBotMessage.content = processedContent;
            
            [weakSelf didChangeValueForKey:@"messages"];
            
        } else if (type == DSKChatStreamResultError) {
            weakSelf.lastError = error;
            [weakSelf willChangeValueForKey:@"messages"];
            DSKChatMessage *currentBotMessage = weakSelf.mutableMessages[botMessageIndex];
            currentBotMessage.content = Localized(@"请求失败，请重试");
            [weakSelf didChangeValueForKey:@"messages"];
        }
    });
}




#pragma mark - 流式处理（临时显示）
// 流式处理：简单去除markdown语法，用于临时显示
- (NSString *)filterMarkdownForStreaming:(NSString *)text {
    if (text.length == 0) return text;
    
    NSMutableString *cleanText = [text mutableCopy];
    
    [self filterOtherMarkdown:cleanText];
    
    // 过滤标题 # ## ###
    NSRegularExpression *headerRegex = [NSRegularExpression regularExpressionWithPattern:@"^#{1,6}\\s*" options:NSRegularExpressionAnchorsMatchLines error:nil];
    [headerRegex replaceMatchesInString:cleanText options:0 range:NSMakeRange(0, cleanText.length) withTemplate:@""];
    
    return [cleanText copy];
}

#pragma mark - 完整处理
// 完整处理：对完整回复进行详细处理
- (NSString *)processCompleteResponse:(NSString *)text {
    if (text.length == 0) return text;
    
    NSMutableString *processedText = [text mutableCopy];
    
    // 1. 处理特殊符号（摄氏度等）
    [self processSpecialSymbols:processedText];
    
    // 3. 过滤其他markdown符号
    [self filterOtherMarkdown:processedText];
    
    // 2. 处理标题格式转换
    [self processHeaders:processedText];
    
    return [processedText copy];
}

// 处理特殊符号（摄氏度等）
- (void)processSpecialSymbols:(NSMutableString *)text {
    // 摄氏度符号处理
    NSDictionary *symbolReplacements = @{
        @"\\|circ\\|text\\{C\\}\\\"": @"℃",
        @"\\^\\|circ\\|text\\{C\\}\\\"": @"℃",
        @"\\|circ\\|text\\{C\\}": @"℃",
        @"\\^\\|circ\\|text\\{C\\}": @"℃",
        @"°C": @"℃",
        @"&deg;C": @"℃",
        @"\\u00b0C": @"℃",
        @"度C": @"℃",
        @"度 C": @"℃",
        // 可以添加其他类似符号的处理
        @"\\|circ\\|text\\{F\\}": @"℉",
        @"\\^\\|circ\\|text\\{F\\}": @"℉",
        @"°F": @"℉"
    };
    
    for (NSString *pattern in symbolReplacements.allKeys) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
        NSString *replacement = symbolReplacements[pattern];
        [regex replaceMatchesInString:text options:0 range:NSMakeRange(0, text.length) withTemplate:replacement];
    }
}

// 处理标题格式转换
- (void)processHeaders:(NSMutableString *)text {
    // 处理 ### 三级标题 和 #### 四级标题，转换为 **标题**
    NSRegularExpression *headerRegex = [NSRegularExpression regularExpressionWithPattern:@"^(#{3,4})\\s+(.+)$" options:NSRegularExpressionAnchorsMatchLines error:nil];
    
    NSMutableArray *headerMatches = [NSMutableArray array];
    [headerRegex enumerateMatchesInString:text options:0 range:NSMakeRange(0, text.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        if (result.numberOfRanges >= 3) {
            NSRange headerRange = [result rangeAtIndex:0];
            NSRange headerContentRange = [result rangeAtIndex:2];
            NSString *headerContent = [text substringWithRange:headerContentRange];
            [headerMatches addObject:@{@"range": [NSValue valueWithRange:headerRange], @"content": headerContent}];
        }
    }];
    
    // 反向替换，避免range变化问题
    for (NSDictionary *match in [headerMatches reverseObjectEnumerator]) {
        NSRange range = [match[@"range"] rangeValue];
        NSString *headerContent = match[@"content"];
        NSString *boldHeader = [NSString stringWithFormat:@"**%@**", headerContent];
        [text replaceCharactersInRange:range withString:boldHeader];
    }
}

// 过滤其他markdown符号
- (void)filterOtherMarkdown:(NSMutableString *)text {
    // 过滤加粗 **text** 或 __text__
    NSRegularExpression *boldRegex = [NSRegularExpression regularExpressionWithPattern:@"\\*\\*(.*?)\\*\\*|__(.*?)__" options:0 error:nil];
    [boldRegex replaceMatchesInString:text options:0 range:NSMakeRange(0, text.length) withTemplate:@"$1$2"];
    
    // 过滤斜体 *text* 或 _text_
    NSRegularExpression *italicRegex = [NSRegularExpression regularExpressionWithPattern:@"\\*(.*?)\\*|_(.*?)_" options:0 error:nil];
    [italicRegex replaceMatchesInString:text options:0 range:NSMakeRange(0, text.length) withTemplate:@"$1$2"];
    
    // 过滤删除线 ~~text~~
    NSRegularExpression *strikeRegex = [NSRegularExpression regularExpressionWithPattern:@"~~(.*?)~~" options:0 error:nil];
    [strikeRegex replaceMatchesInString:text options:0 range:NSMakeRange(0, text.length) withTemplate:@"$1"];
    
    // 过滤代码 `code`
    NSRegularExpression *inlineCodeRegex = [NSRegularExpression regularExpressionWithPattern:@"`(.*?)`" options:0 error:nil];
    [inlineCodeRegex replaceMatchesInString:text options:0 range:NSMakeRange(0, text.length) withTemplate:@"$1"];
    
    // 过滤链接 [text](url)
    NSRegularExpression *linkRegex = [NSRegularExpression regularExpressionWithPattern:@"\\[(.*?)\\]\\(.*?\\)" options:0 error:nil];
    [linkRegex replaceMatchesInString:text options:0 range:NSMakeRange(0, text.length) withTemplate:@"$1"];
    
    // 过滤列表标记
    NSRegularExpression *listRegex = [NSRegularExpression regularExpressionWithPattern:@"^[\\s]*[-*+]\\s*" options:NSRegularExpressionAnchorsMatchLines error:nil];
    [listRegex replaceMatchesInString:text options:0 range:NSMakeRange(0, text.length) withTemplate:@" "];
}

@end
