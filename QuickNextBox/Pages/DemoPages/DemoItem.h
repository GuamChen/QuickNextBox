//
//  DemoItem.h
//  QuickNextBox
//
//  Created by lgc on 2025/11/9.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DemoItem : NSObject

@property (nonatomic, copy) NSString *className;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *itemDescription;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *icon;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
+ (NSArray<DemoItem *> *)demoItemsFromJSONArray:(NSArray *)array;

@end

NS_ASSUME_NONNULL_END