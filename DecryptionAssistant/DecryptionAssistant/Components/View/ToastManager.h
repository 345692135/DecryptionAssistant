//
//  ToastManager.h
//  Cfrj
//
//  Created by Granger on 2019/5/20.
//  Copyright © 2019 granger. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ToastManager : NSObject
+ (void)showMsg:(NSString *)msg;

+ (void)showMsg:(NSString *)msg duration:(NSTimeInterval)duration;

+ (void)showMsgWithError:(NSError *)error;

+ (void)makeToastActivity;

+ (void)hideToastActivity;

+ (void)hideMessage;

@end

NS_ASSUME_NONNULL_END
