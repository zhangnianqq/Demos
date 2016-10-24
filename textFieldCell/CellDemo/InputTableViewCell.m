//
//  InputTableViewCell.m
//  HXBank
//
//  Created by 侯荡荡 on 16/9/18.
//  Copyright © 2016年 Hou. All rights reserved.
//

#import "InputTableViewCell.h"
#import "CellDemo-Swift.h"

static const CGFloat leftPadding     = 15.0;
static const CGFloat rightPadding    = 10.0;
static const CGFloat bothSidePadding = 10.0;
static const CGFloat titleWidth      = 80.0;

@implementation InputTableViewCell
@synthesize iconView, titleLabel, inputField, maskControl, line;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:iconView];
        //iconView.backgroundColor = ColorRandom;
        
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        
        titleLabel.font = [UIFont systemFontOfSize:15.0];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.numberOfLines = 0;
        [self.contentView addSubview:titleLabel];
        //titleLabel.backgroundColor = ColorRandom;
        
        
        inputField = [[HTextField alloc] initWithFrame:CGRectZero];
        inputField.clearsOnBeginEditing = NO;
        inputField.textColor = [UIColor blackColor];
        inputField.clearButtonMode = UITextFieldViewModeWhileEditing;
        inputField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        //inputField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10.f, 0)];
        //inputField.leftViewMode = UITextFieldViewModeAlways;
        inputField.font = [UIFont systemFontOfSize:15.0];
        inputField.delegate = self;
        [inputField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        [self.contentView addSubview:inputField];
        //inputField.backgroundColor = ColorRandom;

        
        maskControl = [[UIControl alloc] initWithFrame:self.contentView.bounds];
        [maskControl addTarget:self action:@selector(respondEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:maskControl];
        maskControl.hidden = YES;
        //maskControl.backgroundColor = ColorRandom;
        
        
        line = [CALayer layer];
        line.frame = CGRectZero;
        
        line.backgroundColor = [UIColor colorWithRGBWithRgb:@"rgb(36, 111, 167)"].CGColor;
        [self.contentView.layer addSublayer:line];

    }
    return self;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL result = [self callbackTextField:textField shouldChangeCharactersInRange:range replacementString:string];
    return result;
}

- (BOOL)callbackTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    BOOL result = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputTableViewCell:textFieldShouldChangeCharactersInRange:replacementString:)]) {
        result = [self.delegate inputTableViewCell:self textFieldShouldChangeCharactersInRange:range replacementString:string];
    }
    return result;
}

#pragma mark - Actions
- (void)textFieldEditingChanged:(HTextField *)textField {
    
    self.inputModel.text = textField.text;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputTableViewCell:textFieldEditingChanged:)]) {
        [self.delegate inputTableViewCell:self textFieldEditingChanged:textField.text];
    }
}

- (void)respondEvent:(id)sender {

    [[UIApplication sharedApplication] sendAction: @selector(resignFirstResponder)
                                               to: nil
                                             from: nil
                                         forEvent: nil];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputTableViewCell:didSelectEvent:)]) {
        [self.delegate inputTableViewCell:self didSelectEvent:self.event];
    }
    
}

- (void)setObject:(InputModel *)object {
    
    if (![object isKindOfClass:[InputModel class]]) return;
    
    self.inputModel             = object;
    iconView.image              = [UIImage imageNamed:object.iconName ?: @""];
    titleLabel.text             = object.title ?: nil;
    inputField.text             = object.text ?: @"";
    inputField.textColor        = object.textColor ?: [UIColor blackColor];
    inputField.placeholder      = object.placeHolder ?: @"";
    inputField.textAlignment    = object.inputAlignment ?: NSTextAlignmentLeft;
    inputField.keyboardType     = object.keyboardType ?: UIKeyboardTypeDefault;
    inputField.secureTextEntry  = object.secureTextEntry;
    maskControl.hidden          = object.editEnabled;
    inputField.enabled          = object.editEnabled;
    maskControl.hidden          = !object.clickEnable;
    inputField.enabled          = !object.clickEnable;
    self.accessoryView          = object.accessoryView ?: nil;
    self.accessoryType          = object.accessoryType ?: UITableViewCellAccessoryNone;
    self.event                  = object.event ?: @"";
}

- (BOOL)inputLimitLength:(NSInteger)length allowString:(NSString *)allowString inputCharacter:(NSString *)character{
   
    if ( [NSString isBlankStringWithString:allowString]) {
        if ([self.inputField.text length] < length || [character length] == 0) {
            return YES;
        }else {
            [self.inputField shakeAnimation];
            return NO;
        }
    } else {
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:allowString] invertedSet];
        //按cs分离出数组,数组按@""分离出字符串
        NSString *filtered = [[character componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        BOOL canChange     = [character isEqualToString:filtered];
        
        if ((canChange && [self.inputField.text length] < length) || [character length] == 0) {
            return YES;
        }else {
            [self.inputField shakeAnimation];
            return NO;
        }
    }
    return YES;
}

#pragma mark - layout
- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    /*
     默认情况下：accessoryView右边距会空出20像素，所以重置accessoryView的frame，让其右边距为0
     */
    CGRect accessoryViewFrame   = self.accessoryView.frame;
    accessoryViewFrame.origin.x = CGRectGetWidth(self.bounds) - CGRectGetWidth(accessoryViewFrame);
    self.accessoryView.frame    = accessoryViewFrame;
    
    CGSize imageSize = iconView.image.size;
    iconView.frame = CGRectMake(leftPadding,
                                (self.height - imageSize.height) / 2,
                                imageSize.width,
                                imageSize.height);
    
    CGFloat padding0 = bothSidePadding;
    if (CGSizeEqualToSize(imageSize, CGSizeZero)) padding0 = 0;
    
    CGFloat title_w  = self.inputModel.titleMaxWidth ?: titleWidth;
    titleLabel.frame = CGRectMake(iconView.right + padding0,
                                  0, [NSString isBlankStringWithString:titleLabel.text]? 0.f : title_w,
                                  self.height);
    
    if (self.inputModel.alignmentBothEnds) [titleLabel alignmentBothEnds];
     CGFloat padding = bothSidePadding;
    if ([NSString isBlankStringWithString:titleLabel.text]) padding = 0;
    
    if (self.accessoryType != UITableViewCellAccessoryNone) {
        inputField.frame = CGRectMake(titleLabel.right + padding,
                                     0,
                                     self.width - (titleLabel.right + padding) - rightPadding - 20,
                                     self.height);
    } else if (self.accessoryView){
        inputField.frame = CGRectMake(titleLabel.right + padding,
                                     0,
                                     self.width - (titleLabel.right + padding) - self.accessoryView.width - rightPadding,
                                     self.height);
    } else {
        inputField.frame = CGRectMake(titleLabel.right + padding,
                                     0,
                                     self.width - (titleLabel.right + padding) - rightPadding,
                                     self.height);
    }
    
    if (!maskControl.isHidden) {
        maskControl.frame = self.contentView.bounds;
    }

    if (CGRectEqualToRect(self.inputModel.lineFrame, CGRectZero)) {
        //line.frame = CGRectMake(inputField.left, inputField.bottom - 0.5, inputField.width, 0.5);
    } else {
        line.frame = self.inputModel.lineFrame;
    }
    
}

@end




@implementation InputModel

@end









