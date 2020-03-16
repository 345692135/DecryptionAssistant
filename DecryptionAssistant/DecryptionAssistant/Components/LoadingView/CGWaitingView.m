//
//  CGLoadingView.m
//  together
//
//  Created by 刘立业 on 2017/6/5.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "CGWaitingView.h"
#import "CGFadeView.h"
#import "CGAlertView.h"

@interface CGWaitingView ()

@property (nonatomic, weak) IBOutlet CGFadeView* backgroundView;
@property (nonatomic, weak) IBOutlet CGAlertView* alertView;

@end

@implementation CGWaitingView

- (void)setTitle:(NSString *)title
{
    self.alertView.title = title;
    CGRect frame = self.alertView.frame;
    frame.origin = CGPointMake(floorf((CGRectGetWidth(self.bounds) - CGRectGetWidth(self.alertView.bounds)) / 2), floorf(CGRectGetHeight(self.bounds) * 0.5 - CGRectGetMidY(self.alertView.bounds)));
    self.alertView.frame = frame;
    [self.backgroundView fadeIn];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    CGFadeView* view_background = [[CGFadeView alloc] initWithFrame:self.bounds];
    [self addSubview:view_background];
    self.backgroundView = view_background;
    
    CGAlertView* alertView = [[CGAlertView alloc] initWithFrame:CGRectZero];
    [self addSubview:alertView];
    self.alertView = alertView;
}

- (void)unshow {
    [self.alertView disappear];
    [self.backgroundView fadeOut];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
