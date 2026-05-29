//
//  KSTask.h
//  TaskList
//
//  Created by Ian Guo on 2026/5/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSTask : NSObject

typedef NS_ENUM(NSUInteger, KSTaskPriority) {
    KSPriorityLow,
    KSPriorityNormal,
    KSPriorityHigh
};

@property (nonatomic, copy) NSString *taskID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, assign) KSTaskPriority taskPriority;
@property (nonatomic, assign, getter=isCompleted) BOOL completed;
@property (nonatomic, strong) NSDate *createdAt;

- (instancetype)initWithTitle:(NSString *)title
                     priority:(KSTaskPriority)priority NS_DESIGNATED_INITIALIZER;

+ (instancetype)taskWithTitle:(NSString *)title;

- (NSDictionary *)toDictionary;
+ (instancetype)taskFromDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
