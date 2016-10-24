//
//  HTextField.m
//  HXBank
//
//  Created by 侯荡荡 on 16/9/18.
//  Copyright © 2016年 Hou. All rights reserved.
//

#import "HTextField.h"


@interface HTextField ()
- (UIToolbar *) generateToolbar;
- (void) doneButtonDidPressed:(id)sender;
- (void) notifierKeyboardWillShow:(NSNotification*)notification;
- (void) notifierKeyboardWillHide:(NSNotification*)notification;
@end

@implementation HTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notifierKeyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notifierKeyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
        self.inputAccessoryView = [self generateToolbar];
        
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        //self.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.placeHolderColor = [UIColor lightGrayColor];
    }
    return self;
}

- (void)setPlaceHolderColor:(UIColor *)placeHolderColor {
    _placeHolderColor = placeHolderColor;
}


//控制placeHolder的颜色、字体
- (void) drawPlaceholderInRect:(CGRect)rect {

    [_placeHolderColor setFill];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode            = NSLineBreakByTruncatingTail;
    style.alignment                = self.textAlignment;
    NSDictionary* attr             = [NSDictionary dictionaryWithObjectsAndKeys:
                                      style, NSParagraphStyleAttributeName,
                                      self.font, NSFontAttributeName,
                                      self.placeHolderColor, NSForegroundColorAttributeName,
                                      nil];
    
    CGRect bounds   = self.bounds;
    CGSize size     = [self.placeholder boundingRectWithSize:CGSizeMake(bounds.size.width, bounds.size.height)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:attr
                                                     context:nil].size;
    
    if (self.textAlignment == NSTextAlignmentLeft ||
        self.textAlignment == NSTextAlignmentCenter) {
        rect.origin.x = 0.0f;
    } else if (self.textAlignment == NSTextAlignmentRight) {
        rect.origin.x = bounds.size.width - size.width;
    }
    rect.size.width = size.width;
    [[self placeholder] drawInRect:rect withAttributes:attr];
    
    
}


//控制placeHolder的位置，左右缩20
- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    
    CGSize size  = [[NSString string] sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:self.font, NSFontAttributeName, nil]];
    CGRect inset = CGRectMake(bounds.origin.x,
                              1.0f,
                              bounds.size.width,
                              size.height);//更好理解些
    return inset;
}

- (BOOL) resignFirstResponder {
    [super resignFirstResponder];
    
    return YES;
}


- (UIToolbar*) generateToolbar {
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, [[UIScreen mainScreen] bounds].size.width, 44.0)];
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonDidPressed:)];
    
    [toolbar setItems:[NSArray arrayWithObjects:item1, item2, nil]];
    
    return toolbar;
}

- (void) doneButtonDidPressed:(id)sender {
    [self resignFirstResponder];
}


- (BOOL) canPerformAction:(SEL)action withSender:(id)sender {
    
    if (action == @selector(copy:) ||
        action == @selector(paste:) ||
        action == @selector(select:) ||
        action == @selector(selectAll:)) {
        return NO;
    }
    
    return [super canPerformAction:action withSender:sender];
}


- (void) notifierKeyboardWillShow:(NSNotification*)notification {
    
    /*
    UIView* firstResponder = [UIResponder currentFirstResponder];
    
    if (![firstResponder isEqual:self]) {
        return;
    }
    */
    
    UIView* subView = nil;
    if ([NSStringFromClass(self.superview.class) isEqualToString:@"UITableViewCellContentView"]) {
        subView = self.superview.superview.superview;
        while (subView != nil) {
            if ([subView.superview isKindOfClass:[UITableView class]]) {
                subView = subView.superview;
                break;
            }
            subView = subView.superview;
        }
        UITableView* tableView = (UITableView*)subView;
        
        CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
        NSDictionary *info                   = notification.userInfo;
        CGRect screenFrame                   = [tableView.superview convertRect:tableView.frame
                                                                         toView:[UIApplication sharedApplication].keyWindow];
        CGFloat tableViewBottomOnScreen      = screenFrame.origin.y + screenFrame.size.height;
        CGFloat tableViewGap                 = screenHeight - tableViewBottomOnScreen;
        CGSize keyboardSize                  = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        UIEdgeInsets contentInsets           = tableView.contentInset;
        contentInsets.bottom                 = keyboardSize.height - tableViewGap;
        
        
        CGFloat animationDuration            = ((NSNumber *)[info objectForKey:UIKeyboardAnimationDurationUserInfoKey]).doubleValue;
        NSUInteger animationCurve            = ((NSNumber *)[info objectForKey:UIKeyboardAnimationCurveUserInfoKey]).intValue;
        
        
        
        [UIView animateWithDuration:animationDuration
                              delay:0
                            options:animationCurve
                         animations: ^{
                             tableView.contentInset          = contentInsets;
                             tableView.scrollIndicatorInsets = contentInsets;
                             
                         }
         
                         completion:nil];
        
    }
    
}

- (void) notifierKeyboardWillHide:(NSNotification*)notification {
    
    UIView* subView = nil;
    if ([NSStringFromClass(self.superview.class) isEqualToString:@"UITableViewCellContentView"]) {
        subView = self.superview.superview.superview;
        while (subView != nil) {
            if ([subView.superview isKindOfClass:[UITableView class]]) {
                subView = subView.superview;
                break;
            }
            subView = subView.superview;
        }
        UITableView* tableView = (UITableView*)subView;
        
        NSDictionary *info                   = notification.userInfo;
        
        CGFloat animationDuration            = ((NSNumber *)[info objectForKey:UIKeyboardAnimationDurationUserInfoKey]).doubleValue;
        NSUInteger animationCurve            = ((NSNumber *)[info objectForKey:UIKeyboardAnimationCurveUserInfoKey]).intValue;
        
        [UIView animateWithDuration:animationDuration
                              delay:0.25f
                            options:animationCurve
                         animations: ^{
                             tableView.contentInset          = UIEdgeInsetsZero;//contentInsets;
                             tableView.scrollIndicatorInsets = UIEdgeInsetsZero;//contentInsets;
                         }
         
                         completion:nil];
        
    }
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}





@end
