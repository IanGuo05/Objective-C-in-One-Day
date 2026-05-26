//
//  KSTaskVCProtocol.h
//  TaskList
//
//  Created by Ian Guo on 2026/5/26.
//

#ifndef KSTaskVCProtocol_h
#define KSTaskVCProtocol_h

@class KSTaskListDetailViewController, KSTask;

@protocol KSTaskVCProtocol <NSObject>

- (void)taskDetail:(KSTaskListDetailViewController *)vc didSaveTask:(KSTask *)task;
- (void)taskDetail:(KSTaskListDetailViewController *)vc didCreateTask:(KSTask *)task;
- (void)taskDetail:(KSTaskListDetailViewController *)vc didDeleteTask:(KSTask *)task;

@end

#endif /* KSTaskVCProtocol_h */
