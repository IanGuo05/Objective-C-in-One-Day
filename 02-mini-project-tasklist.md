# Mini 项目：TaskList（任务清单）

> 目标：用一个 200 行左右的 App，串起所有 OC 核心语法
> 预计动手时间：2h

---

## 项目结构

```
TaskList/
├── Models/
│   ├── Task.h / Task.m              # 模型类（继承、属性、init）
│   └── TaskStore.h / TaskStore.m    # 单例（GCD dispatch_once）
├── Categories/
│   └── UIColor+TaskTheme.h / .m     # Category
├── Protocols/
│   └── TaskDetailDelegate.h         # 协议
├── Controllers/
│   ├── TaskListViewController.h/.m  # 列表（UITableView）
│   └── TaskDetailViewController.h/.m # 详情（delegate + block 双回调）
└── AppDelegate.m
```

---

## 1. Task.h —— 模型 + 枚举

```objc
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TaskPriority) {
    TaskPriorityLow = 0,
    TaskPriorityNormal,
    TaskPriorityHigh,
};

@interface Task : NSObject

@property (nonatomic, copy)   NSString    *taskId;
@property (nonatomic, copy)   NSString    *title;
@property (nonatomic, copy)   NSString    *desc;
@property (nonatomic, assign) TaskPriority priority;
@property (nonatomic, assign, getter=isCompleted) BOOL completed;
@property (nonatomic, strong) NSDate      *createdAt;

// 指定初始化
- (instancetype)initWithTitle:(NSString *)title
                     priority:(TaskPriority)priority NS_DESIGNATED_INITIALIZER;

// 便利构造
+ (instancetype)taskWithTitle:(NSString *)title;

// 字典互转（业务里超常见）
- (NSDictionary *)toDictionary;
+ (instancetype)taskFromDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
```

## Task.m

```objc
#import "Task.h"

@implementation Task

- (instancetype)initWithTitle:(NSString *)title priority:(TaskPriority)priority {
    self = [super init];
    if (self) {
        _taskId    = [[NSUUID UUID].UUIDString copy];
        _title     = [title copy];
        _priority  = priority;
        _completed = NO;
        _createdAt = [NSDate date];
    }
    return self;
}

- (instancetype)init {
    return [self initWithTitle:@"" priority:TaskPriorityNormal];
}

+ (instancetype)taskWithTitle:(NSString *)title {
    return [[self alloc] initWithTitle:title priority:TaskPriorityNormal];
}

- (NSDictionary *)toDictionary {
    return @{
        @"id":        self.taskId    ?: @"",
        @"title":     self.title     ?: @"",
        @"desc":      self.desc      ?: @"",
        @"priority":  @(self.priority),
        @"completed": @(self.completed),
    };
}

+ (instancetype)taskFromDictionary:(NSDictionary *)dict {
    if (![dict isKindOfClass:[NSDictionary class]]) return nil;
    Task *t = [[Task alloc] initWithTitle:dict[@"title"]
                                 priority:[dict[@"priority"] integerValue]];
    t.taskId    = dict[@"id"];
    t.desc      = dict[@"desc"];
    t.completed = [dict[@"completed"] boolValue];
    return t;
}

@end
```

✅ **覆盖点**：类声明、属性修饰词全家桶、`NS_ENUM`、`instancetype`、指定/便利初始化、`super init`、字典字面量、装箱、`?:` nil 兜底

---

## 2. TaskStore.h/.m —— 单例 + 增删改查

```objc
@interface TaskStore : NSObject
+ (instancetype)sharedStore;
- (NSArray<Task *> *)allTasks;
- (void)addTask:(Task *)task;
- (void)removeTaskAtIndex:(NSInteger)index;
- (void)updateTask:(Task *)task;

// 模拟异步加载
- (void)loadTasksWithCompletion:(void (^)(NSArray<Task *> *tasks))completion;
@end

@implementation TaskStore {
    NSMutableArray<Task *> *_tasks;
}

+ (instancetype)sharedStore {
    static TaskStore *instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ instance = [[self alloc] init]; });
    return instance;
}

- (instancetype)init {
    if ((self = [super init])) {
        _tasks = [NSMutableArray array];
    }
    return self;
}

- (NSArray<Task *> *)allTasks { return [_tasks copy]; }

- (void)addTask:(Task *)task {
    if (!task) return;
    [_tasks addObject:task];
}

- (void)removeTaskAtIndex:(NSInteger)index {
    if (index < 0 || index >= _tasks.count) return;
    [_tasks removeObjectAtIndex:index];
}

- (void)updateTask:(Task *)task {
    [_tasks enumerateObjectsUsingBlock:^(Task *t, NSUInteger idx, BOOL *stop) {
        if ([t.taskId isEqualToString:task.taskId]) {
            _tasks[idx] = task;
            *stop = YES;
        }
    }];
}

- (void)loadTasksWithCompletion:(void (^)(NSArray<Task *> *))completion {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:0.5];   // 模拟网络
        NSArray *snapshot = [self allTasks];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(snapshot);
        });
    });
}

@end
```

✅ **覆盖点**：单例（dispatch_once）、Block 类型、GCD 主子线程切换、面向对象封装

---

## 3. TaskDetailDelegate.h —— 协议

```objc
@class Task, TaskDetailViewController;

@protocol TaskDetailDelegate <NSObject>
@required
- (void)taskDetail:(TaskDetailViewController *)vc didSaveTask:(Task *)task;
@optional
- (void)taskDetailDidCancel:(TaskDetailViewController *)vc;
@end
```

✅ **覆盖点**：`@protocol`、`@required/@optional`、`@class` 前向声明

---

## 4. TaskDetailViewController —— delegate + block 双回调

```objc
@interface TaskDetailViewController : UIViewController

@property (nonatomic, strong) Task *task;
@property (nonatomic, weak)   id<TaskDetailDelegate> delegate;     // ⚠️ weak

// Block 回调（与 delegate 二选一或并存）
@property (nonatomic, copy) void (^onSave)(Task *task);            // ⚠️ copy

- (instancetype)initWithTask:(Task *)task;
@end

@implementation TaskDetailViewController

- (instancetype)initWithTask:(Task *)task {
    self = [super initWithNibName:nil bundle:nil];
    if (self) { _task = task; }
    return self;
}

- (void)saveButtonTapped {
    self.task.title = self.titleField.text;

    // 1) delegate 回调
    if ([self.delegate respondsToSelector:@selector(taskDetail:didSaveTask:)]) {
        [self.delegate taskDetail:self didSaveTask:self.task];
    }
    // 2) block 回调
    if (self.onSave) self.onSave(self.task);

    [self.navigationController popViewControllerAnimated:YES];
}

@end
```

✅ **覆盖点**：协议落地、delegate weak、Block copy、`respondsToSelector:` 防 crash

---

## 5. TaskListViewController —— UITableView + 异步加载

```objc
@interface TaskListViewController : UITableViewController <TaskDetailDelegate>
@end

@implementation TaskListViewController

- (void)viewDidLoad {
    [super viewDidLoad];                  // ⚠️ super
    self.title = @"任务清单";

    [[TaskStore sharedStore] addTask:[Task taskWithTitle:@"学习 OC"]];
    [[TaskStore sharedStore] addTask:[Task taskWithTitle:@"熟悉项目"]];

    __weak typeof(self) weakSelf = self;
    [[TaskStore sharedStore] loadTasksWithCompletion:^(NSArray<Task *> *tasks) {
        [weakSelf.tableView reloadData];   // 防循环引用
    }];
}

#pragma mark - UITableViewDataSource (方法重写)

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)s {
    return [[TaskStore sharedStore] allTasks].count;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)ip {
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:cellId]
                          ?: [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                    reuseIdentifier:cellId];
    Task *t = [[TaskStore sharedStore] allTasks][ip.row];
    cell.textLabel.text       = t.title;
    cell.detailTextLabel.text = t.isCompleted ? @"✓ 已完成" : @"待办";
    cell.backgroundColor      = [UIColor taskBackgroundForPriority:t.priority]; // Category
    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)ip {
    Task *t = [[TaskStore sharedStore] allTasks][ip.row];
    TaskDetailViewController *vc = [[TaskDetailViewController alloc] initWithTask:t];

    // 方式 A：delegate
    vc.delegate = self;

    // 方式 B：block（两种都演示一遍，业务里看团队规范）
    __weak typeof(self) weakSelf = self;
    vc.onSave = ^(Task *task) {
        [[TaskStore sharedStore] updateTask:task];
        [weakSelf.tableView reloadData];
    };

    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - TaskDetailDelegate

- (void)taskDetail:(TaskDetailViewController *)vc didSaveTask:(Task *)task {
    [[TaskStore sharedStore] updateTask:task];
    [self.tableView reloadData];
}

@end
```

✅ **覆盖点**：继承 UITableViewController、方法重写、协议实现、Block + `__weak self`、Category 调用、点语法 vs 方法调用

---

## 6. UIColor+TaskTheme —— Category

```objc
@interface UIColor (TaskTheme)
+ (UIColor *)taskBackgroundForPriority:(TaskPriority)priority;
@end

@implementation UIColor (TaskTheme)
+ (UIColor *)taskBackgroundForPriority:(TaskPriority)priority {
    switch (priority) {
        case TaskPriorityHigh:   return [UIColor colorWithRed:1.0 green:0.9 blue:0.9 alpha:1];
        case TaskPriorityNormal: return [UIColor whiteColor];
        case TaskPriorityLow:    return [UIColor colorWithWhite:0.95 alpha:1];
    }
}
@end
```

✅ **覆盖点**：Category 写法、类方法、`switch` over `NS_ENUM`

---

## 完成后的自检清单 ✅

照着下面每一条问自己"我能讲清楚吗？讲不清楚就回去翻 01-syntax.md 对应章节"。

- [ ] 为什么 NSString 用 `copy`，普通对象用 `strong`？
- [ ] 为什么 delegate 必须 `weak`？
- [ ] Block 里为什么要用 `__weak self`？什么时候还要再 `__strong`？
- [ ] OC 支持方法重载吗？
- [ ] `instancetype` 和 `id` 区别？
- [ ] `nil` 给 nil 发消息会崩吗？
- [ ] `#import` vs `@class` 怎么选？
- [ ] `NSArray` 能塞 `nil` 吗？要塞空怎么办？
- [ ] 单例的 `dispatch_once` 为什么是线程安全的？
- [ ] 为什么 `init` 里推荐用 `_ivar = ...` 而不是 `self.ivar = ...`？

10 个都答得上 → 业务代码已经能看懂 80%。

---

## 进阶（明天有空再看）

- Runtime（method swizzling、关联对象）
- KVO / NSNotificationCenter
- AutoLayout（UI 布局，不是语言层面但天天用）
- 与 Swift 互调（`-Bridging-Header.h`）
