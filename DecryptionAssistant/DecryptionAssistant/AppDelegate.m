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
    [UIApplication sharedApplication].idleTimerDisabled=NO;
    
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

-(UIView*)waterView {
    if (!_waterView) {
        _waterView = [UIView new];
        _waterView.backgroundColor = [UIColor clearColor];
        _waterView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        _waterView.userInteractionEnabled = NO;
        _waterView.hidden = YES;
    }
    return _waterView;
}

/**
 加载登录页
 */
- (void)enterPage{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    [self changeRootWithToPageType:ToPageTypeLogin];
    [self.window makeKeyAndVisible];
    [self.window addSubview:self.waterView];
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
//    NSLog(@"\n🚫\n🚫监测到崩溃信息🚫\n🚫\n");
    /*
     * 在这边对避免的异常进行一些处理，比如上传到日志服务器等。
     */
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if (self.window) {
        if (url) {
            NSString *fileName = url.lastPathComponent; // 从路径中获得完整的文件名（带后缀）
            // path 类似这种格式：file:///private/var/mobile/Containers/Data/Application/83643509-E90E-40A6-92EA-47A44B40CBBF/Documents/Inbox/jfkdfj123a.pdf
            NSString *path = url.absoluteString; // 完整的url字符串
            path = [self URLDecodedString:path]; // 解决url编码问题
            NSMutableString *string = [[NSMutableString alloc] initWithString:path];
            if ([path hasPrefix:@"file://"]) { // 通过前缀来判断是文件
                // 去除前缀：/private/var/mobile/Containers/Data/Application/83643509-E90E-40A6-92EA-47A44B40CBBF/Documents/Inbox/jfkdfj123a.pdf
                [string replaceOccurrencesOfString:@"file://" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, path.length)];
                // 此时获取到文件存储在本地的路径，就可以在自己需要使用的页面使用了
                NSDictionary *dict = @{@"fileName":fileName,
                                       @"filePath":string};
                
                if (self.isActiving) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"FileNotification" object:nil userInfo:dict];
                }else {
                    self.dictionary = [NSDictionary dictionaryWithDictionary:dict];
                }
                return YES;
            }
        }
    }
    return YES;
}
// 当文件名为中文时，解决url编码问题
- (NSString *)URLDecodedString:(NSString *)str {
    NSString *decodedString=(__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)str, CFSTR(""), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    NSLog(@"decodedString = %@",decodedString);
    return decodedString;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
