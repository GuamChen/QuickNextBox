//
//  Person+CoreDataProperties.h
//  
//
//  Created by lgc on 2025/11/15.
//
//

#import "Person+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Person (CoreDataProperties)

+ (NSFetchRequest<Person *> *)fetchRequest NS_SWIFT_NAME(fetchRequest());

@property (nonatomic) int16_t age;
@property (nullable, nonatomic, copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
