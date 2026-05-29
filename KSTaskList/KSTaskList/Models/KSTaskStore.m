//
//  KSTaskStore.m
//  TaskList
//
//  Created by Ian Guo on 2026/5/25.
//

#import "KSTaskStore.h"

@interface KSTaskStore ()

@property(nonatomic, strong)NSMutableArray<KSTask *> *tasks;

@end

@implementation KSTaskStore

+ (instancetype)sharedStore {
    static KSTaskStore *intance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        intance = [[self alloc] init];
    });
    return intance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.tasks = [[NSMutableArray alloc] init];
    }
    [self loadKSTaskFromDisk];
    return self;
}

- (NSArray<KSTask *> *)allTasks {
    return self.tasks;
}

- (void)addKSTask:(KSTask *)task {
    NSParameterAssert(task != nil);
    NSParameterAssert(task.taskID.length > 0);
    if (!task || !task.taskID.length) return;
    
    for (KSTask *tasksElement in self.tasks) {
        if ([tasksElement.taskID isEqualToString:task.taskID]) {
            NSLog(@"The task with taskID: %@ is already exist", task.taskID);
            return;
        }
    }
    [self.tasks addObject:task];
    [self.tasks sortUsingComparator:^NSComparisonResult(KSTask *task1, KSTask *task2) {
        return [@(task2.taskPriority) compare:@(task1.taskPriority)];
    }];
}

- (void)removeKSTask:(KSTask *)task {
    NSParameterAssert(task != nil);
    NSParameterAssert(task.taskID.length > 0);
    if (!task || !task.taskID.length) return;
    
    [self.tasks removeObject:task];
}

- (BOOL)updateTasks:(KSTask *)task {
    NSParameterAssert(task != nil);
    NSParameterAssert(task.taskID.length > 0);
    if (!task || !task.taskID.length) return NO;
    
    for (NSInteger index = 0; index < self.tasks.count; index++) {
        if ([self.tasks[index].taskID isEqualToString:task.taskID]) {
            self.tasks[index] = task;
            [self.tasks sortUsingComparator:^NSComparisonResult(KSTask *task1, KSTask *task2) {
                return [@(task2.taskPriority) compare:@(task1.taskPriority)];
            }];
            return YES;
        }
    }
    return NO;
}

- (void)loadKSTaskFromDisk {
    NSURL *documentsDir = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                 inDomains:NSUserDomainMask].firstObject;
    NSURL *fileURL = [documentsDir URLByAppendingPathComponent:@"tasks.json"];
    
    NSData *json = [NSData dataWithContentsOfURL:fileURL];
    if (!json) return;
    
    NSError *error = nil;
    NSArray *dictArray = [NSJSONSerialization JSONObjectWithData:json
                                                         options:NSJSONReadingMutableContainers
                                                           error:&error];
    if (error || ![dictArray isKindOfClass:[NSArray class] ]) {
        NSLog(@"Deserialization Failed, Error: %@", error);
        return;
    }
    
    for (NSDictionary *dict in dictArray) {
        [self.tasks addObject:[KSTask taskFromDictionary:dict]];
    }
    [self.tasks sortUsingComparator:^NSComparisonResult(KSTask *task1, KSTask *task2) {
        return [@(task2.taskPriority) compare:@(task1.taskPriority)];
    }];
}

- (void)saveKSTasksToDisk {
    NSMutableArray *dictArray = [NSMutableArray array];
    for (KSTask *currentKSTask in self.tasks) {
        [dictArray addObject:[currentKSTask toDictionary] ];
    }
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictArray
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (error || !jsonData) {
        NSLog(@"Serialization Failed, Error: %@", error);
        return;
    }
    
    NSURL *documentsDir = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                 inDomains:NSUserDomainMask].firstObject;
    NSURL *fileURL = [documentsDir URLByAppendingPathComponent:@"tasks.json"];
    
    BOOL success = [jsonData writeToURL:fileURL
                                options:NSDataWritingAtomic
                                  error:&error];
    if (error || !success) {
        NSLog(@"Write File Failed, Error: %@", error);
        return;
    }
}

- (void)loadTasksWithCompletion:(void (^)(NSArray<KSTask *> *))completion {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:0.5];
        NSArray *snapshot = [self allTasks];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(snapshot);
        });
    });
}

@end
