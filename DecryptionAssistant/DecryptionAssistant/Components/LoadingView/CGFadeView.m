//
//  CGFadeView.m
//  together
//
//  Created by 刘立业 on 2017/6/5.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "CGFadeView.h"

@implementation CGFadeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    self.alpha = 0;
}

- (void)fadeIn
{
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.alpha = 1;
    } completion:nil];
}

- (void)fadeOut
{
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.alpha = 0;
    } completion:nil];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
