//
//  DSKChatMessage.m
//  QuickNextBox
//
//  Created by lgc on 2025/12/4.
//


//
#import "DSKChatMessage.h"


@implementation DSKChatMessage

- (instancetype)initWithContent:(NSString *)content
                    messageType:(DSKMessageType)messageType {
    self = [super init];
    if (self) {
        _messageId = [[NSUUID UUID] UUIDString];
        _content = content;
        _messageType = messageType;
        _timestamp = [NSDate date];
    }
    return self;
}


- (instancetype)initWithContent:(NSString *)content
                    messageType:(DSKMessageType)messageType
                          image:(UIImage *)image {
    self = [super init];
    if (self) {
        _messageId = [[NSUUID UUID] UUIDString];
        _content = content;
        _messageType = messageType;
        _timestamp = [NSDate date];
        _image = image;
    }
    return self;
}

@end
