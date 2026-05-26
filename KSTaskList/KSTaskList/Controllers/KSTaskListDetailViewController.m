//
//  KSTaskListDetailViewController.m
//  TaskList
//
//  Created by Ian Guo on 2026/5/26.
//

#import "KSTaskListDetailViewController.h"


@implementation KSTaskListDetailViewController

- (instancetype)initWithTask:(KSTask *)task {
    self = [super initWithNibName:nil bundle:nil];
    if (self) _task = task;
    return self;
}

- (void)saveButtonPressed {
    self.task.title = self.titleField.text;
    
    if ([self.delegate respondsToSelector:@selector(taskDetail:didSaveTask:)]) {
        [self.delegate taskDetail:self didSaveTask:self.task];
    }
}

- (void)createButtonPressed {
    self.task.title = self.titleField.text;
    
    if ([self.delegate respondsToSelector:@selector(taskDetail:didCreateTask:)]) {
        [self.delegate taskDetail:self didCreateTask:self.task];
    }
}

- (void)deleteButtonPressed {
    self.task.title = self.titleField.text;
    
    if ([self.delegate respondsToSelector:@selector(taskDetail:didDeleteTask:)]) {
        [self.delegate taskDetail:self didDeleteTask:self.task];
    }
}

@end
