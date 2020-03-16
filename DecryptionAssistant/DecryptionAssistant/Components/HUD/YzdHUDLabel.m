//
//  YzdHUDLabel.m
//  YzdHUD
//
//  Created by ShineYang on 13-12-6.
//  Copyright (c) 2013年 YangZhiDa. All rights reserved.
//

#import "YzdHUDLabel.h"

static YzdHUDLabel *_shareHUDView = nil;
@implementation YzdHUDLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+(YzdHUDLabel *)shareHUDView{
    if (!_shareHUDView) {
        _shareHUDView = [[YzdHUDLabel alloc] init];
        _shareHUDView.numberOfLines = 0;
        _shareHUDView.alpha = 0;
        _shareHUDView.textAlignment = NSTextAlignmentCenter;
        _shareHUDView.backgroundColor = [UIColor clearColor];
//        _shareHUDView.font = [UIFont boldSystemFontOfSize:19.0f];
        if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending) {
            _shareHUDView.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f];
        }
        else {
            _shareHUDView.textColor = [UIColor whiteColor];
        }

    }
    return _shareHUDView;
}
@end
