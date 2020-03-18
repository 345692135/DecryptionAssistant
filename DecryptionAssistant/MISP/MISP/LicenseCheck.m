//
//  LicenseCheck.m
//  MISP
//
//  Created by YouGik on 15-9-21.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import "LicenseCheck.h"

#import "ConfigManager.h"
#import "IConfig.h"
#import "Context+Notify.h"
#import "CommandHelper.h"
#import "tbSysConfig.h"
#import "tbStrategy.h"
#import "GTMBase64.h"

#import "SystemStrategy.h"

#import "AccountManagement.h"


@implementation LicenseCheck

@synthesize access;
@synthesize step;
@synthesize err;
@synthesize isRecv;

- (void)commandResponse:(SystemCommand *)data
{
    //NSLog(@"license response ...");
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
    
    //0921，Log输出调试
    NSString* m = [data getModuleid];//模块码 400 Strategy module
    NSString* opCode = [data getOpcode];//操作码 404
    NSLog(@"MOduleid = %@, license check response opCode = %@",m,opCode);

    
    //使用NSUserDefaults版本
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    //取element
    GDataXMLElement* element = [data getPackageDataObject];
    //NSLog(@"license response data：%@",element);
    if (element == nil) {
        err = [[data getReturnCode]intValue];
        if (err == 0) {
            err = -2;
        }
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
    
    
    //创建doc， 取nodes
    GDataXMLDocument* doc = [[GDataXMLDocument alloc]initWithRootElement:element];
    
    NSArray* nodesArr = [doc nodesForXPath:@"/DATA/LICENSEINFO" error:nil];
    if ([nodesArr count] == 0) {
        [doc release];doc = nil;
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
    
    //get approve info
    GDataXMLElement* licenseInfoXml = [nodesArr objectAtIndex:0];
    //NSLog(@"licenseInfoXml=%@",licenseInfoXml);
    if (licenseInfoXml == nil) {
        [doc release];doc = nil;
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
    

    //base64 解码
    NSString* licenseInfoStr= [[NSString alloc] initWithData:[GTMBase64 decodeString:[licenseInfoXml stringValue]] encoding:NSUTF8StringEncoding];
    //NSLog(@"licenseInfoStr:%@",licenseInfoStr);
    
    //生成xml格式
    NSString* xmlStr = [NSString stringWithFormat:@"<HEAD><MODULEID>400</MODULEID><OPCODE>404</OPCODE><SIGN>111111111111111111111111</SIGN></HEAD><DATA><LICENSEINFO encode=\"\">%@</LICENSEINFO></DATA>",licenseInfoStr];
    NSData* xml2 = [NSData dataWithBytes:[xmlStr UTF8String] length:strlen([xmlStr UTF8String])];
    SystemCommand* data2 = [CommandHelper createCommandWithXMLData:xml2 isVerifyData:NO];
    GDataXMLElement* element2 = [data2 getPackageDataObject];
    GDataXMLDocument* doc2 = [[GDataXMLDocument alloc]initWithRootElement:element2];
    NSArray* nodesArr2 = [doc2 nodesForXPath:@"/DATA/LICENSEINFO/SaleNumber" error:nil];
    
    //首次授权，有10s的数据库刷新时间差，没有任何授权信息
    if([nodesArr count] == 0){
        [doc release];doc = nil;
        [doc2 release];doc2 = nil;
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
    //[nodesArr count] != 0
    [def setBool:YES forKey:@"KlicenseInitailed"];//表示成功了，成功一次后，这个key的值保持为YES
    
    //解析，存入队列
    NSMutableArray* licCodeArrFromServer = [NSMutableArray arrayWithCapacity:0 ];
    for (GDataXMLElement* tt in nodesArr2) {
        NSString* licCode = [tt stringValue];
        [licCodeArrFromServer addObject:licCode];
    }
    //NSLog(@"sale numbers count: %ld",(unsigned long)[licCodeArrFromServer count]);

    
    //设定 移动 授权码:   819-addrList,  795-mail,   809-browser,   818-approve,  xxx-fileShare
    NSArray* mobileLicCodeArr = [NSArray arrayWithObjects:LICENSE_CODE_ADDRLIST,
                                                        LICENSE_CODE_EMAIL,
                                                        LICENSE_CODE_BROWSER,
                                                        LICENSE_CODE_APPROVE,
                                                        nil];
    NSArray* keyArrForDef = [NSArray arrayWithObjects:@"KaddrListLicensed",@"KemailLicensed",
                             @"KbrowserLicensed", @"KapproveLicensed",nil];//@"KfileShareLicensed",

    //比对是否有移动模块授权，授权了哪些功能
    for (int i = 0; i < [mobileLicCodeArr count]; i ++) {
        if([licCodeArrFromServer containsObject:[mobileLicCodeArr objectAtIndex:i]]){
            [def setBool:YES forKey:[keyArrForDef objectAtIndex:i]];
        }
        else{
            [def setBool:NO forKey:[keyArrForDef objectAtIndex:i]];
        }
    }

    //save
    [def synchronize];
    
    //clear document
    [doc release];doc = nil;
    [doc2 release];doc2 = nil;
    
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
        //NSLog(@"license check ip:%@, port:%@",ip0,port0);

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


-(long)licenseCheck
{
    //NSLog(@"license check request...");
    //发送包 - 0921
    SystemCommand* cmd;
    
    cmd = [self createInitCommand_licenseRequest];//上报当期版本信息

    if (cmd == nil) {
        return LICENSE_CHECK_CREATE_INIT_COMMANDD_ERROR;
    }
    isRecv = NO;
    [access commandRequest:cmd];
    
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
-(SystemCommand*)createInitCommand_licenseRequest
{
    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
    NSString* guid= [config getValueByKey:WSConfigItemGuid];//通过uuid计算得到
    NSString* sid = [self getActiveAccountSID];

    //NSLog(@"guid: %@",guid);
    //NSLog(@"sid: %@",sid);
    
    if (guid == nil || sid == nil) {
        return nil;
    }
    
    NSString* xmlStr = [NSString stringWithFormat:@"<HEAD><MODULEID>400</MODULEID><OPCODE>403</OPCODE><SIGN>111111111111111111111111</SIGN></HEAD><DATA><GUID encode=\"\">%@</GUID><USERSID encode=\"\">%@</USERSID></DATA>",guid,sid];
    
    NSLog(@"license check xmlStr:%@",xmlStr);
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
