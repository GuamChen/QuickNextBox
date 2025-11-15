//
//  PersonManager.m
//  QuickNextBox
//
//  Created by lgc on 2025/11/15.
//


// PersonManager.m

#import "PersonManager.h"
#import "CoreDataManager.h"

@implementation PersonManager

+ (instancetype)sharedInstance {
    static PersonManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PersonManager alloc] init];
    });
    return instance;
}

#pragma mark - Create

- (Person *)createPersonWithName:(NSString *)name age:(NSInteger)age {
    NSManagedObjectContext *context = [CoreDataManager sharedInstance].persistentContainer.viewContext;

    Person *person = [NSEntityDescription insertNewObjectForEntityForName:@"Person"
                                                   inManagedObjectContext:context];
    person.name = name;
    person.age = age;

    [[CoreDataManager sharedInstance] saveContext];
    return person;
}

#pragma mark - Fetch

- (NSArray<Person *> *)fetchAllPersons {
    NSManagedObjectContext *context = [CoreDataManager sharedInstance].persistentContainer.viewContext;

    NSFetchRequest *request = [Person fetchRequest];

    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Fetch error: %@", error);
        return @[];
    }
    return result;
}

#pragma mark - Update

- (void)updatePerson:(Person *)person name:(NSString *)name age:(NSInteger)age {
    person.name = name;
    person.age = age;

    [[CoreDataManager sharedInstance] saveContext];
}

#pragma mark - Delete

- (void)deletePerson:(Person *)person {
    NSManagedObjectContext *context = [CoreDataManager sharedInstance].persistentContainer.viewContext;

    [context deleteObject:person];
    [[CoreDataManager sharedInstance] saveContext];
}

@end
