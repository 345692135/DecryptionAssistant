//
//  HudView.m
//  DecryptionAssistant
//
//  Created by Granger on 2019/10/27.
//  Copyright © 2019 granger. All rights reserved.
//

#import "HudView.h"
static const void *HttpRequestHUDKey = &HttpRequestHUDKey;

static HudView *hud = nil;
@implementation HudView

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

+ (instancetype)sharedHud {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hud = [[self alloc] init];
        hud.backgroundColor = [UIColor clearColor];
    });
    return hud;
}

- (MBProgressHUD *)HUD{
    return objc_getAssociatedObject(self, HttpRequestHUDKey);
}

- (void)setHUD:(MBProgressHUD *)HUD{
    objc_setAssociatedObject(self, HttpRequestHUDKey, HUD, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)show:(NSTimeInterval)timeout
{
    // x秒之后再消失
    [[self showHUD] hideAnimated:YES afterDelay:timeout];
}

- (MBProgressHUD*)showHUD{
    [self hide];
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    
    hud.mode = MBProgressHUDModeCustomView;
    //设置动画帧
    UIImageView *hudImageView = [[UIImageView alloc] init];
    hudImageView.image = [UIImage imageNamed:@"vw_common_loading_1"];
    hudImageView.animationImages=[NSArray arrayWithObjects:
                                  [UIImage imageNamed:@"vw_common_loading_1"],
                                  [UIImage imageNamed:@"vw_common_loading_2"],
                                  [UIImage imageNamed:@"vw_common_loading_3"],
                                  [UIImage imageNamed:@"vw_common_loading_4"],
                                  [UIImage imageNamed:@"vw_common_loading_5"],
                                  nil];
    hudImageView.animationDuration = 0.5;
    [hudImageView startAnimating];
    hud.customView = hudImageView;
    // hud.bezelView.backgroundColor = [UIColor clearColor];
    hud.bezelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    // Looks a bit nicer if we make it square.
    hud.square = YES;
    [self setHUD:hud];
    return hud;
}

- (MBProgressHUD*)showHUD:(NSString *)imgName content:(NSString *)content{
    [self hide];
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    
    hud.mode = MBProgressHUDModeCustomView;
    //设置动画帧
    UIImageView *hudImageView = [[UIImageView alloc] init];
    hudImageView.image = [UIImage imageNamed:imgName];
    hud.customView = hudImageView;
    // Looks a bit nicer if we make it square.
    hud.square = YES;
    hud.label.text = content;
    hud.label.textColor = [UIColor whiteColor];
    hud.label.font = [UIFont systemFontOfSize:13];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [UIColor colorWithHexString:@"#2a2a2a"];
    [self setHUD:hud];
    return hud;
}

- (MBProgressHUD*)showCustomHud:(UIView *)customView
{
    [self hide];
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = customView;
    // Looks a bit nicer if we make it square.
    hud.square = YES;
    hud.label.hidden = YES;
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [UIColor colorWithHexString:@"#2a2a2a"];
    hud.backgroundView.backgroundColor  = [UIColor colorWithHexString:@"#2a2a2a"];
    [self setHUD:hud];
    return hud;
}

- (void)showCustom:(UIView *)view{
    [[self showCustomHud:view] hideAnimated:NO afterDelay:1000000.0f];
}

- (void)showCustom:(NSTimeInterval)timeout imgName:(NSString *)imgName content:(NSString *)content
{
    // x秒之后再消失
    [[self showHUD:imgName content:content] hideAnimated:NO afterDelay:timeout];
}

- (void)showCustom:(NSString *)imgName content:(NSString *)content
{
    // x秒之后再消失
    [[self showHUD:imgName content:content] hideAnimated:NO afterDelay:2.0f];
}

- (void)show
{
    [self showHUD];
}

- (void)showError
{
    [self hide];
//    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
//    hud.mode = MBProgressHUDModeCustomView;
//    //设置动画帧
//    UIImageView *hudImageView = [[UIImageView alloc] init];
//    hudImageView.image = [UIImage imageNamed:@"vw_common_loading_error"];
//    hudImageView.animationImages=[NSArray arrayWithObjects: [UIImage imageNamed:@"vw_common_loading_error"],                                  nil];
//    hudImageView.animationDuration = 1.5;
//    [hudImageView startAnimating];
//    hud.customView = hudImageView;
//    // hud.bezelView.backgroundColor = [UIColor clearColor];
//    hud.bezelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
//    // Looks a bit nicer if we make it square.
//    hud.square = YES;
//    [hud hideAnimated:YES afterDelay:2];
//    [self setHUD:hud];
    
}

- (void)hide{
    [[self HUD] hideAnimated:YES];
}

@end
