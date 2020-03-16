//
//  CGLoadingViewManager.m
//  together
//
//  Created by 刘立业 on 2017/6/5.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "CGWaitingViewManager.h"
#import "CGWaitingView.h"
#import "AppDelegate.h"

@interface CGWaitingViewManager ()

@property (nonatomic, strong) CGWaitingView* loadingView;

@end

@implementation CGWaitingViewManager

static CGWaitingViewManager* _sharedInstance = nil;

+ (CGWaitingViewManager*)sharedInstance
{
    if (!_sharedInstance) {
        _sharedInstance = [[CGWaitingViewManager alloc] init];
    }
    
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        CGWaitingView* loadingView = [[CGWaitingView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.loadingView = loadingView;
    }
    return self;
}

- (void)showMessageWithMessage:(NSString*)message onViewController:(UIViewController*)viewController
{
    UIView* view = viewController.view;
    
    [self showMessage:message onView:view];
}

- (void)clear
{
    if (self.loadingView.superview) {
        [self.loadingView unshow];
        [self performSelector:@selector(unShow) withObject:nil afterDelay:1];
    }
}

- (void)unShow
{
    [self.loadingView removeFromSuperview];
}

- (void)showMessageAtTopWithMessage:(NSString*)message
{
    UIView* view = nil;
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UIWindow* window = appDelegate.window;
    UIViewController* rootViewController = window.rootViewController;
    UIViewController* v = [self fetchTopViewController:rootViewController];
    if (v.navigationController) {
        view = v.navigationController.view;
    }
    else {
        view = v.view;
    }
    
    [self showMessage:message onView:view];
}

- (void)showMessage:(NSString *)message onView:(UIView*)view
{
    self.loadingView.title = message;
    [view addSubview:self.loadingView];
}

- (UIViewController*)fetchTopViewController:(id)v
{
    if ([v isKindOfClass:[UINavigationController class]]) {
        return [self fetchTopViewController:((UINavigationController*)v).topViewController];
    }
    else if ([v isKindOfClass:[UIViewController class]]) {
        UIViewController* vc = v;
        if (vc.presentedViewController) {
            return [self fetchTopViewController:vc.presentedViewController];
        }
        else {
            return vc;
        }
    }
    return nil;
}

@end
