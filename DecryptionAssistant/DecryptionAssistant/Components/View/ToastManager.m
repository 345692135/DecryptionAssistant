//
//  ToastManager.m
//  Cfrj
//
//  Created by Granger on 2019/5/20.
//  Copyright © 2019 granger. All rights reserved.
//

#import "ToastManager.h"
#import "UIView+Toast.h"

@implementation ToastManager


+ (void)showMsg:(NSString *)msg duration:(NSTimeInterval)duration {
    if (msg.length) {
        [CSToastManager setQueueEnabled:YES];
        UIView *window = [[[UIApplication sharedApplication] windows] lastObject];
        
        [window makeToast:msg duration:duration position:[NSValue valueWithCGPoint:CGPointMake((kScreenWidth - 1) / 2, kScreenHeight - 120 + kTBarBottomHeight)]];
    }
    
}

+ (void)showMsg:(NSString *)msg {
    
    if (msg.length) {
        [CSToastManager setQueueEnabled:YES];
        UIView *window = [[[UIApplication sharedApplication] windows] lastObject];
        
        [window makeToast:msg duration:1.0f position:[NSValue valueWithCGPoint:CGPointMake((kScreenWidth - 1) / 2, kScreenHeight - 120 + kTBarBottomHeight)]];
    }
    
    
}


+ (void)showMsgWithError:(NSError *)error {
    if ([error.userInfo[@"errorMessage"] isKindOfClass:[NSString class]]) {
        NSString *errorMess = error.userInfo[@"errorMessage"];
        if (errorMess.length) {
            [CSToastManager setQueueEnabled:YES];
            UIView *window = [[[UIApplication sharedApplication] windows] lastObject];
            
            [window makeToast:error.userInfo[@"errorMessage"] duration:1.0f position:[NSValue valueWithCGPoint:CGPointMake((kScreenWidth - 1) / 2, kScreenHeight - 120 + kTBarBottomHeight)]];
        }
    }
}

+ (void)makeToastActivity {
    
    [CSToastManager setQueueEnabled:YES];
    UIView *window = [[[UIApplication sharedApplication] windows] lastObject];
    window.userInteractionEnabled = NO;
    [window makeToastActivity:CSToastPositionCenter];
}

+ (void)hideToastActivity {
    UIView *window = [[[UIApplication sharedApplication] windows] lastObject];
    window.userInteractionEnabled = YES;
    [window hideToastActivity];
}
+ (void)hideMessage{
    
    UIView *window = [[[UIApplication sharedApplication] windows] lastObject];
    window.userInteractionEnabled = YES;
    [window hideAllToasts];
}

@end
