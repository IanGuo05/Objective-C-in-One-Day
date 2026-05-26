//
//  KSUIColor.h
//  TaskList
//
//  Created by Ian Guo on 2026/5/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIColor.h>
#import "../Models/KSTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface KSUIColor : NSObject

+ (UIColor *)taskColorByPriority:(KSTaskPriority) priority;

@end

NS_ASSUME_NONNULL_END
