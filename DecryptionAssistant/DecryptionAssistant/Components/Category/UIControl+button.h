//
//  UIControl+button.h
//  SecretMail
//
//  Created by Granger on 2019/11/19.
//  Copyright © 2019 granger. All rights reserved.
//

#import <UIKit/UIKit.h>
#define defaultInterval 1//默认时间间隔

@interface UIControl (button)
@property(nonatomic,assign)NSTimeInterval time;//用这个给重复点击加间隔

@property(nonatomic,assign)BOOL isIgnoreEvent;//YES不允许点击NO允许点击
@end
