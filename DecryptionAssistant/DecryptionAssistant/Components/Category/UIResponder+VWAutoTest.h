//
//  UIResponder+VWAutoTest.h
//  SecretMail
//
//  Created by Granger on 2019/11/19.
//  Copyright © 2019 granger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIResponder (VWAutoTest)

- (NSString *)nameWithInstance:(id)instance;
- (NSString *)findNameWithInstance:(UIView *)instance;

@end
