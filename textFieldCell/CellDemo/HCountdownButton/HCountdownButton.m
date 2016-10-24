//
//  HCountdownButton.m
//  HXBank
//
//  Created by 侯荡荡 on 16/9/21.
//  Copyright © 2016年 Hou. All rights reserved.
//

#import "HCountdownButton.h"
#import "HCountdownButtonManager.h"

@interface HCountdownButton ()

@property (nonatomic, strong) UILabel *overlayLabel;
@property (nonatomic, assign) NSTimeInterval leftTime;
@end

@implementation HCountdownButton

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self initialize];
    }
    
    return self;
}

- (void)dealloc {
    NSLog(@"***> %s [%@]", __func__, _identifyKey);
}

- (void)initialize {
    self.identifyKey        = NSStringFromClass([self class]);
    self.clipsToBounds      = YES;
    self.layer.cornerRadius = 4;
    
    [self addSubview:self.overlayLabel];
}

- (UILabel *)overlayLabel {
    if (!_overlayLabel) {
        _overlayLabel                 = [UILabel new];
        _overlayLabel.textColor       = self.titleLabel.textColor;
        _overlayLabel.backgroundColor = self.backgroundColor;
        _overlayLabel.font            = self.titleLabel.font;
        _overlayLabel.textAlignment   = NSTextAlignmentCenter;
        _overlayLabel.hidden          = YES;
    }
    
    return _overlayLabel;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.overlayLabel.frame = self.bounds;
    
    if ([[HCountdownButtonManager defaultManager] countdownTaskExistWithKey:self.identifyKey task:nil]) {
        
        [self shouldCountingDown:^(NSTimeInterval leftTimeInterval) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(countingDown:leftTimeInterval:)]) {
                [self.delegate countingDown:self leftTimeInterval:leftTimeInterval];
            }
        } Completed:^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(fireFinished:)]) {
                [self.delegate fireFinished:self];
            }
        }];
    }
    
}


- (void)shouldCountingDown:(void (^)(NSTimeInterval))countingDown Completed:(void(^)())completed{
    
    self.enabled             = NO;
    self.titleLabel.alpha    = 0;
    self.overlayLabel.hidden = NO;
    self.overlayLabel.text   = self.titleLabel.text;
    self.overlayLabel.font   = self.titleLabel.font;
    self.overlayLabel.textAlignment = self.titleLabel.textAlignment;
    [self.overlayLabel setTextColor:self.disabledTitleColor ?:self.titleLabel.textColor];
    [self.overlayLabel setBackgroundColor:self.disabledBackgroundColor ?: self.backgroundColor];
    
    
    NSTimeInterval timeIntervals = self.timeInterval ?: 60;
    
    __weak __typeof(self) weakSelf = self;
    [[HCountdownButtonManager defaultManager] scheduledCountDownWithKey:self.identifyKey timeInterval:timeIntervals countingDown:^(NSTimeInterval leftTimeInterval) {
        __strong __typeof(weakSelf) self = weakSelf;
        self.overlayLabel.text = [NSString stringWithFormat:@"%@ 秒后重试", @(leftTimeInterval)];
        self.leftTime = leftTimeInterval;
        if (countingDown) countingDown(leftTimeInterval);
        
    } finished:^(NSTimeInterval finalTimeInterval) {
        
        __strong __typeof(weakSelf) self = weakSelf;
        self.enabled             = YES;
        self.overlayLabel.hidden = YES;
        self.titleLabel.alpha    = 1;
        [self.overlayLabel setBackgroundColor:self.backgroundColor];
        [self.overlayLabel setTextColor:self.titleLabel.textColor];
        if (completed) completed();
        
    }];
}

- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    if (![[self actionsForTarget:target forControlEvent:UIControlEventTouchUpInside] count]) {
        return;
    }
    
    [super sendAction:action to:target forEvent:event];
}

- (NSTimeInterval)leftTimeInterval {
    
    return self.leftTime;
}


- (void)fire {
    [self shouldCountingDown:nil Completed:nil];
}

- (void)invalidate {
    [[HCountdownButtonManager defaultManager] stopCountDownWithKey:self.identifyKey];
}

@end

