//
//  TSUserDefaults.m
//  Muren
//
//  Created by lgc on 2025/11/6.
//



//
//  TSUserDefaults.m

//
//  Created by fc01 on 15/3/24.
//  Copyright (c) 2015年 fc01. All rights reserved.
//

#import "TSUserDefaults.h"

@implementation TSUserDefaults
/**
 解释：
 
 这是"方法实现宏"
 当写 BOOL_KEY(HasLogined) 时，会展开为两个完整的方法：
 objc
 +(void)setHasLogined:(bool)value{
 NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
 [ud setBool:value forKey:@"HasLogined"];  // 注意：@#__key__ 变成字符串@"HasLogined"
 [ud synchronize];
 }
 
 +(bool)getHasLogined{
 NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
 return [ud boolForKey:@"HasLogined"];
 }*/
// bool
#define BOOL_KEY(__key__) \
+(void)set##__key__:(bool)value{\
NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];\
[ud setBool:value forKey:@#__key__];\
[ud synchronize];\
}\
\
+(bool)get##__key__{\
NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];\
return [ud boolForKey:@#__key__];\
}
//float
#define FLOAT_KEY(__key__) \
+(void)set##__key__:(float)value{\
NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];\
[ud setFloat:value forKey:@#__key__];\
[ud synchronize];\
}\
\
+(float)get##__key__{\
NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];\
return [ud floatForKey:@#__key__];\
}

//NSInteger
#define INTEGER_KEY(__key__) \
+(void)set##__key__:(NSInteger)value{\
NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];\
[ud setInteger:value forKey:@#__key__];\
[ud synchronize];\
}\
\
+(NSInteger)get##__key__{\
NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];\
return [ud integerForKey:@#__key__];\
}

// NSString
#define STRING_KEY(__key__) \
+(void)set##__key__:(NSString*)value{\
NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];\
[ud setObject:value forKey:@#__key__];\
[ud synchronize];\
}\
\
+(NSString*)get##__key__{\
NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];\
NSString *ret = [ud objectForKey:@#__key__];\
return ret==nil?@"":ret;\
}


#include "TSUserDefaults__Key.h"

#undef BOOL_KEY
#undef STRING_KEY
#undef FLOAT_KEY

@end
