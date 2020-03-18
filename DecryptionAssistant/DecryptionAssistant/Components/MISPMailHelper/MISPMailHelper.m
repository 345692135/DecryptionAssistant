//
//  MISPMailHelper.m
//  cellDemo
//
//  Created by 刘秀红 on 2017/6/16.
//  Copyright © 2017年 刘秀红. All rights reserved.
//

#import "MISPMailHelper.h"
#import "Context.h"
#import "AuthentificationManager.h"
#import "SocketProxyManager.h"
#import "updateProcess.h"
#import "NSData+CryptoEmail.h"
#import <UIKit/UIKit.h>
//#import "CGAccountData.h"
#import "MailStrategyAnalysis.h"
#import "MailStrategyProperty.h"
#import "CGChinasecMailPackTaskData.h"
//#import "CGAddressData.h"
#import "UserSrategyHelper.h"
#import "CryptoCoreData.h"

@interface MISPMailHelper ()

@property (nonatomic, copy) NSString* accountName;
@property (nonatomic, copy) NSString* password;

@end

@implementation MISPMailHelper

static MISPMailHelper* _sharedInstance = nil;

+ (MISPMailHelper *)sharedInstance
{
    if (!_sharedInstance) {
        _sharedInstance = [[MISPMailHelper alloc] init];
    }
    
    return _sharedInstance;
}

#pragma mark -
#pragma mark 初始化安元

- (void)handleInitOperationWithIp:(NSString*)ip
                             port:(NSString*)port
                              key:(NSString*)key
                       completion:(void (^)(BOOL ifSuccess))completion
{
    @synchronized(self)
    {
        [Context setIp:ip prot:port];
        [Context setProductKey:key];
        Context* ctx = [Context getInstance]; //初始化
        if (completion) {
            completion(ctx != nil);
        }
    };
}

#pragma mark -
#pragma mark 登录

-(void)loginWithAccountName:(NSString*)accountName
                   password:(NSString*)password
                 completion:(void (^)(BOOL ifSuccess))completion
{
    self.accountName = accountName;
    self.password = password;
    
    NSUserDefaults *uDefault = [NSUserDefaults standardUserDefaults];
    id userIsFirstLogin = [uDefault objectForKey:@"userIsFirstLogin"];
    if (!userIsFirstLogin) {
        [uDefault setBool:YES forKey:@"userIsFirstLogin"];
        [uDefault synchronize];
    }
    
    @synchronized(self){

        //登录
        AuthentificationManager* actManager = [AuthentificationManager getInstance];
        id<ICertify> certify = [actManager getUserNameCertifyPrivder];
        UserAccount* account = [[UserAccount alloc] initWithUserName:self.accountName password:self.password];
        @try {
            NSLog(@"--------");
            long iRet = [certify loginWithUserAccount:account];
            
            NSLog(@"++++++++");
            //写标志
            NSString *documentsDirectory= [NSHomeDirectory()
                                           stringByAppendingPathComponent:@"Documents"];
            
            NSFileManager* fm = [NSFileManager defaultManager];
            NSString *loginRegister =[documentsDirectory stringByAppendingPathComponent:@"loginRegister.plist"];
            if (![fm fileExistsAtPath:loginRegister])
            {
                [fm createFileAtPath:loginRegister contents:nil attributes:nil];
                NSMutableDictionary* createDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Wodersoft",@"1",nil];
                [createDic writeToFile:loginRegister atomically:YES];
            }

            int nRet = [certify getLoginAccoutStutus];
            //离线
            if (nRet == 10) {
                //iRet == 2814是登录失败密码错误。 iRet == 2054则是网络连接失败，断网允许离线登录
                if ([UserSrategyHelper permissionOffline] == NO && (iRet == 2814 || iRet == 2054)) {
                    [certify logoutWithUserAccount:nil];
                    self.chinasecAccountStatus = kcgChinasecAccountStatus_noLogin;
                    
                    if (completion) {
                        completion(NO);
                    }
                }
                else {
                    self.chinasecAccountStatus = kcgChinasecAccountStatus_offline;
                    if (completion) {
                        completion(YES);
                    }
                }
            }
            //在线
            else if (nRet == 20) {
                [[SocketProxyManager getInstance] start];
                NSLog(@"在线状态");
                BOOL userIsFirstLogin = [[uDefault objectForKey:@"userIsFirstLogin"] boolValue];
                if (userIsFirstLogin) {
                    [uDefault setBool:NO forKey:@"userIsFirstLogin"];
                    [uDefault synchronize];
                }
                self.chinasecAccountStatus = kcgChinasecAccountStatus_online;
                if (completion) {
                    completion(YES);
                }
            }
            else{//0528 - nRet=-1 ，nRet返回值：10离线，20在线
                if ([UserSrategyHelper permissionOffline] == YES && iRet == 2054) {
                    [certify logoutWithUserAccount:nil];
                }
                self.chinasecAccountStatus = kcgChinasecAccountStatus_noLogin;
                if (completion) {
                    completion(NO);
                }
                //            }
            }
        } @catch (NSException *exception) {
            NSLog(@"exception:%@",exception);
            
            completion(NO);
        } @finally {
            
        }
        
    }
}

//-(void)login
//{
//    NSUserDefaults *uDefault = [NSUserDefaults standardUserDefaults];
//    [uDefault setBool:YES forKey:@"userIsFirstLogin"];
//    
//    @synchronized(self){
//        //获取用户名字符串
//        UITextField *accountTextField;
//        
//        UITextField *pinTextField;
//        [pinTextField resignFirstResponder];
//        
//        //获取密码字符串
//        UITextField *keyTextField;
//        [keyTextField resignFirstResponder];
//        
//        //modified by guolian.tan @2016-12-06
//        NSString *accountName;
//        
//        
//        
//            AuthentificationManager* actManager = [AuthentificationManager getInstance];
//            id<ICertify> certify = [actManager getUserNameCertifyPrivder];
//            UserAccount* account;
//            
//            //1203 自动登录，影响密码重置后登录
//            //account = [[UserAccount alloc]initWithUserName:accountName password:keyTextField.text];
//            
//            //自动去除密码字符串前后空格 modified by guolian.tan @2017-03-22
//            NSString *filterPassword;
//            account = [[UserAccount alloc] initWithUserName:accountName password:filterPassword];
//            
//            //0528 - 登录
//            long iRet = [certify loginWithUserAccount:account];
//            NSString *documentsDirectory= [NSHomeDirectory()
//                                           stringByAppendingPathComponent:@"Documents"];
//            
//            NSFileManager* fm = [NSFileManager defaultManager];
//            NSString *loginRegister =[documentsDirectory stringByAppendingPathComponent:@"loginRegister.plist"];
//            if (![fm fileExistsAtPath:loginRegister])
//            {
//                [fm createFileAtPath:loginRegister contents:nil attributes:nil];
//                NSMutableDictionary* createDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Wodersoft",@"1",nil];
//                [createDic writeToFile:loginRegister atomically:YES];
//            }
//            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:loginRegister];
//            NSString *loginAccoutRegister = [dic objectForKey:accountName];
//            if (loginAccoutRegister&&loginAccoutRegister.boolValue == YES) {
//            }else{
//                if (0!=iRet){
//                    NSString *message = [[NSString alloc]initWithFormat:@"%@:%@",NSLocalizedString(@"login_error", nil),[self loginErrInformation:iRet]];
//                    UIAlertView *alertView = [[UIAlertView alloc]
//                                              initWithTitle:NSLocalizedString(@"login_error_notice", nil)
//                                              message:message delegate:self cancelButtonTitle:
//                                              NSLocalizedString(@"login_error_sure", nil)
//                                              otherButtonTitles: nil];
//                    [alertView setTag:LOGIN_STRATEGY_FAILD];
//                    [message release];
//                    [alertView show];
//                    [alertView release];
//                    return;
//                }else{
//                    BOOL userStrategyReturnIsOK = [uDefault boolForKey:@"userStrategyReturnIsOK"];
//                    if (userStrategyReturnIsOK == YES) {
//                        NSString *message = [[NSString alloc]initWithFormat:@"获取策略失败"];
//                        UIAlertView *alertView = [[UIAlertView alloc]
//                                                  initWithTitle:NSLocalizedString(@"login_error_notice", nil)
//                                                  message:message delegate:self cancelButtonTitle:
//                                                  NSLocalizedString(@"login_error_sure", nil)
//                                                  otherButtonTitles: nil];
//                        [alertView setTag:LOGIN_STRATEGY_FAILD_REAL];
//                        [message release];
//                        [alertView show];
//                        [alertView release];
//                        return;
//                    }
//                }
//            }
//            
//            //NSLog(@"login iRet -- %ld",iRet); //0-成功，13825-未知错误(控制台重置密码后)
//            int nRet = [certify getLoginAccoutStutus];
//            //NSLog(@"login nRet -- %d",nRet);
//            
//            if (kSTisTestProcess) {
//                //nRet = 20;
//            }
//            
//            if (nRet == 10) {//offline
//                if ( (b_permissOfflineLogin == NO) && (iRet == 2814 || iRet == 2054)) {
//                    //登录失败密码错误。 iRet == 2054则是网络连接失败，断网允许离线登录
//                    [certify logoutWithUserAccount:nil];
//                    
//                    NSString *message = [[NSString alloc]initWithFormat:@"%@:%@",NSLocalizedString(@"login_error", nil),[self loginErrInformation:iRet]];
//                    UIAlertView *alertView = [[UIAlertView alloc]
//                                              initWithTitle:NSLocalizedString(@"login_error_notice", nil)
//                                              message:message delegate:self cancelButtonTitle:
//                                              NSLocalizedString(@"login_error_sure", nil)
//                                              otherButtonTitles: nil];
//                    [alertView setTag:LOGIN_ERROR];
//                    [message release];
//                    [alertView show];
//                    [alertView release];
//                    return;
//                    
//                }//end if for iRet != 2054
//                
//                //登录成功后，记录该用户，下一次登陆时候默认显示该用户
//                //[self saveAccount:accountName andPassword:keyTextField.text];
//                
//                //保存过滤后，并且登陆成功后的用户名与密码到plist文件 modified by guolian.tan @2017-03-22
//                [self saveAccount:accountName andPassword:filterPassword];
//                
//                ///////////////////////////////////////////////////////////////////
//                
//                AppDelegate *loginStatusDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
//                loginStatusDelegate.loginStatus = OFFLINE;   //离线登录后，由OFFLINE_LOGIN --> OFFLINE
//                if (!isPushFunClaNaV) {
//                    
//                    NSString *accountSID = [certify getActiveAccountSID];
//                    //获取document目录，建立plist文件，存放锁屏密码
//                    NSString *documentsDirectory= [NSHomeDirectory()
//                                                   stringByAppendingPathComponent:@"Documents"];
//                    NSString *filename=[documentsDirectory stringByAppendingPathComponent:@"lockViewPassword.plist"];
//                    //先读文件
//                    NSMutableDictionary* dic2 = [NSMutableDictionary dictionaryWithContentsOfFile:filename];
//                    NSString *userLockVPassword = [dic2 objectForKey:accountSID];
//                    if ([UserSrategyHelper lockScreen] && userLockVPassword == nil) {
//                        
//                        /*LSZ*/
//                        /*
//                         FunClassNavViewController *funClassNavView = [[FunClassNavViewController alloc]init];
//                         [self.navigationController pushViewController:funClassNavView animated:YES];
//                         [funClassNavView release];
//                         */
//                        [self showMainView];
//                        isPushFunClaNaV = YES;
//                        
//                        //锁屏
//                        DrawPatternLockViewController *lockVC = [[DrawPatternLockViewController alloc] init];
//                        lockVC.isFirst = YES;
//                        
//                        [self presentViewController:lockVC animated:YES completion:nil];
//                        
//                        [lockVC setTarget:self withAction:@selector(lockEntered:)];
//                        [lockVC release];
//                        
//                    }
//                    else
//                    {
//                        /*LSZ*/
//                        /*
//                         FunClassNavViewController *funClassNavView = [[FunClassNavViewController alloc]init];
//                         [self.navigationController pushViewController:funClassNavView animated:YES];
//                         [funClassNavView release];
//                         */
//                        [self showMainView];
//                        isPushFunClaNaV = YES;
//                        
//                    }
//                    
//                }else{//if  isPushFunClaNaV == YES
//                    
//                    if (iRet != 2054) {//登录错误，退出账号。。。
//                        [certify logoutWithUserAccount:nil];
//                        
//                        NSString *message = [[NSString alloc]initWithFormat:@"%@:%@",NSLocalizedString(@"login_error", nil),[self loginErrInformation:iRet]];
//                        UIAlertView *alertView = [[UIAlertView alloc]
//                                                  initWithTitle:NSLocalizedString(@"login_error_notice", nil)
//                                                  message:message delegate:self cancelButtonTitle:
//                                                  NSLocalizedString(@"login_error_sure", nil)
//                                                  otherButtonTitles: nil];
//                        [alertView setTag:LOGIN_ERROR];
//                        [message release];
//                        [alertView show];
//                        [alertView release];
//                        return;
//                        
//                    }//end if for iRet != 2054
//                    
//                    //以下是处理2054错误（无网络连接）
//                    NSString *accountSID = [certify getActiveAccountSID];
//                    //获取document目录，建立plist文件，存放锁屏密码
//                    NSString *documentsDirectory= [NSHomeDirectory()
//                                                   stringByAppendingPathComponent:@"Documents"];
//                    NSString *filename=[documentsDirectory stringByAppendingPathComponent:@"lockViewPassword.plist"];
//                    //先读文件
//                    NSMutableDictionary* dic2 = [NSMutableDictionary dictionaryWithContentsOfFile:filename];
//                    NSString *userLockVPassword = [dic2 objectForKey:accountSID];
//                    if ([UserSrategyHelper lockScreen] && userLockVPassword == nil) {
//                        
//                        /*LSZ*/
//                        /*
//                         FunClassNavViewController *funClassNavView = [[FunClassNavViewController alloc]init];
//                         [self.navigationController pushViewController:funClassNavView animated:YES];
//                         [funClassNavView release];
//                         */
//                        [self showMainView];
//                        isPushFunClaNaV = YES;
//                        
//                        //锁屏
//                        DrawPatternLockViewController *lockVC = [[DrawPatternLockViewController alloc] init];
//                        lockVC.isFirst = YES;
//                        [self presentViewController:lockVC animated:YES completion:nil];
//                        
//                        [lockVC setTarget:self withAction:@selector(lockEntered:)];
//                        [lockVC release];
//                        
//                    }
//                    //无else，此处不添加，在login页面，维持原状态。
//                }
//            }else if (nRet == 20){//online
//                
//                //登录成功后，记录该用户，下一次登陆时候默认显示该用户
//                //[self saveAccount:accountName andPassword:keyTextField.text];
//                
//                //保存过滤后，并且登陆成功后的用户名与密码到plist文件 modified by guolian.tan @2017-03-22
//                [self saveAccount:accountName andPassword:filterPassword];
//                
//                ///////////////////////////////////////////////////////////////////////
//                
//                AppDelegate *loginStatusDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
//                loginStatusDelegate.loginStatus = ONLINE;
//                
//                
//                [[SocketProxyManager getInstance]start];
//                
//                if (!isPushFunClaNaV) {
//                    
//                    NSString *accountSID = [certify getActiveAccountSID];
//                    //获取document目录，建立plist文件，存放锁屏密码
//                    NSString *documentsDirectory= [NSHomeDirectory()
//                                                   stringByAppendingPathComponent:@"Documents"];
//                    NSString *filename=[documentsDirectory stringByAppendingPathComponent:@"lockViewPassword.plist"];
//                    //先读文件
//                    NSMutableDictionary* dic2 = [NSMutableDictionary dictionaryWithContentsOfFile:filename];
//                    NSString *userLockVPassword = [dic2 objectForKey:accountSID];
//                    if ([UserSrategyHelper lockScreen] && userLockVPassword == nil) {
//                        
//                        /*LSZ*/
//                        /*
//                         FunClassNavViewController *funClassNavView = [[FunClassNavViewController alloc]init];
//                         [self.navigationController pushViewController:funClassNavView animated:YES];
//                         [funClassNavView release];
//                         */
//                        [self showMainView];
//                        isPushFunClaNaV = YES;
//                        
//                        //锁屏
//                        DrawPatternLockViewController *lockVC = [[DrawPatternLockViewController alloc] init];
//                        lockVC.isFirst = YES;
//                        [self presentViewController:lockVC animated:YES completion:nil];
//                        
//                        [lockVC setTarget:self withAction:@selector(lockEntered:)];
//                        [lockVC release];
//                        
//                    }
//                    else
//                    {
//                        /*LSZ*/
//                        /*
//                         FunClassNavViewController *funClassNavView = [[FunClassNavViewController alloc]init];
//                         [self.navigationController pushViewController:funClassNavView animated:YES];
//                         [funClassNavView release];
//                         */
//                        [self showMainView];
//                        isPushFunClaNaV = YES;
//                    }
//                    
//                }else{// if isPushFunClaNaV == YES
//                    
//                    NSString *accountSID = [certify getActiveAccountSID];
//                    //获取document目录，建立plist文件，存放锁屏密码
//                    NSString *documentsDirectory= [NSHomeDirectory()
//                                                   stringByAppendingPathComponent:@"Documents"];
//                    NSString *filename=[documentsDirectory stringByAppendingPathComponent:@"lockViewPassword.plist"];
//                    //先读文件
//                    NSMutableDictionary* dic2 = [NSMutableDictionary dictionaryWithContentsOfFile:filename];
//                    NSString *userLockVPassword = [dic2 objectForKey:accountSID];
//                    if ([UserSrategyHelper lockScreen] && userLockVPassword == nil) {
//                        
//                        /*LSZ*/
//                        /*
//                         FunClassNavViewController *funClassNavView = [[FunClassNavViewController alloc]init];
//                         [self.navigationController pushViewController:funClassNavView animated:YES];
//                         [funClassNavView release];
//                         */
//                        [self showMainView];
//                        isPushFunClaNaV = YES;
//                        
//                        //锁屏
//                        DrawPatternLockViewController *lockVC = [[DrawPatternLockViewController alloc] init];
//                        lockVC.isFirst = YES;
//                        [self presentViewController:lockVC animated:YES completion:nil];
//                        
//                        [lockVC setTarget:self withAction:@selector(lockEntered:)];
//                        [lockVC release];
//                        
//                    }
//                    //无else，此处不添加，在login页面，维持原状态。
//                }
//            }
//            else //0528 - nRet=-1 ，nRet返回值：10离线，20在线
//            {
//                if (b_permissOfflineLogin && (iRet == 2054)) {
//                    b_permissOfflineLogin = NO;
//                    [self offlineLogin:nil];
//                    AppDelegate *loginStatusDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
//                    loginStatusDelegate.loginStatus = OFFLINE;   //离线登录后，由OFFLINE_LOGIN --> OFFLINE
//                    return;
//                }
//                
//                
//                AppDelegate *loginStatusDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
//                loginStatusDelegate.loginStatus = LOGIN_NONE;
//                
//                //0528 err = 2054 notify：“登录失败：网络连接失败”
//                NSString *message = [[NSString alloc]initWithFormat:@"%@:%@",NSLocalizedString(@"login_error", nil),[self loginErrInformation:iRet]];
//                UIAlertView *alertView = [[UIAlertView alloc]
//                                          initWithTitle:NSLocalizedString(@"alertview_notice", nil) message:
//                                          message delegate:self
//                                          cancelButtonTitle:NSLocalizedString(@"alertview_sure", nil)
//                                          otherButtonTitles: nil];
//                [alertView setTag:LOGIN_FAIL];
//                [message release];
//                [alertView show];
//                [alertView release];
//            }
//        //else 用户名、密码不为空
//        
//        // [alertView release];//已经让其自动释放
//        
//        [NSThread detachNewThreadSelector:@selector(hiddenStatus) toTarget:self withObject:nil];
//        //发送通知
//        AppDelegate *loginStatusDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
//        NSNotification* notify = [NSNotification notificationWithName:@"Notify_LoginStatus" object:nil];//loginStatusDelegate.statusBar --> nil
//        [[NSNotificationCenter defaultCenter] postNotification:notify];
//    }// @synchronized(self)
//    /*
//     FunClassNavViewController *funClassNavView = [[FunClassNavViewController alloc]init];
//     [self.navigationController pushViewController:funClassNavView animated:YES];
//     [funClassNavView release];
//     */
//    
//    //0528
//    [activityIndicator stopAnimating];
//    self.logIn_Button.enabled = YES;
//    self.logInSet_Button.enabled = YES;
//    b_permissOfflineLogin = NO;
//    
//}

//-(void)login1WithAccountName:(NSString*)accountName
//                   password:(NSString*)password
//                 completion:(void (^)(BOOL ifSuccess))completion
//{
//    self.accountName = accountName;
//    self.password = password;
//    
//    NSUserDefaults *uDefault = [NSUserDefaults standardUserDefaults];
//    [uDefault setBool:YES forKey:@"userIsFirstLogin"];
//    
//    @synchronized(self){
//        
//        //登录
//        AuthentificationManager* actManager = [AuthentificationManager getInstance];
//        id<ICertify> certify = [actManager getUserNameCertifyPrivder];
//        UserAccount* account = [[UserAccount alloc] initWithUserName:self.accountName password:self.password];
//        long iRet = [certify loginWithUserAccount:account];
//        
//        int nRet = [certify getLoginAccoutStutus];
//        //离线
//        if (nRet == 10) {
//            
//        }
//        //在线
//        else if (nRet == 20) {
//            [[SocketProxyManager getInstance] start];
//            NSLog(@"在线状态");
//        }
//        //离线登录
//        else{
//            
//        }
//        
//        if (completion) {
//            completion(iRet == 0 && nRet == 20);
//        }
//    }
//}

#pragma mark -
#pragma mark 检测安元帐号是否激活

//- (BOOL)isChinasecActiveWithAccountData:(CGAccountData*)accountData
//{
//    return self.chinasecAccountStatus != kcgChinasecAccountStatus_noLogin;
////    AuthentificationManager* actManager = [AuthentificationManager getInstance];
////    id<ICertify> certify = [actManager getUserNameCertifyPrivder];
////    int nRet = [certify getLoginAccoutStutus];
////    return nRet == 20;
//}

//#pragma mark -
//#pragma mark 初始化安元
//
//- (void)initializeChinasecWithAccountData:(CGAccountData*)accountData
//{
//    @synchronized(self)
//    {
//        Context* ctx = [Context getInstance]; //初始化
//        if (ctx) {
//            [[MISPMailHelper sharedInstance] loginWithAccountName:accountData.chinasecAccount password:accountData.password completion:^(BOOL ifSuccess) {
//                if (ifSuccess) {
//                    NSLog(@"登录安元成功！");
//                }
//            }];
//        }
//    };
//}

#pragma mark -
#pragma mark 获取策略

- (void)fetchStrategyWithCompletion:(void (^)(BOOL ifSuccess))completion
{
//    AuthentificationManager* actManager = [AuthentificationManager getInstance];
//    id<ICertify> certify = [actManager getUserNameCertifyPrivder];
//    [certify fetchStrategyWithCompletion:^(BOOL ifSuccess) {
//        if (completion) {
//            completion(ifSuccess);
//        }
//    }];
}

#pragma mark -
#pragma mark 加密

- (void)encryptWithFilePath:(NSString*)filePath completion:(void (^)(BOOL ifSuccess, NSData* data))completion
{
    
}

#pragma mark -
#pragma mark 解密

- (NSData*)decryptWithFilePath:(NSString*)filePath
{
    return [NSData dataWithEncryptContentsOfFile:filePath];
}

- (void)decryptWithFilePath:(NSString*)filePath completion:(void (^)(BOOL ifSuccess, NSData* data))completion
{
    NSData* data = [NSData dataWithEncryptContentsOfFile:filePath];
    if (completion) {
        completion(data != nil, data);
    }
}

#pragma mark -
#pragma mark 登出

- (void)logOut
{
    @synchronized(self){
        AuthentificationManager* actManager = [AuthentificationManager getInstance];
        id<ICertify> certify = [actManager getUserNameCertifyPrivder];
        
        [certify logoutWithUserAccount:nil];
    };
}

#pragma mark -
#pragma mark 清理

- (void)clear
{
    
}

#pragma mark -
#pragma mark addressData数组 -> addressDataDic数组

- (NSArray*)addressDataDicArrayWithAddressDataArray:(NSArray*)addressDataArray
{
    NSMutableArray* addressDataDicArray = [[NSMutableArray alloc] init];
//    NSInteger count = addressDataArray.count;
//    for (NSInteger i = 0; i < count; i++) {
//        CGAddressData* addressData = addressDataArray[i];
//        NSDictionary* dic = @{
//                              @"mailBox": addressData.mailBox,
//                              @"displayName": addressData.displayName
//                              };
//        [addressDataDicArray addObject:dic];
//    }
    
    return addressDataDicArray;
}

#pragma mark -
#pragma mark addressDataDic数组 -> addressData数组

- (NSArray*)addressDataArrayWithAddressDataDicArray:(NSArray*)addressDataDicArray
{
    NSMutableArray* addressDataArray = [[NSMutableArray alloc] init];
//    NSInteger count = addressDataDicArray.count;
//    for (NSInteger i = 0; i < count; i++) {
//        NSDictionary* addressDataDic = addressDataDicArray[i];
//        CGAddressData* addressData = [[CGAddressData alloc] initWithDisplayName:addressDataDic[@"displayName"]
//                                                                        mailBox:addressDataDic[@"mailBox"]];
//        [addressDataArray addObject:addressData];
//    }
    
    return addressDataArray;
}

- (NSArray*)ChinasecMailPackTaskDatasWithAddressDatas:(NSArray*)addressDatas
{
    NSMutableArray* mailType_friendMail = [[NSMutableArray alloc] init];
    
//    //获取策略
//    MailStrategyAnalysis *analysis = [MailStrategyAnalysis sharedInstance];
//    NSArray* addressDataDicArray = [self addressDataDicArrayWithAddressDataArray:addressDatas];
//    NSMutableSet* userListSet = [[NSMutableSet alloc] initWithArray:addressDataDicArray];
//    NSArray* sendListProperty = [analysis getSendAddressDataDicList:userListSet];
//    //将策略相同的用户合并起来
//    for (MailStrategyProperty* property in sendListProperty) {
//        NSLog(@"action = %@, level = %@", property.encAction, property.level);
//        NSString* encAction = property.encAction;
//        NSString* level = property.level;
//        if ([encAction isEqualToString:@"DENY"]) {
//            continue;
//        }
//        
//        //获取/创建taskData
//        CGChinasecMailPackTaskData* taskData_target = nil;
//        for (CGChinasecMailPackTaskData* taskData in mailType_friendMail) {
//            if ([taskData.encAction isEqualToString:encAction]) {
//                if ([encAction isEqualToString:@"ENCALL"]
//                    || [encAction isEqualToString:@"ENCATT"]) {
//                    if ([taskData.level isEqualToString:level]) {//要确保密级一致
//                        taskData_target = taskData;
//                        break;
//                    }
//                }
//                else {
//                    taskData_target = taskData;
//                    break;
//                }
//            }
//        }
//        if (!taskData_target) {
//            taskData_target = [[CGChinasecMailPackTaskData alloc] initWithEncAction:encAction level:level];
//            [mailType_friendMail addObject:taskData_target];
//        }
//        
//        //为taskData设置用户列表
//        
//        NSArray* addressDataArray = [self addressDataArrayWithAddressDataDicArray:property.userList];
//        [taskData_target.userList addObjectsFromArray:addressDataArray];
//    }
    return mailType_friendMail;
}

@end
