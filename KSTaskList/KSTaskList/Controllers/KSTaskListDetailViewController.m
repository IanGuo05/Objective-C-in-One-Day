//
//  KSTaskListDetailViewController.m
//  TaskList
//
//  Created by Ian Guo on 2026/5/26.
//

#import "KSTaskListDetailViewController.h"


@interface KSTaskListDetailViewController ()

@property (nonatomic, strong) KSTask *task;
@property (nonatomic, strong) UITextField *titleField;
@property (nonatomic, strong) UITextField *descField;
@property (nonatomic, strong) UILabel *priorityLabel;
@property (nonatomic, strong) UISlider *prioritySlider;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *deleteButton;

@end

@implementation KSTaskListDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // 根据 mode 配置不同的标题
    if (self.mode == KSTaskDetailModeCreate) {
        self.title = @"New Task";
    } else {
        self.title = @"Task Details";
    }
    
    CGFloat leftMargin = 16;
    CGFloat fieldWidth = self.view.bounds.size.width - 2 * leftMargin;
    
    // Title TextField
    self.titleField = [[UITextField alloc] initWithFrame:CGRectMake(leftMargin, 100, fieldWidth, 40)];
    self.titleField.borderStyle = UITextBorderStyleRoundedRect;
    self.titleField.placeholder = @"Task Title Here!";
    if (self.mode == KSTaskDetailModeEdit) {
        self.titleField.text = self.task.title;
    }
    [self.view addSubview:self.titleField];
    
    // Description TextField
    self.descField = [[UITextField alloc] initWithFrame:CGRectMake(leftMargin, 160, fieldWidth, 100)];
    self.descField.borderStyle = UITextBorderStyleRoundedRect;
    self.descField.placeholder = @"Task Description Here!";
    if (self.mode == KSTaskDetailModeEdit) {
        self.descField.text = self.task.desc;
    }
    [self.view addSubview:self.descField];
    
    // Priority Slider
    self.prioritySlider = [[UISlider alloc] initWithFrame:CGRectMake(leftMargin, 305, fieldWidth, 30)];
    self.prioritySlider.minimumValue = 0;
    self.prioritySlider.maximumValue = 2;
    
    if (self.mode == KSTaskDetailModeCreate) {
        self.prioritySlider.value = KSPriorityNormal;
    } else {
        self.prioritySlider.value = self.task.taskPriority;
    }
    [self.prioritySlider addTarget:self action:@selector(prioritySliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [self updateSliderTintColor];
    [self.view addSubview:self.prioritySlider];
    
    // Priority Label
    self.priorityLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, 270, fieldWidth, 30)];
    self.priorityLabel.font = [UIFont systemFontOfSize:16];
    self.priorityLabel.textAlignment = NSTextAlignmentLeft;
    [self updatePriorityLabel];
    [self.view addSubview:self.priorityLabel];
    
    // Save/Create Button
    self.saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.saveButton.frame = CGRectMake(leftMargin, 350, 140, 44);
    self.saveButton.clipsToBounds = YES;
    self.saveButton.layer.cornerRadius = 8;
    if (self.mode == KSTaskDetailModeCreate) {
        [self.saveButton setTitle:@"Create" forState:UIControlStateNormal];
        self.saveButton.backgroundColor = [UIColor systemGreenColor];
    } else {
        [self.saveButton setTitle:@"Save" forState:UIControlStateNormal];
        self.saveButton.backgroundColor = [UIColor systemBlueColor];
    }
    [self.saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.saveButton.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    [self.saveButton addTarget:self action:@selector(saveButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.saveButton];
    
    // Delete Button
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.deleteButton.frame = CGRectMake(leftMargin + 156, 350, 140, 44);
    self.deleteButton.clipsToBounds = YES;
    self.deleteButton.layer.cornerRadius = 8;
    self.deleteButton.backgroundColor = [UIColor systemRedColor];
    [self.deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    [self.deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.deleteButton.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    [self.deleteButton addTarget:self action:@selector(deleteButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    if (self.mode == KSTaskDetailModeCreate) {
        self.deleteButton.hidden = YES;
    }
    [self.view addSubview:self.deleteButton];
}

- (instancetype)initWithTask:(KSTask *)task {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _task = task;
        _mode = KSTaskDetailModeEdit;
    }
    return self;
}

- (instancetype)initWithNewTask {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _task = [[KSTask alloc] init];
        _mode = KSTaskDetailModeCreate;
    }
    return self;
}

- (void)saveButtonPressed {
    self.task.title = self.titleField.text;
    self.task.desc = self.descField.text;
    self.task.taskPriority = (KSTaskPriority)round(self.prioritySlider.value);
    
    if (self.mode == KSTaskDetailModeCreate) {
        if ([self.delegate respondsToSelector:@selector(taskDetail:didCreateTask:)]) {
            [self.delegate taskDetail:self didCreateTask:self.task];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(taskDetail:didSaveTask:)]) {
            [self.delegate taskDetail:self didSaveTask:self.task];
        }
    }
}

- (void)prioritySliderValueChanged {
    // 步进到离散值：让 slider 只停在 0, 1, 2
    NSInteger steppedValue = (NSInteger)round(self.prioritySlider.value);
    self.prioritySlider.value = steppedValue;
    [self updatePriorityLabel];
    [self updateSliderTintColor];
}

- (void)updatePriorityLabel {
    NSInteger value = (NSInteger)round(self.prioritySlider.value);
    NSString *priorityText;
    switch (value) {
        case KSPriorityLow:    priorityText = @"Priority: Low"; break;
        case KSPriorityNormal: priorityText = @"Priority: Normal"; break;
        case KSPriorityHigh:   priorityText = @"Priority: High"; break;
        default:               priorityText = @"Priority: Normal"; break;
    }
    self.priorityLabel.text = priorityText;
}

- (void)updateSliderTintColor {
    NSInteger value = (NSInteger)round(self.prioritySlider.value);
    switch (value) {
        case KSPriorityLow:    self.prioritySlider.tintColor = [UIColor systemGreenColor]; break;
        case KSPriorityNormal: self.prioritySlider.tintColor = [UIColor systemBlueColor]; break;
        case KSPriorityHigh:   self.prioritySlider.tintColor = [UIColor systemRedColor]; break;
        default:               self.prioritySlider.tintColor = [UIColor systemBlueColor]; break;
    }
}

- (void)deleteButtonPressed {
    if ([self.delegate respondsToSelector:@selector(taskDetail:didDeleteTask:)]) {
        [self.delegate taskDetail:self didDeleteTask:self.task];
    }
}

@end
