//
//  PersonManager.h
//  QuickNextBox
//
//  Created by lgc on 2025/11/15.
//


// PersonManager.h

#import <Foundation/Foundation.h>
#import "Person+CoreDataClass.h"

@interface PersonManager : NSObject

+ (instancetype)sharedInstance;

- (Person *)createPersonWithName:(NSString *)name age:(NSInteger)age;
- (NSArray<Person *> *)fetchAllPersons;
- (void)deletePerson:(Person *)person;
- (void)updatePerson:(Person *)person name:(NSString *)name age:(NSInteger)age;

@end
