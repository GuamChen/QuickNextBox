//
//  DemoItem.m
//  QuickNextBox
//
//  Created by lgc on 2025/11/9.
//


#import "DemoItem.h"

@implementation DemoItem

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _className = [dict[@"className"] copy] ?: @"";
        _title = [dict[@"title"] copy] ?: @"";
        _itemDescription = [dict[@"description"] copy] ?: @"";
        _category = [dict[@"category"] copy] ?: @"未分类";
        _icon = [dict[@"icon"] copy] ?: @"doc";
    }
    return self;
}

+ (NSArray<DemoItem *> *)demoItemsFromJSONArray:(NSArray *)array {
    NSMutableArray *items = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        DemoItem *item = [[DemoItem alloc] initWithDictionary:dict];
        [items addObject:item];
    }
    return [items copy];
}

@end
