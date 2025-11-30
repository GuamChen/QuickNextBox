//
//  CoreDataViewController.m
//  QuickNextBox
//
//  Created by lgc on 2025/11/15.
//

#import "CoreDataViewController.h"
#import "PersonManager.h"

@interface CoreDataViewController ()
@end

@implementation CoreDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 新增
    [[PersonManager sharedInstance] createPersonWithName:@"Tom" age:20];
    [[PersonManager sharedInstance] createPersonWithName:@"Jerry" age:18];
    
    // 查询
    NSArray *list = [[PersonManager sharedInstance] fetchAllPersons];
    for (Person *p in list) {
        NSLog(@"Person: %@ - %d", p.name, p.age);
    }
    
    // 更新
    Person *first = list.firstObject;
    [[PersonManager sharedInstance] updatePerson:first name:@"UpdatedName" age:99];
    
    // 删除
    if (list.count > 1) {
        [[PersonManager sharedInstance] deletePerson:list[1]];
    }
}

@end
