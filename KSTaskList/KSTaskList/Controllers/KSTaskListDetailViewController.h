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

@interface KSTaskListDetailViewController : UIViewController

@property (nonatomic, strong) KSTask *task;
@property (nonatomic, strong) UITextField *titleField;
@property (nonatomic, weak) id<KSTaskVCProtocol> delegate;

- (instancetype)initWithTask:(KSTask *)task;

@end

NS_ASSUME_NONNULL_END
