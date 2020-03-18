//
//  MobileApprove.m
//  MISP
//
//  Created by wondersoft on 16/4/7.
//  Copyright © 2016年 wondersoft. All rights reserved.
//

#import "MobileApprove.h"

#import "ConfigManager.h"
#import "IConfig.h"
#import "Context+Notify.h"
#import "CommandHelper.h"
#import "tbSysConfig.h"
#import "tbStrategy.h"
#import "GTMBase64.h"
#import "SystemStrategy.h"
#import "AccountManagement.h"


@implementation MobileApprove
@synthesize access;
@synthesize step;
@synthesize err;
@synthesize isRecv;
@synthesize approveListInfo;

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
    //NSLog(@"MOduleid = %@",moCode);
    
    //取data element
    GDataXMLElement* element = [data getPackageDataObject2];
    //NSLog(@"approve list response data：%@",element);
   
    if (element == nil) {
        [self.mobileApproveDelegate getApproveListSucceed:nil isEnd:toGetCount];//set file list nil
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
    NSArray* approveListInfoNodesArr = [doc nodesForXPath:@"/RESPONSE/TABLE/ROW" error:nil];
    if ([approveListInfoNodesArr count] == 0) {//with out files to download
        NSLog(@"********************");
        [self.mobileApproveDelegate getApproveListSucceed:nil isEnd:toGetCount];//set file list nil
        [doc release];doc = nil;
        err = [[data getReturnCode]intValue];
        if (err == 0) {
            err = -2;//return err
        }
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
    //NSLog(@"approveListInfoNodesArr first object:%@",[approveListInfoNodesArr firstObject]);
    
    //base64 解码
//    NSString* fileListInfoStr=[filesInfoXml stringValue];// [[NSString alloc] initWithData:[GTMBase64 decodeString:[filesInfoXml stringValue]] encoding:NSUTF8StringEncoding];
//    NSLog(@"fileListInfoStr:%@",fileListInfoStr);

    //都取完了
    if ([approveListInfoNodesArr count] < toGetCount ) {
        toGetCount = -1;
    }

    for (GDataXMLElement* fileInfoElement in approveListInfoNodesArr) {
        //去重---
        NSArray* requestIdElements = [fileInfoElement elementsForName:@"RequestId"];
        NSString* requestId = [[requestIdElements objectAtIndex:0] stringValue];
        //NSLog(@"---------------------requestId:%@",requestId);
        if(requestId==nil){
            requestId = @"-1";
        }
        BOOL isRepeat = NO;
        for (NSArray* tmpArr in self.approveListInfo) {
            if ([[tmpArr lastObject] isEqualToString:requestId]) {
                isRepeat = YES;
                continue;
            }
        }
        if (isRepeat) {
            continue;
        }//===
        
        
        NSArray* fileNameElements = [fileInfoElement elementsForName:@"DocName"];
        NSString* fileName = [[fileNameElements objectAtIndex:0] stringValue];
        //NSLog(@"---------------------filename:%@",fileName);
        
        NSArray* startTimeElements = [fileInfoElement elementsForName:@"StartTime"];
        NSString* startTime = [[startTimeElements objectAtIndex:0] stringValue];
        //NSLog(@"---------------------startTime:%@",startTime);
        
        NSArray* applicantElements = [fileInfoElement elementsForName:@"SubmitPersonName"];
        NSString* applicant = [[applicantElements objectAtIndex:0] stringValue];
        //NSLog(@"---------------------applicant:%@",applicant);
       
        
        NSArray* approveTypeElements = [fileInfoElement elementsForName:@"ProcessType"];
        NSString* approveType = [[approveTypeElements objectAtIndex:0] stringValue];
        //NSLog(@"---------------------approveType:%@",approveType);
        
        NSArray* statusElementsElements = [fileInfoElement elementsForName:@"RequestStatus"];
        NSString* status = [[statusElementsElements objectAtIndex:0] stringValue];
        //NSLog(@"---------------------status:%@",status);
        
        NSArray* permissonIdElements = [fileInfoElement elementsForName:@"PermissionId"];
        NSString* permissonId = [[permissonIdElements objectAtIndex:0] stringValue];
        //NSLog(@"---------------------permissonId:%@",permissonId);
        if(permissonId==nil){
            permissonId = @"-1";
        }
        
        NSArray* actionTypeElements = [fileInfoElement elementsForName:@"ActionType"];
        NSString* actionType = [[actionTypeElements objectAtIndex:0] stringValue];
        //NSLog(@"---------------------actionType:%@",actionType);
        if(actionType==nil){
            actionType = @"-1";
        }
        
        NSArray* StatusLineElements = [fileInfoElement elementsForName:@"StatusLine"];
        NSString* StatusLine = [[StatusLineElements objectAtIndex:0] stringValue];
        //NSLog(@"---------------------StatusLine:%@",StatusLine);
       
        
        NSArray* RemarksElements = [fileInfoElement elementsForName:@"Remarks"];
        NSString* Remarks1 = [[RemarksElements objectAtIndex:0] stringValue];
        //NSLog(@"---------------------Remarks:%@",Remarks1);
        NSString* Remarks = [NSString stringWithFormat:@"%@",Remarks1];
        

        //base64 解码
//           NSString* Remarks2=[[NSString alloc] initWithData:[GTMBase64 decodeString:Remarks1 ] encoding:NSUTF8StringEncoding];
//        NSLog(@"---------------------Remarks2:%@",Remarks2);

        //    NSLog(@"fileListInfoStr:%@",fileListInfoStr);
        
        NSArray* arr = [NSArray arrayWithObjects:fileName,startTime,applicant,approveType,status,permissonId,actionType,StatusLine,Remarks,requestId, nil];
        [self.approveListInfo addObject:arr];
    }

    NSLog(@"response approveListInfo count: %ld",(long)[approveListInfo count]);
    //delegate method to transport arguments
    [self.mobileApproveDelegate getApproveListSucceed:approveListInfo isEnd:toGetCount];
    
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
    self.mobileApproveDelegate = delegate;
    self.approveListInfo = [[NSMutableArray alloc]init];
    toGetCount = 0;
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
-(long)getApproveList:(NSString*)type withPage:(int)page
{
    SystemCommand* cmd;
    
    cmd = [self createInitCommand:type withPage:page];//
    
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

//request sharing files list
-(SystemCommand*)createInitCommand:(NSString*)type withPage:(int)page
{
    NSString* sid = [self getActiveAccountSID];

    if (sid == nil) {
        return nil;
    }
    
    NSString* queryType = @"";
    NSString* requestStatus = @"";
    if ([type isEqualToString:@"我的申请"]) {
        queryType = @"0";
        requestStatus = @"7";
    }
    else if ([type isEqualToString:@"我的待办"]) {
        queryType = @"1";
        requestStatus = @"0";
    }
    else if ([type isEqualToString:@"我的已办"]) {
        queryType = @"2";
        requestStatus = @"7";
    }
    
    NSString* limitStr = [NSString stringWithFormat:@"%d",20*page];
    toGetCount = 20*page;
    
    NSString* xmlStr = [NSString stringWithFormat:@"<HEAD><MODULEID>C00</MODULEID><SIGN>1111</SIGN></HEAD><DATA><REQUEST><CMD>PROCESSQUERY</CMD><CMDDESC UserSid=\"%@\" QueryType=\"%@\" RequestStatus=\"%@\" ProcessType=\"3\" Flag=\"0\" SubmitPersionId=\"-1\" StartTime=\"\" EndTime=\"\" LastActionTime=\"\"></CMDDESC><CURSOR Start=\"0\" Limit=\"%@\"></CURSOR></REQUEST></DATA>",sid,queryType,requestStatus,limitStr];
    
    //NSLog(@"MA list request xmlStr:%@",xmlStr);
    NSData* xml = [NSData dataWithBytes:[xmlStr UTF8String] length:strlen([xmlStr UTF8String])];
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
