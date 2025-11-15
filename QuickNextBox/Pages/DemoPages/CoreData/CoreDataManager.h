//
//  CoreDataManager.h
//  QuickNextBox
//
//  Created by lgc on 2025/11/15.
//


// CoreDataManager.h

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataManager : NSObject

@property (readonly, strong) NSPersistentContainer *persistentContainer;

/// 单例
+ (instancetype)sharedInstance;

/// 保存
- (void)saveContext;

@end
