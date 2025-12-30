//
//  DSKChatMessage.h
//  QuickNextBox
//
//  Created by lgc on 2025/12/4.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



typedef NS_ENUM(NSUInteger, DSKMessageType) {
    DSKMessageTypeUser,
    DSKMessageTypeBot
};

@interface DSKChatMessage : NSObject


@property (nonatomic, strong) NSString *messageId;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, assign) DSKMessageType messageType;
@property (nonatomic, strong) NSDate *timestamp;

@property (nonatomic, strong) UIImage *image; // 新增图片属性



- (instancetype)initWithContent:(NSString *)content
                    messageType:(DSKMessageType)messageType;

- (instancetype)initWithContent:(NSString *)content
                    messageType:(DSKMessageType)messageType
                          image:(UIImage *)image;

@end
