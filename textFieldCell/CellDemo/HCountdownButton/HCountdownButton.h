//
//  HCountdownButton.h
//  HXBank
//
//  Created by 侯荡荡 on 16/9/21.
//  Copyright © 2016年 Hou. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@class HCountdownButton;

@protocol HCountdownButtonDelegate <NSObject>
@optional
//计时完成
- (void) fireFinished:(HCountdownButton *)countdownButton;
//时间跳动
- (void) countingDown:(HCountdownButton *)countdownButton leftTimeInterval:(NSTimeInterval)leftTimeInterval;
@end

@interface HCountdownButton : UIButton

@property (nonatomic, copy) IBInspectable NSString *identifyKey;
@property (nonatomic, strong) IBInspectable UIColor *disabledBackgroundColor;
@property (nonatomic, strong) IBInspectable UIColor *disabledTitleColor;
@property (nonatomic, assign) IBInspectable NSTimeInterval timeInterval;
@property (nonatomic, assign, readonly) NSTimeInterval leftTimeInterval;
@property (nonatomic, weak) id <HCountdownButtonDelegate>  delegate;

//开始计时
- (void)fire;
- (void)invalidate;

@end
