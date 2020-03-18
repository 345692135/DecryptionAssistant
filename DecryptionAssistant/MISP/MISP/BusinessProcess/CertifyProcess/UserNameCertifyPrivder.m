//
//  UserNameCertifyPrivder.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-9-4.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import "UserNameCertifyPrivder.h"

#import "ConfigManager.h"
#import "IConfig.h"
#import "Context+Notify.h"
#import "CommandHelper.h"
#import "GTMBase64.h"
#import "NSString+Degist.h"
#import "AccountManagement.h"
#import "ws_systemsecurity.h"

#import "SubmitSysteminformation.h"
#import "updateProcess.h"

#import "UserSrategyHelper.h"
#import "FlowStatistics.h"
#import "SystemStrategy.h"


@implementation UserNameCertifyPrivder
@synthesize access;
@synthesize isRecv;
@synthesize step;
@synthesize err;

- (void)commandResponse:(SystemCommand *)data
{
    NSLog(@"usernameCertifyprivder commandresponse....");
    if (data == nil) {
        err = SYSTEM_NETWORK_TIMEOUT;
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
    if ([[data getReturnCode]intValue] != 0) {
        //        TRACK(@"%@",[[[data head]rootElement]stringValue]);
        err = [[data getReturnCode]intValue];
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
    
    GDataXMLElement* element = [data getPackageDataObject];
    //    TRACK(@"Package is %@",[element XMLString]);
    if (element == nil) {
        if ([[data getOpcode]intValue] == 204 || [[data getOpcode]intValue] == 502) {//Logout response and change password
            err = [[data getReturnCode]intValue];
        }else{
            err = [[data getReturnCode]intValue];
            if (err == 0) {
                err = SYSTEM_INER_ERROR;
            }
        }
        
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
    
    GDataXMLDocument* doc = [[GDataXMLDocument alloc]initWithRootElement:element];
    
    if ([[data getOpcode]intValue] == 302) {//certify
        [self processCertify:doc];//&&5
    }
    
    //clear document
    [doc release];doc = nil;
    
    err = 0;
    //set step +1 is success
    step = step +1;
    
    [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
    isRecv = YES;
    
}

- (void)processCertify:(GDataXMLDocument*)doc
{
    //get token
    GDataXMLElement* token = [[doc nodesForXPath:@"/DATA/TOKENENC" error:nil] objectAtIndex:0];
    if (token == nil) {
        [doc release];doc = nil;
        err = CERTIFY_GET_TOKEN_ERROR;
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
    
    //get key
    GDataXMLElement* key = [[doc nodesForXPath:@"/DATA/KEYENC" error:nil] objectAtIndex:0];
    if (key == nil) {
        [doc release];doc = nil;
        err = CERTIFY_GET_SESSION_KEY_ERROR;
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
    //get usersid
    GDataXMLElement* sid = [[doc nodesForXPath:@"/DATA/USERSID" error:nil] objectAtIndex:0];
    if (sid == nil) {
        [doc release];doc = nil;
        err = CERTIFY_GET_USER_SID_ERROR;
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
    
    
    AccountManagement* accountManager = [AccountManagement getInstance];
    SystemAccount* accountNow = [accountManager getActiveAccount];
    //token dec
//    NSString* tokenDec = [[NSString alloc] initWithData:[GTMBase64 decodeString:[token stringValue]] encoding:NSUTF8StringEncoding];
//    NSString *tokenDec = [token stringValue];
    
    [accountNow setToken:[token stringValue]];
//    [tokenDec release];tokenDec = nil;
    NSData* sekey = [[NSData alloc]initWithBytes:[[key stringValue] UTF8String] length:[[key stringValue] length]];
    [accountNow setSessionKey:sekey];
    [sekey release];sekey = nil;
    [accountNow setUserSid:[sid stringValue]];
    [accountNow setAccount_st:WSAccountStatusOnline];
    [accountManager changeAccountStatus:WSAccountStatusOnline];
    
    //submit system info
    //int count = [accountManager getAccountCountInDatabase];
    //if (count == 2) {
    //submit device info
    SubmitSysteminformation* submitsysinfo = [[SubmitSysteminformation alloc]init];
    [submitsysinfo submit];//&&6
    //[submitsysinfo release];submitsysinfo=nil;
    TRACK(@"submit system info");
    //}
    
    FlowStatistics* fs = [[FlowStatistics alloc]init];
    [fs submit];
    //[fs release];fs = nil;
    
    TRACK(@"submit 3G flow info")
    
    
}


- (id)init
{
    self = [super init];
    if (self) {         id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
        NSString* ip0 = [config getValueByKey:WSConfigItemIP];
        NSString* port0 = [config getValueByKey:WSConfigItemPort];
        
        if (ip0 == nil || port0 == nil) {
            return nil;
        }
        TCPAccess* newAccess = [[TCPAccess alloc]init];
        self.access = newAccess;
        [newAccess release];
        
        [access setIpAddress:ip0];
        [access setPortNum:[port0 intValue]];
        [access setDelegate:self];
        step = 0;
        err = 0;
        
        //add observer
        NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
        [notifyCenter addObserver:self selector:@selector(resetIpAndPort) name:@"IP_PORT_CHANGED" object:nil];
        
    }
    return self;
}

- (void)dealloc
{
    [access setDelegate:nil];
    [access release];access = nil;
    [super dealloc];
}

- (void)resetIpAndPort
{
    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
    NSString* ip0 = [config getValueByKey:WSConfigItemIP];
    NSString* port0 = [config getValueByKey:WSConfigItemPort];
    
    [access setIpAddress:ip0];
    [access setPortNum:[port0 intValue]];
}

#pragma mark delegate method

//add by lijuan 离线登录
- (long)loginWithUserAccountAfterFirstlogin:(UserAccount *)account{
    @synchronized(self) {
        NSError* error = nil;
        err = 0;
        step = 0;
        isRecv = NO;
        AccountManagement* accountManager = [AccountManagement getInstance];
        //Context* ctx = [Context getInstance];
        //[ctx statusNotifyMessage:@"begin certify" code:0];
        
        [self printActiveAccountInfo];//for test
        
        SystemAccount* activeAccount = [accountManager registerAccountWithUserAccount:account error:&error];
        if (activeAccount == nil) {
            //[ctx statusNotifyMessage:[error domain] code:[error code]];
            return [error code];
        }
        
        [self printActiveAccountInfo];//for test
        
        //NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        
        //get account status
        SystemAccount* accountNow = [accountManager getActiveAccount];
        if([accountNow account_st] == WSAccountStatusOffine){
            //add by liguixi 2014-3-19检查设备是否挂失，挂失后发送通知给客户端
            NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
            if ([userDefaults boolForKey:@"device_lost"]) {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"CLEAR_DATA_SYSTEM_STRATEGY" object:nil];
                return 0;
            }
            if ([UserSrategyHelper permissionOffline] == YES) {//by lijuan：实际上只是判断了允许离线登录
                [userDefaults  setBool:YES forKey:@"permitOfflineLoginFlag"];
                //[ctx statusNotifyMessage:@"offine login is successed" code:0];
                NSString* strMessage = @"用户离线登录成功";
                NSNotification* notify = [NSNotification notificationWithName:@"USER_OFFINE_LOGIN" object:strMessage];
                NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
                [notifyCenter postNotification:notify];
            }
            
            //TRACK(@"[INFO]:permission offline is %d",[UserSrategyHelper permissionOffline])
        }
    }
    return err;
}


- (long)loginWithUserAccount:(UserAccount*)account
{
    @synchronized(self) {
        NSError* error = nil;
        err = 0;
        step = 0;
        isRecv = NO;
        AccountManagement* accountManager = [AccountManagement getInstance];
        //Context* ctx = [Context getInstance];
        //[ctx statusNotifyMessage:@"begin certify" code:0];
        
        [self printActiveAccountInfo];//for test
        
        //add by lijuan 20170208 离线登录后ActiceAccount未注销，此处添加手动注销
        if ([accountManager getActiveAccountCount] >= 1) { //active account is nil
            [accountManager unregisterActiveAccount];
        }
        
        SystemAccount* activeAccount = [accountManager registerAccountWithUserAccount:account error:&error];
        if (activeAccount == nil) {
            //[ctx statusNotifyMessage:[error domain] code:[error code]];
            return [error code];
        }
        
        [self printActiveAccountInfo];//for test
        
        //get account status
        SystemAccount* accountNow = [accountManager getActiveAccount];
        if([accountNow account_st] == WSAccountStatusOffine){
            //add by liguixi 2014-3-19检查设备是否挂失，挂失后发送通知给客户端
            NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
            if ([userDefaults boolForKey:@"device_lost"]) {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"CLEAR_DATA_SYSTEM_STRATEGY" object:nil];
                return 0;
            }
            if ([UserSrategyHelper permissionOffline] == YES) {
                //[ctx statusNotifyMessage:@"offine login is successed" code:0];
                NSString* strMessage = @"用户离线登录成功";
                NSNotification* notify = [NSNotification notificationWithName:@"USER_OFFINE_LOGIN" object:strMessage];
                NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
                [notifyCenter postNotification:notify];
            }
            
            TRACK(@"[INFO]:permission offline is %d",[UserSrategyHelper permissionOffline])
        }
        
        //online certify
        SystemCommand* cmd = [self createCertifyCommand:accountNow];
        if (cmd == nil) {
            [accountManager unregisterActiveAccount];
            return CERTIFY_CREATE_USERPWD_COMMAND_ERROR;
        }
        isRecv = NO;
        [access commandRequest:cmd];
        
        //wait recv
        while (!isRecv)
        {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        
        [self printActiveAccountInfo];//for test
        
        if (err != 0) {
            //if certify is losed
            if ([accountNow account_st] == WSAccountStatusUnknow || [accountNow account_st] == WSAccountStatusMistrust) {
                TRACK(@"del certify lose account")
                [accountManager unregisterActiveAccount];
                [self printActiveAccountInfo];
                
            }else if([accountNow account_st] == WSAccountStatusOffine) {
                if ([UserSrategyHelper permissionOffline] == NO) {
                    TRACK(@"del certify lose account (can not permission offline login)")
                    [accountManager unregisterActiveAccount];
                    [self printActiveAccountInfo];
                }
            }
            
        }
        
        if (err != 0) {
            
            //[ctx statusNotifyMessage:@"online login is failed" code:err];//在线登录failed
            
        }else{
            // add by liguixi 2014-3-19
            //登录成功之后取消设备挂失标志
            NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:NO forKey:@"device_lost"];
            [userDefaults synchronize];
            //[ctx statusNotifyMessage:@"online login is successed" code:err];//在线登录succeed
            
            //update user strategy  0627
            //add by lijuan 20170208
            //如果是二次登录则不需要发送下面更新策略的通知，如果发送界面顶部会有提示，此时已经登录过，所以不需要提示
            NSString* strMessage = @"";
            NSNotification* notify = nil;
            NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
            NSString *secondLoginFlag = [self getSecondLoginFlag];
            if (![secondLoginFlag isEqualToString:@"YES"]) {
                //update user strategy  0627
                strMessage = @"正在更新用户策略";
                notify = [NSNotification notificationWithName:@"UPDATE_USER_STRATEGY" object:strMessage];
                [notifyCenter postNotification:notify];
                
                long iRet = 0;
                updateProcess* update = [[updateProcess alloc]init];
                iRet = [update updateUeserStrategyByUsersid: [accountNow userSid]];
                [update release];
                
                if (iRet != 0){ //0528
                    strMessage = @"更新用户策略失败";
                }else{
                    strMessage = @"更新用户策略完毕";
                }
                notify = [NSNotification notificationWithName:@"UPDATE_USER_STRATEGY" object:strMessage];
                [notifyCenter postNotification:notify];
            }

            
            //online login is success
            strMessage = @"用户在线登录成功";
            notify = [NSNotification notificationWithName:@"USER_ONLINE_LOGIN" object:strMessage];
            [notifyCenter postNotification:notify];
            
            strMessage = @"重启心跳";
            notify = [NSNotification notificationWithName:@"IP_PORT_CHANGED" object:strMessage];
            [notifyCenter postNotification:notify];
            
        }
        
        [access disconnect];
        
    }
    if (err ==2809) {
        // add by liguixi 2014-3-19
        //设备挂失后添加设备挂失的标志
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:YES forKey:@"device_lost"];
        [userDefaults synchronize];
    }
    return err;
}


- (long)logoutWithUserAccount:(UserAccount*)account
{
    @synchronized(self) {
        
        err = 0;
        step = 0;
        isRecv = NO;
        AccountManagement* accountManager = [AccountManagement getInstance];
        //Context* ctx = [Context getInstance];
        
        [self printActiveAccountInfo];//for test
        
        //[ctx statusNotifyMessage:@"begin logout" code:0];
        if ([accountManager getActiveAccountCount] < 1) { //active account is nil
            return 0;
        }
        //get account status
        SystemAccount* accountNow = [accountManager getActiveAccount];
        
        if([accountNow account_st] == WSAccountStatusOffine){// offline user account
            [accountManager unregisterActiveAccount];
            //[ctx statusNotifyMessage:@"offine logout is successed" code:0];
        }else if([accountNow account_st] == WSAccountStatusOnline){//online user account
            SystemCommand* cmd = [self createLogoutCommand:accountNow];
            isRecv = NO;
            [access commandRequest:cmd];
            
            //wait recv
            while (!isRecv)
            {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
            
            if (err == 0) {
                [accountManager unregisterActiveAccount];
                //[ctx statusNotifyMessage:@"logout certify is successed" code:err];
            }else{
                [accountManager unregisterActiveAccount]; //失败也要强制注销掉
                //[ctx statusNotifyMessage:@"logout certify is failed" code:err];
            }
            
            [access disconnect];
        }
        [self printActiveAccountInfo];//for test
    }
    return 0;
}


- (long)changePassword:(NSString*)oldPwd newPassword:(NSString*)newPwd
{
    @synchronized(self) {
        err = 0;
        step = 0;
        isRecv = NO;
        AccountManagement* accountManager = [AccountManagement getInstance];
        //Context* ctx = [Context getInstance];
        
        if ([accountManager getActiveAccountCount] < 1) { //active account is nil
            return 0;
        }
        
        //[ctx statusNotifyMessage:@"begin change password" code:0];
        //get account status
        SystemAccount* accountNow = [accountManager getActiveAccount];
        if([accountNow account_st] == WSAccountStatusOffine){// offline user account
            //[ctx statusNotifyMessage:@"offine status can not change password" code:0];
        }else if([accountNow account_st] == WSAccountStatusOnline){//online user account
            
            //check old password
            if ([[accountNow.pwdAct userPassword]isEqualToString:oldPwd] == NO) {
                //[ctx statusNotifyMessage:@"change password old password local judge is losed" code:0];
                return CHANGE_PASSWORD_OLD_PASSWORD_ERROR;
            }
            
            SystemCommand* cmd = [self createChangePasswordCommand:[accountNow.pwdAct userPassword]
                                                       newPassword:newPwd
                                                          userName:[accountNow.pwdAct userName]
                                                           userSid:[accountNow userSid]];
            if (cmd == nil) {
                NSLog(@"****change password command is nil****");
                return SYSTEM_INER_ERROR;
            }
            
            isRecv = NO;
            [access commandRequest:cmd];
            
            //wait recv
            while (!isRecv)
            {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
            
            if (err == 0) {
                [[accountNow pwdAct]setUserPassword:newPwd];
                [[accountNow pwdAct]setUserPasswordMD5:[newPwd md5]];
                [[accountNow pwdAct]setUserPasswordSHA1:[newPwd sha1]];
                [accountManager changePassword];
                //[ctx statusNotifyMessage:@"change password is successed" code:err];
            }else{
                //[ctx statusNotifyMessage:@"change password is failed" code:err];
            }
            
            [access disconnect];
        }
    }
    return err;
}

- (int)getLoginAccoutStutus
{
    @synchronized(self){
        AccountManagement* accountManager = [AccountManagement getInstance];
        SystemAccount* accountNow = [accountManager getActiveAccount];
        if ([accountNow account_st]== WSAccountStatusOffine) {
            return 10;
        }else if([accountNow account_st]== WSAccountStatusOnline){
            return 20;
        }else{
            return -1;
        }
    }
}

- (long)activeAccountReOnlinelogin
{
    @synchronized(self){
        
        err = 0;
        step = 0;
        isRecv = NO;
        AccountManagement* accountManager = [AccountManagement getInstance];
        //Context* ctx = [Context getInstance];
        //get account status
        SystemAccount* accountNow = [accountManager getActiveAccount];
        
        if ([accountNow account_st] == WSAccountStatusOnline) {//already online
            return 0;
        }
        
        if([accountNow account_st] != WSAccountStatusOffine){
            return CERTIFY_RELOGIN_ERROR;
        }
        
        //online certify
        SystemCommand* cmd = [self createCertifyCommand:accountNow];
        if (cmd == nil) {
            return CERTIFY_CREATE_USERPWD_COMMAND_ERROR;
        }
        isRecv = NO;
        [access commandRequest:cmd];
        
        //wait recv        
        while (!isRecv)
        {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        
        [self printActiveAccountInfo];//for test
        
        if (err != 0) {
            //if certify is losed
            if ([accountNow account_st] == WSAccountStatusUnknow || [accountNow account_st] == WSAccountStatusMistrust) {
                TRACK(@"del certify lose account")
                [accountManager unregisterActiveAccount];
                [self printActiveAccountInfo];
            }
        }
        
        if (err != 0) {
            //[ctx statusNotifyMessage:@"online login is failed" code:err];
        }else{
            //[ctx statusNotifyMessage:@"online login is successed" code:err];
        }
        
        [access disconnect];
    }
    return err;
}

#pragma mark Tools method

- (SystemCommand*)createCertifyCommand:(SystemAccount*)account
{
    if (account == nil) {
        return nil;
    }
    long lRet = 0;
    size_t encLen = 0;
    unsigned char pwdenc[180] = {0};
    
    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
    NSString* guid = [config getValueByKey:WSConfigItemGuid];
    
    // encrypt password
    NSString* password = [[account pwdAct]userPassword];
    lRet = Ikey_Encrypt((unsigned char*)[password UTF8String], [password length], pwdenc, &encLen);
    if (lRet == -1) {
        return nil;
    }
    
    NSString* encPasswordBase64 = [[NSString alloc] initWithData:[GTMBase64 encodeBytes:pwdenc length:encLen]
                                                        encoding:NSUTF8StringEncoding];
    
    NSString* xmlStr = [NSString stringWithFormat:@"<HEAD>\
                        <MODULEID>300</MODULEID>\
                        <OPCODE>301</OPCODE>\
                        <SIGN>111111111111111111111111</SIGN>\
                        </HEAD>\
                        <DATA>\
                        <GUID encode=\"\">%@</GUID>\
                        <USERSID encode=\"\">%@</USERSID>\
                        <CERTIFYTYPE encode=\"\">30101</CERTIFYTYPE>\
                        <USERACCOUNT encode=\"\">%@</USERACCOUNT>\
                        <PASSWORDENCLEN encode=\"\">%ld</PASSWORDENCLEN>\
                        <PASSWORDENC encode=\"BASE64\">%@</PASSWORDENC>\
                        </DATA>",guid,
                        SYSTEM_DEFAULT_USER_SID,
                        [[account pwdAct]userName],
                        (unsigned long)[encPasswordBase64 length],
                        encPasswordBase64];
    [encPasswordBase64 release];encPasswordBase64 = nil;
    
    //    TRACK(@"%@",xmlStr);
    
    NSData* xml = [NSData dataWithBytes:[xmlStr UTF8String] length:strlen([xmlStr UTF8String])];
    SystemCommand* command = [CommandHelper createCommandWithXMLData:xml isVerifyData:NO];
    
    return command;
    
}

- (SystemCommand*)createLogoutCommand:(SystemAccount*)account
{
    if (account == nil) {
        return nil;
    }
    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
    NSString* guid = [config getValueByKey:WSConfigItemGuid];
    
    //    TRACK(@"Token is %@",[account token]);
    
    NSString* xmlStr = [NSString stringWithFormat:@"<HEAD>\
                        <MODULEID>200</MODULEID>\
                        <OPCODE>203</OPCODE>\
                        <SIGN>111111111111111111111111</SIGN>\
                        </HEAD>\
                        <DATA>\
                        <GUID encode=\"\">%@</GUID>\
                        <USERSID encode=\"\">%@</USERSID>\
                        <TOKENSHA1 encode=\"\">%@</TOKENSHA1>\
                        </DATA>",guid,
                        [account userSid],
                        [account token]];
    
    NSData* xml = [NSData dataWithBytes:[xmlStr UTF8String] length:strlen([xmlStr UTF8String])];
    SystemCommand* command = [CommandHelper createCommandWithXMLData:xml isVerifyData:NO];
    
    return command;
}

- (SystemCommand*)createChangePasswordCommand:(NSString*)oldPin
                                  newPassword:(NSString*)newPin
                                     userName:(NSString*)name
                                      userSid:(NSString*)sid
{
    unsigned char oldpwdenc[512] = {0};
    unsigned char newpwdenc[512] = {0};
    long lRet = 0;
    size_t encLen = 0;
    
    //encrypt  old password
    lRet = Ikey_Encrypt((unsigned char*)[oldPin UTF8String], [oldPin length], oldpwdenc, &encLen);
    if (lRet == -1) {
        NSLog(@"****ikey encrypt old password failed****");
        return nil;
    }
    
    NSString* encOldPasswordBase64 = [[NSString alloc] initWithData:[GTMBase64 encodeBytes:oldpwdenc length:encLen]
                                                           encoding:NSUTF8StringEncoding];
    
    //encrypt  new password
    lRet = 0;
    encLen= 0;
    lRet = Ikey_Encrypt((unsigned char*)[newPin UTF8String], [newPin length], newpwdenc, &encLen);
    if (lRet == -1) {
        NSLog(@"****ikey encrypt new password failed****");
        [encOldPasswordBase64 release];
        return nil;
    }
    
    
    NSString* encNewPasswordBase64 = [[NSString alloc] initWithData:[GTMBase64 encodeBytes:newpwdenc length:encLen]
                                                           encoding:NSUTF8StringEncoding];
    
    
    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
    NSString* guid = [config getValueByKey:WSConfigItemGuid];
    
    NSString* xmlStr = [NSString stringWithFormat:@"<HEAD>\
                        <SIGN>null</SIGN>\
                        <MODULEID>500</MODULEID>\
                        <OPCODE>501</OPCODE>\
                        </HEAD>\
                        <DATA>\
                        <USERACCOUNT>%@</USERACCOUNT>\
                        <PASSWORDENCLEN>%d</PASSWORDENCLEN>\
                        <GUID>%@</GUID>\
                        <PASSWORDENC encode=\"BASE64\">%@</PASSWORDENC>\
                        <USERSID>%@</USERSID>\
                        <NEWPASSWORDENC encode=\"BASE64\">%@</NEWPASSWORDENC>\
                        <NEWPASSWORDENCLEN>%d</NEWPASSWORDENCLEN>\
                        </DATA>\
                        ",name,(unsigned long)[oldPin length],guid,encOldPasswordBase64,sid,encNewPasswordBase64,[newPin length]];
    
    NSData* xml = [NSData dataWithBytes:[xmlStr UTF8String] length:strlen([xmlStr UTF8String])];
    SystemCommand* command = [CommandHelper createCommandWithXMLData:xml isVerifyData:NO];
    [encOldPasswordBase64 release];
    [encNewPasswordBase64 release];
    return command;
}

- (NSString*)getActiveAccountSID
{
    AccountManagement* accountManager = [AccountManagement getInstance];
    SystemAccount* account = [accountManager getActiveAccount];
    return [account userSid];
}

-(void) wakeup
{
    //NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
    usleep(10);
    [self performSelectorOnMainThread:@selector(setRecv) withObject:nil waitUntilDone:YES];
    //[pool release];
}

-(void)setRecv
{
    self.isRecv = YES;
}

- (void)printActiveAccountInfo
{
    //test
    AccountManagement* accountManager = [AccountManagement getInstance];
    SystemAccount* tmp = [accountManager getActiveAccount];
    TRACK(@"3 NOW ACTIVE ACCOUNT IS <%@>",tmp)
    TRACK(@"3 Active account info :\r \t SID: %@ \r\t%d",[tmp userSid],[tmp account_st]);
}

//begin: add by lijuan 20170117: 获取二次登录的标志位
- (NSString *)getSecondLoginFlag{
    NSString *documentsDirectory= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *fileNameForLogin = [documentsDirectory stringByAppendingPathComponent:@"secondLoginFlag.plist"];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:fileNameForLogin];
    return [dictionary objectForKey:@"KIsSecondLoginFlag"];
}


@end
