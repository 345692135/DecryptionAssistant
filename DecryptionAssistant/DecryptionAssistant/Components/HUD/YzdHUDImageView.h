//
//  YzdHUDImageView.h
//  YzdHUD
//
//  Created by ShineYang on 13-12-6.
//  Copyright (c) 2013年 YangZhiDa. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    kcgGraghType_none,
    kcgGraghType_success,
    kcgGraghType_fail
} cgGraghType;

@interface YzdHUDImageView : UIView
+(YzdHUDImageView *)shareHUDView;

@property (nonatomic, assign) cgGraghType graghType;

@end
