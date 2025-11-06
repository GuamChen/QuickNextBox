//
//  TSUserDefaults.h
//  Muren
//
//  Created by lgc on 2025/11/6.
//


//
//  TSUserDefaults.h

//
//  Created by fc01 on 15/3/24.
//  Copyright (c) 2015年 fc01. All rights reserved.
//

#import <Foundation/Foundation.h>

/**声明这是一个只有类方法的工具类，不能创建实例对象。**/
NS_ROOT_CLASS
@interface TSUserDefaults

/**
 这是一个"方法声明宏"
 当你在代码中写 BOOL_KEY(HasLogined) 时，预处理器会展开为：
 objc
 +(void)setHasLogined:(bool)value;
 +(bool)getHasLogined;
 ## 是连接符，把 set 和 HasLogined 连接成 setHasLogined
 */
#define BOOL_KEY(__key__)\
+(void)set##__key__:(bool)value;\
+(bool)get##__key__;

#define FLOAT_KEY(__key__)\
+(void)set##__key__:(float)value;\
+(float)get##__key__;

#define INTEGER_KEY(__key__)\
+(void)set##__key__:(NSInteger)value;\
+(NSInteger)get##__key__;

#define STRING_KEY(__key__)\
+(void)set##__key__:(NSString*)value;\
+(NSString*)get##__key__;

/**
 包含键定义文件：
 
 objc
 #include "TSUserDefaults__Key.h"
 这个文件里包含了所有具体的键定义，比如：
 
 objc
 BOOL_KEY(isNotFirstRun)
 BOOL_KEY(HasLogined)
 STRING_KEY(UserName)
 */
#include "TSUserDefaults__Key.h"

/**
 #undef 的作用是取消宏定义
 */
#undef BOOL_KEY
#undef STRING_KEY
#undef FLOAT_KEY
#undef INTEGER_KEY

@end







