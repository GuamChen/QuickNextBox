// CoreDataManager.m

#import "CoreDataManager.h"

@implementation CoreDataManager

+ (instancetype)sharedInstance {
    static CoreDataManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CoreDataManager alloc] init];
    });
    return manager;
}

#pragma mark - Persistent Container

- (NSPersistentContainer *)persistentContainer {
    static NSPersistentContainer *_container = nil;
    
    if (_container == nil) {
        // ⚠️ 这里名字必须与你的 .xcdatamodeld 文件名一致
        _container = [[NSPersistentContainer alloc] initWithName:@"Model"];
        
        [_container loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
            if (error != nil) {
                NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                abort();
            }
        }];
    }
    
    return _container;
}

#pragma mark - Save Context
- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    
    if (context.hasChanges) {
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Failed to save: %@ %@", error, error.userInfo);
        }
    }
}

@end
