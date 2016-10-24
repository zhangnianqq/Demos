//
//  UIResponder+Category.m
//  TextfieldCellDemo
//
//  Created by 侯荡荡 on 16/7/12.
//  Copyright © 2016年 Hou. All rights reserved.
//

#import "UIResponder+Category.h"

@implementation UIResponder (Category)

static __weak id currentFirstResponder;

+ (id)currentFirstResponder {
    currentFirstResponder = nil;
    [[UIApplication sharedApplication] sendAction:@selector(findFirstResponder:) to:nil from:nil forEvent:nil];
    return currentFirstResponder;
}

- (void)findFirstResponder:(id)sender {
    currentFirstResponder = self;
}

@end
