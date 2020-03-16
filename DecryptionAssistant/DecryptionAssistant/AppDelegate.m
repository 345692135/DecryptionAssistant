//
//  AppDelegate.m
//  DecryptionAssistant
//
//  Created by Granger on 2020/3/16.
//  Copyright © 2020 sain. All rights reserved.
//

#import "AppDelegate.h"
#import "BaseNaviViewController.h"
#import "AnyuanLoginViewController.h"

#import <AvoidCrash.h>

@interface AppDelegate ()

@property (strong, nonatomic) AnyuanLoginViewController *loginVC;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self initApp:launchOptions];
    return YES;
}

/**
 数据加载
 
 @param launchOptions launchOptions
 */
- (void)initApp:(NSDictionary *)launchOptions{
    
    // 捕获程序崩溃
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    
    if (@available(iOS 11.0, *)) {
        UIScrollView.appearance.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        UITableView.appearance.estimatedRowHeight = 0;
        UITableView.appearance.estimatedSectionHeaderHeight = 0;
        UITableView.appearance.estimatedSectionFooterHeight = 0;
    }
    
    [self config];
    [self enterPage];
    [self avoidCrash];
}

/**
 捕获异常
 
 @param exception 异常信息
 */
void UncaughtExceptionHandler(NSException *exception) {
    NSArray *arr = [exception callStackSymbols];//得到当前调用栈信息
    NSString *reason = [exception reason];//非常重要，就是崩溃的原因
    NSString *name = [exception name];//异常类型
    NSLog(@"exception == %@",exception);
    NSLog(@"exception.arr == %@",arr);
    NSLog(@"exception.reason == %@",reason);
    NSLog(@"exception.name == %@",name);
    
}

-(void)config {
    
}

/**
 加载登录页
 */
- (void)enterPage{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    [self changeRootWithToPageType:ToPageTypeLogin];
    [self.window makeKeyAndVisible];
}

/// root切换
/// @param toPageType toPageType description
-(void)changeRootWithToPageType: (ToPageType)toPageType {
    switch (toPageType) {
        case ToPageTypeLogin:
        {
            if (!_loginVC) {
                _loginVC = [[AnyuanLoginViewController alloc] init];
            }
            BaseNaviViewController *navVC = [[BaseNaviViewController alloc] initWithRootViewController:self.loginVC];
            self.window.rootViewController = navVC;
            [self clearOtherController:self.loginVC];
        }
            break;
            
        default:
            break;
    }
    
}

-(void)clearOtherController:(UIViewController*)control {
    if (self.loginVC && control != self.loginVC) {
        self.loginVC = nil;
    }
    
}

- (void)avoidCrash {
    
    /*
     * 项目初期不需要对"unrecognized selector sent to instance"错误进行处理，因为还没有相关的崩溃的类
     * 后期出现后，再使用makeAllEffective方法，把所有对应崩溃的类添加到数组中，避免崩溃
     * 对于正式线可以启用该方法，测试线建议关闭该方法
     */
    [AvoidCrash becomeEffective];
    
    
//    [AvoidCrash makeAllEffective];
//    NSArray *noneSelClassStrings = @[
//                                     @"NSString"
//                                     ];
//    [AvoidCrash setupNoneSelClassStringsArr:noneSelClassStrings];
    
    
    //监听通知:AvoidCrashNotification, 获取AvoidCrash捕获的崩溃日志的详细信息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealwithCrashMessage:) name:AvoidCrashNotification object:nil];
}

- (void)dealwithCrashMessage:(NSNotification *)notification {
    NSLog(@"\n🚫\n🚫监测到崩溃信息🚫\n🚫\n");
    /*
     * 在这边对避免的异常进行一些处理，比如上传到日志服务器等。
     */
}

@end
