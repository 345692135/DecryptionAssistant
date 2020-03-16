//
//  YzdHUDImageView.m
//  YzdHUD
//
//  Created by ShineYang on 13-12-6.
//  Copyright (c) 2013年 YangZhiDa. All rights reserved.
//

#import "YzdHUDImageView.h"

static YzdHUDImageView *_shareHUDView = nil;
@implementation YzdHUDImageView
{
    UIImageView* signImageView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        imageView.image = [UIImage imageNamed:@"fg_sign_right"];
        imageView.center = CGPointZero;
        [self addSubview:imageView];
        signImageView = imageView;
    }
    return self;
}

+(YzdHUDImageView *)shareHUDView{
    if (!_shareHUDView) {
        _shareHUDView = [[YzdHUDImageView alloc] init];
        _shareHUDView.alpha = 0;
    }
    return _shareHUDView;
}

//- (void)drawRect:(CGRect)rect
//{
//    if (_graghType == kcgGraghType_none) {
//        
//    }
//    else if (_graghType == kcgGraghType_success) {
//        //画底色
//        CGContextRef context = UIGraphicsGetCurrentContext();
////        CGContextSaveGState(context);
////        
////        CGContextSetRGBFillColor(context, 0, 1, 0, 1);
////        
////        CGContextFillEllipseInRect(context, CGRectMake(0, 0, 34, 34));
////        
////        CGContextRestoreGState(context);
//        //画对号
//        
//        CGContextSaveGState(context);
//        
//        CGContextDrawImage(context, CGRectMake(30, 30, -30, -30), [UIImage imageNamed:@"fg_sign_right"].CGImage);
////        CGContextSetRGBStrokeColor(context, 27.0 / 255, 169.0 / 255, 186.0 / 255, 1);
////        CGContextSetLineWidth(context, 4.0f);
////        CGContextSetLineJoin(context, kCGLineJoinRound);
////        CGContextSetLineCap(context, kCGLineCapButt);
////        
////        CGContextMoveToPoint(context, 9, 18);
////        CGContextAddLineToPoint(context, 15, 24);
////        CGContextAddLineToPoint(context, 27, 12);
////        
////        CGContextStrokePath(context);
//        
//        CGContextRestoreGState(context);
//    }
//    else if (_graghType == kcgGraghType_fail) {
//        //画底色
//        CGContextRef context = UIGraphicsGetCurrentContext();
//        CGContextSaveGState(context);
//        
//        CGContextSetRGBFillColor(context, 0, 1, 0, 1);
//        
//        CGContextFillEllipseInRect(context, CGRectMake(0, 0, 34, 34));
//        
//        CGContextRestoreGState(context);
//        //画错号
//        CGContextSaveGState(context);
//        
//        CGContextSetRGBStrokeColor(context, 1, 1, 1, 1);
//        CGContextSetLineWidth(context, 4.0f);
//        CGContextSetLineJoin(context, kCGLineJoinRound);
//        CGContextSetLineCap(context, kCGLineCapButt);
//        
//        CGContextMoveToPoint(context, 10, 10);
//        CGContextAddLineToPoint(context, 24, 24);
//        CGContextMoveToPoint(context, 24, 10);
//        CGContextAddLineToPoint(context, 10, 24);
//        
//        CGContextStrokePath(context);
//        
//        CGContextRestoreGState(context);
//    }
//}

- (void)setGraghType:(cgGraghType)graghType
{
    _graghType = graghType;
    if (graghType == kcgGraghType_success) {
        signImageView.hidden = NO;
    }
    else if (graghType == kcgGraghType_fail) {
        signImageView.hidden = YES;
    }
    else if (graghType == kcgGraghType_none) {
        signImageView.hidden = YES;
    }
//    [self setNeedsDisplay];
}

@end
