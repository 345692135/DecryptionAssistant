//
//  SharingFileCheck.m
//  MISP
//
//  Created by wondersoft on 16/4/7.
//  Copyright © 2016年 wondersoft. All rights reserved.
//

#import "SharingFileCheck.h"

#import "ConfigManager.h"
#import "IConfig.h"
#import "Context+Notify.h"
#import "CommandHelper.h"
#import "tbSysConfig.h"
#import "tbStrategy.h"
#import "GTMBase64.h"
#import "SystemStrategy.h"
#import "AccountManagement.h"


@implementation SharingFileCheck
@synthesize access;
@synthesize step;
@synthesize err;
@synthesize isRecv;
@synthesize sharingFilesInfoList;

- (void)commandResponse:(SystemCommand *)data
{
    //NSLog(@"sharing file response ...");
    if (data == nil) {
         NSLog(@"sharing file response ... (data == nil)");
        err = SYSTEM_NETWORK_TIMEOUT;
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
    
    if ([[data getReturnCode]intValue] != 0) {
        NSLog(@"sharing file response ... [[data getReturnCode]intValue] != 0  :  %d",[[data getReturnCode]intValue]);
        err = [[data getReturnCode]intValue];
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
    
    //Log输出调试
    NSString* moCode = [data getModuleid];//模块码
    NSString* opCode = [data getOpcode];//操作码
    NSLog(@"MOduleid = %@, opCode = %@",moCode,opCode);
    
    //send results response
    if ([opCode isEqualToString:@"d04"]) {
        [self.sharingFileCheckDelegate downloadResultsReported:YES];//How to deal with report fail
        err = 0;
        step = step +1; //set step +1 is success
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        //return;
    }

    //取data element
    GDataXMLElement* element = [data getPackageDataObject];
    //NSLog(@"sharing file response data：%@",element);
   
    if (element == nil) {
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
    NSArray* FileInfoNodesArr = [doc nodesForXPath:@"/DATA/FILELIST/FILEINFO" error:nil];
    if ([FileInfoNodesArr count] == 0) {//with out files to download
        [self.sharingFileCheckDelegate getSharingFilesInfoSucceed:nil];//set file list nil
        [doc release];doc = nil;
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
    //NSLog(@"FileInfoNodesArr:%@",FileInfoNodesArr);
    
    //base64 解码
//    NSString* fileListInfoStr=[filesInfoXml stringValue];// [[NSString alloc] initWithData:[GTMBase64 decodeString:[filesInfoXml stringValue]] encoding:NSUTF8StringEncoding];
//    NSLog(@"fileListInfoStr:%@",fileListInfoStr);


    for (GDataXMLElement* fileInfoElement in FileInfoNodesArr) {

        NSArray* fileNameElements = [fileInfoElement elementsForName:@"FILENAME"];
        NSString* fileName = [[fileNameElements objectAtIndex:0] stringValue];
        //NSLog(@"---------------------filename:%@",fileName);
        
        NSArray* fileSizeElements = [fileInfoElement elementsForName:@"FILESIZE"];
        NSString* fileSize = [[fileSizeElements objectAtIndex:0] stringValue];
        //NSLog(@"---------------------fileSize:%@",fileSize);
        
        NSArray* fileTimeElements = [fileInfoElement elementsForName:@"TIME"];
        NSString* fileTime = [[fileTimeElements objectAtIndex:0] stringValue];
        //NSLog(@"---------------------fileTime:%@",fileTime);
        
        NSArray* fileMD5Elements = [fileInfoElement elementsForName:@"FILEMD5"];
        NSString* fileMD5 = [[fileMD5Elements objectAtIndex:0] stringValue];
        //NSLog(@"---------------------fileMD5:%@",fileMD5);
        
        NSArray* PCGuidElements = [fileInfoElement elementsForName:@"PCGUID"];
        NSString* PCGuid = [[PCGuidElements objectAtIndex:0] stringValue];
        //NSLog(@"---------------------PCGuid:%@",PCGuid);
        
        NSArray* fileUrlElements = [fileInfoElement elementsForName:@"FILEURL"];
        NSString* fileURL = [[fileUrlElements objectAtIndex:0] stringValue];
        NSString* sub1FileUrl = [[fileURL componentsSeparatedByString:@"mobFileName="]firstObject];
        NSString* sub3FileUrl = [fileName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];//encode
        NSString* fileURL2 = [NSString stringWithFormat:@"%@mobFileName=%@",sub1FileUrl,sub3FileUrl];
        //NSLog(@"---------------------fileURL2:%@",fileURL2);
        
        NSArray* arr = [NSArray arrayWithObjects:fileName,fileSize,fileTime,fileMD5,PCGuid,fileURL2, nil];
        [sharingFilesInfoList addObject:arr];
    }

    NSLog(@"response sharingFilesInfoList count: %ld",(long)[sharingFilesInfoList count]);
    //delegate method to transport arguments
    [self.sharingFileCheckDelegate getSharingFilesInfoSucceed:sharingFilesInfoList];
    
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
    self.sharingFileCheckDelegate = delegate;
    sharingFilesInfoList = [[NSMutableArray alloc]init];
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
-(long)sharingFileCheck
{
    SystemCommand* cmd;
    
    cmd = [self createInitCommand_sharingFile];//
    
    if (cmd == nil) {
        return SHARING_FILE_CHECK_CREATE_INIT_COMMANDD_ERROR;
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
-(SystemCommand*)createInitCommand_sharingFile
{
    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
    NSString* guid= [config getValueByKey:WSConfigItemGuid];//通过uuid计算得到
    NSString* sid = [self getActiveAccountSID];
    
    //NSLog(@"guid: %@",guid);
    //NSLog(@"sid: %@",sid);
    
    if (guid == nil || sid == nil) {
        return nil;
    }
    
    NSString* xmlStr = [NSString stringWithFormat:@"<HEAD><MODULEID>D00</MODULEID><OPCODE>D01</OPCODE><SIGN>111111111111111111111111</SIGN></HEAD><DATA><GUID encode=\"\">%@</GUID><USERSID encode=\"\">%@</USERSID></DATA>",guid,sid];
    
    //NSString* xmlStr = [NSString stringWithFormat:@"<HEAD><MODULEID>400</MODULEID><OPCODE>403</OPCODE><SIGN>111111111111111111111111</SIGN></HEAD><DATA><GUID encode=\"\">%@</GUID><USERSID encode=\"\">%@</USERSID></DATA>",guid,sid];
    
//    <HEAD><MODULEID>400</MODULEID><OPCODE>403</OPCODE><SIGN>111111111111111111111111</SIGN></HEAD><DATA><GUID encode="">37A46CE4-C536532C-B449E059-7CB16EED</GUID><USERSID encode="">A53EDEBB-BDF544C0-BBFF5D01-1C525D21</USERSID></DATA>
    
    NSLog(@"sharingFile xmlStr:%@",xmlStr);
    NSData* xml = [NSData dataWithBytes:[xmlStr UTF8String] length:strlen([xmlStr UTF8String])];
    SystemCommand* command = [CommandHelper createCommandWithXMLData:xml isVerifyData:NO];
    
    return command;
}

#pragma mark - Send Download Results
- (long)sendDownloadResults:(NSArray*)resultsInfo
{
    SystemCommand* cmd;
    
    cmd = [self createInitCommand_downloadResults:resultsInfo];//
    
    if (cmd == nil) {
        return SHARING_FILE_CHECK_CREATE_INIT_COMMANDD_ERROR;
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

//send download files results
-(SystemCommand*)createInitCommand_downloadResults:(NSArray*)resultsInfo
{
    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
    NSString* guid= [config getValueByKey:WSConfigItemGuid];//通过uuid计算得到
    NSString* sid = [self getActiveAccountSID];
    
    //NSLog(@"guid: %@",guid);
    //NSLog(@"sid: %@",sid);
    
    if (guid == nil || sid == nil) {
        return nil;
    }
    
    //------- need to pack data
    NSString* resultsInfoStr = @"";
    for (NSDictionary* dic in resultsInfo) {
        NSArray* tmpArr = [dic objectForKey:@"kFileInfo"];
        NSString* fileName = [tmpArr firstObject];
        NSString* fileNameElement = [NSString stringWithFormat:@"<FILENAME>%@</FILENAME>",fileName];
        
        NSString* downloadResult = [dic objectForKey:@"kDownloadResult"];
        NSString* downloadElement = [NSString stringWithFormat:@"<DOWNLOAD>%@</DOWNLOAD>",downloadResult];

        NSString* fileMD5 = [tmpArr objectAtIndex:3];
        NSString* fileMD5Element = [NSString stringWithFormat:@"<FILEMD5>%@</FILEMD5>",fileMD5];
        
        NSString* PCGuid = [tmpArr objectAtIndex:4];
        NSString* PCGuidElement = [NSString stringWithFormat:@"<PCGUID>%@</PCGUID>",PCGuid];
        
        NSString* fileInfo = [NSString stringWithFormat:@"<FILEINFO>%@%@%@%@</FILEINFO>",fileNameElement,downloadElement,fileMD5Element,PCGuidElement];
        
        resultsInfoStr = [resultsInfoStr stringByAppendingString:fileInfo];
        
    }
    //==
   
    
    NSString* xmlStr = [NSString stringWithFormat:@"<HEAD><MODULEID>D00</MODULEID><OPCODE>D03</OPCODE><SIGN>111111111111111111111111</SIGN></HEAD><DATA><GUID encode=\"\">%@</GUID><USERSID encode=\"\">%@</USERSID><FILELIST encode=\"\">%@</FILELIST></DATA>",guid,sid,resultsInfoStr];
    
    NSLog(@"downloadResults xmlStr:%@",xmlStr);
    NSData* xml = [NSData dataWithBytes:[xmlStr UTF8String] length:strlen([xmlStr UTF8String])];
    SystemCommand* command = [CommandHelper createCommandWithXMLData:xml isVerifyData:NO];
    
    return command;
}

#pragma mark -
-(void) wakeup
{
    //NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
//    [self performSelectorOnMainThread:@selector(setRecv) withObject:nil waitUntilDone:YES];
    //[pool release];
    [self setRecv];
}

-(void)setRecv
{
    self.isRecv = YES;
}



@end
