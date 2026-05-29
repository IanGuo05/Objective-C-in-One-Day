//
//  KSTaskListDetailViewController.h
//  TaskList
//
//  Created by Ian Guo on 2026/5/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KSTask.h"
#import "KSTaskVCProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, KSTaskDetailMode) {
    KSTaskDetailModeEdit,
    KSTaskDetailModeCreate
};

@interface KSTaskListDetailViewController : UIViewController

@property (nonatomic, weak) id<KSTaskVCProtocol> delegate;
@property (nonatomic, assign) KSTaskDetailMode mode;

- (instancetype)initWithTask:(KSTask *)task;
- (instancetype)initWithNewTask;

@end

NS_ASSUME_NONNULL_END
