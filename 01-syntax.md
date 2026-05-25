# Objective-C 一天速成：语法手册

> 目标：从 Swift/其他语言切到 OC，看得懂业务代码、能动手改。
> 每一节都是"最短可用版"，看完直接就能用在项目里。

---

## 0. 一定要先理解的"心智模型"

OC = C + 面向对象 + 消息发送（Smalltalk 风格）

- 类靠 **`.h`（接口）/ `.m`（实现）** 分离
- 方法调用本质是 **"发消息"**：`[obj doSomething]` ≡ `objc_msgSend(obj, @selector(doSomething))`
- 万物皆指针（对象都用 `*`），`id` 是"任意对象指针"
- `nil` 给 `nil` 发消息**不会崩**（重要！与 Java/Swift 不同）

```objc
NSString *s = nil;
NSUInteger len = [s length]; // 不崩，返回 0
```

---

## 1. 基本数据类型与指针

### 值类型（C 原语）
```objc
int        i = 1;
NSInteger  n = 100;     // 平台相关，64 位上是 long
NSUInteger u = 100;
CGFloat    f = 1.5;     // iOS UI 用这个
BOOL       ok = YES;    // YES / NO
```

### 对象类型（必须带 `*`）
```objc
NSString  *s   = @"hello";
NSNumber  *num = @(42);          // 装箱
NSArray   *arr = @[@1, @2, @3];  // 字面量
NSDictionary *d = @{@"k": @"v"};
```

### `id` / `instancetype` / `nil` 家族
| 类型 | 含义 | 用在哪 |
|---|---|---|
| `id` | 任意对象指针 | 通用容器、回调参数 |
| `instancetype` | 当前类的实例 | 构造方法返回值（推荐） |
| `nil` | 对象空 | 给对象赋空 |
| `Nil` | 类对象空 | 给 Class 赋空（少见） |
| `NULL` | C 指针空 | C 函数返回 |
| `[NSNull null]` | "占位的空" | 集合里不能放 nil，用它代替 |

---

## 2. 集合类型

OC 集合分**不可变 / 可变**两套：
- `NSArray` / `NSMutableArray`
- `NSDictionary` / `NSMutableDictionary`
- `NSSet` / `NSMutableSet`

```objc
NSMutableArray *arr = [NSMutableArray array];
[arr addObject:@"a"];
[arr addObject:@"b"];
NSString *first = arr[0];  // 等价于 [arr objectAtIndex:0]

NSMutableDictionary *dict = [NSMutableDictionary dictionary];
dict[@"name"] = @"张三";    // 等价于 setObject:forKey:

for (NSString *item in arr) { NSLog(@"%@", item); }
```

⚠️ **集合里不能放 `nil`**，要放空用 `[NSNull null]`。

---

## 3. 类的声明与实例化

### Person.h
```objc
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

@property (nonatomic, copy)   NSString *name;   // 字符串永远用 copy
@property (nonatomic, assign) NSInteger age;    // 值类型用 assign

- (instancetype)initWithName:(NSString *)name age:(NSInteger)age;
- (void)sayHello;

+ (instancetype)personWithName:(NSString *)name;  // 类方法（工厂）

@end

NS_ASSUME_NONNULL_END
```

### Person.m
```objc
#import "Person.h"

@implementation Person

- (instancetype)initWithName:(NSString *)name age:(NSInteger)age {
    self = [super init];      // 必须先调 super
    if (self) {
        _name = [name copy];  // 直接用 _ivar，避免在 init 里走 setter
        _age  = age;
    }
    return self;
}

+ (instancetype)personWithName:(NSString *)name {
    return [[self alloc] initWithName:name age:0];
}

- (void)sayHello {
    NSLog(@"Hi, I'm %@, %ld", self.name, (long)self.age);
}

@end
```

### 实例化 & 调用
```objc
Person *p = [[Person alloc] initWithName:@"张三" age:18];
[p sayHello];
p.name = @"李四";          // 点语法，等价于 [p setName:@"李四"]
```

---

## 4. 属性修饰词全家桶

| 修饰词 | 用在哪 | 说明 |
|---|---|---|
| `nonatomic` | 几乎所有属性 | 非原子，**性能好**；UI 一律用这个 |
| `atomic` | 极少用 | 原子（不等于线程安全） |
| `strong` | 对象（默认） | 强引用，引用计数 +1 |
| `weak` | delegate / 父引用 | 不持有，对象销毁自动置 nil |
| `copy` | NSString / Block | 防止外面传 NSMutableString 偷偷改 |
| `assign` | 基本类型 | 不涉及引用计数 |
| `unsafe_unretained` | 极少用 | 像 weak 但不会自动置 nil |
| `readonly` | 对外只读 | 不生成 setter |
| `readwrite` | 默认 | 同时生成 setter/getter |
| `getter=` / `setter=` | 改方法名 | `BOOL` 常用 `getter=isEnabled` |

**记忆口诀（业务里 90% 场景）**：
```
NSString → copy
Block    → copy
delegate → weak
普通对象 → strong
基本类型 → assign
```

---

## 5. 构造函数

OC 没有 Swift 的 `init?`，靠返回 `nil` 表示失败。

```objc
- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (!self) return nil;
    if (![dict isKindOfClass:[NSDictionary class]]) return nil;  // 失败返回 nil
    _name = [dict[@"name"] copy];
    return self;
}
```

**指定初始化方法（designated initializer）**：所有便利初始化方法最终都要调它。

```objc
// 便利方法
- (instancetype)init {
    return [self initWithName:@"匿名" age:0];   // 调指定初始化
}
```

---

## 6. 继承与 `super`

```objc
@interface Employee : Person
@property (nonatomic, copy) NSString *company;
- (instancetype)initWithName:(NSString *)name age:(NSInteger)age company:(NSString *)company;
@end

@implementation Employee
- (instancetype)initWithName:(NSString *)name age:(NSInteger)age company:(NSString *)company {
    self = [super initWithName:name age:age];  // 调父类指定初始化
    if (self) { _company = [company copy]; }
    return self;
}

- (void)sayHello {
    [super sayHello];                    // 先执行父类逻辑
    NSLog(@"I work at %@", self.company);
}
@end
```

---

## 7. 方法重写 vs 重载（划重点 ⚠️）

- **重写（override）**：子类同名同参 → ✅ 支持
- **重载（overload）**：同名不同参 → ❌ **OC 不支持**

OC 通过"方法名拼参数标签"区分方法，所以这两个**是不同方法**，不算重载：
```objc
- (void)setColor:(UIColor *)color;
- (void)setColor:(UIColor *)color animated:(BOOL)animated;
```
方法名分别是 `setColor:` 和 `setColor:animated:`。

---

## 8. 枚举

```objc
// 普通枚举
typedef NS_ENUM(NSInteger, TaskPriority) {
    TaskPriorityLow = 0,
    TaskPriorityNormal,
    TaskPriorityHigh,
};

// 位运算选项（可组合）
typedef NS_OPTIONS(NSUInteger, TaskFlag) {
    TaskFlagNone     = 0,
    TaskFlagPinned   = 1 << 0,
    TaskFlagArchived = 1 << 1,
};

TaskFlag f = TaskFlagPinned | TaskFlagArchived;
```

---

## 9. 协议（Protocol）—— 面向协议核心

```objc
@protocol TaskDetailDelegate <NSObject>
@required
- (void)taskDetail:(UIViewController *)vc didSaveTask:(Task *)task;
@optional
- (void)taskDetailDidCancel:(UIViewController *)vc;
@end
```

**delegate 模式（业务里到处是）**：
```objc
@interface TaskDetailVC : UIViewController
@property (nonatomic, weak) id<TaskDetailDelegate> delegate;  // ⚠️ weak！
@end

// 调用时：
if ([self.delegate respondsToSelector:@selector(taskDetailDidCancel:)]) {
    [self.delegate taskDetailDidCancel:self];
}
```

**为什么 delegate 必须 weak？** 防止循环引用：A 持有 B（strong），B 又持有 A（strong）→ 谁都释放不了。

---

## 10. Block（闭包）

```objc
// 声明类型
typedef void (^TaskCompletion)(Task *task, NSError *error);

// 作为属性
@property (nonatomic, copy) TaskCompletion onSave;   // ⚠️ copy！

// 调用
self.onSave = ^(Task *task, NSError *error) {
    NSLog(@"saved: %@", task);
};
if (self.onSave) { self.onSave(task, nil); }
```

### 防循环引用三件套
```objc
__weak typeof(self) weakSelf = self;
self.network.completion = ^(id data) {
    __strong typeof(weakSelf) strongSelf = weakSelf;  // 防中途释放
    if (!strongSelf) return;
    [strongSelf handleData:data];
};
```

---

## 11. Category（分类）

给已有类加方法，不用动源码：

```objc
// NSString+MD5.h
@interface NSString (MD5)
- (NSString *)md5;
@end

// 调用
NSString *hash = [@"abc" md5];
```

⚠️ Category 不能加成员变量（要靠 runtime 关联对象）。

---

## 12. 三种范式对比

| 范式 | 在 OC 里的体现 | 适用场景 |
|---|---|---|
| **面向对象 (OOP)** | 类、继承、多态 | 模型、业务实体 |
| **面向协议 (POP)** | `@protocol` + delegate / 多协议组合 | 模块解耦、回调、能力抽象 |
| **面向过程** | C 函数、`static` 工具方法 | 工具函数、性能热点、算法 |

**选择标准**：
- 状态 + 行为绑定 → 类
- "能做某件事" 的能力 → 协议
- 纯计算、无状态 → C 函数

---

## 13. GCD 基础（业务必用）

```objc
// 后台异步
dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
    NSData *data = [self loadFromNetwork];
    // 切回主线程更新 UI
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
});

// 单例
+ (instancetype)sharedInstance {
    static TaskStore *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ instance = [[self alloc] init]; });
    return instance;
}
```

---

## 14. `#import` vs `@class`

- **`.h` 文件里**：能 `@class` 就 `@class`（前向声明），减少编译依赖、避免循环 import
- **`.m` 文件里**：用到具体方法/属性时再 `#import`

```objc
// Task.h
@class TaskCategory;
@interface Task : NSObject
@property (nonatomic, strong) TaskCategory *category;
@end

// Task.m
#import "TaskCategory.h"
```

---

## 15. 学习路上最常见的 5 个坑

1. **NSString 用 strong 不用 copy** → 外面传 NSMutableString 改了你也跟着变
2. **delegate 用 strong** → 循环引用，内存泄漏
3. **Block 里直接用 self** → 循环引用，必须 `__weak`
4. **集合塞 nil** → 直接 crash
5. **以为 `[obj method]` 在 obj 是 nil 时会崩** → 不会，但返回值是 0/nil/NO，要小心
