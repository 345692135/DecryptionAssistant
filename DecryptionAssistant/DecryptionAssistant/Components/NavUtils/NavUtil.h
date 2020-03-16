//
//  UtilsNav.h
//  SecretMail
//
//  Created by Granger on 2019/11/19.
//  Copyright © 2019 granger. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NavUtil : NSObject
+ (UIViewController *)topViewController;
+ (UIViewController *)_topViewController:(UIViewController *)vc;
@end

NS_ASSUME_NONNULL_END
