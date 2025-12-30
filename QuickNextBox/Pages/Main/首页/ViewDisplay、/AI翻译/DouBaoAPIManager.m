//
//  DouBaoAPIManager.m
//  QuickNextBox
//
//  Created by lgc on 2025/12/4.
//


#import "DouBaoAPIManager.h"


@interface DouBaoAPIManager ()

@end

@implementation DouBaoAPIManager {
    NSURLSession *_session;
    NSString *_apiBaseURL;
    NSMutableDictionary *_streamTasks; // 管理进行中的流式任务
    NSMutableDictionary *_streamHandlers;
    NSMutableDictionary *_accumulatedContents;
    NSMutableDictionary *_requestContexts; // 新增：存储请求上下文
}


+ (instancetype)sharedManager {
    static DouBaoAPIManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        _apiBaseURL = @"https://ark.cn-beijing.volces.com";
        self.is_thinking = NO;
        
        _streamTasks = [NSMutableDictionary dictionary];
        _streamHandlers = [NSMutableDictionary dictionary];
        _accumulatedContents = [NSMutableDictionary dictionary];
        _requestContexts = [NSMutableDictionary dictionary]; // 初始化请求上下文存储
        
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    }
    return self;
}


- (NSDictionary *)buildTextRequestBody:(NSString *)msg {
    
    NSString *formattedPrompt = @"你是一个语言翻译专家。 现在为ios 软件语言做翻译适配。翻译格式比较特殊。 ios语言适配文件Localizable.strings。需要翻译英语、繁体中文、日语、Dutch语、法语、德语、西班牙语、";
    
    return @{
        @"model": @"doubao-1-5-thinking-vision-pro-250428",
        @"messages": @[@{@"role": @"user", @"content": formattedPrompt}],
        @"stream": @YES,
        @"thinking": @{ @"type": self.is_thinking?@"enabled":@"disabled"},
        //        @"tools": [ToolCallExecutor.sharedManager getCallBackToolList], // 添加工具声明
        //        @"tool_choice": @"auto",
    };
}



- (NSDictionary *)buildImageRequestBody:(UIImage *)image message:(NSString *)msg {
    NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
    NSString *base64Image = [imageData base64EncodedStringWithOptions:0];
    
    // 构建格式化的提问内容
    NSString *formattedPrompt = msg;
    
    return @{
        @"model": @"doubao-1-5-thinking-vision-pro-250428",
        @"messages": @[
            @{
                @"role": @"user",
                @"content": @[
                    @{@"type": @"image_url", @"image_url": @{@"url": [NSString stringWithFormat:@"data:image/jpeg;base64,%@", base64Image]}},
                    @{@"type": @"text", @"text": formattedPrompt}
                ],
            }
        ],
        @"stream": @YES,
        @"thinking": @{ @"type": self.is_thinking ? @"enabled" : @"disabled"},
        
    };
}


#pragma mark - 流式接口
- (NSURLSessionDataTask *)uploadImage:(UIImage *)image withMessage:(NSString *)message streamHandler:(DSKChatStreamHandler)handler {
    if(image){
        return [self sendRequestWithType:AiChatRequestTypeImage message:message image:image streamHandler:handler];
    }else {
        return [self sendRequestWithType:AiChatRequestTypeText message:message image:nil streamHandler:handler];
    }
}


- (NSURLSessionDataTask *)sendRequestWithType:(AiChatRequestType)type message:(NSString *)msg image:(UIImage *)image streamHandler:(DSKChatStreamHandler)handler {
    
    NSURL *url = [NSURL URLWithString:[_apiBaseURL stringByAppendingString:@"/api/v3/chat/completions"]];

    NSString *apiKey = @"9b2969e0-003b-4e89-9656-cb262526b856";
    
    NSDictionary *requestBody;
    switch (type) {
        case AiChatRequestTypeText:
            requestBody = [self buildTextRequestBody:msg];
            break;
        case AiChatRequestTypeImage:
            requestBody = [self buildImageRequestBody:image message:msg];
            break;
    }
    
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:requestBody options:0 error:&jsonError];
    if (jsonError) {
        handler(DSKChatStreamResultError, nil, jsonError);
        return nil;
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", apiKey] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    request.HTTPBody = jsonData;
    [self logRequest:request body:jsonData requestBody:requestBody];
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request];
    
    // 保存回调
    _streamHandlers[@(task.taskIdentifier)] = [handler copy];
    _accumulatedContents[@(task.taskIdentifier)] = [NSMutableString string];
    if (requestBody[@"messages"]) {
        _requestContexts[@(task.taskIdentifier)] = requestBody[@"messages"];
    }
    
    [task resume];
    return task;
}


/// URLSession会话结束
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    DSKChatStreamHandler handler = _streamHandlers[@(task.taskIdentifier)];
    NSMutableString *accumulatedContent = _accumulatedContents[@(task.taskIdentifier)];
    
    if (error) {
        handler(DSKChatStreamResultError, nil, error);
    } else {
        handler(DSKChatStreamResultFinished, accumulatedContent, nil);
    }
    
    // 清理
    //    [ToolCallExecutor.sharedManager removelocationManager];
    
    [_streamHandlers removeObjectForKey:@(task.taskIdentifier)];
    [_accumulatedContents removeObjectForKey:@(task.taskIdentifier)];
}


/// URLSession会话内容解析处理
#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
    DSKChatStreamHandler handler = _streamHandlers[@(dataTask.taskIdentifier)];
    NSMutableString *accumulatedContent = _accumulatedContents[@(dataTask.taskIdentifier)];
    
    if (data.length > 0) {
        NSString *chunk = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self processStreamChunk:chunk  dataTask:dataTask accumulatedContent:accumulatedContent handler:handler];
    }
}



- (void)processStreamChunk:(NSString *)chunk dataTask:(NSURLSessionDataTask *)dataTask accumulatedContent:(NSMutableString *)accumulatedContent handler:(DSKChatStreamHandler)handler {
    
    NSArray *lines = [chunk componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    for (NSString *line in lines) {
        if ([line hasPrefix:@"data:"]) {
            NSString *jsonStr = [[line substringFromIndex:5] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            if ([jsonStr isEqualToString:@"[DONE]"]) {
                handler(DSKChatStreamResultFinished, accumulatedContent.copy, nil);
                continue;
            }
            
            NSError *jsonError;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options:0  error:&jsonError];
            
            if (!jsonError) {
                
                NSString *deltaContent = response[@"choices"][0][@"delta"][@"content"];
                NSLog(@"daltacontent : %@", deltaContent);
                if (deltaContent) {
                    [accumulatedContent appendString:deltaContent];
                    handler(DSKChatStreamResultContent, deltaContent, nil);
                }
            }
        }else {
            NSLog(@"no data?什么东西： %@", line);
        }
    }
}



#pragma mark - 辅助方法   新增工具调用相关方法

// 将对象转换为JSON字符串
- (NSString *)jsonStringFromObject:(id)object {
    if (!object) return @"";
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
    
    if (error || !jsonData) {
        NSLog(@"JSON序列化失败: %@", error);
        return @"";
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (void)logRequest:(NSURLRequest *)request body:(NSData *)body requestBody: (NSDictionary*) requestBody{
    NSLog(@"Request URL: %@", request.URL.absoluteString);
    NSLog(@"Request Headers: %@", request.allHTTPHeaderFields);
    NSLog(@"Request requestBody: %@", requestBody);
}








#pragma mark - === 多语言翻译流水线 ===

// 语言数组（可以按需增加/删减）
// 这里使用语言标识仅用于文件夹命名和提示，API 提示里写全名更稳
- (NSArray<NSString *> *)targetLanguages {
    return @[
        @"English",        // 英语
        @"Traditional Chinese", // 繁体中文
        @"Japanese",       // 日语
        @"German",         // 德语
        @"French",         // 法语
        @"Spanish",        // 西班牙语
        @"Dutch"           // 荷兰语（Dutch）
    ];
}

// 1. 从本地读取 Localizable.strings 文件并按行解析 "key" = "value";
- (NSArray<NSString *> *)readLocalizableLinesFromPath:(NSString *)filePath error:(NSError **)outError {
    // 1. 直接用 plist 方式读（最安全）
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    if (!dict || dict.count == 0) {
        if (outError) {
            *outError = [NSError errorWithDomain:@"LocalizableRead"
                                            code:-1
                                        userInfo:@{NSLocalizedDescriptionKey: @"无法读取 Localizable.strings（可能不是有效 plist）"}];
        }
        return nil;
    }
    
    // 2. 按原顺序恢复为 "key" = "value";
    NSMutableArray *lines = [NSMutableArray array];
    
    for (NSString *key in dict.allKeys) {
        NSString *value = dict[key] ?: @"";
        NSString *line = [NSString stringWithFormat:@"\"%@\" = \"%@\";", key, value];
        [lines addObject:line];
    }
    
    return lines.copy;
}

// 2. 将数组按每 batchSize 行切分成多个批次，返回 array< array<NSString *> >
- (NSArray<NSArray<NSString *> *> *)batchesFromLines:(NSArray<NSString *> *)lines batchSize:(NSInteger)batchSize {
    NSMutableArray *batches = [NSMutableArray array];
    NSInteger total = lines.count;
    for (NSInteger i = 0; i < total; i += batchSize) {
        NSRange r = NSMakeRange(i, MIN(batchSize, total - i));
        NSArray *sub = [lines subarrayWithRange:r];
        [batches addObject:sub];
    }
    return batches.copy;
}

// 辅助：把一组 lines 拼接为 prompt 中传给模型的内容（保持格式）
- (NSString *)formattedPromptForLines:(NSArray<NSString *> *)lines language:(NSString *)language {
    NSMutableString *msg = [NSMutableString string];
    [msg appendString:@"你是语言翻译专家。现在为 iOS 软件做多语言适配。输入是 Localizable.strings 的若干行。请只翻译等号右边（value），不要翻译等号左边（key）。返回结果必须保持 Localizable.strings 格式：每行格式为 \"key\" = \"翻译后的 value\";，不要在输出中添加额外标记、解释或注释。\n\n"];
    [msg appendFormat:@"目标语言：%@。\n\n", language];
    [msg appendString:@"下面是要翻译的 10 行（或少于10行）：\n"];
    for (NSString *line in lines) {
        [msg appendFormat:@"%@\n", line];
    }
    [msg appendString:@"\n请直接返回翻译后的多行 Localizable.strings 内容（一行对应一翻译），保持原有的 key 不变。"];
    return msg.copy;
}

// 3. 发起单个批次的翻译请求（非流式），返回翻译文本（多行） via completion
- (void)sendTranslationRequestForLines:(NSArray<NSString *> *)lines
                              language:(NSString *)language
                            completion:(void(^)(NSString *translatedText, NSError *error))completion {
    NSString *urlString = [_apiBaseURL stringByAppendingString:@"/api/v3/chat/completions"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *apiKey = @""; // 还是建议放到安全存储
    
    // 构建 prompt
    NSString *prompt = [self formattedPromptForLines:lines language:language];
    
    // 构建请求 body（非流式，stream: false）
    NSDictionary *message = @{ @"role": @"user", @"content": prompt };
    NSDictionary *body = @{
        @"model": @"doubao-1-5-thinking-vision-pro-250428",
        @"messages": @[message],
        @"stream": @NO,
        @"thinking": @{ @"type": self.is_thinking?@"enabled":@"disabled" }
    };
    
    NSError *jsonErr = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body options:0 error:&jsonErr];
    if (jsonErr) {
        if (completion) completion(nil, jsonErr);
        return;
    }
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    req.HTTPMethod = @"POST";
    [req setValue:[NSString stringWithFormat:@"Bearer %@", apiKey] forHTTPHeaderField:@"Authorization"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    req.HTTPBody = jsonData;
    
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:req
                                             completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (completion) completion(nil, error);
            return;
        }
        if (!data) {
            if (completion) completion(nil, [NSError errorWithDomain:@"DouBaoAPI" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"无响应数据"}]);
            return;
        }
        NSError *parseErr = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseErr];
        if (parseErr || ![json isKindOfClass:[NSDictionary class]]) {
            // 尝试把 data 当作纯文本返回（防止模型直接返回文本）
            NSString *rawText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (rawText && rawText.length > 0) {
                if (completion) completion(rawText, nil);
            } else {
                if (completion) completion(nil, parseErr ?: [NSError errorWithDomain:@"DouBaoAPI" code:-2 userInfo:@{NSLocalizedDescriptionKey: @"解析返回 JSON 失败"}]);
            }
            return;
        }
        // 兼容两种常见返回结构：choices[0].message.content 或 choices[0].text
        NSString *resultText = nil;
        id choices = json[@"choices"];
        if ([choices isKindOfClass:[NSArray class]] && ((NSArray *)choices).count > 0) {
            NSDictionary *first = ((NSArray *)choices)[0];
            // GPT style: message.content
            id message = first[@"message"];
            if ([message isKindOfClass:[NSDictionary class]]) {
                NSString *content = message[@"content"];
                if (content && [content isKindOfClass:[NSString class]]) {
                    resultText = content;
                }
            }
            // older/different: first[@"text"]
            if (!resultText) {
                NSString *text = first[@"text"];
                if (text && [text isKindOfClass:[NSString class]]) {
                    resultText = text;
                }
            }
            // some APIs embed in choices[0].delta.content for streaming — not our case here
        }
        // fallback: json["result"] or json["output"]
        if (!resultText) {
            if ([json[@"result"] isKindOfClass:[NSString class]]) resultText = json[@"result"];
            else if ([json[@"output"] isKindOfClass:[NSString class]]) resultText = json[@"output"];
        }
        if (resultText && completion) {
            completion(resultText, nil);
        } else {
            if (completion) {
                completion(nil, [NSError errorWithDomain:@"DouBaoAPI" code:-3 userInfo:@{NSLocalizedDescriptionKey: @"未在返回中找到翻译文本"}]);
            }
        }
    }];
    [task resume];
}

// 4. 解析 AI 返回的多行翻译文本为 key->value 字典（保留原有格式）
- (NSDictionary<NSString *, NSString *> *)parseTranslatedLines:(NSString *)translatedText {
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    __block NSCharacterSet *trimSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    [translatedText enumerateLinesUsingBlock:^(NSString * _Nonnull line, BOOL * _Nonnull stop) {
        NSString *trim = [line stringByTrimmingCharactersInSet:trimSet];
        if (trim.length == 0) return;
        // 正则匹配 "key" = "value";
        NSError *err = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\s*\"([^\"]+)\"\\s*=\\s*\"([^\"]*)\"\\s*;?\\s*$" options:0 error:&err];
        if (!err) {
            NSTextCheckingResult *m = [regex firstMatchInString:trim options:0 range:NSMakeRange(0, trim.length)];
            if (m && m.numberOfRanges >= 3) {
                NSString *key = [trim substringWithRange:[m rangeAtIndex:1]];
                NSString *val = [trim substringWithRange:[m rangeAtIndex:2]];
                if (key) map[key] = val ? val : @"";
            }
        }
    }];
    return map.copy;
}

// 5. 主流程：把 sourcePath 的每 10 行转成多语言写入沙盒 Documents/translation/<lang>/Localizable.strings
- (void)translateLocalizableAtPath:(NSString *)sourcePath
                         batchSize:(NSInteger)batchSize
                        completion:(void(^)(BOOL success, NSDictionary<NSString*, NSString*> *errorsByLang))completion {
    NSError *err = nil;
    NSArray<NSString *> *lines = [self readLocalizableLinesFromPath:sourcePath error:&err];
    if (!lines) {
        if (completion) completion(NO, @{@"_read_error": err.localizedDescription ?: @"读取失败"});
        return;
    }
    NSArray<NSArray<NSString *> *> *batches = [self batchesFromLines:lines batchSize:batchSize];
    NSArray<NSString *> *languages = [self targetLanguages];
    
    // 准备输出存储：每个语言一个 NSMutableDictionary 用于收集 key->translatedValue
    NSMutableDictionary<NSString*, NSMutableDictionary<NSString*, NSString*>*> *allTranslations = [NSMutableDictionary dictionary];
    for (NSString *lang in languages) {
        allTranslations[lang] = [NSMutableDictionary dictionary];
    }
    // 记录每个语言可能发生的错误
    NSMutableDictionary *errors = [NSMutableDictionary dictionary];
    __block NSInteger totalTasks = batches.count * languages.count;
    __block NSInteger completedTasks = 0;
    dispatch_queue_t finishQueue = dispatch_get_main_queue();
    
    for (NSString *lang in languages) {
        for (NSArray<NSString *> *batch in batches) {
            // 对每个 (lang, batch) 发请求
            [self sendTranslationRequestForLines:batch language:lang completion:^(NSString *translatedText, NSError *error) {
                @synchronized (allTranslations) {
                    if (error || !translatedText) {
                        NSString *errMsg = error.localizedDescription ?: @"无返回";
                        NSMutableArray *arr = errors[lang];
                        if (!arr) { arr = [NSMutableArray array]; errors[lang] = arr; }
                        [arr addObject:errMsg];
                    } else {
                        // 解析返回的多行，得到 key->value
                        NSDictionary *mapped = [self parseTranslatedLines:translatedText];
                        // 如果解析得到为空，尝试逐行对照原 batch 逐个替换 value（更保守）
                        if (mapped.count == 0) {
                            // 尝试解析每行 value（如果返回是只给了翻译值，一行一value）
                            NSArray *returnLines = [translatedText componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                            NSInteger minCount = MIN(returnLines.count, batch.count);
                            for (NSInteger i = 0; i < minCount; i++) {
                                NSString *origLine = batch[i];
                                // 提取 key
                                NSError *regexErr = nil;
                                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\s*\"([^\"]+)\"\\s*=\\s*\"([^\"]*)\"\\s*;?\\s*$" options:0 error:&regexErr];
                                NSTextCheckingResult *m = [regex firstMatchInString:origLine options:0 range:NSMakeRange(0, origLine.length)];
                                if (m && m.numberOfRanges >= 2) {
                                    NSString *key = [origLine substringWithRange:[m rangeAtIndex:1]];
                                    NSString *translatedVal = [returnLines[i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                    // 如果该行看起来仍是 "key" = "val"; 的格式，则再次解析去掉 key
                                    NSRange potentialRange = [translatedVal rangeOfString:@"=\""];
                                    // 直接使用 trimmed line 为 value
                                    if (key) {
                                        allTranslations[lang][key] = translatedVal;
                                    }
                                }
                            }
                        } else {
                            // 合并 mapped 到 allTranslations[lang]
                            NSMutableDictionary *dictForLang = allTranslations[lang];
                            [dictForLang addEntriesFromDictionary:mapped];
                        }
                    }
                    completedTasks++;
                    // 所有任务完成后，写文件
                    if (completedTasks == totalTasks) {
                        // 写入沙盒 Documents/translation/<lang>/Localizable.strings
                        NSFileManager *fm = [NSFileManager defaultManager];
                        NSString *docs = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                        NSString *translationRoot = [docs stringByAppendingPathComponent:@"translation"];
                        NSError *mkdirErr = nil;
                        if (![fm fileExistsAtPath:translationRoot]) {
                            [fm createDirectoryAtPath:translationRoot withIntermediateDirectories:YES attributes:nil error:&mkdirErr];
                            if (mkdirErr) NSLog(@"创建 translation 目录失败: %@", mkdirErr);
                        }
                        
                        // 对每个语言生成文件
                        for (NSString *wLang in languages) {
                            NSDictionary *map = allTranslations[wLang];
                            // 如果没有翻译结果，仍写空文件或跳过？这里写入原始 key 但 value 为空，便于检查
                            NSMutableString *outContent = [NSMutableString string];
                            // 保持原始顺序：按原 lines 遍历取 key
                            for (NSString *origLine in lines) {
                                NSError *regexErr = nil;
                                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\s*\"([^\"]+)\"\\s*=\\s*\"([^\"]*)\"\\s*;?\\s*$" options:0 error:&regexErr];
                                NSTextCheckingResult *m = [regex firstMatchInString:origLine options:0 range:NSMakeRange(0, origLine.length)];
                                if (m && m.numberOfRanges >= 2) {
                                    NSString *key = [origLine substringWithRange:[m rangeAtIndex:1]];
                                    NSString *origVal = [origLine substringWithRange:[m rangeAtIndex:2]];
                                    NSString *translatedVal = map[key];
                                    if (!translatedVal) {
                                        // 若没有翻译，使用原值或空字符串；这里我们保留原值以免丢失
                                        translatedVal = origVal ?: @"";
                                    }
                                    // 转义引号等（简单处理）
                                    NSString *escapedVal = [translatedVal stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
                                    [outContent appendFormat:@"\"%@\" = \"%@\";\n", key, escapedVal];
                                } else {
                                    // 保留无法匹配的行原样输出（注释、空行等）
                                    [outContent appendFormat:@"%@\n", origLine];
                                }
                            }
                            // 写入文件夹 translation/<lang>/
                            NSString *langFolder = [translationRoot stringByAppendingPathComponent:wLang];
                            if (![fm fileExistsAtPath:langFolder]) {
                                [fm createDirectoryAtPath:langFolder withIntermediateDirectories:YES attributes:nil error:nil];
                            }
                            NSString *outPath = [langFolder stringByAppendingPathComponent:@"Localizable.strings"];
                            NSError *writeErr = nil;
                            BOOL ok = [outContent writeToFile:outPath atomically:YES encoding:NSUTF8StringEncoding error:&writeErr];
                            if (!ok) {
                                errors[wLang] = [NSString stringWithFormat:@"写入失败: %@", writeErr.localizedDescription ?: @"未知错误"];
                            } else {
                                NSLog(@"已写入 %@ 的翻译文件到：%@", wLang, outPath);
                            }
                        }
                        // 回调完成
                        BOOL success = (errors.count == 0);
                        if (completion) completion(success, errors.count ? errors : nil);
                    }
                } // @synchronized
            }];
        } // end for batch
    } // end for language
}



@end
