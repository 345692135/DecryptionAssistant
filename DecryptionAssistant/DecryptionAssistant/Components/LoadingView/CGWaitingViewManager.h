//
//  CGLoadingViewManager.h
//  together
//
//  Created by 刘立业 on 2017/6/5.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CGWaitingViewManager : NSObject

+ (CGWaitingViewManager*)sharedInstance;

- (void)showMessageWithMessage:(NSString*)message onViewController:(UIViewController*)viewController;
- (void)showMessageAtTopWithMessage:(NSString*)message;
- (void)clear;

@end
