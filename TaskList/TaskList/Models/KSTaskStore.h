//
//  KSTaskStore.h
//  TaskList
//
//  Created by Ian Guo on 2026/5/25.
//

#import <Foundation/Foundation.h>
#import "KSTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface KSTaskStore : NSObject

@property(nonatomic, copy)NSMutableArray<KSTask *> *tasks;

+ (instancetype)sharedStore;
- (NSArray<KSTask *> *)allTasks;
- (void)addKSTask:(KSTask *)task;
- (void)removeKSTask:(NSInteger) index;
- (BOOL)updateTasks:(KSTask *)task;

@end

NS_ASSUME_NONNULL_END
