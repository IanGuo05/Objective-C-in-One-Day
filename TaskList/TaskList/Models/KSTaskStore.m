//
//  KSTaskStore.m
//  TaskList
//
//  Created by Ian Guo on 2026/5/25.
//

#import "KSTaskStore.h"

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
        self.tasks = [NSMutableArray init];
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
        if ([tasksElement.taskID isEqualTo:task.taskID]) {
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
        if ([self.tasks[index].taskID isEqualTo:task.taskID]) {
            self.tasks[index] = task;
            return YES;
        }
    }
    return NO;
}

@end
