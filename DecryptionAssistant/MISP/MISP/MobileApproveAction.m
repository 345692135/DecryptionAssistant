//
//  MobileApproveAction.m
//  MISP
//
//  Created by wondersoft on 16/4/7.
//  Copyright © 2016年 wondersoft. All rights reserved.
//

#import "MobileApproveAction.h"

#import "ConfigManager.h"
#import "IConfig.h"
#import "Context+Notify.h"
#import "CommandHelper.h"
#import "tbSysConfig.h"
#import "tbStrategy.h"
#import "GTMBase64.h"
#import "SystemStrategy.h"
#import "AccountManagement.h"
#import "ConvertTool.h"

@implementation MobileApproveAction
@synthesize access;
@synthesize step;
@synthesize err;
@synthesize isRecv;
@synthesize approveItemInfo;

- (void)commandResponse:(SystemCommand *)data
{
    NSLog(@"approve response ...");
    if (data == nil) {
         NSLog(@"approve response ... (data == nil)");
        err = SYSTEM_NETWORK_TIMEOUT;
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
    
    if ([[data getReturnCode]intValue] != 0) {
        NSLog(@"approve response ... [[data getReturnCode]intValue] != 0  :  %d",[[data getReturnCode]intValue]);
        err = [[data getReturnCode]intValue];
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
    
    //Log输出调试
    NSString* moCode = [data getModuleid];//模块码
    NSLog(@"MOduleid = %@",moCode);
    
    //取data element
    GDataXMLElement* element = [data getPackageDataObject2];
    NSLog(@"approve action response data：%@",element);
   
    if (element == nil) {
        [self.mobileApproveActionDelegate actionResult:nil];//set result
        err = [[data getReturnCode]intValue];
        if (err == 0) {
            err = -2;//return err
        }
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
   
    
    
    //创建doc，取nodes
    GDataXMLDocument* doc = [[GDataXMLDocument alloc]initWithRootElement:element];
    NSArray* actionResultInfoNodesArr = [doc nodesForXPath:@"/RESPONSE" error:nil];
    if ([actionResultInfoNodesArr count] == 0) {//with out files to download
        [self.mobileApproveActionDelegate actionResult:nil];//set file list nil
        [doc release];doc = nil;
        err = [[data getReturnCode]intValue];
        if (err == 0) {
            err = -2;//return err
        }
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
    NSLog(@"approve action result:%@",actionResultInfoNodesArr);

    

    for (GDataXMLElement* fileInfoElement in actionResultInfoNodesArr) {
        
        NSArray* ProcessFlagElements = [fileInfoElement elementsForName:@"ProcessFlag"];
        NSString* ProcessFlag = [[ProcessFlagElements objectAtIndex:0] stringValue];
        NSLog(@"---------------------ProcessFlag:%@",ProcessFlag);

        if ([ProcessFlag isEqualToString:@"0"]) {
            [self.approveItemInfo addObject:ProcessFlag];
        }        
    }

    NSLog(@"response approveListInfo count: %ld",(long)[self.approveItemInfo count]);
    //delegate method to transport arguments
    
    
    [self.mobileApproveActionDelegate actionResult:nil];

    
    
    //clear document
    [doc release];doc = nil;
    
    err = 0;
    //set step +1 is success
    step = step +1;
    
    [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
    isRecv = YES;
}


- (id)initWithDelegate:(id)delegate
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
    self.mobileApproveActionDelegate = delegate;
    self.approveItemInfo = [[NSMutableArray alloc]init];
    session = 0; //1-第一次，2-第二次

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

#pragma mark - Sharing File Check
- (long)approveAction1:(NSArray *)Info
{
    SystemCommand* cmd;
    
    cmd = [self createInitCommand1:Info];//
    
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
    
    return err;
    
}

//request sharing files list
-(SystemCommand*)createInitCommand1:(NSArray*)Info
{
    NSString* sid = [self getActiveAccountSID];

    if (sid == nil) {
        return nil;
    }
    
    NSString* requestID= [Info firstObject];
    NSString* strComment= [Info objectAtIndex:1];

    NSString* xmlStr = [NSString stringWithFormat:@"<HEAD><MODULEID>C00</MODULEID><SIGN>1111</SIGN></HEAD><DATA><REQUEST><CMD>PROCESSRUN</CMD><CMDDESC UserSid=\"%@\" RequestType=\"Terminate\" RequestId=\"%@\" StrComment=\"%@\"></CMDDESC><CURSOR Start=\"0\" Limit=\"100\"></CURSOR></REQUEST></DATA>",sid,requestID,strComment];
    
    //NSLog(@"MA action request xmlStr:%@",xmlStr);
    NSData* xml = [NSData dataWithBytes:[xmlStr UTF8String] length:strlen([xmlStr UTF8String])];
    SystemCommand* command = [CommandHelper createCommandWithXMLData:xml isVerifyData:NO];
    
    return command;
}

#pragma mark -
- (long)approveAction21:(NSArray *)Info
{
    SystemCommand* cmd;
    
    cmd = [self createInitCommand21:Info];//
    
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


//
-(SystemCommand*)createInitCommand21:(NSArray*)Info
{
    NSString* sid = [self getActiveAccountSID];
    
    if (sid == nil) {
        return nil;
    }
    
    //NSLog(@"InfoInfoInfoInfo:%@",Info);
    NSString* requestID= [Info firstObject];
    
    NSString* xmlStr = [NSString stringWithFormat:@"<HEAD><MODULEID>C00</MODULEID><SIGN>1111</SIGN></HEAD><DATA><REQUEST><CMD>PROCESSRUN</CMD><CMDDESC UserSid=\"%@\" RequestType=\"Flag\" RequestId=\"%@\"></CMDDESC><CURSOR Start=\"0\" Limit=\"100\"></CURSOR></REQUEST></DATA>",sid,requestID];
    
    NSString* subXmlStr = [NSString stringWithFormat:@"<REQUEST><CMD>PROCESSRUN</CMD><CMDDESC UserSid=\"%@\" RequestType=\"Flag\" RequestId=\"%@\"></CMDDESC><CURSOR Start=\"0\" Limit=\"100\"></CURSOR></REQUEST>",sid,requestID];
    NSLog(@"1origin legth: %ld",[subXmlStr length]);
    
    //encode base64
    NSData* subXmlStrTmp = [NSData dataWithBytes:[subXmlStr UTF8String]  length:strlen([subXmlStr UTF8String])];
    NSData* xmlData = [GTMBase64 encodeData:subXmlStrTmp];
    NSString* xmlDataStr = [[NSString alloc]initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSLog(@"1base64 legth: %ld",[xmlDataStr length]);
    //ObjectName 和 ObjectParam 的index 呼唤
    //NSString* xmlStr = [NSString stringWithFormat:@"<HEAD><MODULEID>C00</MODULEID><SIGN>1111</SIGN></HEAD><DATA>%@</DATA>",xmlDataStr];
        
    
    NSLog(@"request xmlStr21:%@",xmlStr);
    NSData* xml = [NSData dataWithBytes:[xmlStr UTF8String] length:strlen([xmlStr UTF8String])];
    SystemCommand* command = [CommandHelper createCommandWithXMLData:xml isVerifyData:NO];
    return command;
}


#pragma mark -
- (long)approveAction22:(NSArray *)Info
{
    SystemCommand* cmd;
    
    cmd = [self createInitCommand22:Info];//
    
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
    
    return err;
    
}

//request sharing files list
-(SystemCommand*)createInitCommand22:(NSArray*)Info
{
    NSString* sid = [self getActiveAccountSID];
    
    if (sid == nil) {
        return nil;
    }
    
    //NSLog(@"InfoInfoInfoInfo:%@",Info);
    NSString* requestID= [Info firstObject];
    NSString* strComment= [Info objectAtIndex:1];
    NSString* rows =[Info objectAtIndex:2];
    NSLog(@"strComment:%@",strComment);
    
    NSString* xmlStr = [NSString stringWithFormat:@"<HEAD><MODULEID>C00</MODULEID><SIGN>1111</SIGN></HEAD><DATA><REQUEST><CMD>PROCESSRUN</CMD><CMDDESC UserSid=\"%@\" RequestType=\"Update\" RequestId=\"%@\" ActionId=\"0\" StrComment=\"%@\"></CMDDESC><CURSOR Start=\"1\" Limit=\"100\"></CURSOR><TABLES><TABLE ID=\"OBJECTDATA\"></TABLE></TABLES><TABLE ID=\"OBJECTDATA\"><Fields><Field ID=\"ObjectTargetType\" index=\"1\"></Field><Field ID=\"ObjectTargetID\" index=\"2\"></Field><Field ID=\"ObjectName\" index=\"3\"></Field><Field ID=\"ObjectParam\" index=\"4\" ></Field></Fields>%@</TABLE></REQUEST></DATA>",sid,requestID,strComment,rows];
    
    NSString* subXmlStr = [NSString stringWithFormat:@"<REQUEST><CMD>PROCESSRUN</CMD><CMDDESC UserSid=\"%@\" RequestType=\"Update\" RequestId=\"%@\" ActionId=\"0\" StrComment=\"%@\"></CMDDESC><CURSOR Start=\"1\" Limit=\"100\"></CURSOR><TABLES><TABLE ID=\"OBJECTDATA\"></TABLE></TABLES><TABLE ID=\"OBJECTDATA\"><Fields><Field ID=\"ObjectTargetType\" index=\"1\"></Field><Field ID=\"ObjectTargetID\" index=\"2\"></Field><Field ID=\"ObjectName\" index=\"3\"></Field><Field ID=\"ObjectParam\" index=\"4\" ></Field></Fields>%@</TABLE></REQUEST>",sid,requestID,strComment,rows];
    
    NSLog(@"2origin legth: %ld",[subXmlStr length]);

    //encode base64
    NSData* subXmlStrTmp = [NSData dataWithBytes:[subXmlStr UTF8String]  length:strlen([subXmlStr UTF8String])];
    NSData* xmlData = [GTMBase64 encodeData:subXmlStrTmp];
    NSString* xmlDataStr = [[NSString alloc]initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    //ObjectName 和 ObjectParam 的index 呼唤
    //NSString* xmlStr = [NSString stringWithFormat:@"<HEAD><MODULEID>C00</MODULEID><SIGN>1111</SIGN></HEAD><DATA>%@</DATA>",xmlDataStr];
    NSLog(@"2base64 legth: %ld",[xmlDataStr length]);

    //NSLog(@"request xmlStr:%@",xmlStr);
    NSLog(@"xml22:%@",xmlStr);
    

    
    NSData* xml = [NSData dataWithBytes:[xmlStr UTF8String] length:strlen([xmlStr UTF8String])];

    xml = nil;
    SystemCommand* command = [CommandHelper createCommandWithXMLData:xml isVerifyData:NO];
    return command;
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
