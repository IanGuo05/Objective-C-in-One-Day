//
//  KSTaskListListViewController.m
//  TaskList
//
//  Created by Ian Guo on 2026/5/26.
//

#import "KSTaskListListViewController.h"
#import "../Models/KSTask.h"
#import "../Models/KSTaskStore.h"
#import "../Categories/KSUIColor.h"

@implementation KSTaskListListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Task Leeeest";
    
    [[KSTaskStore sharedStore] addKSTask:[KSTask taskWithTitle:@"Learning OC Syntax"]];
    [[KSTaskStore sharedStore] addKSTask:[KSTask taskWithTitle:@"Complete OC Practicing Project"]];
    
    __weak typeof(self) weakSelf = self;
    [[KSTaskStore sharedStore] loadTasksWithCompletion:^(NSArray<KSTask *> *tasks) {
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[KSTaskStore sharedStore] allTasks].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"taskCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID] ?:
    [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                              reuseIdentifier:cellID];
    
    KSTask *currentTask = [[KSTaskStore sharedStore] allTasks][indexPath.row];
    cell.textLabel.text = currentTask.title;
    cell.detailTextLabel.text = currentTask.desc;
    cell.backgroundColor = [KSUIColor taskColorByPriority:currentTask.taskPriority];
    return cell;
}

#pragma mark - KSTaskVCProtocol

- (void)taskDetail:(KSTaskListDetailViewController *)vc didSaveTask:(KSTask *)task {
    
}

- (void)taskDetail:(KSTaskListDetailViewController *)vc didCreateTask:(KSTask *)task {
    
}

- (void)taskDetail:(KSTaskListDetailViewController *)vc didDeleteTask:(KSTask *)task {
    
}

@end
