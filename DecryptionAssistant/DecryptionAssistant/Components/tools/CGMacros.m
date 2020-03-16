//
//  CGMacros.m
//  safemail
//
//  Created by Apple on 15/10/28.
//  Copyright © 2015年 Apple. All rights reserved.
//

#import "CGMacros.h"
#import "UIWindow+YzdHUD.h"
#import "AppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>
#import "ChineseInclude.h"
#import "PinYinForObjc.h"
//#import "CGContactData.h"
//#import "CGAttachmentManager.h"
//#import "Attachment.h"
//#import "CGAttachmentData.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
//#import <MailCore/MailCore.h> //♐
#import "CGWaitingViewManager.h"

typedef enum : NSUInteger {
    indicatorState_none,
    indicatorState_countTime,
    indicatorState_wait,
} indicatorState;

@implementation CGMacros
{
    BOOL stopCommandBuffer;
    indicatorState state_;
    CGFloat scaleFactor;    //适配缩放率(水平方向增量的一半)
    CGFloat scaleFactor2;    //适配缩放率(水平方向增量）
    CGFloat scaleFactorY;    //适配缩放率（垂直方向增量）
}

static CGMacros* sharedInstance_ = nil;
static SystemSoundID  shakeSoundID;
static SystemSoundID  succeedSoundID;
static SystemSoundID  newMailSoundID;
static SystemSoundID  errorSoundID;

static NSArray* promptStringArray = nil;

+ (CGMacros*) sharedInstance
{
    if (! sharedInstance_) {
        sharedInstance_ = [[CGMacros alloc] init];
        
        NSString *path_succeed = @"/System/Library/Audio/UISounds/mail-sent.caf";
        NSString *path_newMail = @"/System/Library/Audio/UISounds/new-mail.caf";
        NSString *path_error = @"/System/Library/Audio/UISounds/ReceivedMessage.caf";
        
        shakeSoundID = kSystemSoundID_Vibrate;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path_succeed], &succeedSoundID);
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path_newMail], &newMailSoundID);
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path_error], &errorSoundID);

        promptStringArray = @[NSLocalizedString(@"Mark", nil),
                              NSLocalizedString(@"Save", nil),
                              NSLocalizedString(@"Add", nil),
                              NSLocalizedString(@"Encryption", nil),
                              NSLocalizedString(@"Cancelation", nil),
                              NSLocalizedString(@"Set", nil),
                              NSLocalizedString(@"Reset", nil)];
        
    }
    
    return sharedInstance_;
}

- (CGFloat)scaleFactor
{
    if (scaleFactor == 0) {
        scaleFactor = (CGRectGetWidth([UIScreen mainScreen].bounds) / 320 - 1) / 2 + 1;
    }
    
    return scaleFactor;
}

- (CGFloat)scaleFactor2
{
    if (scaleFactor2 == 0) {
        scaleFactor2 = CGRectGetWidth([UIScreen mainScreen].bounds) / 320;
    }
    
    return scaleFactor2;
}

- (CGFloat)scaleFactorY
{
    if (scaleFactorY == 0) {
        scaleFactorY = CGRectGetHeight([UIScreen mainScreen].bounds) / 480;
    }
    
    return scaleFactorY;
}

- (CGFloat)getLabelWidthWithContent:(NSString *)content withLabelHeight:(CGFloat)height withFont:(UIFont *)font
{
    CGSize contentLabelContentSize = CGSizeZero;
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil];
    contentLabelContentSize = [content boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
    return ceilf(contentLabelContentSize.width);
}

- (CGFloat)getLabelHeightWithContent:(NSString *)content withLabelWidth:(CGFloat)width withFont:(UIFont *)font
{
    CGSize contentLabelContentSize = CGSizeZero;
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil];
    contentLabelContentSize = [content boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
    return ceilf(contentLabelContentSize.height);
}

- (CGFloat)getLabelHeightWithContent:(NSString *)content withLabelWidth:(CGFloat)width withFont:(UIFont *)font withLineSpace:(CGFloat)lineSpace
{
    CGSize contentLabelContentSize = CGSizeZero;
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpace;
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, paragraphStyle, NSParagraphStyleAttributeName,nil];
    contentLabelContentSize = [content boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
    return ceilf(contentLabelContentSize.height);
}

/**
 * 提示
 */
- (void)alertWithMessage:(NSString *)message target:(id)target completion:(void (^)(UIAlertAction * _Nullable))completion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:completion];
        [alertController addAction:action];
        [target presentViewController:alertController animated:YES completion:nil];
    });
}

- (void)showMessageWithMessage:(NSString*)message
{
    [[UIApplication sharedApplication].keyWindow showHUDWithText:message Type:ShowPhotoNone Enabled:YES];
}

- (nullable NSString*)generatedId
{
    return [[NSString alloc] initWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000];
}

- (NSString*)timeStamp
{
    NSDate* date = [NSDate date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMMddHHmmssFFF";
    return [dateFormatter stringFromDate:date];
}

- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:candidate];
}

- (NSString*)timeDescriptionWithDate:(NSDate*)date
{
    NSDate* nowDate = [NSDate date];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMMddHHmm";
    
    NSString* dateString = [dateFormatter stringFromDate:date];
    NSInteger year_date = [[dateString substringWithRange:NSMakeRange(0, 4)] integerValue];
    NSInteger month_date = [[dateString substringWithRange:NSMakeRange(4, 2)] integerValue];
    NSInteger day_date = [[dateString substringWithRange:NSMakeRange(6, 2)] integerValue];
    NSInteger hour_date = [[dateString substringWithRange:NSMakeRange(8, 2)] integerValue];
    NSInteger minute_date = [[dateString substringWithRange:NSMakeRange(10, 2)] integerValue];
    
    NSString* nowString = [dateFormatter stringFromDate:nowDate];
    NSInteger year_now = [[nowString substringWithRange:NSMakeRange(0, 4)] integerValue];
    NSInteger month_now = [[nowString substringWithRange:NSMakeRange(4, 2)] integerValue];
    NSInteger day_now = [[nowString substringWithRange:NSMakeRange(6, 2)] integerValue];
    NSInteger hour_now = [[nowString substringWithRange:NSMakeRange(8, 2)] integerValue];
    NSInteger minute_now = [[nowString substringWithRange:NSMakeRange(10, 2)] integerValue];

    //今年
    if (year_date == year_now) {
        //本月
        if (month_date == month_now) {
            //今天
            if (day_date == day_now) {
                //本小时
                if (hour_date == hour_now) {
                    //过去
                    if (minute_now - minute_date >= 0) {
                        if (minute_now - minute_date < 1) {
                            return @"刚刚";
                        }
                        else if (minute_now - minute_date <= 59) {
                            return [[NSString alloc] initWithFormat:@"%ld%@", (minute_now - minute_date), @"分钟前"];
                        }
                    }
                }
                return [[NSString alloc] initWithFormat:@"%02ld:%02ld", (long)hour_date, (long)minute_date];
            }
            //昨天
            else if (day_date - day_now == -1) {
//                return [[NSString alloc] initWithFormat:@"%@%02ld:%02ld", NSLocalizedString(@"Yesterday ", nil), (long)hour_date, (long)minute_date];
                if ([[self getPreferredLanguage] isEqualToString:@"zh-Hans-US"]) {
                    return [[NSString alloc] initWithFormat:@"%@%02ld:%02ld", @"昨天", (long)hour_date, (long)minute_date];
                }
                else {
                    return @"昨天";
                }
            }
            //明天
            else if (day_date - day_now == 1) {
                return [[NSString alloc] initWithFormat:@"%@%02ld:%02ld", @"明天", (long)hour_date, (long)minute_date];
            }
            //其他天
            else {
                
            }
        }
        //其他月
        else {
            
        }
        return [[NSString alloc] initWithFormat:@"%ld-%02ld", (long)month_date, (long)day_date];
    }
    //过去
    else if (year_date < year_now) {
        
    }
    //未来
    else {
        
    }
    return [[NSString alloc] initWithFormat:@"%ld-%02ld-%02ld", (long)year_date, (long)month_date, (long)day_date];
}

#pragma mark -
#pragma mark HUD

- (void)startActivityWithEnable:(BOOL)enable
{
    if (1) {
        UIWindow* window = ((AppDelegate*)[UIApplication sharedApplication].delegate).window;
        UIView* view_mask = [window viewWithTag:101];
        if (!view_mask) {
            UIView* view = [[UIView alloc] initWithFrame:window.bounds];
            view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.15];
            view.tag = 101;
            [window addSubview:view];
        }
    }
    stopCommandBuffer = NO;
    [self showIndicator:YES];
}

- (void)stopActivity
{
    UIWindow* window = ((AppDelegate*)[UIApplication sharedApplication].delegate).window;
    UIView* view_mask = [window viewWithTag:101];
    if (!view_mask) {
    }
    else {
        [view_mask removeFromSuperview];
    }
    
    stopCommandBuffer = YES;
    [self showIndicator:NO];
}

- (void)showIndicator:(BOOL)isShow
{
    switch (state_) {
        case indicatorState_none:
        {
            if (isShow) {
                state_ = indicatorState_countTime;
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
                [self performSelector:@selector(onTimeOut) withObject:nil afterDelay:0.5f];
                NSLog(@"1");
            }
            else {
                
            }
        }
            break;
            
        case indicatorState_countTime:
        {
            if (isShow) {
                
            }
            else {
                
            }
        }
            break;
            
        case indicatorState_wait:
        {
            if (isShow) {
                
            }
            else {
                state_ = indicatorState_none;
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                NSLog(@"2");
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)onTimeOut
{
    state_ = indicatorState_wait;
    [self showIndicator:! stopCommandBuffer];
}

- (void)playSoundEffectWithSoundType:(cgSoundType)soundType
{
    if (soundType == kcgSoundType_shake) {
        AudioServicesPlaySystemSound(shakeSoundID);
    }
    else if (soundType == kcgSoundType_succeed) {
        AudioServicesPlaySystemSound(succeedSoundID);
    }
    else if (soundType == kcgSoundType_newMail) {
        AudioServicesPlaySystemSound(newMailSoundID);
    }
    else if (soundType == kcgSoundType_error) {
        AudioServicesPlaySystemSound(errorSoundID);
    }
}

- (nullable NSArray*)searchWithKey:(nullable NSString*)key inArray:(nullable NSArray*)dataArray
{
    NSMutableArray* searchResults = [[NSMutableArray alloc]init];
    //没中文
    if (key.length>0&&![ChineseInclude isIncludeChineseInString:key]) {
        for (int i=0; i<dataArray.count; i++) {
            //目标有中文
            if ([ChineseInclude isIncludeChineseInString:dataArray[i]]) {
                //全拼
                NSString *tempPinYinStr = [PinYinForObjc chineseConvertToPinYin:dataArray[i]];
                NSRange titleResult=[tempPinYinStr rangeOfString:key options:NSCaseInsensitiveSearch];
                if (titleResult.length>0) {
                    [searchResults addObject:dataArray[i]];
                }
                //拼音首字母
                NSString *tempPinYinHeadStr = [PinYinForObjc chineseConvertToPinYinHead:dataArray[i]];
                NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:key options:NSCaseInsensitiveSearch];
                if (titleHeadResult.length>0) {
                    [searchResults addObject:dataArray[i]];
                }
            }
            //目标没有中文
            else {
                NSRange titleResult=[dataArray[i] rangeOfString:key options:NSCaseInsensitiveSearch];
                if (titleResult.length>0) {
                    [searchResults addObject:dataArray[i]];
                }
            }
        }
        //有中文
    } else if (key.length>0&&[ChineseInclude isIncludeChineseInString:key]) {
        for (NSString *tempStr in dataArray) {
            NSRange titleResult=[tempStr rangeOfString:key options:NSCaseInsensitiveSearch];
            if (titleResult.length>0) {
                [searchResults addObject:tempStr];
            }
        }
    }
    return searchResults;
}

- (BOOL)searchWithKey:(nullable NSString*)key keyHasChinese:(BOOL)keyHasChinese inString:(nullable NSString*)string
{
    //没中文
    if (key.length>0&&!keyHasChinese) {
            //目标有中文
            if ([ChineseInclude isIncludeChineseInString:string]) {
                //全拼
                NSString *tempPinYinStr = [PinYinForObjc chineseConvertToPinYin:string];
                NSRange titleResult=[tempPinYinStr rangeOfString:key options:NSCaseInsensitiveSearch];
                if (titleResult.length>0) {
                    return YES;
                }
                //拼音首字母
                NSString *tempPinYinHeadStr = [PinYinForObjc chineseConvertToPinYinHead:string];
                NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:key options:NSCaseInsensitiveSearch];
                if (titleHeadResult.length>0) {
                    return YES;
                }
            }
            //目标没有中文
            else {
                NSRange titleResult=[string rangeOfString:key options:NSCaseInsensitiveSearch];
                if (titleResult.length>0) {
                    return YES;
                }
            }
        //有中文
    } else if (key.length>0&&keyHasChinese) {
        NSRange titleResult=[string rangeOfString:key options:NSCaseInsensitiveSearch];
        if (titleResult.length>0) {
            return YES;
        }
    }
    return NO;
}

- (nullable NSArray*)searchWithKey:(nullable NSString*)key inContactDataArray:(nullable NSArray*)dataArray
{
    NSMutableArray* searchResults = [[NSMutableArray alloc] init];
    
//    if (dataArray) {
//        BOOL keyHasChinese = [ChineseInclude isIncludeChineseInString:key];
//        NSMutableArray* searchResults = [[NSMutableArray alloc]init];
//        NSInteger count = dataArray.count;
//        for (int i = 0; i < count; i++) {
//            CGContactData* contactData = dataArray[i];
//            if ([self searchWithKey:key keyHasChinese:keyHasChinese inString:contactData.friendMail]
//                || [self searchWithKey:key keyHasChinese:keyHasChinese inString:contactData.friendNickName]) {
//                [searchResults addObject:contactData];
//            }
//        }
//    }
    
    return searchResults;
}

- (nullable UIImage *)image:(nullable UIImage *)image fillSize:(CGSize)viewsize
{
    CGSize size = image.size;
    
    CGFloat factor = [UIScreen mainScreen].scale;
    
    CGFloat scalex = viewsize.width / size.width;
    CGFloat scaley = viewsize.height / size.height;
    CGFloat scale = MAX(scalex, scaley);
    
    UIGraphicsBeginImageContext(CGSizeMake(viewsize.width * factor, viewsize.height * factor));
    
    CGFloat width = size.width * scale;
    CGFloat height = size.height * scale;
    
    float dwidth = ((viewsize.width - width) / 2.0f);
    float dheight = ((viewsize.height - height) / 2.0f);
    
    CGRect rect = CGRectMake(dwidth * factor, dheight * factor, size.width * scale * factor, size.height * scale * factor);
    [image drawInRect:rect];
    
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newimg;
}

- (void)showDownloadingStatus
{
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    UIWindow* window = appDelegate.window;
    CGRect rect = [UIScreen mainScreen].bounds;
    NSInteger tag_label = 88;
    
    UILabel* label_ = [window viewWithTag:tag_label];
    if (label_) {
        [label_ removeFromSuperview];
    }
    
    UILabel* label_prompt = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 30)];
    label_prompt.textColor = [UIColor whiteColor];
    label_prompt.font = [UIFont systemFontOfSize:15];
    label_prompt.text = NSLocalizedString(@"Loading attachments, please wait...", nil);//@"正在下载附件，请稍后...";
    label_prompt.textAlignment = NSTextAlignmentCenter;
    [label_prompt sizeToFit];
    CGRect frame = label_prompt.frame;
    frame.size.width += 20;
    frame.size.height += 20;
    label_prompt.frame = frame;
    label_prompt.center = CGPointMake(CGRectGetMidX(rect), CGRectGetHeight(rect) * 0.3);
    label_prompt.tag = tag_label;
    
    label_prompt.backgroundColor = [UIColor colorWithHex:0x383f41];
    label_prompt.layer.cornerRadius = 3;
    label_prompt.layer.masksToBounds = YES;
    
    [window addSubview:label_prompt];
}

- (void)showPrompt:(NSString*)prompt
{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UIWindow* window = appDelegate.window;
    
    NSInteger tag_container = 76;
    UIView* view_container = [window viewWithTag:tag_container];
    
    //删除已有的容器
    if (view_container) {
        [view_container removeFromSuperview];
    }
    
    //创建容器
    view_container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    view_container.backgroundColor = [UIColor blackColor];
    view_container.layer.cornerRadius = 5;
    view_container.layer.masksToBounds = YES;
    view_container.userInteractionEnabled = NO;
    view_container.tag = tag_container;
    [window addSubview:view_container];
    
    //创建文本
    UILabel* label_prompt = [[UILabel alloc] initWithFrame:CGRectMake(10, 6, 100, 100)];
    label_prompt.textColor = [UIColor whiteColor];
    label_prompt.font = [UIFont systemFontOfSize:15];
    label_prompt.textAlignment = NSTextAlignmentCenter;
    label_prompt.numberOfLines = 0;
    [view_container addSubview:label_prompt];
    
    //设置文本框大小
    CGRect frame_promptLabel = label_prompt.frame;
    frame_promptLabel.size.width = CGRectGetWidth(window.bounds) - 30 * 2;
    label_prompt.frame = frame_promptLabel;
    label_prompt.text = prompt;
    [label_prompt sizeToFit];
    
    //设置容器大小
    CGRect frame_containerView = view_container.frame;
    frame_containerView.size.width = CGRectGetWidth(label_prompt.frame) + 20;
    frame_containerView.size.height = CGRectGetHeight(label_prompt.frame) + 12;
    view_container.frame = frame_containerView;
    
    //设置容器位置
    view_container.center = CGPointMake(CGRectGetMidX(window.bounds), CGRectGetHeight(window.bounds) - 60 - CGRectGetMidY(view_container.bounds));
    
    //容器消失动画
    [UIView animateWithDuration:0.2 delay:1 + prompt.length * 0.06 options:UIViewAnimationOptionCurveEaseIn animations:^{
        view_container.alpha = 0;
    } completion:^(BOOL finished) {
        [view_container removeFromSuperview];
    }];
}

- (void)removeDownloadingStatus
{
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    UIWindow* window = appDelegate.window;
    NSInteger tag_label = 88;
    
    UILabel* label_ = [window viewWithTag:tag_label];
    if (label_) {
        [label_ removeFromSuperview];
    }
}

- (void)showHudWithImageFileName:(NSString*)fileName promptContent:(NSString*)promptContent
{
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    UIWindow* window = appDelegate.window;
    CGRect rect = [UIScreen mainScreen].bounds;
    NSInteger tag_imageView = 77;
    
    UIImageView* imageView_ = [window viewWithTag:tag_imageView];
    if (imageView_) {
        [imageView_ stopAnimating];
        [imageView_ removeFromSuperview];
    }
    
    imageView_ = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 91, 91)];
    imageView_.center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    imageView_.image = [UIImage imageNamed:fileName];
    imageView_.tag = tag_imageView;
    [window addSubview:imageView_];
    
    
    UILabel* label_ = [[UILabel alloc] initWithFrame:CGRectMake(2, 50, 92 - 2 * 2, 35)];
    label_.textColor = [UIColor whiteColor];
    label_.font = [UIFont systemFontOfSize:13];
    label_.text = promptContent;
//    label_.adjustsFontSizeToFitWidth = YES;
    label_.numberOfLines = 0;
    label_.textAlignment = NSTextAlignmentCenter;
    [imageView_ addSubview:label_];
    
    label_.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint* labelConstraintWidth = [NSLayoutConstraint constraintWithItem:label_ attribute:(NSLayoutAttributeWidth) relatedBy:(NSLayoutRelationLessThanOrEqual) toItem:imageView_ attribute:(NSLayoutAttributeWidth) multiplier:1 constant:0];
    [imageView_ addConstraint:labelConstraintWidth];
    
    NSLayoutConstraint* labelConstraintCenterX = [NSLayoutConstraint constraintWithItem:label_ attribute:(NSLayoutAttributeCenterX) relatedBy:(NSLayoutRelationEqual) toItem:imageView_ attribute:(NSLayoutAttributeCenterX) multiplier:1 constant:0];
    [imageView_ addConstraint:labelConstraintCenterX];
    

    
    NSLayoutConstraint* labelConstraintCenterY = [NSLayoutConstraint constraintWithItem:label_ attribute:(NSLayoutAttributeCenterY) relatedBy:(NSLayoutRelationEqual) toItem:imageView_ attribute:(NSLayoutAttributeBottom) multiplier:1 constant:-(CGRectGetMidY(imageView_.bounds) - 5) / 2];
    [imageView_ addConstraint:labelConstraintCenterY];

    
    imageView_.alpha = 0;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        imageView_.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 delay:1.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
            imageView_.alpha = 0;
        } completion:^(BOOL finished) {
            [imageView_ removeFromSuperview];
        }];
    }];
}

//kcgPromptType_sign,//标记成功
//kcgPromptType_save,//保存成功
//kcgPromptType_add,//添加成功、添加失败
//kcgPromptType_AddPw,//加密成功、加密失败
//kcgPromptType_RemovePw //取消成功、取消失败
- (void)showPromptWithPromptType:(cgPromptType)promptType isSucceed:(BOOL)isSucceed
{
    NSString* string_type = promptStringArray[promptType];
    NSString* string_result = isSucceed ? NSLocalizedString(@"succeed", nil) : NSLocalizedString(@"fail", nil);
    NSString* string_space = NSLocalizedString(@" ", nil);
    NSString* string_content = [[NSString alloc] initWithFormat:@"%@%@%@", string_type, string_space, string_result];
    NSString* imageFileName = isSucceed ? @"safemail_prompt_succeed" : @"safemail_prompt_fail";
    [self showHudWithImageFileName:imageFileName promptContent:string_content];
}

//- (void)showSignSucceed
//{
//    [self showHudWithImageFileName:@"safemail_biaoji"];
//}
//
//- (void)showSaveSucceed
//{
//    [self showHudWithImageFileName:@"safemail_baocun"];
//}
//
//- (void)showAddSucceed
//{
//    [self showHudWithImageFileName:@"safemail_tianjia"];
//}
//
//- (void)showAddFail
//{
//    [self showHudWithImageFileName:@"safemail_tianjiashb"];
//}
//
//- (void)showAddPwSucceed
//{
//    [self showHudWithImageFileName:@"safemail_jiami"];
//}
//
//- (void)showAddPwFail
//{
//    [self showHudWithImageFileName:@"safemail_jiamishb"];
//}
//
//- (void)showRemovePwSucceed
//{
//    [self showHudWithImageFileName:@"safemail_jiemi"];
//}
//
//- (void)showRemovePwFail
//{
//    [self showHudWithImageFileName:@"safemail_jiemishb"];
//}

//根据简称得到首字索引
- (NSInteger)indexWithString:(nullable NSString*)testString
{
    NSInteger index = 0;
    if (testString && ![[testString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        
        unichar ch = [testString characterAtIndex:0];
        
        if (0x4e00 < ch  && ch < 0x9fff) {
            NSString *tempPinYinHeadStr = [PinYinForObjc chineseConvertToPinYinHead:[testString substringToIndex:1]];
            index = [tempPinYinHeadStr characterAtIndex:0] % 6;
        }
        else {
            index = ch % 6;
        }
    }
    return index;
}


//根据名字得到简称
- (nullable NSString*)fetchStringWithString:(nullable NSString*)testString
{
    if (!testString || [testString isEqualToString:@""]) {
        return @"未";
    }
    
    //    NSString *testString = @"春1mianBU觉晓";
    NSMutableString* resultString = [[NSMutableString alloc] init];
    NSInteger strLength = [testString length];
    CGFloat number = 0;
    
    for (int i = 0; i < strLength; i++) {
        CGFloat newNumber = 0;
        unichar ch = [testString characterAtIndex:i];
        
        //第一个字母是中文
        if (0x4300 < ch && ch < 0x9fff) {
            NSString* str = [testString substringWithRange:NSMakeRange(i, 1)];
            if ([str isEqualToString:@"【"] || [str isEqualToString:@"】"]) {
                continue;
            }
            newNumber = number + 3.0f;
        }
        //第一个字母非中文
        else {
            if ((ch >= 48 && ch < 58) ||
                (ch >= 65 && ch < 91) ||
                (ch >= 97 && ch < 123) ||
                (ch == '~')) {
                
            }
            else {
                continue;
            }
            
            newNumber = number + 1.5f;
        }
        
        if (newNumber > 3.0f) {
            return resultString;
        }
        
        [resultString appendString:[testString substringWithRange:NSMakeRange(i, 1)]];
        number = newNumber;
    }
    
    if ([resultString isEqualToString:@""]) {
        [resultString appendString:@"未"];
    }
    
    return resultString;
    
    
    //    NSInteger alength = [testString length];
    //    for (int i = 0; i<alength; i++) {
    //        char commitChar = [testString characterAtIndex:i];
    //        NSString *temp = [testString substringWithRange:NSMakeRange(i,1)];
    //        const char *u8Temp = [temp UTF8String];
    //        if (3==strlen(u8Temp)){
    //            //            NSLog(@"字符串中含有中文");
    //            if (i == 0) {
    //                [resultString appendString:[testString substringWithRange:NSMakeRange(i, 1)]];
    //                break;
    //            }
    //            else {
    //                break;
    //            }
    //        }
    //        else {
    //            if (i == 0) {
    //                [resultString appendString:[[testString substringWithRange:NSMakeRange(i, 1)] uppercaseString]];
    //            }
    //            else if (i == 1) {
    //                [resultString appendString:[[testString substringWithRange:NSMakeRange(i, 1)] lowercaseString]];
    //                break;
    //            }
    //        }
    //        //        else if((commitChar>64)&&(commitChar<91)){
    //        //            NSLog(@"字符串中含有大写英文字母");
    //        //        }else if((commitChar>96)&&(commitChar<123)){
    //        //            NSLog(@"字符串中含有小写英文字母");
    //        //        }else if((commitChar>47)&&(commitChar<58)){
    //        //            NSLog(@"字符串中含有数字");
    //        //        }else{
    //        //            NSLog(@"字符串中含有非法字符");
    //        //        }
    //    }
    //    return resultString;
}

- (NSString*)getPreferredLanguage
{
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    NSArray * allLanguages = [defaults objectForKey:@"AppleLanguages"];
    
    NSString * preferredLang = [allLanguages objectAtIndex:0];
    
//    NSLog(@"当前语言:%@", preferredLang);
    
    return preferredLang;
}

- (BOOL)isCurrentLanguageChinese
{
    return [[self getPreferredLanguage] containsString:@"zh-Han"];
}

- (NSString*)dateStringOfmailContent:(NSDate*)date
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    if ([self isCurrentLanguageChinese]) {
        dateFormatter.dateFormat = @"yyyy/M/d EEE H:mm";
    }
    else {
        dateFormatter.dateFormat = @"EEE MMM. d,yyyy, H:mm aa";
    }
    return [dateFormatter stringFromDate:date];
}

- (NSString*)shortOfDateStringOfmailContent:(NSDate*)date
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    if ([self isCurrentLanguageChinese]) {
        dateFormatter.dateFormat = @"M/d EEE H:mm";
    }
    else {
        dateFormatter.dateFormat = @"EEE MMM. d, H:mm aa";
    }
    return [dateFormatter stringFromDate:date];
}

- (BOOL)valiMobile:(NSString *)mobile{
    if (mobile.length < 11)
    {
        return NO;
    }else{
        /**
         * 移动号段正则表达式
         */
        NSString *CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}$";
        /**
         * 联通号段正则表达式
         */
        NSString *CU_NUM = @"^((13[0-2])|(145)|(15[5-6])|(176)|(18[5,6]))\\d{8}|(1709)\\d{7}$";
        /**
         * 电信号段正则表达式
         */
        NSString *CT_NUM = @"^((133)|(153)|(177)|(18[0,1,9]))\\d{8}$";
        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM_NUM];
        BOOL isMatch1 = [pred1 evaluateWithObject:mobile];
        NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU_NUM];
        BOOL isMatch2 = [pred2 evaluateWithObject:mobile];
        NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT_NUM];
        BOOL isMatch3 = [pred3 evaluateWithObject:mobile];
        
        if (isMatch1 || isMatch2 || isMatch3) {
            return YES;
        }else{
            return NO;
        }
    }
    return YES;
}

- (NSString*)attachmentExtension:(NSString *)mimeType
{
    if ([mimeType isEqualToString:@"image/jpeg"]) {
        return @"jpg";
    }
    else if ([mimeType isEqualToString:@"image/gif"]) {
        return @"gif";
    }
    else if ([mimeType isEqualToString:@"image/tiff"] || [mimeType isEqualToString:@"image/tif"]) {
        return @"tif";
    }
    else {
        return @"png";
    }
}

+ (UIImage*)generateBigImageWithSrcImage:(UIImage*)srcImage
{
    //1.图像缩放前尺寸
    CGSize graphSize_original = srcImage.size;
    
    //2.画布尺寸
    CGSize canvasSize_bigImage = CGSizeZero;
    
    //3.图像缩放后尺寸
    CGSize graphSize_bigImage_scaled = CGSizeZero;
    
    //计算画布尺寸和图像缩放后尺寸
    CGFloat graphAspectRatio = graphSize_original.height / graphSize_original.width;
//    //头像
//    if (imageType == 1) {
//        CGFloat minEdgeLength = MIN(graphSize_original.width, graphSize_original.height);//图像缩放前的最短边
//        BOOL bIfFetchCanvasWidth = graphSize_original.width < graphSize_original.height;//是否取画布的宽度为图像缩放后的宽度
//        
//        //大图
//        canvasSize_bigImage = CGSizeMake(640, 640);//画布尺寸
//        CGFloat minEdgeLength_bigImage = MIN(minEdgeLength, canvasSize_bigImage.width);//取最短边
//        //图像缩放后尺寸
//        if (bIfFetchCanvasWidth) {
//            graphSize_bigImage_scaled = CGSizeMake(minEdgeLength_bigImage, minEdgeLength_bigImage * graphAspectRatio);
//        }
//        else {
//            graphSize_bigImage_scaled = CGSizeMake(minEdgeLength_bigImage / graphAspectRatio, minEdgeLength_bigImage);
//        }
//    }
//    //参加活动的照片
//    else if (imageType == 2) {
        //大图
        canvasSize_bigImage = CGSizeMake(640, 640 * graphAspectRatio);//画布尺寸
        CGFloat minWith_bigImage = MIN(graphSize_original.width, canvasSize_bigImage.width);//取最短宽度
        graphSize_bigImage_scaled = CGSizeMake(minWith_bigImage, minWith_bigImage * graphAspectRatio);//图像缩放后尺寸
//    }
    
    //4.图像位置
    CGPoint graphOffset_bigImage = CGPointMake((canvasSize_bigImage.width - graphSize_bigImage_scaled.width) / 2, (canvasSize_bigImage.height - graphSize_bigImage_scaled.height) / 2);
    
    
    //5.创建大图
    UIGraphicsBeginImageContext(canvasSize_bigImage);
    [srcImage drawInRect:CGRectMake(graphOffset_bigImage.x, graphOffset_bigImage.y, graphSize_bigImage_scaled.width, graphSize_bigImage_scaled.height)];
    UIImage* bigImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return bigImage;
}

- (BOOL)judgeCheckMailResult:(kcgCheckMailResult)kcgCheckMailResult viewController:(UIViewController*)viewController
{
    if (kcgCheckMailResult == kcgCheckMailResult_OK)  return YES;
    
    if (kcgCheckMailResult == kcgCheckMailResult_MailContentIsTooBig) {
        if (viewController) {
            ALERT_MESSAGE(NSLocalizedString(@"Your mail content is too large, please modify to resend", nil), viewController, nil);
        }
    }
    else if (kcgCheckMailResult == kcgCheckMailResult_MailContentIsTooBigForSaveTempMail) {
        if (viewController) {
            ALERT_MESSAGE(NSLocalizedString(@"Your mail content is too large, please modify to save temp mail", nil), viewController, nil);
        }
    }
    else if (kcgCheckMailResult == kcgCheckMailResult_MailContentIsTooBigForSaveDraft) {
        if (viewController) {
            ALERT_MESSAGE(NSLocalizedString(@"Your mail content is too large, please modify to save draft", nil), viewController, nil);
        }
    }

    return NO;
}

- (BOOL)ifNeedUseProxy
{
    return YES;
}

- (nullable NSString*)fetchValidStringOrNil:(nullable NSString*)string
{
    return (string && ![string isEqualToString:@""] && ![string isEqual: [NSNull null]]) ? string : nil;
}

- (nullable NSString*)fetchValidStringOrEmptyString:(nullable NSString*)string;
{
    return (string && ![string isEqualToString:@""] && ![string isEqual: [NSNull null]]) ? string : @"";
}

//typedef enum {
//    kCLAuthorizationStatusNotDetermined = 0, // 用户尚未做出选择这个应用程序的问候
//    kCLAuthorizationStatusRestricted,        // 此应用程序没有被授权访问的照片数据。可能是家长控制权限
//    kCLAuthorizationStatusDenied,            // 用户已经明确否认了这一照片数据的应用程序访问
//    kCLAuthorizationStatusAuthorized         // 用户已经授权应用访问照片数据} CLAuthorizationStatus;
//}
- (BOOL)canCameraWithViewController:(UIViewController*)viewController
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        return YES;
    }
    else if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        //无权限，弹出提示
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"Camera can not start, please open the camera authority in the settings.", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action_OK = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:action_OK];
        [viewController presentViewController:alertController animated:YES completion:nil];
        
        return NO;
    }
    else {
        return YES;
    }
}

- (BOOL)canOpenPhotoWithViewController:(UIViewController*)viewController
{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusNotDetermined) {
        return YES;
    }
    else if (author == ALAuthorizationStatusRestricted || author ==ALAuthorizationStatusDenied){
        //无权限，弹出提示
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"Photo library can not be open, please open the photo library authority in the settings.", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action_OK = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:action_OK];
        [viewController presentViewController:alertController animated:YES completion:nil];
        
        return NO;
    }
    else {
        return YES;
    }
}

- (BOOL)canRecordWithViewController:(UIViewController*)viewController
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        return YES;
    }
    else if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        //无权限，弹出提示
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"Microphone can not start, please set the microphone in the settings.", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action_OK = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:action_OK];
        [viewController presentViewController:alertController animated:YES completion:nil];
        
        return NO;
    }
    else {
        return YES;
    }
}

//验证ip格式是否正确
- (BOOL)isValidatIP:(nullable NSString *)ipAddress
{
    NSString  *urlRegEx =@"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:ipAddress];
}

- (void)showWaitMessageWithMessage:(NSString*)message viewController:(UIViewController*)viewController
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[CGWaitingViewManager sharedInstance] showMessageWithMessage:message onViewController:viewController];
    });
}

- (void)showMessageAtTopWithMessage:(NSString*)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[CGWaitingViewManager sharedInstance] showMessageAtTopWithMessage:message];
    });
}

- (void)stopShowWaitMessage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[CGWaitingViewManager sharedInstance] clear];
    });
}

- (nullable NSString*)sizeStringWithByteLength:(NSInteger)length
{
    CGFloat fLength = length;
    //B
    if (fLength / 1024 < 1) {
        return [NSString stringWithFormat:@"%.0fB", fLength];
    }
    
    //KB
    fLength /= 1024;
    if (fLength / 1024 < 1) {
        return [NSString stringWithFormat:@"%.2fKB", fLength];
    }
    
    //MB
    fLength /= 1024;
    if (fLength / 1024 < 1) {
        return [NSString stringWithFormat:@"%.2fMB", fLength];
    }
    
    //GB
    fLength /= 1024;
    if (fLength / 1024 < 1) {
        return [NSString stringWithFormat:@"%.2fGB", fLength];
    }
    
    return nil;
}

#pragma mark 获取launch图

- (UIImage*)fetchLaunchImage
{
    
    CGSize viewSize = [UIScreen mainScreen].bounds.size;
    // 竖屏
    NSString *viewOrientation = @"Portrait";
    NSString *launchImageName = nil;
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict in imagesDict)
    {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]])
        {
            launchImageName = dict[@"UILaunchImageName"];
            break;
        }
    }
    return [UIImage imageNamed:launchImageName];
}

#pragma mark 判断字符串是否空串

- (BOOL)isStringEmptyWithString:(nullable NSString*)string
{
    return (!string
            || [string isEqual:[NSNull null]]
            || [string isEqualToString:@"<null>"]
            || [string isEqualToString:@"(null)"]
            || [string isEqualToString:@""]);
}

@end
