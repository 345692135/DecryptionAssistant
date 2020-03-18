//
//  UpdateCheck.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-8-29.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import "UpdateCheck.h"

#import "ConfigManager.h"
#import "IConfig.h"
#import "Context+Notify.h"
#import "CommandHelper.h"
#import "tbSysConfig.h"
#import "tbStrategy.h"
#import "GTMBase64.h"

#import "SystemStrategy.h"

#import "AccountManagement.h"


@implementation UpdateCheck

@synthesize access;
@synthesize step;
@synthesize err;
@synthesize isRecv;

- (void)commandResponse:(SystemCommand *)data
{
    //NSLog(@"update response ...");
    if (data == nil) {
        err = SYSTEM_NETWORK_TIMEOUT;
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }

    if ([[data getReturnCode]intValue] != 0) {
        err = [[data getReturnCode]intValue];
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
    
    //0526，opCode=604则不做处理
    NSString* m = [data getModuleid];//null
    NSString* opCode = [data getOpcode];//升级成功后上报响应包
    NSLog(@"MOduleid = %@, updateCheck response opCode = %@",m,opCode);
    if ([opCode isEqualToString:@"604"]) {//检查升级的响应包opCode为602
        NSLog(@"-----------");
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        err = 0;//0528
        isRecv = YES;
        return;
    }

    
    //取数据
    GDataXMLElement* element = [data getPackageDataObject];
    //NSLog(@"update response data：%@",element);
    
    //使用NSuserDefaults版本
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    if (element == nil) {
        [def setObject:@"errorResponse" forKey:@"kUpdateResponse"];
        err = [[data getReturnCode]intValue];
        if (err == 0) {
            err = -2;
        }
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }else{
        [def setObject:@"correctResponse" forKey:@"kUpdateResponse"];
    }
    
    GDataXMLDocument* doc = [[GDataXMLDocument alloc]initWithRootElement:element];

    
    //get download URL
//    GDataXMLElement* URL = [[doc nodesForXPath:@"/DATA/URL" error:nil] objectAtIndex:0];
    //NSLog(@"url=%@",URL);
    NSArray *urlArray = [doc nodesForXPath:@"/DATA/URL" error:nil];
    if (!(urlArray&&urlArray.count>0)) {
        [def setObject:@"withoutDownloadURL" forKey:@"kDownloadURL"];
        [doc release];doc = nil;
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
    GDataXMLElement* URL = [urlArray objectAtIndex:0];
    
    if (URL == nil) {
        [def setObject:@"withoutDownloadURL" forKey:@"kDownloadURL"];
        [doc release];doc = nil;
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }else{
        //change base64
        NSString* xmlURL= [[NSString alloc] initWithData:[GTMBase64 decodeString:[URL stringValue]] encoding:NSUTF8StringEncoding];
        if ([xmlURL isEqual:nil]) {
            [def setObject:@"withoutDownloadURL" forKey:@"kDownloadURL"];
        }else{
            [def setObject:xmlURL forKey:@"kDownloadURL"];
        }
    }
    
    
    //get latest version
//    GDataXMLElement* version = [[doc nodesForXPath:@"/DATA/VERSION" error:nil] objectAtIndex:0];
    
    NSArray *versionArray = [doc nodesForXPath:@"/DATA/VERSION" error:nil];
    if (!(versionArray&&versionArray.count>0)) {
        [def setObject:@"withoutNewVersionInfo" forKey:@"kLatestVersion"];
        [doc release];doc = nil;
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
    GDataXMLElement* version = [versionArray objectAtIndex:0];
    NSLog(@"ver=%@",version);
    if (version == nil) {
        [def setObject:@"withoutNewVersionInfo" forKey:@"kLatestVersion"];
        [doc release];doc = nil;
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }else{
        NSString* xmlVersion = [NSString stringWithFormat:@"%@",[version stringValue]];
        
        if ([xmlVersion isEqual:nil]) {
            [def setObject:@"withoutNewVersionInfo" forKey:@"kLatestVersion"];
        }else{
            //xmlVersion = [NSString stringWithFormat:@"Mob Safe V3.1.2"]; //for test
            [def setObject:xmlVersion forKey:@"kLatestVersion"];
        }
    }
    
    //save
    [def synchronize];
    
    //clear document
    [doc release];doc = nil;
    
    err = 0;
    //set step +1 is success
    step = step +1;
    
    [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
    isRecv = YES;
}



- (id)init
{
    self = [super init];
    if (self) {
        id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
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
    }
    return self;
}

//- (void)dealloc
//{
//    [access setDelegate:nil];
//    [access release];access = nil;
//    [super dealloc];
//}


- (NSString*)getActiveAccountSID
{
    AccountManagement* accountManager = [AccountManagement getInstance];
    SystemAccount* account = [accountManager getActiveAccount];
    return [account userSid];
}


-(long)updateCheckThread
{
    //当前版本
    NSString* localVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    //上次使用记录版本
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    NSString* previousVersion = [def objectForKey:@"kPreviousVersion"];
    
    //发送包 - 0526 分为版本上报和升级结果上报
    SystemCommand* cmd;
    
    if ([previousVersion isEqualToString:@"withoutPreVersionInfo"])//安装后首次打开
    {
        //NSLog(@"首次打开");
        [def setObject:localVersion forKey:@"kPreviousVersion"];
        cmd = [self createInitCommand_updateRequest];//上报当期版本信息
    }
    else if([previousVersion isEqualToString:localVersion])
    {
        //NSLog(@"发送版本信息");
        cmd = [self createInitCommand_updateRequest];//上报当期版本信息，返回包opCode=602
    }
    else//升级后首次打开，preVersion不同于localVersion
    {
        NSLog(@"升级成功后上报");
        [def setObject:localVersion forKey:@"kPreviousVersion"];
        cmd = [self createInitCommand_updateSucceed];//升级成功上报，返回包opCode=604
    }
    
    [def synchronize];
    
    if (cmd == nil) {
        return UPDATE_CHECK_CREATE_INIT_COMMANDD_ERROR;
    }

    isRecv = NO;
    [access commandRequest:cmd];
    
    err = 0;//0528

    return 0;
}

-(long)updateCheck
{
    
    [NSThread detachNewThreadSelector:@selector(updateCheckThread) toTarget:self withObject:nil];

     while (!isRecv)
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    [access disconnect];
    [access setDelegate:nil];
    [access release];access = nil;

    return err;
    
}

//请求服务器最新版本
-(SystemCommand*)createInitCommand_updateRequest
{
    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
    NSString* guid= [config getValueByKey:WSConfigItemGuid];//通过uuid计算得到
    NSString* sid = [self getActiveAccountSID];
    NSString* localVersion = [[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleShortVersionString" ];
    
    //NSLog(@"guid: %@",guid);
    //NSLog(@"sid: %@",sid);
    
    if (guid == nil || sid == nil) {
        return nil;
    }
    
    NSString* xmlStr = [NSString stringWithFormat:@"<HEAD> <MODULEID>600</MODULEID> <OPCODE>601</OPCODE><SIGN>111111111111111111111111</SIGN></HEAD>   <DATA><GUID encode=\"\">%@</GUID>  <USERSID encode=\"\">%@</USERSID>   <VERSION encode=\"\">%@</VERSION>  <OSTYPE encode=\"\">%d</OSTYPE> </DATA>",guid,sid,localVersion,UPDATE_CHECK_REQUEST_DATA_OSTYPE_IOS];
    
    NSData* xml = [NSData dataWithBytes:[xmlStr UTF8String] length:strlen([xmlStr UTF8String])];
    SystemCommand* command = [CommandHelper createCommandWithXMLData:xml isVerifyData:NO];
    
    return command;
}

//上报升级成功
-(SystemCommand*)createInitCommand_updateSucceed
{
    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
    NSString* guid= [config getValueByKey:WSConfigItemGuid];//通过uuid计算得到
    NSString* sid = [self getActiveAccountSID];
    NSString* localVersion = [[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleShortVersionString" ];
    
    if (guid == nil || sid == nil) {
        return nil;
    }
    
    //取当前日期
    NSDateFormatter *formatter = [[[NSDateFormatter alloc]init]autorelease];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString* currentDate = [formatter stringFromDate:[NSDate date]];//2015-05-26
    
    NSString* xmlStr = [NSString stringWithFormat:@"<HEAD> <MODULEID>600</MODULEID> <OPCODE>603</OPCODE><SIGN>111111111111111111111111</SIGN></HEAD>   <DATA><GUID encode=\"\">%@</GUID>  <USERSID encode=\"\">%@</USERSID>   <VERSION encode=\"\">%@</VERSION>  <CHECKTIMEUTC encode=\"\">%@</CHECKTIMEUTC> <STATUS encode=\"\">%d</STATUS> </DATA>",guid,sid,localVersion,currentDate,UPDATE_CHECK_REQUEST_UPDATE_SUCCEED];
    
    NSData* xml = [NSData dataWithBytes:[xmlStr UTF8String] length:strlen([xmlStr UTF8String])];
    SystemCommand* command = [CommandHelper createCommandWithXMLData:xml isVerifyData:NO];
    
    return command;
}

    
-(void) wakeup
{
    //NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
    [self performSelectorOnMainThread:@selector(setRecv) withObject:nil waitUntilDone:YES];
    //[pool release];
}

-(void)setRecv
{
    self.isRecv = YES;
}



@end
