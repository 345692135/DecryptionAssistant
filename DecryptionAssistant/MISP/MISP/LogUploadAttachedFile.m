//
//  LogUploadAttachedFile.h.m
//  MISP
//
//  Created by lijuan on 16/4/19.
//  Copyright © 2016年 wondersoft. All rights reserved.
//

#import "LogUploadAttachedFile.h"

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

@implementation LogUploadAttachedFile

@synthesize access;
@synthesize step;
@synthesize err;
@synthesize isRecv;

- (void)commandResponse:(SystemCommand *)data
{
    NSLog(@"log upload response ...");
    /*if (data == nil) {
        NSLog(@"log upload response ... (data == nil)");
        err = SYSTEM_NETWORK_TIMEOUT;
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }*/
    /*
    NSString *moduleId = [data getModuleid];//模块码 800
    NSString *opCode = [data getOpcode];//操作码 806
    NSLog(@"---LogUploadAttachedFile---moduleId=%@---opCode=%@", moduleId, opCode);
    //if ([moduleId isEqualToString:@""] || [opCode isEqualToString:@""]) {
    if (moduleId == nil || opCode == nil) {
        NSLog(@"log upload response ... (data == nil)");
        err = SYSTEM_NETWORK_TIMEOUT;
        //[NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
//        self.isRecv = YES;
        isRecv = YES;
        return;
    }
    
    if ([moduleId isEqualToString:@"e00"]) {
        if (self.isGuidRequest == YES) {
            if (![opCode isEqualToString:@"e02"]) {
                err = [[data getReturnCode]  intValue];
                //[NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
//                self.isRecv = YES;
                isRecv = YES;
                return;
            }
        //}else if(![opCode isEqualToString:@"E04"]){
        }else if(![opCode isEqualToString:@"e04"]){
            err = [[data getReturnCode] intValue];
            //[NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
//            self.isRecv = YES;
            isRecv = YES;
            return;
        }
    }else{
        err = [[data getReturnCode] intValue];
        //[NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
//        self.isRecv = YES;
        isRecv = YES;
        return;
    }

    if ([[data getReturnCode] intValue] != 0) {
        NSLog(@"log upload response ...[data getReturnCode]: %d",[[data getReturnCode]intValue]);
        err = [[data getReturnCode]intValue];
        //[NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
//        self.isRecv = YES;
        isRecv = YES;
        return;
    }

    //当为GUID返回的时候取data element
    GDataXMLElement *element = nil;
    if (self.isGuidRequest == YES) {
        element = [data getPackageDataObject];    //[data getPackageDataObjectForGUID];
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
        
        NSArray *array = [element children];
        NSUserDefaults *uDefault = [NSUserDefaults standardUserDefaults];
        [uDefault setObject:@"" forKey:@"SERVER_RESPONSE_GUID_STRING"];
        if (array.count > 0) {
            for (int i = 0; i < [array count]; i++) {
                GDataXMLElement *ele = [array objectAtIndex:i];
                if (ele != nil) {
                    if ([[ele name] isEqualToString:@"GUID"]) {
                        NSString *str = [ele stringValue];
                        NSLog(@"---------GUID-----str=%@", str);   //此时拿到服务器返回的GUID串
                        [uDefault setObject:str forKey:@"SERVER_RESPONSE_GUID_STRING"];
                    }
                }else{
                    err = [[data getReturnCode] intValue];
                    if (err == 0) {
                        err = -2;//return err
                    }
                    //[NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
//                    self.isRecv = YES;
                    isRecv = YES;
                    return;
                }
            }
        }else{
            err = [[data getReturnCode] intValue];
            if (err == 0) {
                err = -2;//return err
            }
            //[NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
//            self.isRecv = YES;
            isRecv = YES;
            return;
        }
    }else{
        //附件内容上传时返回的内容
        element = [data getPackageDataObject];
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
    }

    err = 0;
    step = step +1;
    isRecv = YES;
     */
    @try {
        NSString *moduleId = [data getModuleid];//模块码 800
        NSString *opCode = [data getOpcode];//操作码 806
        NSLog(@"---LogUploadAttachedFile---moduleId=%@---opCode=%@", moduleId, opCode);
        //if ([moduleId isEqualToString:@""] || [opCode isEqualToString:@""]) {
        if (moduleId == nil || opCode == nil) {
            NSLog(@"log upload response ... (data == nil)");
            err = SYSTEM_NETWORK_TIMEOUT;
            //[NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
            //        self.isRecv = YES;
            isRecv = YES;
            return;
        }
        
        if ([moduleId isEqualToString:@"e00"]) {
            if (self.isGuidRequest == YES) {
                if (![opCode isEqualToString:@"e02"]) {
                    err = [[data getReturnCode]  intValue];
                    //[NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
                    //                self.isRecv = YES;
                    isRecv = YES;
                    return;
                }
                //}else if(![opCode isEqualToString:@"E04"]){
            }else if(![opCode isEqualToString:@"e04"]){
                err = [[data getReturnCode] intValue];
                //[NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
                //            self.isRecv = YES;
                isRecv = YES;
                return;
            }
        }else{
            err = [[data getReturnCode] intValue];
            //[NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
            //        self.isRecv = YES;
            isRecv = YES;
            return;
        }
        
        if ([[data getReturnCode] intValue] != 0) {
            NSLog(@"log upload response ...[data getReturnCode]: %d",[[data getReturnCode]intValue]);
            err = [[data getReturnCode]intValue];
            //[NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
            //        self.isRecv = YES;
            isRecv = YES;
            return;
        }
        
        //当为GUID返回的时候取data element
        GDataXMLElement *element = nil;
        if (self.isGuidRequest == YES) {
            element = [data getPackageDataObject];    //[data getPackageDataObjectForGUID];
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
            
            NSArray *array = [element children];
            NSUserDefaults *uDefault = [NSUserDefaults standardUserDefaults];
            [uDefault setObject:@"" forKey:@"SERVER_RESPONSE_GUID_STRING"];
            if (array.count > 0) {
                for (int i = 0; i < [array count]; i++) {
                    GDataXMLElement *ele = [array objectAtIndex:i];
                    if (ele != nil) {
                        if ([[ele name] isEqualToString:@"GUID"]) {
                            NSString *str = [ele stringValue];
                            NSLog(@"---------GUID-----str=%@", str);   //此时拿到服务器返回的GUID串
                            [uDefault setObject:str forKey:@"SERVER_RESPONSE_GUID_STRING"];
                        }
                    }else{
                        err = [[data getReturnCode] intValue];
                        if (err == 0) {
                            err = -2;//return err
                        }
                        //[NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
                        //                    self.isRecv = YES;
                        isRecv = YES;
                        return;
                    }
                }
            }else{
                err = [[data getReturnCode] intValue];
                if (err == 0) {
                    err = -2;//return err
                }
                //[NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
                //            self.isRecv = YES;
                isRecv = YES;
                return;
            }
        }else{
            //附件内容上传时返回的内容
            element = [data getPackageDataObject];
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
        }
        
        err = 0;
        step = step +1;
        isRecv = YES;

    } @catch (NSException *exception) {
        NSLog(@"日志上传报错%@",exception);
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

#pragma mark -
-(long) logUpload:(NSArray*)log withType:(NSString*)type withGUID:(BOOL) guidFlag
{
    //发送包 - 160420
    SystemCommand* cmd;
    
    cmd = [self createInitCommand:log withType:type withGUID:guidFlag];//
    
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


-(SystemCommand*)createInitCommand:(NSArray*)log withType:(NSString*)type withGUID:(BOOL) guidFlag
{
    NSString* logOpCode = @"";
    NSString* logDataInfo = @"";
    if (guidFlag == YES) {
        self.isGuidRequest = YES;
        logOpCode = [self getGUIDOpCode:type];
        logDataInfo = [self getLogDataInfoForGUID:log];
    }else{
        self.isGuidRequest = NO;
        logOpCode = [self getAttachedFileOpCode:type];
        logDataInfo = [self getLogDataInfoForAttachedFile:log];
    }
    
    NSLog(@"---commandRequest-------logOpCode=%@", logOpCode);
    
    NSString* xmlStr = [NSString stringWithFormat:@"<HEAD><MODULEID>E00</MODULEID><OPCODE>%@</OPCODE><SIGN>111111111111111111111111</SIGN></HEAD><DATA>%@</DATA>",logOpCode,logDataInfo];

    //NSLog(@"log xmlStr:%@",xmlStr);
    NSData* xml = [NSData dataWithBytes:[xmlStr UTF8String] length:strlen([xmlStr UTF8String])];
    SystemCommand* command = [CommandHelper createCommandWithXMLData:xml isVerifyData:NO];
    
    return command;
}

- (NSString*)getGUIDOpCode:(NSString*)type
{
    NSString* opCode = @"";
    opCode = [NSString stringWithFormat:@"E01"];
    return opCode;
}

- (NSString*)getAttachedFileOpCode:(NSString*)type
{
    NSString* opCode = @"";
    opCode = [NSString stringWithFormat:@"E03"];
    return opCode;
}

- (NSString*)getLogDataInfoForGUID:(NSArray*)logInfo
{
    NSString *logXmlStr = @"";
    logXmlStr = [NSString stringWithFormat:@"<NAME>%@</NAME><FILESIZE>%@</FILESIZE>", logInfo[0], logInfo[1]];
    return logXmlStr;
}


- (NSString*)getLogDataInfoForAttachedFile:(NSArray*)logInfo
{
    NSString *logXmlStr = @"";
    logXmlStr = [NSString stringWithFormat:@"<NAME>%@</NAME><CLTGUID>%@</CLTGUID><AttGUID>%@</AttGUID><LENGTH>%@</LENGTH><INDEX>%@</INDEX><CONTENT>%@</CONTENT>", logInfo[0], logInfo[1], logInfo[2], logInfo[3], logInfo[4], logInfo[5]];
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

