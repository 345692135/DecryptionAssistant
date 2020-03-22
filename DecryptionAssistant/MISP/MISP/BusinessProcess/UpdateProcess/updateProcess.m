//
//  updateProcess.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-9-9.
//
//

#import "updateProcess.h"
#import "ConfigManager.h"
#import "IConfig.h"
#import "Context+Notify.h"
#import "CommandHelper.h"
#import "tbSysConfig.h"
#import "tbStrategy.h"
#import "GTMBase64.h"


@implementation updateProcess
@synthesize access;
@synthesize step;
@synthesize err;
@synthesize isRecv;

- (void)commandResponse:(SystemCommand *)data
{
    if (data == nil) {
        err = SYSTEM_NETWORK_TIMEOUT;
        isRecv = YES;
//        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        self.isRecv = YES;
        isRecv = YES;
        return;
    }
    if ([[data getReturnCode]intValue] != 0) {
        err = [[data getReturnCode]intValue];
        isRecv = YES;
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
    
    GDataXMLElement* element = [data getPackageDataObject];
//    TRACK(@"Package is %@",[element XMLString]);
    if (element == nil) {
        err = [[data getReturnCode]intValue];
        if (err == 0) {
            err = SYSTEM_INER_ERROR;
        }
        isRecv = YES;
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
    
    GDataXMLDocument* doc = [[GDataXMLDocument alloc]initWithRootElement:element];
    
    [self processUpdate:doc];
    
    //clear document
    [doc release];doc = nil;
    
    err = 0;

    isRecv = YES;
    [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
    isRecv = YES;
    
}

- (void)processUpdate:(GDataXMLDocument*)doc
{
    //get REQUSTTYPE
    GDataXMLElement* type = [[doc nodesForXPath:@"/DATA/REQUSTTYPE" error:nil] objectAtIndex:0];
    if (type == nil) {
        [doc release];doc = nil;
        err = UPDATE_STRATEGY_GET_REQUEST_TYPE_ERROR;
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
//    TRACK(@"%@",[[doc rootElement]XMLString])
    NSString* strategyType = [type stringValue];
    if (strategyType == nil) {
        [doc release];doc = nil;
        err = UPDATE_STRATEGY_GET_REQUEST_TYPE_ERROR;
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
    
    if ([strategyType isEqualToString:@"40101"]) {//system strategy
        
        //get system strategy
        GDataXMLElement* systemStrategy = [[doc nodesForXPath:@"/DATA/STRATEGY" error:nil] objectAtIndex:0];
        if (systemStrategy == nil) {
            [doc release];doc = nil;
            err = UPDATE_SYSTEM_STRATEGY_ERROR;
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
        
    }else if([strategyType isEqualToString:@"40103"]){//user strategy
        GDataXMLElement* userStrategy = [[doc nodesForXPath:@"/DATA/STRATEGY" error:nil] objectAtIndex:0];
        if (userStrategy == nil) {
            [doc release];doc = nil;
            err = UPDATE_USER_STRATEGY_ERROR;
            [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
            isRecv = YES;
            return;
        }
        
        GDataXMLElement* userSid = [[doc nodesForXPath:@"/DATA/USERSID" error:nil] objectAtIndex:0];
        if (userSid == nil) {
            [doc release];doc = nil;
            err = UPDATE_STRATEGY_GET_SID_TYPE_ERROR;
            [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
            isRecv = YES;
            return;
        }
        
        //change base64
        NSString* xmlUserStrategy = [[NSString alloc] initWithData:[GTMBase64 decodeString:[userStrategy stringValue]] encoding:NSUTF8StringEncoding];
        
        //NSLog(@"----------用户策略：%@", xmlUserStrategy);
        
        NSString* sql = [NSString stringWithFormat:@"WHERE strategy_sid = '%@'",[userSid stringValue]];
        tbStrategy* strategy =(tbStrategy*)[tbStrategy findFirstByCriteria:sql];
        const char* szBuffer = [xmlUserStrategy UTF8String];
        //TRACK(@"==sid:%@==%@",[userSid stringValue],strategy)
        if (strategy != nil) {
            [strategy setXmlData:[NSData dataWithBytes:szBuffer length:strlen(szBuffer)]];
            [strategy save];
            [tbStrategy clearCache];
        }else{//new strategy
            tbStrategy* newStrategy = [[tbStrategy alloc]init];
            [newStrategy setStrategySid:[userSid stringValue]];
            [newStrategy setXmlData:[NSData dataWithBytes:szBuffer length:strlen(szBuffer)]];
            [newStrategy save];
            [newStrategy release]; newStrategy = nil;
            [tbStrategy clearCache];
            
        }
        [xmlUserStrategy release];xmlUserStrategy = nil;
    }
    
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

- (long)updateSystemStrategy
{
    @synchronized(self){
        err = 0;
        step = 0;
        isRecv = NO;
        
        //update system strategy
        SystemCommand* cmd = [self createUpdateStrategyCommandByUserid:SYSTEM_SYSTEMSTRATEGY_SID type:@"40101"];
        if (cmd == nil) {
            return CREATE_UPDATE_STRATEGY_COMMAND_ERROR;
        }
        isRecv = NO;
        
        [access commandRequest:cmd];
        
        //wait recv
        while (!isRecv) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        
//        Context* ctx = [Context getInstance];
//        
//        if (err != 0) {
//            [ctx statusNotifyMessage:@"update system strategy is failed" code:err];
//        }else{
//            [ctx statusNotifyMessage:@"update system strategy is successed" code:err];
//        }
        
        [access disconnect];
    }
    
    return 0;
}

- (long)updateDefaultUeserStrategy
{
    @synchronized(self){
    err = 0;
    step = 0;
    isRecv = NO;
    
    //update default user strategy
    SystemCommand* cmd = [self createUpdateStrategyCommandByUserid:SYSTEM_DEFAULT_USER_SID type:@"40103"];
    if (cmd == nil) {
        return CREATE_UPDATE_STRATEGY_COMMAND_ERROR;
    }
    isRecv = NO;
    [access commandRequest:cmd];
    
    //wait recv
    while (!isRecv) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
        
    self.isRecv = NO;
//    Context* ctx = [Context getInstance];
//    if (err != 0) {
//        [ctx statusNotifyMessage:@"update default user strategy is failed" code:err];
//    }else{
//        [ctx statusNotifyMessage:@"update default user strategy is successed" code:err];
//    }
    
    [access disconnect];
    }
    self.isRecv = NO;
    return 0;
}

- (long)updateUeserStrategyByUsersid:(NSString*)sid
{
    @synchronized(self){
    err = 0;
    step = 0;
    isRecv = NO;
 
    //update user strategy
    SystemCommand* cmd = [self createUpdateStrategyCommandByUserid:sid type:@"40103"];
    if (cmd == nil) {
        return CREATE_UPDATE_STRATEGY_COMMAND_ERROR;
    }
    self.isRecv = NO;
    [access commandRequest:cmd];

    //wait recv
    while (!isRecv) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
        
//    Context* ctx = [Context getInstance];
//    if (err != 0) {
//        [ctx statusNotifyMessage:@"update user strategy is failed" code:err];
//    }else{
//        [ctx statusNotifyMessage:@"update user strategy is successed" code:err];
//    }
    
    [access disconnect];
    }
    
    return err;//0528 - 0改err
}

- (long)updateSystemPermission
{
    @synchronized(self){
    err = 0;
    step = 0;
    isRecv = NO;
    return 0;
    }
}

#pragma mark update strategy command

- (SystemCommand*)createUpdateStrategyCommandByUserid:(NSString*)sid type:(NSString*)type
{
    if (sid == nil || type == nil) {
        return nil;
    }
    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
    NSString* guid = [config getValueByKey:WSConfigItemGuid];
    
    NSString* xmlStr = [NSString stringWithFormat:@"<HEAD>\
                        <MODULEID>400</MODULEID>\
                        <OPCODE>401</OPCODE>\
                        <SIGN>111111111111111111111111</SIGN>\
                        </HEAD>\
                        <DATA>\
                        <GUID encode=\"\">%@</GUID>\
                        <USERSID encode=\"\">%@</USERSID>\
                        <REQUSTTYPE encode=\"\">%@</REQUSTTYPE>\
                        </DATA>",
                        guid,
                        sid,
                        type];
    
    //    TRACK(@"%@",xmlStr);
    
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
    step++;
}


@end
