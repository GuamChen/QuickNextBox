//
//  DouBaoAPIManager.h
//  QuickNextBox
//
//  Created by lgc on 2025/12/4.
//


#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, AiChatRequestType) {
    AiChatRequestTypeText,
    AiChatRequestTypeImage,
    
};


typedef NS_ENUM(NSUInteger, DSKChatStreamResultType) {
    DSKChatStreamResultContent,  // 内容更新
    DSKChatStreamResultFinished, // 流式结束
    DSKChatStreamResultError     // 错误
};


typedef void (^DSKChatStreamHandler)(DSKChatStreamResultType type, NSString *content, NSError  *error);


@interface DouBaoAPIManager : NSObject <NSURLSessionDelegate>

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, DSKChatStreamHandler> *streamHandlers;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSMutableString *> *accumulatedContents;
@property (nonatomic, assign) BOOL is_thinking;



+ (instancetype)sharedManager;


- (NSURLSessionDataTask *)uploadImage:(UIImage *)image withMessage:(NSString *)message streamHandler:(DSKChatStreamHandler)handler;

- (void)translateLocalizableAtPath:(NSString *)sourcePath
batchSize:(NSInteger)batchSize
completion:(void(^)(BOOL success, NSDictionary<NSString*, NSString*> *errorsByLang))completion;

@end
