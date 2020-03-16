//
//  UINavigationController+VWExtend.m
//  SecretMail
//
//  Created by Granger on 2019/11/19.
//  Copyright © 2019 granger. All rights reserved.
//

#import "UINavigationController+VWExtend.h"

@implementation UINavigationController (VWExtend)

- (NSUInteger)supportedInterfaceOrientations {
    UIViewController *viewControllerToAsk = self.viewControllers.firstObject;
    return [viewControllerToAsk supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotate {
    UIViewController *viewControllerToAsk = self.viewControllers.firstObject;
    return [viewControllerToAsk shouldAutorotate];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    UIViewController *viewControllerToAsk = [self.viewControllers lastObject];
    return [viewControllerToAsk preferredStatusBarStyle];
}
@end
