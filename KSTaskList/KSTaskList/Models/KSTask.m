//
//  KSTask.m
//  TaskList
//
//  Created by Ian Guo on 2026/5/25.
//

#import "KSTask.h"

@implementation KSTask

- (instancetype)initWithTitle:(NSString *)title priority:(KSTaskPriority)priority {
    self = [super init];
    if (self) {
        _taskID = [[NSUUID UUID].UUIDString copy];
        _title = title;
        _taskPriority = priority;
        _completed = NO;
        _createdAt = [NSDate date];
    }
    return self;
}

- (instancetype)init {
    return [self initWithTitle:@"" priority:KSPriorityNormal];
}

+ (instancetype)taskWithTitle:(NSString *)title {
    return [[self alloc] initWithTitle:title priority:KSPriorityNormal];
}

- (NSDictionary *)toDictionary {
    return @{
        @"id":        self.taskID    ?: @"",
        @"title":     self.title     ?: @"",
        @"desc":      self.desc      ?: @"",
        @"priority":  @(self.taskPriority),
        @"completed": @(self.completed),
    };
}

+ (instancetype)taskFromDictionary:(NSDictionary *)dict {
    if (![dict isKindOfClass:[NSDictionary class]]) return nil;
    KSTask *newTask = [[KSTask alloc] initWithTitle:dict[@"title"]
                                            priority:[dict[@"priority"] integerValue]];
    newTask.taskID = dict[@"id"];
    newTask.desc = dict[@"desc"];
    newTask.completed = [dict[@"completed"] boolValue];
    return newTask;
}

@end
