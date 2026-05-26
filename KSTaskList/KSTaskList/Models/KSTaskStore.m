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
}

- (void)removeKSTask:(NSInteger)index {
    NSParameterAssert(index < self.tasks.count);
    if (index >= self.tasks.count) return;
    
    [self.tasks removeObjectAtIndex:index];
}

- (BOOL)updateTasks:(KSTask *)task {
    NSParameterAssert(task != nil);
    NSParameterAssert(task.taskID.length > 0);
    if (!task || !task.taskID.length) return NO;
    
    for (NSInteger index = 0; index < self.tasks.count; index++) {
        if ([self.tasks[index].taskID isEqualToString:task.taskID]) {
            self.tasks[index] = task;
            return YES;
        }
    }
    return NO;
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
