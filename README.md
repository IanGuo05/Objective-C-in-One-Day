# Objective-C 一天速成

为「从其他语言转 iOS Objective-C」准备的最小可用学习包。

## 文件
- `01-syntax.md` — 语法手册（覆盖你列的所有点 + 业务高频补充）
- `02-mini-project-tasklist.md` — 实战项目「任务清单」骨架代码

## 推荐节奏
| 时段 | 做什么 |
|---|---|
| 上午 09:00–12:00 | 通读 01-syntax §1–§7（基础+类+继承）|
| 下午 13:00–15:00 | 通读 01-syntax §8–§15（协议/Block/Category/GCD/避坑）|
| 下午 15:00–17:00 | 跟着 02-mini-project 敲一遍 |
| 下午 17:00–18:00 | 完成自检清单 + 翻一段你们项目里的真实代码验证理解 |

## 必须补的语法点（你的清单里漏的）
1. **内存管理 / ARC**：`strong/weak/copy/assign` 选择 + 循环引用
2. **Block**：业务回调主力，`__weak self` 必学
3. **Category**：iOS 项目里 `XXX+Extension.h` 满地都是
4. **GCD**：`dispatch_async` 主子线程切换
5. **`id` / `instancetype` / `nil` 家族**：看代码会迷糊的小东西
6. **`#import` vs `@class`**：编译速度和循环引用相关

## 上手第一周建议
- 每天看一段你们项目里的真实代码，对照本手册翻译成"心智模型"
- 准备一个 `objc-notes.md`，把踩到的坑写下来
- 一周后回看，应该 90% 业务代码都能读
