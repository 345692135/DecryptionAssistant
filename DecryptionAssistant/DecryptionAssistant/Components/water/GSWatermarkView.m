//
//  GSWaterMarkView.m
//  GSWatermarkView
//
//  Created by gensee on 2020/2/28.
//  Copyright © 2020年 sheng. All rights reserved.
//

#import "GSWatermarkView.h"

#if !TARGET_OS_WATCH
#include <asl.h>
#include <notify.h>
#include <notify_keys.h>
#include <sys/time.h>

#import <libkern/OSAtomic.h>
#endif

#define LOG_DEBUG 1

@implementation GSWatermarkParam

@end

////弧度转角度
//static inline double gs_radianToDegree(int radian) {
//    return ((radian) * (180.0 / M_PI));
//}
//角度转弧度
static inline double gs_degreeToRadian(int angle) {
    return ((angle) / 180.0 * M_PI);
}

@interface GSWatermarkView ()

@end

@implementation GSWatermarkView {
    CGSize _textSize;
    double _privateAngle;
    dispatch_source_t _timer;
    BOOL _isShow;
    int durationCD;
    int intervalCD;
    // 检测是否是当次渲染的哨兵对象
    int32_t _sentiel;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self setup];
        [self _cancelPreviousDraw];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self _cancelPreviousDraw];
}

- (void)setup {
    _privateAngle = 0;
    _horizonSpacing = 10;
    _verticalSpacing = 10;
//    self.backgroundColor = [UIColor clearColor];
}

- (void)setRichtext:(NSAttributedString *)richtext {
    if (richtext.length > 180)  return;
    _richtext = richtext;
    _textSize = [_richtext boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    if (_timer) {
        _timer = nil;
    }
    _isShow = YES;
    [self _cancelPreviousDraw];
    [self setNeedsDisplay];
}

- (void)_startTimer {
    if (_timer) {
        _timer = nil;
    }
    if (_duration > 0) {
        if (_interval == 0) {
            self.alpha = 1.f;
            return;
        }
    }else {
        self.alpha = 0.f;
        return;
    }
    
    if (_timer) {
        _timer = nil;
    }
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, (1 * NSEC_PER_SEC)), (1 * NSEC_PER_SEC), 0);
    __weak typeof(self) wself = self;
    dispatch_source_set_event_handler(_timer, ^{
        __strong typeof(self) sself = wself;
        if (sself->_isShow) {
            sself->durationCD++;
            if (sself->durationCD == sself->_duration) {
                sself->durationCD = 0;
                sself->_isShow = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    sself.alpha = 0.f;
                });
            }
        }else {
            sself->intervalCD++;
            if (sself->intervalCD == sself->_interval) {
                sself->intervalCD = 0;
                sself->_isShow = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    sself.alpha = 1.f;
                });
            }
        }
    });
    dispatch_resume(_timer);
}


- (void)setAngle:(int)angle {
    _angle = angle;
    _privateAngle = gs_degreeToRadian(angle);
    [self _cancelPreviousDraw];
    [self setNeedsDisplay];
}

- (void)setVerticalSpacing:(int)verticalSpacing {
    _verticalSpacing = verticalSpacing;
    [self _cancelPreviousDraw];
    [self setNeedsDisplay];
}

- (void)setHorizonSpacing:(int)horizonSpacing {
    _horizonSpacing = horizonSpacing;
    [self _cancelPreviousDraw];
    [self setNeedsDisplay];
}


- (void)setDuration:(int)duration {
    _duration = duration;
    [self _startTimer];
}

- (void)setInterval:(int)interval {
    _interval = interval;
    [self _startTimer];
}

// setNeedsDisplay triggerd this method , and also layer`s dispaly() method
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    
    CGSize size = self.bounds.size;
    //TODO: queue pool will be use
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *image = [self makeWatermarkImg:size];
        if (image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.layer.contents = (__bridge id)(image.CGImage);
                self.layer.contentsGravity = kCAGravityCenter;
                self.layer.masksToBounds = YES;
                self.layer.contentsScale = image.scale;
            });
        }
    });
}


- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self _startTimer];
}

- (UIImage *)makeWatermarkImg:(CGSize)size{
    int32_t value = _sentiel;
    BOOL (^isCancelled)(void) = ^BOOL() {
        return value != self->_sentiel;
    };
    // Create the bitmap context
    // draw water mark - step 1
    CGFloat MaxW,MaxH,sqrtvalue;
    sqrtvalue = sqrt(size.width*size.width + size.height*size.height);
    MaxW = sqrtvalue;
    MaxH = sqrtvalue;
    //context scale factor is 0 , use UIGraphicsBeginImageContext maybe blur
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(MaxW, MaxH), NO, 0);
#if DEBUG
    struct timeval timeval = {
        .tv_sec = 0
    };
    gettimeofday(&timeval,NULL);
#endif
    if (CGSizeEqualToSize(_textSize, CGSizeZero)) {
        return nil;
    }
    CGFloat H = _textSize.height;
    CGFloat W = _textSize.width;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //计算竖向数量
    int max_ver = (MaxH + _verticalSpacing) / (H + _verticalSpacing);
    int max_hor = (MaxW + _horizonSpacing) / (W + _horizonSpacing);
    
    int remain = (int)(MaxW + _horizonSpacing) % (int)(W + _horizonSpacing);
    if (remain > _horizonSpacing - 10) {
        max_hor ++;
#if LOG_DEBUG
        printf("remain %d max hor ++\n",remain);
#endif
    }
    //    printf("My View [%f] [%f] \n",self.bounds.size.width,self.bounds.size.height);
//        printf("Max [%f] [%f] \n",MaxW,MaxH);
//        printf("Max Num [%d] [%d] \n",max_hor,max_ver);
    //长度可以容下2个
    if (max_hor <= 1) {
        for (int i = 0; i < max_ver; i ++) {
            if (i % 2 == 0) {
                int gap = (size.width - W)/2;
                if (gap <= 0) gap = 0;
                [_richtext drawAtPoint:CGPointMake(gap - W - _horizonSpacing, (i)*(H + _verticalSpacing))];
                [_richtext drawAtPoint:CGPointMake(gap, (i)*(H + _verticalSpacing))];
                [_richtext drawAtPoint:CGPointMake(gap + W + _horizonSpacing, (i)*(H + _verticalSpacing))];
            }else {
                int gap = (W / 2);
                if (gap <= 0) gap = 0;
                [_richtext drawAtPoint:CGPointMake(-gap + (self.bounds.size.width - W)/2, (i)*(H + _verticalSpacing))];
                [_richtext drawAtPoint:CGPointMake(-gap + (self.bounds.size.width - W)/2 + (W + _horizonSpacing), (i)*(H + _verticalSpacing))];
            }
            if (isCancelled()) {
                UIGraphicsEndImageContext();
#if LOG_DEBUG
                printf("[DEBUG] cancel previous draw 0 \n");
#endif
                return nil;
            }
        }
    }else if (max_hor == 2) {
        for (int i = 0; i < max_ver; i ++) {
            if (i % 2 == 0) {
                int gap = (size.width - W)/2;
                if (gap <= 0) gap = 0;
                [_richtext drawAtPoint:CGPointMake(gap - W - _horizonSpacing, (i)*(H + _verticalSpacing))];
                [_richtext drawAtPoint:CGPointMake(gap, (i)*(H + _verticalSpacing))];
                [_richtext drawAtPoint:CGPointMake(gap + W + _horizonSpacing, (i)*(H + _verticalSpacing))];
            }else {
                int gap = _horizonSpacing;
                if (gap <= 0) gap = 0;
                [_richtext drawAtPoint:CGPointMake(gap - W - _horizonSpacing, (i)*(H + _verticalSpacing))];
                [_richtext drawAtPoint:CGPointMake(gap, (i)*(H + _verticalSpacing))];
                [_richtext drawAtPoint:CGPointMake(gap + (W + _horizonSpacing), (i)*(H + _verticalSpacing))];
            }
            if (isCancelled()) {
                UIGraphicsEndImageContext();
#if LOG_DEBUG
                printf("[DEBUG] cancel previous draw 1 \n");
#endif
                return nil;
            }
        }
    }else {
        
        for (int i = 0; i < max_ver; i ++) {
            if (i % 2 == 0) {
                for (int j = 0; j < max_hor; j ++) {
                    if (j == 0) [_richtext drawAtPoint:CGPointMake(- W - _horizonSpacing, (i)*(H + _verticalSpacing))];
                    [_richtext drawAtPoint:CGPointMake((j)*(W + _horizonSpacing), (i)*(H + _verticalSpacing))];
                }
            }else {
                for (int j = 0; j < (max_hor - 1); j ++) {
                    if (j == 0) [_richtext drawAtPoint:CGPointMake((W + _horizonSpacing)/2 - W - _horizonSpacing, (i)*(H + _verticalSpacing))];
                    [_richtext drawAtPoint:CGPointMake((W + _horizonSpacing)/2 + (j)*(W + _horizonSpacing), (i)*(H + _verticalSpacing))];
                }
            }
            if (isCancelled()) {
                UIGraphicsEndImageContext();
#if LOG_DEBUG
                printf("[DEBUG] cancel previous draw 2 \n");
#endif
                return nil;
            }
        }
    }
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //context scale factor is 0 , use UIGraphicsBeginImageContext maybe blur
    //rotation method - step 2
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(MaxW, MaxH), NO, 0);
    context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, MaxW/2, MaxH/2);
    CGContextRotateCTM(context, _privateAngle);
    CGContextTranslateCTM(context, -MaxW/2, -MaxH/2);
    
    if (isCancelled()) {
        UIGraphicsEndImageContext();
        return nil;
    }
    
    [newImage drawAtPoint:CGPointMake(0, 0)];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
#if DEBUG
    struct timeval timeval2 = {
        .tv_sec = 0
    };
    gettimeofday(&timeval2,NULL);
    NSTimeInterval interval = timeval2.tv_sec - timeval.tv_sec + (timeval2.tv_usec - timeval.tv_usec)/ 1e9;
    // judge spending time to debug
    if (interval > 0.05) {
        printf("[WARNING] GSWatermarkView draw image speed time too long (%f sec) \n",interval);
    }
#endif
    
    return newImage;
}

- (void)_cancelPreviousDraw {
    OSAtomicIncrement32(&_sentiel);
}

#pragma mark - touch

// ignored touch event
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return nil;
}

@end
