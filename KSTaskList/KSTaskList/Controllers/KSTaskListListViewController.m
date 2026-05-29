//
//  KSTaskListListViewController.m
//  TaskList
//
//  Created by Ian Guo on 2026/5/26.
//

#import "KSTaskListListViewController.h"
#import "KSTaskListDetailViewController.h"
#import "KSTask.h"
#import "KSTaskStore.h"
#import "KSUIColor.h"

@interface KSTaskListListViewController ()

@property(nonatomic, strong)UIBarButtonItem *createViewButton;

@end

@implementation KSTaskListListViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Task Leeeest";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"+"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(addButtonPressed)];
    
//    [[KSTaskStore sharedStore] addKSTask:[KSTask taskWithTitle:@"Learning OC Syntax"]];
//    [[KSTaskStore sharedStore] addKSTask:[[KSTask alloc] initWithTitle:@"Complete OC Practicing Projoect" priority:KSPriorityLow]];
//    [[KSTaskStore sharedStore] addKSTask:[[KSTask alloc] initWithTitle:@"Release the TaskList App" priority:KSPriorityHigh]];
    
    __weak typeof(self) weakSelf = self;
    [[KSTaskStore sharedStore] loadTasksWithCompletion:^(NSArray<KSTask *> *tasks) {
        [weakSelf.tableView reloadData];
    }];
}

- (void)addButtonPressed {
    KSTaskListDetailViewController *vc = [[KSTaskListDetailViewController alloc] initWithNewTask];
    vc.delegate = self;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    KSTask *currentTask = [[KSTaskStore sharedStore] allTasks][indexPath.row];
    KSTaskListDetailViewController *vc = [[KSTaskListDetailViewController alloc] initWithTask:currentTask];
    
    vc.delegate = self;
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - KSTaskVCProtocol

- (void)taskDetail:(KSTaskListDetailViewController *)vc didSaveTask:(KSTask *)task {
    [[KSTaskStore sharedStore] updateTasks:task];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)taskDetail:(KSTaskListDetailViewController *)vc didCreateTask:(KSTask *)task {
    [[KSTaskStore sharedStore] addKSTask:task];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)taskDetail:(KSTaskListDetailViewController *)vc didDeleteTask:(KSTask *)task {
    [[KSTaskStore sharedStore] removeKSTask:task];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
