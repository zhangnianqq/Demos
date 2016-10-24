//
//  InputTableViewCell.h
//  HXBank
//
//  Created by 侯荡荡 on 16/9/18.
//  Copyright © 2016年 Hou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTextField.h"

@class InputModel, InputTableViewCell;

@protocol InputTableViewCellDelegate <NSObject>
@optional
- (void) inputTableViewCell:(InputTableViewCell *)cell didSelectEvent:(NSString *)event;
//输入框变换时触发
- (void) inputTableViewCell:(InputTableViewCell *)cell textFieldEditingChanged:(NSString *)value;
//将要变化时根据输入格式是否正确 返回是否把对应字符加入输入框内
- (BOOL) inputTableViewCell:(InputTableViewCell *)cell textFieldShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
@end

@interface InputTableViewCell : UITableViewCell
<UITextFieldDelegate>
//模型赋值
- (void) setObject:(InputModel *)object;
//长度限制  字符格式限制 字符串
- (BOOL) inputLimitLength:(NSInteger)length allowString:(NSString *)allowString inputCharacter:(NSString *)character;

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel     *titleLabel;
@property (nonatomic, strong) HTextField  *inputField;
@property (nonatomic, strong) UIControl   *maskControl;
@property (nonatomic, strong) CALayer     *line;
@property (nonatomic, strong) NSString    *event;
@property (nonatomic, strong) InputModel  *inputModel;
@property (nonatomic, weak  ) id <InputTableViewCellDelegate> delegate;

@end


@interface InputModel : NSObject
@property (nonatomic, strong) NSString         *iconName;
@property (nonatomic, strong) NSString         *title;
@property (nonatomic, strong) NSString         *text;
@property (nonatomic, strong) UIColor          *textColor;
@property (nonatomic, strong) NSString         *placeHolder;
@property (nonatomic, assign) NSTextAlignment  inputAlignment;
@property (nonatomic, assign) UIKeyboardType   keyboardType;
@property (nonatomic, assign) BOOL             editEnabled;
@property (nonatomic, assign) BOOL             clickEnable;
@property (nonatomic, assign) BOOL             secureTextEntry;         //是否密文
@property (nonatomic, assign) BOOL             alignmentBothEnds;
@property (nonatomic, assign) CGFloat          titleMaxWidth;
@property (nonatomic, assign) CGRect           lineFrame;
@property (nonatomic, strong) NSString         *event;
@property (nonatomic, strong) UIView           *accessoryView;
@property (nonatomic, assign) UITableViewCellAccessoryType accessoryType;
@end


