//
//  Person+CoreDataProperties.m
//  
//
//  Created by lgc on 2025/11/15.
//
//

#import "Person+CoreDataProperties.h"

@implementation Person (CoreDataProperties)

+ (NSFetchRequest<Person *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Person"];
}

@dynamic age;
@dynamic name;

@end
