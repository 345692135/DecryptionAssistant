//
//  UIColor+Hex.m
//  SecretMail
//
//  Created by Granger on 2019/11/19.
//  Copyright © 2019 granger. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)
+(UIColor *) getColorWithColor:(KCOLORS)tagColor
{
    
    NSString *hexColor;
    //普通黄色和字体黄色
    if (tagColor == KgrayColor) {
        hexColor = @"333333";
    }
    else if (tagColor == KblackColor){
        hexColor = @"000000";
        
    }
    else if (tagColor == kblueColor){
        hexColor = @"0070e7";
    }
    else if (tagColor == KlightGrayColor){
        hexColor = @"6e6d77";
    }
    else if (tagColor == KtabBarColor){
        hexColor = @"767e8d";
    }
    else if (tagColor == KlineGrayColor){
        hexColor = @"CCCCCC";
    }
    else if (tagColor == KlittleBlack){
        hexColor = @"666666";
    }
    else if (tagColor == kUrlGrayColor){
        hexColor = @"999999";
    }
    else if (tagColor == kYellow){
        hexColor = @"f15713";
    }
    else if (tagColor == KdealerGrayColor){
        hexColor = @"808c9e";
    }
    else if (tagColor == KGPSYellowColor){
        hexColor = @"ffa800";
    }
    else if (tagColor == KshadowColor){
        hexColor = @"002e73";
    }
    else if (tagColor == KlineServiceColor){
        hexColor = @"ebebeb";
    }
    else if (tagColor == KOrderColor){
        hexColor = @"9d9d9d";
    }
    else if (tagColor == KTrackColor1){
        hexColor = @"9bcaff";
    } else if (tagColor == kBodyBackground1){
        hexColor = @"f5f5f5";
    } else if (tagColor == kBtnRed){
        hexColor = @"e71806";
    }
    
    

    
    unsigned int red, green, blue;
    NSRange range;
    range.length =2;
    range.location =0 ;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]]scanHexInt:&red];
    range.location =2;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]]scanHexInt:&green];
    range.location =4;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]]scanHexInt:&blue];
    
    return [UIColor colorWithRed:(float)(red/255.0f)green:(float)(green/255.0f)blue:(float)(blue/255.0f)alpha:1.0f];
}

+ (UIColor*) colorWithHex:(long)hexColor;
{
    return [UIColor colorWithHex:hexColor alpha:1.];
}

+ (UIColor *)colorWithHex:(long)hexColor alpha:(float)opacity
{
    float red = ((float)((hexColor & 0xFF0000) >> 16))/255.0;
    float green = ((float)((hexColor & 0xFF00) >> 8))/255.0;
    float blue = ((float)(hexColor & 0xFF))/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:opacity];
}

@end
