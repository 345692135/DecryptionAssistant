//
//  UIColor+Hex.h
//  SecretMail
//
//  Created by Granger on 2019/11/19.
//  Copyright © 2019 granger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)
typedef NS_ENUM(NSInteger, KCOLORS) {
    KgrayColor,
    KlightGrayColor,
    KlineGrayColor,//虚线
    KlineServiceColor,//服务界面分割线颜色
    KblackColor,//黑色
    KlittleBlack,
    kblueColor,//
    KtabBarColor,
    kUrlGrayColor,
    KdealerGrayColor,//经销商界面的灰色
    kYellow,
    KshadowColor,
    KGPSYellowColor,
    KOrderColor,
    KTrackColor1,
    KTrackColor2,
    kBodyBackground1,        //body背景色
    kBtnRed,        //button 红色
};
+(UIColor *)getColorWithColor:(KCOLORS)tagColor;
+ (UIColor *)colorWithHex:(long)hexColor;
+ (UIColor *)colorWithHex:(long)hexColor alpha:(float)opacity;
@end
