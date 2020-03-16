//
//  UIWindow+YzdHUD.m
//  YzdHUD
//
//  Created by ShineYang on 13-12-6.
//  Copyright (c) 2013年 YangZhiDa. All rights reserved.
//

#import "UIWindow+YzdHUD.h"
#import "YzdHUDBackgroundView.h"
#import "YzdHUDImageView.h"
#import "YzdHUDIndicator.h"
#import "YzdHUDLabel.h"
#import "CGMacros.h"

#define YzdHUDBounds CGRectMake(0, 0, 150, 46)
#define YzdHUDYesBounds CGRectMake(0, 0, 80, 80)
#define YzdHUDYesAndMessageBounds CGRectMake(0, 0, 120, 46)
#define YzdHUDCenter CGPointMake(self.bounds.size.width/2, self.bounds.size.height * 0.4)
#define YzdHUDBackgroundAlpha 1
#define YzdHUDComeTime 0.15
#define YzdHUDStayTime 1
#define YzdHUDGoTime 0.15
#define YzdHUDFont 16

@implementation UIWindow (YzdHUD)

-(void)showHUDWithText:(NSString *)text Type:(showHUDType)type Enabled:(BOOL)enabled{
    
    [[YzdHUDBackgroundView shareHUDView] removeFromSuperview];
    [[YzdHUDImageView shareHUDView] removeFromSuperview];
    [[YzdHUDLabel shareHUDView] removeFromSuperview];
    [[YzdHUDIndicator shareHUDView] removeFromSuperview];

    if (type == ShowPhotoYes) {
        [self showHUDWithText:text Type:type Enabled:(BOOL)enabled Bounds:YzdHUDYesBounds Center:YzdHUDCenter BackgroundAlpha:YzdHUDBackgroundAlpha ComeTime:YzdHUDComeTime StayTime:YzdHUDStayTime GoTime:YzdHUDGoTime];
    }
    else if (type == ShowPhotoYesAndMessage) {
        [self showHUDWithText:text Type:type Enabled:enabled Bounds:YzdHUDYesAndMessageBounds Center:YzdHUDCenter BackgroundAlpha:YzdHUDBackgroundAlpha ComeTime:YzdHUDComeTime StayTime:YzdHUDStayTime GoTime:YzdHUDGoTime];
    }
    else {
        [self showHUDWithText:text Type:type Enabled:(BOOL)enabled Bounds:YzdHUDBounds Center:YzdHUDCenter BackgroundAlpha:YzdHUDBackgroundAlpha ComeTime:YzdHUDComeTime StayTime:YzdHUDStayTime GoTime:YzdHUDGoTime];
    }
}

-(void)showHUDWithText:(NSString *)text Type:(showHUDType)type Enabled:(BOOL)enabled Bounds:(CGRect)bounds Center:(CGPoint)center BackgroundAlpha:(CGFloat)backgroundAlpha ComeTime:(CGFloat)comeTime StayTime:(CGFloat)stayTime GoTime:(CGFloat)goTime{
//    static BOOL isShow = YES;
//    if (isShow) {
//        isShow = NO;

    
        [self addSubview:[YzdHUDBackgroundView shareHUDView]];
        [self addSubview:[YzdHUDImageView shareHUDView]];
        [self addSubview:[YzdHUDLabel shareHUDView]];
        [self addSubview:[YzdHUDIndicator shareHUDView]];
        
//    }
    //背景
    [YzdHUDBackgroundView shareHUDView].center = center;
    
    //文字
    if (type == ShowPhotoYesAndMessage) {
        [YzdHUDLabel shareHUDView].center = CGPointMake(26 + 5 + CGRectGetMidX(bounds), center.y);
        [YzdHUDLabel shareHUDView].textAlignment = NSTextAlignmentLeft;
    }
    else {
        [YzdHUDLabel shareHUDView].center = CGPointMake(center.x, center.y);
        [YzdHUDLabel shareHUDView].textAlignment = NSTextAlignmentCenter;
    }
    
    CGFloat width_bound = GET_LABEL_WIDTH(text, CGRectGetHeight(bounds), [UIFont systemFontOfSize:YzdHUDFont]) + 20;
    width_bound = fminf(width_bound, [UIScreen mainScreen].bounds.size.width - 20);
    bounds = CGRectMake(0, 0, width_bound, CGRectGetHeight(bounds));
    
    
    //图片
    if (type == ShowPhotoYesAndMessage) {
        [YzdHUDImageView shareHUDView].center = CGPointMake(26, center.y);
    }
    else {
        [YzdHUDImageView shareHUDView].center = CGPointMake(center.x, center.y);
    }
    //        [YzdHUDIndicator shareHUDView].center = CGPointMake(center.x, center.y - bounds.size.height/6);
    [self goTimeBounds:bounds];

    
    
    [YzdHUDLabel shareHUDView].bounds = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
    if ([self textLength:text] * YzdHUDFont + 20 > bounds.size.width) {
        if ([self textLength:text] * (YzdHUDFont - 2) + 20 >= bounds.size.width) {
            [YzdHUDLabel shareHUDView].font = [UIFont systemFontOfSize:YzdHUDFont - 4];
        }
        else {
            [YzdHUDLabel shareHUDView].font = [UIFont systemFontOfSize:YzdHUDFont - 2];
        }
    }
    else {
        [YzdHUDLabel shareHUDView].font = [UIFont systemFontOfSize:YzdHUDFont];
    }
    
    self.userInteractionEnabled = enabled;
    
    switch (type) {
        case ShowLoading:
            [self showLoadingWithText:(NSString *)text Type:(showHUDType)type Enabled:(BOOL)enabled Bounds:(CGRect)bounds Center:(CGPoint)center BackgroundAlpha:(CGFloat)backgroundAlpha ComeTime:(CGFloat)comeTime StayTime:(CGFloat)stayTime GoTime:(CGFloat)goTime];
            break;
        case ShowPhotoNone:
            [self showPhotoNoneWithText:(NSString *)text Type:(showHUDType)type Enabled:(BOOL)enabled Bounds:(CGRect)bounds Center:(CGPoint)center BackgroundAlpha:(CGFloat)backgroundAlpha ComeTime:(CGFloat)comeTime StayTime:(CGFloat)stayTime GoTime:(CGFloat)goTime];
            break;
        case ShowPhotoYesAndMessage:
            [self showPhotoYesAndMessageWithText:(NSString *)text Type:(showHUDType)type Enabled:(BOOL)enabled Bounds:(CGRect)bounds Center:(CGPoint)center BackgroundAlpha:(CGFloat)backgroundAlpha ComeTime:(CGFloat)comeTime StayTime:(CGFloat)stayTime GoTime:(CGFloat)goTime];
            break;
        case ShowPhotoYes:
            [self showPhotoYesWithText:(NSString *)text Type:(showHUDType)type Enabled:(BOOL)enabled Bounds:(CGRect)bounds Center:(CGPoint)center BackgroundAlpha:(CGFloat)backgroundAlpha ComeTime:(CGFloat)comeTime StayTime:(CGFloat)stayTime GoTime:(CGFloat)goTime];
            break;
        case ShowPhotoNo:
            [self showPhotoNoWithText:(NSString *)text Type:(showHUDType)type Enabled:(BOOL)enabled Bounds:(CGRect)bounds Center:(CGPoint)center BackgroundAlpha:(CGFloat)backgroundAlpha ComeTime:(CGFloat)comeTime StayTime:(CGFloat)stayTime GoTime:(CGFloat)goTime];
            break;
        case ShowDismiss:
            [self showDismissWithText:(NSString *)text Type:(showHUDType)type Enabled:(BOOL)enabled Bounds:(CGRect)bounds Center:(CGPoint)center BackgroundAlpha:(CGFloat)backgroundAlpha ComeTime:(CGFloat)comeTime StayTime:(CGFloat)stayTime GoTime:(CGFloat)goTime];
            break;
            
        default:
            break;
    }
}

-(void)showLoadingWithText:(NSString *)text Type:(showHUDType)type Enabled:(BOOL)enabled Bounds:(CGRect)bounds Center:(CGPoint)center BackgroundAlpha:(CGFloat)backgroundAlpha ComeTime:(CGFloat)comeTime StayTime:(CGFloat)stayTime GoTime:(CGFloat)goTime{
    if ([YzdHUDBackgroundView shareHUDView].alpha != 0) {
        return;
    }
  
    [YzdHUDLabel shareHUDView].text = text;
    [[YzdHUDIndicator shareHUDView] stopAnimating];
    [YzdHUDImageView shareHUDView].alpha = 0;

    [UIView animateWithDuration:comeTime animations:^{
        [self comeTimeBounds:bounds];
        [self comeTimeAlpha:backgroundAlpha withImage:NO];
        [[YzdHUDIndicator shareHUDView] startAnimating];
    } completion:^(BOOL finished) {

    }];
}

-(void)showPhotoNoneWithText:(NSString *)text Type:(showHUDType)type Enabled:(BOOL)enabled Bounds:(CGRect)bounds Center:(CGPoint)center BackgroundAlpha:(CGFloat)backgroundAlpha ComeTime:(CGFloat)comeTime StayTime:(CGFloat)stayTime GoTime:(CGFloat)goTime{
    if ([[YzdHUDIndicator shareHUDView] isAnimating]) {
        [[YzdHUDIndicator shareHUDView] stopAnimating];
        
        [YzdHUDImageView shareHUDView].bounds = CGRectZero;
//        CGRectMake(0, 0, (bounds.size.width/2.5 - 5) * 2, (bounds.size.height/2.5 - 5) * 2);
    }else{
        if ([YzdHUDBackgroundView shareHUDView].alpha != 0) {
            return;
        }
        [self goTimeBounds:bounds];
        [self goTimeInit];
    }
    
    [YzdHUDLabel shareHUDView].text = text;
    [YzdHUDImageView shareHUDView].graghType = kcgGraghType_none;
    [UIView animateWithDuration:comeTime animations:^{
        [self comeTimeBounds:bounds];
        [self comeTimeAlpha:backgroundAlpha withImage:YES];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:stayTime animations:^{
            [self stayTimeAlpha:backgroundAlpha];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:goTime animations:^{
                [self goTimeBounds:bounds];
                [self goTimeInit];;
            } completion:^(BOOL finished) {
                //Nothing
            }];
        }];
    }];
}
-(void)showPhotoYesAndMessageWithText:(NSString *)text Type:(showHUDType)type Enabled:(BOOL)enabled Bounds:(CGRect)bounds Center:(CGPoint)center BackgroundAlpha:(CGFloat)backgroundAlpha ComeTime:(CGFloat)comeTime StayTime:(CGFloat)stayTime GoTime:(CGFloat)goTime{
    if ([[YzdHUDIndicator shareHUDView] isAnimating]) {
        [[YzdHUDIndicator shareHUDView] stopAnimating];
        
        [YzdHUDImageView shareHUDView].bounds = CGRectZero;
        //        CGRectMake(0, 0, (bounds.size.width/2.5 - 5) * 2, (bounds.size.height/2.5 - 5) * 2);
    }else{
        if ([YzdHUDBackgroundView shareHUDView].alpha != 0) {
            return;
        }
        [self goTimeBounds:bounds];
        [self goTimeInit];
    }
    
    [YzdHUDLabel shareHUDView].text = text;
    [YzdHUDImageView shareHUDView].graghType = kcgGraghType_success;
    [UIView animateWithDuration:comeTime animations:^{
        [self comeTimeBounds:bounds];
        [self comeTimeAlpha:backgroundAlpha withImage:YES];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:stayTime animations:^{
            [self stayTimeAlpha:backgroundAlpha];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:goTime animations:^{
                [self goTimeBounds:bounds];
                [self goTimeInit];;
            } completion:^(BOOL finished) {
                //Nothing
            }];
        }];
    }];
}

-(void)showPhotoYesWithText:(NSString *)text Type:(showHUDType)type Enabled:(BOOL)enabled Bounds:(CGRect)bounds Center:(CGPoint)center BackgroundAlpha:(CGFloat)backgroundAlpha ComeTime:(CGFloat)comeTime StayTime:(CGFloat)stayTime GoTime:(CGFloat)goTime{
    if ([[YzdHUDIndicator shareHUDView] isAnimating]) {
        [[YzdHUDIndicator shareHUDView] stopAnimating];
        
        [YzdHUDImageView shareHUDView].bounds = CGRectZero;
//        CGRectMake(0, 0, (bounds.size.width/2.5 - 5) * 2, (bounds.size.height/2.5 - 5) * 2);
    }else{
        if ([YzdHUDBackgroundView shareHUDView].alpha != 0) {
            return;
        }
        [self goTimeBounds:bounds];
        [self goTimeInit];
    }
    
    [YzdHUDLabel shareHUDView].text = text;
    [YzdHUDImageView shareHUDView].graghType = kcgGraghType_success;
    [UIView animateWithDuration:comeTime animations:^{
        [self comeTimeBounds:bounds];
        [self comeTimeAlpha:backgroundAlpha withImage:YES];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:stayTime animations:^{
            [self stayTimeAlpha:backgroundAlpha];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:goTime animations:^{
                [self goTimeBounds:bounds];
                [self goTimeInit];;
            } completion:^(BOOL finished) {
                //Nothing
            }];
        }];
    }];
}

-(void)showPhotoNoWithText:(NSString *)text Type:(showHUDType)type Enabled:(BOOL)enabled Bounds:(CGRect)bounds Center:(CGPoint)center BackgroundAlpha:(CGFloat)backgroundAlpha ComeTime:(CGFloat)comeTime StayTime:(CGFloat)stayTime GoTime:(CGFloat)goTime{
    if ([[YzdHUDIndicator shareHUDView] isAnimating]) {
        [[YzdHUDIndicator shareHUDView] stopAnimating];
        
        [YzdHUDImageView shareHUDView].bounds = CGRectZero;
//        CGRectMake(0, 0, (bounds.size.width/2.5 - 5) * 2, (bounds.size.height/2.5 - 5) * 2);
    }else{
        if ([YzdHUDBackgroundView shareHUDView].alpha != 0) {
            return;
        }
        [self goTimeBounds:bounds];
        [self goTimeInit];
    }
    
    [YzdHUDLabel shareHUDView].text = text;
    [YzdHUDImageView shareHUDView].graghType = kcgGraghType_fail;
    [UIView animateWithDuration:comeTime animations:^{
        [self comeTimeBounds:bounds];
        [self comeTimeAlpha:backgroundAlpha withImage:YES];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:stayTime animations:^{
            [self stayTimeAlpha:backgroundAlpha];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:goTime animations:^{
                [self goTimeBounds:bounds];
                [self goTimeInit];;
            } completion:^(BOOL finished) {
                //Nothing
            }];
        }];
    }];
}

-(void)showDismissWithText:(NSString *)text Type:(showHUDType)type Enabled:(BOOL)enabled Bounds:(CGRect)bounds Center:(CGPoint)center BackgroundAlpha:(CGFloat)backgroundAlpha ComeTime:(CGFloat)comeTime StayTime:(CGFloat)stayTime GoTime:(CGFloat)goTime{
    if ([[YzdHUDIndicator shareHUDView] isAnimating]) {
        [[YzdHUDIndicator shareHUDView] stopAnimating];
    }
    
    [YzdHUDLabel shareHUDView].text = nil;
//    [YzdHUDImageView shareHUDView].image = nil;
    [UIView animateWithDuration:goTime animations:^{
        [YzdHUDImageView shareHUDView].bounds = CGRectZero;
//        CGRectMake(0, 0, (bounds.size.width/2.5 - 5) * 2, (bounds.size.height/2.5 - 5) * 2);
        [self goTimeBounds:bounds];
        [self goTimeInit];
    } completion:^(BOOL finished) {
        //Nothing
    }];
}

#pragma mark 状态
-(void)goTimeBounds:(CGRect)bounds{
    [YzdHUDBackgroundView shareHUDView].bounds =
    CGRectMake(0, 0, bounds.size.width, bounds.size.height);
    [YzdHUDImageView shareHUDView].bounds = CGRectZero;
//    CGRectMake(0, 0, (bounds.size.width/2.5 - 5) * 2, (bounds.size.height/2.5 - 5) * 2);
}

-(void)goTimeInit{
    [YzdHUDBackgroundView shareHUDView].alpha = 0;
    [YzdHUDImageView shareHUDView].alpha = 0;
    [YzdHUDLabel shareHUDView].alpha = 0;
    [[YzdHUDIndicator shareHUDView] stopAnimating];
}

-(void)stayTimeAlpha:(CGFloat)alpha{
    [YzdHUDBackgroundView shareHUDView].alpha = alpha - 0.01;
}

-(void)comeTimeBounds:(CGRect)bounds{
    [YzdHUDBackgroundView shareHUDView].bounds =
    CGRectMake(0, 0, bounds.size.width, bounds.size.height);
    [YzdHUDImageView shareHUDView].bounds = CGRectZero;
//    CGRectMake(0, 0, bounds.size.width/2.5 - 5, bounds.size.height/2.5 - 5);
}

-(void)comeTimeAlpha:(CGFloat)alpha withImage:(BOOL)isImage{
    [YzdHUDBackgroundView shareHUDView].alpha = alpha;
    [YzdHUDLabel shareHUDView].alpha = 1;
    if (isImage) {
        [YzdHUDImageView shareHUDView].alpha = 1;
    }
}

#pragma mark - 计算字符串长度
- (int)textLength:(NSString *)text{
    float number = 0.0;
    for (int index = 0; index < [text length]; index++)
    {
        NSString *character = [text substringWithRange:NSMakeRange(index, 1)];
        
        if ([character lengthOfBytesUsingEncoding:NSUTF8StringEncoding] == 3)
        {
            number++;
        }
        else
        {
            number = number + 0.5;
        }
    }
    return ceil(number);
}


@end
