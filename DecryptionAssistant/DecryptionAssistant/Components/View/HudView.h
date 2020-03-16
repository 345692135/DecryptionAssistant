//
//  HudView.h
//  DecryptionAssistant
//
//  Created by Granger on 2019/10/27.
//  Copyright © 2019 granger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface HudView : UIView

+ (instancetype)sharedHud;
- (void)show;
- (void)showError;
- (void)hide;
- (void)show:(NSTimeInterval)timeout;
- (void)showCustom:(NSString *)imgName content:(NSString *)content;
- (void)showCustom:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
