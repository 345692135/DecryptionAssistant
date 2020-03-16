//
//  YzdHUDIndicator.m
//  YzdHUD
//
//  Created by ShineYang on 13-12-6.
//  Copyright (c) 2013年 YangZhiDa. All rights reserved.
//

#import "YzdHUDIndicator.h"

static YzdHUDIndicator *_shareHUDView = nil;
@implementation YzdHUDIndicator

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+(YzdHUDIndicator *)shareHUDView{
    if (!_shareHUDView) {
        if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending) {
            _shareHUDView = [[YzdHUDIndicator alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        else {
            _shareHUDView = [[YzdHUDIndicator alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        }
    }
    return _shareHUDView;
}

@end
