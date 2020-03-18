//
//  LogUploadInterface.m
//  MISP
//
//  Created by lijuan on 17/5/8.
//  Copyright © 2017年 wondersoft. All rights reserved.


#import "LogUploadInterface.h"
#import "ConfigManager.h"
#import "IConfig.h"
#import "Context+Notify.h"
#import "CommandHelper.h"
#import "tbSysConfig.h"
#import "tbStrategy.h"
#import "GTMBase64.h"

#import "SystemStrategy.h"
#import "AccountManagement.h"
#import <ifaddrs.h>
#import <arpa/inet.h>

@implementation LogUploadInterface

@synthesize access;
@synthesize step;
@synthesize err;
@synthesize isRecv;


- (void)commandResponse:(SystemCommand *)data
{
    NSLog(@"--------commandResponse----data=%@", data);
    /*if (data == nil) {
        NSLog(@"log upload response ... (data == nil)");
        err = SYSTEM_NETWORK_TIMEOUT;
        
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }*/
    
    /*by leiqiang :崩溃在if ([moduleId isEqualToString:@"800"])内self.isRecv崩溃（野指针） ,下面使用@try规避错误。*/
    /* NSString *moduleId = [data getModuleid];//模块码 800
     NSString *opCode = [data getOpcode];//操作码 806
     NSLog(@"---LogUploadInterface---moduleid = %@,---log upload response opCode = %@",moduleId, opCode);
     //if ([moduleId isEqualToString:@""] || [opCode isEqualToString:@""]) {
     if (moduleId == nil || opCode == nil) {
     NSLog(@"log upload response ... (data == nil)");
     err = SYSTEM_NETWORK_TIMEOUT;
     //[NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
     self.isRecv = YES;
     isRecv = YES;
     return;
     }
     
     if ([moduleId isEqualToString:@"800"]){
     if (![opCode isEqualToString:@"806"]) {
     err = [[data getReturnCode] intValue];
     //[NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
     self.isRecv = YES;
     isRecv = YES;
     return;
     }
     }else{
     err = [[data getReturnCode] intValue];
     //[NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
     self.isRecv = YES;
     isRecv = YES;
     return;
     }
     
     
     if ([[data getReturnCode] intValue] != 0) {
     NSLog(@"------log upload response ...[data getReturnCode]: %d",[[data getReturnCode] intValue]);
     err = [[data getReturnCode] intValue];
     //[NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
     self.isRecv = YES;
     isRecv = YES;
     return;
     }
     
     //取data element
     GDataXMLElement *element = [data getPackageDataObject];
     if (element == nil) {
     err = [[data getReturnCode] intValue];
     if (err == 0) {
     err = -2;//return err
     }
     //[NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
     self.isRecv = YES;
     isRecv = YES;
     return;
     }
     
     err = 0;
     step = step +1;
     isRecv = YES;*/
    @try {
        NSString *moduleId = [data getModuleid];//模块码 800
        NSString *opCode = [data getOpcode];//操作码 806
        NSLog(@"---LogUploadInterface---moduleid = %@,---log upload response opCode = %@",moduleId, opCode);
        //if ([moduleId isEqualToString:@""] || [opCode isEqualToString:@""]) {
        if (moduleId == nil || opCode == nil) {
            NSLog(@"log upload response ... (data == nil)");
            err = SYSTEM_NETWORK_TIMEOUT;
            //[NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
//            self.isRecv = YES;
            isRecv = YES;
            return;
        }
        
        if ([moduleId isEqualToString:@"800"]){
            if (![opCode isEqualToString:@"806"]) {
                err = [[data getReturnCode] intValue];
                //[NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
//                self.isRecv = YES;
                isRecv = YES;
                return;
            }
        }else{
            err = [[data getReturnCode] intValue];
            //[NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
//            self.isRecv = YES;
            isRecv = YES;
            return;
        }
        
        
        if ([[data getReturnCode] intValue] != 0) {
            NSLog(@"------log upload response ...[data getReturnCode]: %d",[[data getReturnCode] intValue]);
            err = [[data getReturnCode] intValue];
            //[NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
//            self.isRecv = YES;
            isRecv = YES;
            return;
        }
        
        //取data element
        GDataXMLElement *element = [data getPackageDataObject];
        if (element == nil) {
            err = [[data getReturnCode] intValue];
            if (err == 0) {
                err = -2;//return err
            }
            //[NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
//            self.isRecv = YES;
            isRecv = YES;
            return;
        }
        
        err = 0;
        step = step +1;
        isRecv = YES;
        
    } @catch (NSException *exception) {
        NSLog(@"错误-------%@",exception.reason);
    } @finally {
    }
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


- (NSString*)getActiveAccountSID
{
    AccountManagement* accountManager = [AccountManagement getInstance];
    SystemAccount* account = [accountManager getActiveAccount];
    return [account userSid];
}


#pragma mark -
-(long) logUpload:(NSArray*)log withType:(NSString*)type
{
    //发送包 - 160420
    SystemCommand* cmd;
    
    cmd = [self createInitCommand:log withType:type];//
    
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


-(SystemCommand*)createInitCommand:(NSArray*)log withType:(NSString*)type
{
    NSString* logOpCode = [self getOpCode:type];
    NSString* logDataInfo = [self getLogDataInfo:log];
    
    NSString* xmlStr = [NSString stringWithFormat:@"<HEAD><MODULEID>800</MODULEID><OPCODE>%@</OPCODE><SIGN>111111111111111111111111</SIGN></HEAD><DATA>%@</DATA>",logOpCode,logDataInfo];
    
    //<LOGTYPE encode=\"\">%@</LOGTYPE>
    
    //NSLog(@"log xmlStr:%@",xmlStr);
    NSData* xml = [NSData dataWithBytes:[xmlStr UTF8String] length:strlen([xmlStr UTF8String])];
    SystemCommand* command = [CommandHelper createCommandWithXMLData:xml isVerifyData:NO];
    
    return command;
}


- (NSString*)getOpCode:(NSString*)type
{
    NSString* opCode = [NSString stringWithFormat:@"805"]; //新做的日志模块request请求全部发送805，回码是806
    return opCode;
}


- (NSString*)getLogDataInfo:(NSArray*)logInfo
{
//    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
//    NSString *sid_str = [self getActiveAccountSID];
//    NSString *guid_str= [config getValueByKey:WSConfigItemGuid];//通过uuid计算得到
//    NSString *clientIP_str = [self getIPAddress];//@"92.168.155.209";
//    
//    NSMutableArray *mutableLogInfo = [NSMutableArray arrayWithArray:logInfo];
//    [mutableLogInfo replaceObjectAtIndex:2 withObject:sid_str];
//    [mutableLogInfo replaceObjectAtIndex:3 withObject:guid_str]; //上层得到的是设备的UUID，在sdk中进一步转成guid
//    [mutableLogInfo replaceObjectAtIndex:6 withObject:clientIP_str];
//    logInfo = [NSArray arrayWithArray:mutableLogInfo];
    
    //NSInteger typeNum = [type integerValue];

    //将最终上传给服务器的日志信息以类型为Key保存到本地，方便数据失败时将其保存到数据库
    //这样做的一个目的是上层不能完全拿到日志数据数组，只有在sdk中才能完全拿到，所以要保存此处的数据 20170512
    //NSUserDefaults *uDefaults = [NSUserDefaults standardUserDefaults];
    //[uDefaults setObject:logInfo forKey:type];
    
    if (logInfo[3] == nil || logInfo[2] == nil) {
        //NSLog(@"guid: %@",guid_1);  NSLog(@"sid: %@",sid_2);
        return nil;
    }
    
    NSString *logXmlStr = @"";
//    if ((typeNum == BasicAccountLogin) || (typeNum == BasicClientInstall))
//    {
        logXmlStr = [NSString stringWithFormat:@"<dwLogVersion>1</dwLogVersion><wLevel>%@</wLevel><wType>%@</wType><strUserSid>%@</strUserSid><strCltGuid>%@</strCltGuid><strOsUserName>%@</strOsUserName><timeClt>%@</timeClt><ipClt>%@</ipClt><dwTypeId1>%@</dwTypeId1><dwTypeId2>%@</dwTypeId2><cAtt_GUID>%@</cAtt_GUID><dwKey_Count>%@</dwKey_Count><wKey_0>%@</wKey_0><wKey_1>%@</wKey_1><wKey_2>%@</wKey_2><wKey_3>%@</wKey_3><wKey_4></wKey_4>",logInfo[0], logInfo[1], logInfo[2],  logInfo[3], logInfo[4], logInfo[5], logInfo[6], logInfo[7], logInfo[8], logInfo[9], logInfo[10], logInfo[11], logInfo[12], logInfo[13], logInfo[14]];
    //}
 
    
    /* if ([type isEqualToString:@"log_mob_login"])
    {
        //NSLog(@"logInfo:%@",logInfo);
        NSString* mobileIdentifier_k0 = [logInfo firstObject];//@"手机唯一标识";
        NSString* logonUserName_k1 = [logInfo objectAtIndex:1];//@"登陆用户名";
        NSString* logonTime_k2 = [logInfo objectAtIndex:2];//@"登陆时间";
        
        //注意 dwKey_Count = 3    dwTypeId1>4352</dwTypeId1><dwTypeId2>4355</dwTypeId2>
        NSString* logXmlStr = [NSString stringWithFormat:@"<REQUEST><dwLogVersion>1</dwLogVersion><wLevel>3</wLevel><wType>0</wType><dwuserID>0</dwuserID><strCltGuid>%@</strCltGuid><strUserSid>%@</strUserSid><strOsUserName>%@</strOsUserName><ipClt>%@</ipClt><cAtt_GUID></cAtt_GUID><dwKey_Count>3</dwKey_Count><wKey_0>%@</wKey_0><wKey_1>%@</wKey_1><wKey_2>%@</wKey_2><wKey_3></wKey_3><wKey_4></wKey_4><wKey_5></wKey_5><wKey_6></wKey_6><wKey_7></wKey_7><wKey_8></wKey_8><wKey_9></wKey_9><bVerify>73F25B7E80508EB41C55C5121773DA08B312A9BB00000000</bVerify><bSign>128个0</bSign><dwCltId>0</dwCltId><dwOSSessionId>0</dwOSSessionId><dwTypeId1>24832</dwTypeId1><dwTypeId2>4355</dwTypeId2><dwTypeId3>0</dwTypeId3><dwTypeId4>0</dwTypeId4><dwTargetId1>-1</dwTargetId1><dwTargetType1>-1</dwTargetType1><dwTargetId2>-1</dwTargetId2><dwTargetType2>-1</dwTargetType2><dwVerifyMode>1</dwVerifyMode><dwSignMode>0</dwSignMode><timeClt>%@</timeClt></REQUEST>",guid_1,sid_2,osUserName_3,clientIP_4,mobileIdentifier_k0,logonUserName_k1,logonTime_k2, logonTime_k2];
        
        return logXmlStr;
    }else if ([type isEqualToString:@"log_mob_email"])
    {
        //NSLog(@"logInfo:%@",logIΩnfo);
        NSString* sendType_k0 = [logInfo firstObject];//发送类型，附件加密1，全文加密2，明文外发3
        NSString* sendPlainReason_k1 = [logInfo objectAtIndex:1];//详细信息，如明文外发理由等，其他情况可以不写
        NSString* from_k2 = [logInfo objectAtIndex:2];//发件人
        NSString* to_k3 = [logInfo objectAtIndex:3];//收件人，中间以分号分隔（；）
        NSString* sentTime_k4 = [logInfo objectAtIndex:4];//发送时间
        NSString* subject_k5 = [logInfo objectAtIndex:5]; //邮件主题
        NSString* attName_k6 = [logInfo objectAtIndex:6]; //附件名，中间以分号分隔（；）
        NSString* attSize_k7 = [logInfo objectAtIndex:7]; //附件大小，中间以分号分隔（；）
        
        //注意 dwKey_Count = 8   <dwTypeId1>4352</dwTypeId1><dwTypeId2>4356</dwTypeId2>
        NSString* logXmlStr = [NSString stringWithFormat:@"<REQUEST><dwLogVersion>1</dwLogVersion><wLevel>3</wLevel><wType>0</wType><dwuserID>0</dwuserID><strCltGuid>%@</strCltGuid><strUserSid>%@</strUserSid><strOsUserName>%@</strOsUserName><ipClt>%@</ipClt><cAtt_GUID></cAtt_GUID><dwKey_Count>8</dwKey_Count><wKey_0>%@</wKey_0><wKey_1>%@</wKey_1><wKey_2>%@</wKey_2><wKey_3>%@</wKey_3><wKey_4>%@</wKey_4><wKey_5>%@</wKey_5><wKey_6>%@</wKey_6><wKey_7>%@</wKey_7><wKey_8></wKey_8><wKey_9></wKey_9><bVerify>73F25B7E80508EB41C55C5121773DA08B312A9BB00000000</bVerify><bSign>128个0</bSign><dwCltId>0</dwCltId><dwOSSessionId>0</dwOSSessionId><dwTypeId1>24832</dwTypeId1><dwTypeId2>4356</dwTypeId2><dwTypeId3>0</dwTypeId3><dwTypeId4>0</dwTypeId4><dwTargetId1>-1</dwTargetId1><dwTargetType1>-1</dwTargetType1><dwTargetId2>-1</dwTargetId2><dwTargetType2>-1</dwTargetType2><dwVerifyMode>1</dwVerifyMode><dwSignMode>0</dwSignMode><timeClt>%@</timeClt></REQUEST>",guid_1,sid_2,osUserName_3,clientIP_4,sendType_k0,sendPlainReason_k1,from_k2,to_k3,sentTime_k4,subject_k5,attName_k6,attSize_k7, sentTime_k4];
        
        return logXmlStr;
    }else if ([type isEqualToString:@"log_mob_approve"]) //log_mob_approve
    {
        NSLog(@"logInfo:%@",logInfo);
        NSString* userName_k0 = [logInfo firstObject]; //当前用户名
        NSString* fileName_k1 = [logInfo objectAtIndex:1];//文件名
        NSString* process_k2 = [logInfo objectAtIndex:2];//审批流程
        NSString* processCount_k3 = [logInfo objectAtIndex:3];  //审批流程数-1
        NSString* remarks_k4 = [logInfo objectAtIndex:4];//备注
        NSString* actionType_kx = [logInfo objectAtIndex:5];//4353-同意，4354-拒绝
        NSString* approveTime_ky = [logInfo objectAtIndex:6];//审批时间
        NSLog(@"--%@",fileName_k1);
        NSLog(@"--%@",process_k2);
        NSLog(@"--%@",remarks_k4);
        //注意 dwKey_Count = 5     dwTypeId1>4352</dwTypeId1><dwTypeId2>4353 或 4354</dwTypeId2>
        NSString* logXmlStr = [NSString stringWithFormat:@"<REQUEST><dwLogVersion>1</dwLogVersion><wLevel>3</wLevel><wType>0</wType><dwuserID>0</dwuserID><strCltGuid>%@</strCltGuid><strUserSid>%@</strUserSid><strOsUserName>%@</strOsUserName><ipClt>%@</ipClt><cAtt_GUID></cAtt_GUID><dwKey_Count>5</dwKey_Count><wKey_0>%@</wKey_0><wKey_1>%@</wKey_1><wKey_2>%@</wKey_2><wKey_3>%@</wKey_3><wKey_4>%@</wKey_4><wKey_5></wKey_5><wKey_6></wKey_6><wKey_7></wKey_7><wKey_8></wKey_8><wKey_9></wKey_9><bVerify>73F25B7E80508EB41C55C5121773DA08B312A9BB00000000</bVerify><bSign>128个0</bSign><dwCltId>0</dwCltId><dwOSSessionId>0</dwOSSessionId><dwTypeId1>24832</dwTypeId1><dwTypeId2>%@</dwTypeId2><dwTypeId3>0</dwTypeId3><dwTypeId4>0</dwTypeId4><dwTargetId1>-1</dwTargetId1><dwTargetType1>-1</dwTargetType1><dwTargetId2>-1</dwTargetId2><dwTargetType2>-1</dwTargetType2><dwVerifyMode>1</dwVerifyMode><dwSignMode>0</dwSignMode><timeClt>%@</timeClt></REQUEST>",guid_1,sid_2,osUserName_3,clientIP_4,userName_k0,fileName_k1,process_k2,processCount_k3,remarks_k4,actionType_kx,approveTime_ky];
        //dwTypeId1 = x6100
        return logXmlStr;
    }*/
    
    return logXmlStr;
}



// Get IP Address
- (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
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


- (NSString*) replaceUnicode:(NSString*)aUnicodeString
{
    NSString *tempStr1 = [aUnicodeString stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                           
                                                           mutabilityOption:NSPropertyListImmutable
                                                                     format:NULL
                                                           errorDescription:NULL];
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
}


@end
