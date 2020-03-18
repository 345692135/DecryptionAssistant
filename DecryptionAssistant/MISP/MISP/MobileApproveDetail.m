//
//  MobileApproveDetail.m
//  MISP
//
//  Created by wondersoft on 16/4/7.
//  Copyright © 2016年 wondersoft. All rights reserved.
//

#import "MobileApproveDetail.h"

#import "ConfigManager.h"
#import "IConfig.h"
#import "Context+Notify.h"
#import "CommandHelper.h"
#import "tbSysConfig.h"
#import "tbStrategy.h"
#import "GTMBase64.h"
#import "SystemStrategy.h"
#import "AccountManagement.h"


@implementation MobileApproveDetail
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
    //NSLog(@"approve list response data：%@",element);
   
    if (element == nil) {
        [self.mobileApproveDetailDelegate getApproveItemSucceed1:nil];//set file list nil
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
    NSArray* approveItemInfoNodesArr = [doc nodesForXPath:@"/RESPONSE/TABLE/ROW" error:nil];
    if ([approveItemInfoNodesArr count] == 0) {//with out files to download
        [self.mobileApproveDetailDelegate getApproveItemSucceed1:nil];//set file list nil
        [doc release];doc = nil;
        err = [[data getReturnCode]intValue];
        if (err == 0) {
            err = -2;//return err
        }
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
    //NSLog(@"approveItemInfoNodesArr:%@",approveItemInfoNodesArr);
    
    //base64 解码
//    NSString* fileListInfoStr=[filesInfoXml stringValue];// [[NSString alloc] initWithData:[GTMBase64 decodeString:[filesInfoXml stringValue]] encoding:NSUTF8StringEncoding];
//    NSLog(@"fileListInfoStr:%@",fileListInfoStr);

    NSString* serverIP = @"-1";
    NSString* attDate = @"";
    NSString* attCltGuid = @"";
    NSString* attAttGuid = @"";
    NSString* fileName = @"";
    NSString* rows = @"";
    NSMutableArray* selectionInfo = [[NSMutableArray alloc]init];
    NSMutableArray* rowsInfo = [[NSMutableArray alloc]init];
    
    for (GDataXMLElement* fileInfoElement in approveItemInfoNodesArr) {
        
        if (session == 1) {
            NSArray* objectTargetTypeElements1 = [fileInfoElement elementsForName:@"ObjectTargetType"];
            NSString* ObjectTargetType = [[objectTargetTypeElements1 objectAtIndex:0] stringValue];
            //NSLog(@"---------------------ObjectTargetType:%@",ObjectTargetType);
            NSArray* objectTargetTypeElements2 = [fileInfoElement elementsForName:@"ObjectTargetID"];
            NSString* ObjectTargetID = [[objectTargetTypeElements2 objectAtIndex:0] stringValue];
            //NSLog(@"---------------------ObjectTargetID:%@",ObjectTargetID);
            NSArray* objectTargetTypeElements3 = [fileInfoElement elementsForName:@"ObjectName"];
            NSString* ObjectName = [[objectTargetTypeElements3 objectAtIndex:0] stringValue];
            //NSLog(@"---------------------ObjectName:%@",ObjectName);
            NSArray* objectTargetTypeElements4 = [fileInfoElement elementsForName:@"ObjectParam"];
            NSString* ObjectParam = [[objectTargetTypeElements4 objectAtIndex:0] stringValue];
            //NSLog(@"---------------------ObjectParam:%@",ObjectParam);
            
            NSString* str1 = [NSString stringWithFormat:@"<ObjectTargetType>%@</ObjectTargetType>",ObjectTargetType];
            NSString* str2 = [NSString stringWithFormat:@"<ObjectTargetID>%@</ObjectTargetID>",ObjectTargetID];
            NSString* str3 = [NSString stringWithFormat:@"<ObjectName>%@</ObjectName>",ObjectName];
            NSString* str4 = [NSString stringWithFormat:@"<ObjectParam>%@</ObjectParam>",ObjectParam];
            NSString* rowTmp = [NSString stringWithFormat:@"<ROW>%@%@%@%@</ROW>",str1,str2,str3,str4];
            
            [rowsInfo addObject:rowTmp];
            rows = [rows stringByAppendingString:rowTmp];
            
            if ([ObjectTargetType isEqualToString:@"14"]) {
                [selectionInfo addObject:ObjectName];
            }
            else if ([ObjectTargetType isEqualToString:@"32"]) {
                NSLog(@"AttStoredIP_MISP:%@",ObjectName);//即为初始化时获取的主服务器IP
                serverIP = ObjectName;
            }
            else if ([ObjectTargetType isEqualToString:@"4"]) {
                fileName = ObjectName;
                //attCltGuid = ObjectParam;
            }
            else if ([ObjectTargetType isEqualToString:@"2"]) {
                attAttGuid = [[ObjectName componentsSeparatedByString:@"_"]firstObject];
                NSArray* tmpArr = [attAttGuid componentsSeparatedByString:@"-"];
                attDate = [NSString stringWithFormat:@"%@-%@-%@",[tmpArr firstObject],[tmpArr objectAtIndex:1],[tmpArr objectAtIndex:2]];
                attCltGuid = ObjectParam;
            }
            
        }
        else if (session == 2) {
            NSArray* HistoryIdElements = [fileInfoElement elementsForName:@"HistoryId"];
            NSString* HistoryId = [[HistoryIdElements objectAtIndex:0] stringValue];
            //NSLog(@"---------------------HistoryId:%@",HistoryId);
    
            NSArray* NameElements = [fileInfoElement elementsForName:@"Name"];
            NSString* Name = [[NameElements objectAtIndex:0] stringValue];
            //NSLog(@"---------------------Name:%@",Name);
    
            NSArray* ActionTimeElements = [fileInfoElement elementsForName:@"ActionTime"];
            NSString* ActionTime = [[ActionTimeElements objectAtIndex:0] stringValue];
            //NSLog(@"---------------------ActionTime:%@",ActionTime);
            
            NSArray* StrCommentElements = [fileInfoElement elementsForName:@"StrComment"];
            NSString* StrComment = [[StrCommentElements objectAtIndex:0] stringValue];
            NSLog(@"---------------------StrComment:%@",StrComment);
    
            NSArray* arr = [NSArray arrayWithObjects:HistoryId,Name,ActionTime,StrComment,nil];

            [self.approveItemInfo addObject:arr];
        }
    }
    

    NSLog(@"response approveListInfo count: %ld",(long)[self.approveItemInfo count]);
    //delegate method to transport arguments
    
    if (session == 1) {
        [self.approveItemInfo addObject:selectionInfo];
        
        NSArray* downloadUrlInfo = [NSArray arrayWithObjects:serverIP,attDate,attCltGuid,attAttGuid,fileName, nil];
        [self.approveItemInfo addObject:downloadUrlInfo];
        [self.approveItemInfo addObject:rowsInfo];
        
        NSArray* rowsInfo2 = [NSArray arrayWithObjects:rows,nil];
        [self.approveItemInfo addObject:rowsInfo2];
        
        [self.mobileApproveDetailDelegate getApproveItemSucceed1:approveItemInfo];

    }
    else if (session == 2) {
        [self.mobileApproveDetailDelegate getApproveItemSucceed2:approveItemInfo];

    }
    
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
    self.mobileApproveDetailDelegate = delegate;
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
//

- (NSString*)getActiveAccountSID
{
    AccountManagement* accountManager = [AccountManagement getInstance];
    SystemAccount* account = [accountManager getActiveAccount];
    return [account userSid];
}

#pragma mark - Sharing File Check
- (long)getApproveItem:(NSString*)requestID withRequestType:(NSString*)requestType
{
    SystemCommand* cmd;
    
    cmd = [self createInitCommand:requestID withRequestType:requestType];//
    
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
-(SystemCommand*)createInitCommand:(NSString*)requestID withRequestType:(NSString*)requestType
{
    NSString* sid = [self getActiveAccountSID];

    if (sid == nil) {
        return nil;
    }
    if ([requestType isEqualToString:@"Object"]) {
        session = 1;
    }
    else if ([requestType isEqualToString:@"StrComment"]) {
        session = 2;
    }
    
    NSString* xmlStr = [NSString stringWithFormat:@"<HEAD><MODULEID>C00</MODULEID><SIGN>1111</SIGN></HEAD><DATA><REQUEST><CMD>PROCESSRUN</CMD><CMDDESC UserSid=\"%@\" RequestType=\"%@\" RequestId=\"%@\"></CMDDESC><CURSOR Start=\"0\" Limit=\"100\"></CURSOR></REQUEST></DATA>",sid,requestType,requestID];
    
    //RequestType = Object/StrComment
    //RequestId = 审批项唯一标识
    
    //NSLog(@"MA detail request xmlStr:%@",xmlStr);
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
