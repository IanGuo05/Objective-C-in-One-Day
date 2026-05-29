//
//  KSUIColor.m
//  TaskList
//
//  Created by Ian Guo on 2026/5/26.
//

#import "KSUIColor.h"

@implementation KSUIColor

+ (UIColor *)taskColorByPriority:(KSTaskPriority)priority {
    switch (priority) {
        case KSPriorityLow: return [UIColor colorWithWhite:0.95 alpha:1];
        case KSPriorityNormal: return [UIColor whiteColor];
        case KSPriorityHigh: return [UIColor colorWithRed:1.0 green:0.9 blue:0.9 alpha:1];
    }
}

@end
