//
//  SystemSetup.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-8-29.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import "SystemSetup.h"

#import "ConfigManager.h"
#import "IConfig.h"
#import "Context+Notify.h"
#import "CommandHelper.h"
#import "tbSysConfig.h"
#import "tbStrategy.h"
#import "GTMBase64.h"

#import "SystemStrategy.h"

@implementation SystemSetup
@synthesize access;
@synthesize step;
@synthesize err;
@synthesize isRecv;

- (void)commandResponse:(SystemCommand *)data
{
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
    
    
    //20160419，Log输出调试
    NSString* m = [data getModuleid];//模块码 100
    NSString* opCode = [data getOpcode];//操作码 104
    NSLog(@"MOduleid = %@, opCode = %@",m,opCode);
    if ([opCode isEqualToString:@"104"]) {
        GDataXMLElement* element104 = [data getPackageDataObject];
        NSLog(@"element104:%@",element104);
        if (element104 == nil) {
            err = [[data getReturnCode]intValue];
            if (err == 0) {
                err = -2;
            }
            [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
            isRecv = YES;
            return;
        }
        GDataXMLDocument* doc104 = [[GDataXMLDocument alloc]initWithRootElement:element104];
        //get system strategy
        GDataXMLElement* mainServerIP = [[doc104 nodesForXPath:@"/DATA/MAINSERVERIP" error:nil] objectAtIndex:0];
        NSLog(@"mainServerIP:%@",mainServerIP);
        if (mainServerIP == nil) {
            [doc104 release];doc104 = nil;
            err = SYSTEM_IP_PORT_ERROR;
            [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
            isRecv = YES;
            return;
        }
        else {
            NSString* xmlMainServerIP= [[NSString alloc] initWithData:[GTMBase64 decodeString:[mainServerIP stringValue]] encoding:NSUTF8StringEncoding];
            NSLog(@"xmlMainServerIP:%@",xmlMainServerIP);
            
            xmlMainServerIP = [mainServerIP stringValue];
            NSLog(@"xmlMainServerIP:%@",xmlMainServerIP);
            [self saveMainServerIP:xmlMainServerIP];
            
            err = 0;
            step = step +1;
            [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
            isRecv = YES;
        }
        
        NSLog(@"get main server ip for mobile approve succeed...");
        return;
    }
    
    
    
    GDataXMLElement* element = [data getPackageDataObject];
    if (element == nil) {
        err = [[data getReturnCode]intValue];
        if (err == 0) {
            err = -2;
        }
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
    GDataXMLDocument* doc = [[GDataXMLDocument alloc]initWithRootElement:element];
    
    //get system strategy
    GDataXMLElement* systemStrategy = [[doc nodesForXPath:@"/DATA/SYSTEMSTRATEGY" error:nil] objectAtIndex:0];
    if (systemStrategy == nil) {
        [doc release];doc = nil;
        err = SYSTEM_INIT_SYSTEMSTRATEGY_ERROR;
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
    
    //change base64
    NSString* xmlSystemStrategy = [[NSString alloc] initWithData:[GTMBase64 decodeString:[systemStrategy stringValue]] encoding:NSUTF8StringEncoding];
    //change '&'
    NSString* xmlSystemStrategy2 = [xmlSystemStrategy stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    
    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
    [config setValueByKey:WSConfigItemSystemStrategy value:xmlSystemStrategy2];
    [xmlSystemStrategy release];xmlSystemStrategy = nil;
    
    //get defult user strategy
    
    GDataXMLElement* userStrategy = [[doc nodesForXPath:@"/DATA/NOMALUSERSTRATEGY" error:nil] objectAtIndex:0];
    if (userStrategy == nil) {
        [doc release];doc = nil;
        err = SYSTEM_INIT_NOMALUSERSTRATEGY_ERROR;
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
    
    //change base64
    NSString* xmlUserStrategy = [[NSString alloc] initWithData:[GTMBase64 decodeString:[userStrategy stringValue]] encoding:NSUTF8StringEncoding];
    
    //change '&'
    NSString* xmlUserStrategy2 = [xmlUserStrategy stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    
    NSString* sql = [NSString stringWithFormat:@"WHERE strategy_sid = '%@'",SYSTEM_DEFAULT_USER_SID];
    tbStrategy* strategy =(tbStrategy*)[tbStrategy findFirstByCriteria:sql];
    if (strategy != nil) {
        const char* szBuffer = [xmlUserStrategy2 UTF8String];
        [strategy setXmlData:[NSData dataWithBytes:szBuffer length:strlen(szBuffer)]];
        [strategy save];
        [tbStrategy clearCache];
    }
    [xmlUserStrategy release];xmlUserStrategy = nil;
    
    
    //get system author
    GDataXMLElement* authorStrategy = [[doc nodesForXPath:@"/DATA/AUTHORSTRATEGY" error:nil] objectAtIndex:0];
    if (authorStrategy == nil) {
        [doc release];doc = nil;
        err = SYSTEM_INIT_AUTHORSTRATEGY_ERROR;
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
    
    //change base64
    NSString* xmlAuthorStrategy = [[NSString alloc] initWithData:[GTMBase64 decodeString:[authorStrategy stringValue]] encoding:NSUTF8StringEncoding];
    
    //change '&'
    NSString* xmlAuthorStrategy2 = [xmlAuthorStrategy stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    
    [config setValueByKey:WSConfigItemSystemPermission value:xmlAuthorStrategy2];
    [xmlAuthorStrategy release];xmlAuthorStrategy = nil;
    
    //get guid
    GDataXMLElement* guid = [[doc nodesForXPath:@"/DATA/GUID" error:nil] objectAtIndex:0];
    if (guid == nil) {
        [doc release];doc = nil;
        err = SYSTEM_INIT_GUID_ERROR;
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
    [config setValueByKey:WSConfigItemGuid value:[guid stringValue]];
    
    NSLog(@"guid has been save to db.");
    
    //clear document
    [doc release];doc = nil;
    
    err = 0;
    //set step +1 is success
    step = step +1;
    //set system init is YES
//    [config setValueByKey:WSConfigInit value:[NSNumber numberWithBool:YES]]; //modify by wangbingyang 2012-11-21
    
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

- (void)dealloc
{
    [access setDelegate:nil];
    [access release];access = nil;
    [super dealloc];
}

-(long) beginSetup
{
    SystemCommand* cmd = [self createInitCommand];
    if (cmd == nil) {
        return SYSTEM_SETUP_CREATE_INIT_COMMAND_ERROR;
    }
    isRecv = NO;
    [access commandRequest:cmd];
    
    while (!isRecv)
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    //For test code
    
//    NSString* path = [[NSBundle mainBundle]pathForResource:@"init" ofType:@"xml"];
//    NSData *data= [NSData dataWithContentsOfFile:path];
//    SystemCommand* cmd = [CommandHelper createCommandWithXMLData:data isVerifyData:NO];
//    
//    GDataXMLElement* element = [cmd getPackageDataObject];
//    GDataXMLDocument* doc = [[GDataXMLDocument alloc]initWithRootElement:element];
//    GDataXMLElement* systemStrategy = [[doc nodesForXPath:@"/DATA/SYSTEMSTRATEGY/RESPONSE" error:nil] objectAtIndex:0];
//    
//    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
//    [config setValueByKey:WSConfigItemSystemStrategy value:[systemStrategy XMLString]];
//    
//    SystemStrategy* strategy = [config getValueByKey:WSConfigItemSystemStrategy];
//    
//    NSLog(@"%@",[strategy getStrategySHA1]);
    [access disconnect];
    
    return err;
    
}

-(SystemCommand*)createInitCommand
{
    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
    NSString* macAddr = [config getValueByKey:WSConfigItemMacAddress];
    NSString* productKey = [config getValueByKey:WSConfigItemProductKey];
    
    if (macAddr == nil || productKey == nil) {
        return nil;
    }
//    TRACK(@"product key is <%@>",productKey);
    NSString* xmlStr = [NSString stringWithFormat:@"<HEAD><MODULEID>100</MODULEID><OPCODE>101</OPCODE><SIGN>111111111111111111111111</SIGN></HEAD><DATA><GUID encode=\"\">%@</GUID><PRODUCTKEY encode=\"\">%@</PRODUCTKEY></DATA>",macAddr,productKey];
    
    NSData* xml = [NSData dataWithBytes:[xmlStr UTF8String] length:strlen([xmlStr UTF8String])];
    SystemCommand* command = [CommandHelper createCommandWithXMLData:xml isVerifyData:NO];
    
    return command;
}

#pragma mark -
-(long) getMainServerIP
{
    SystemCommand* cmd = [self createInitCommand2];
    if (cmd == nil) {
        return SYSTEM_SETUP_CREATE_INIT_COMMAND_ERROR;
    }
    isRecv = NO;
    [access commandRequest:cmd];
    
    while (!isRecv)
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    [access disconnect];
    
    return err;
    
}

-(SystemCommand*)createInitCommand2
{
    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
    NSString* macAddr = [config getValueByKey:WSConfigItemMacAddress];
    NSString* productKey = [config getValueByKey:WSConfigItemProductKey];
    
    NSString* guid= [config getValueByKey:WSConfigItemGuid];//通过uuid计算得到

    if (guid == nil) {
        return nil;
    }

    NSString* xmlStr = [NSString stringWithFormat:@"<HEAD><MODULEID>100</MODULEID><OPCODE>103</OPCODE><SIGN>111111111111111111111111</SIGN></HEAD><DATA><GUID encode=\"\">%@</GUID></DATA>",guid];
    
    NSLog(@"getMainServerIP check xmlStr:%@",xmlStr);
    NSData* xml = [NSData dataWithBytes:[xmlStr UTF8String] length:strlen([xmlStr UTF8String])];
    SystemCommand* command = [CommandHelper createCommandWithXMLData:xml isVerifyData:NO];
    
    return command;
}

- (void)saveMainServerIP:(NSString*)mainServerIP
{
    //使用NSUserDefaults版本
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    [def setObject:mainServerIP forKey:@"kMainServerIP"];
    [def synchronize];
}

#pragma mark -

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
