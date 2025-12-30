//
//  DSKChatViewModel.h
//  QuickNextBox
//
//  Created by lgc on 2025/12/4.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DSKChatMessage.h"


@interface DSKChatViewModel : NSObject

@property (nonatomic, strong) NSArray<DSKChatMessage *> *messages;
@property (nonatomic, strong) NSError *lastError;

//@property (nonatomic, assign) BOOL  is_at_commulicating ;
//@property (nonatomic, strong) UIImage *selectedImage; // 新增选择的图片

- (void)uploadImage:(UIImage *)image withMessage:(NSString *)message completion:(void(^)(NSString *response, NSError *error))completion;


/**
 
 */
- (void)translateText:(NSString*)strList fromLang:(NSString*)origLang toLang:(NSString*)TargetLang completion:(void(^)(NSString* response, NSError *error)) completion;





@end
