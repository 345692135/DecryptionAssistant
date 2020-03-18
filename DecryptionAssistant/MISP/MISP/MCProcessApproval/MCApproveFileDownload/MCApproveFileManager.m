//
//  MCApproveFileManager.m
//  MISP
//
//  Created by TanGuoLian on 17/6/10.
//  Copyright © 2017年 wondersoft. All rights reserved.
//

#define k_request_failed -1 //请求失败

#import "MCApproveFileManager.h"

#import "MCApproveFileTCPAccess.h"
#import "IConfig.h"
#import "ConfigManager.h"
#import "AccountManagement.h"
#import "GTMBase64.h"
#import "NSData+DecryptApproveFile.h"

@interface MCApproveFileManager ()<CommandResponseDelegate>

@property (nonatomic,assign)BOOL isRecv;
@property (nonatomic,strong)MCApproveFileTCPAccess *acess;

@property (nonatomic,strong)MCApproveFileModel *model;

//文件字节长度
@property (nonatomic,assign) long long fileLength;

//文件本地保存路径
@property (nonatomic,strong) NSString *filePath;

@property (nonatomic,strong) NSMutableData *data;

@end

@implementation MCApproveFileManager

#pragma mark - setter && getter

- (MCApproveFileModel *)model
{
    if (!_model)
    {
        _model = [[MCApproveFileModel alloc] init];
    }
    
    return _model;
}

- (NSMutableData *)data
{
    if (!_data)
    {
        _data = [[NSMutableData alloc] init];
    }
    
    return _data;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
        NSString *ip = [config getValueByKey:WSConfigItemIP];
        NSString *port = [config getValueByKey:WSConfigItemPort];
        
        if (!ip || !port)
        {
            return nil;
        }
        self.acess = [[MCApproveFileTCPAccess alloc]init];
        
        [self.acess setIpAddress:ip];
        [self.acess setPortNum:[port intValue]];
        [self.acess setDelegate:self];
    }
    
    return self;
}

#pragma mark - CommandResponseDelegate

-(void)commandResponse:(MCApproveFileTCPAccess *)tcpAccess data:(SystemCommand *)data
{
    if (!data)
    {
        self.model.xmlCode = k_request_failed;
        self.isRecv = YES;
        return;
    }
    
    if ([[data getReturnCode] intValue] != 0)
    {
        //请求错误，具体根据错误码定
        self.model.xmlCode = [[data getReturnCode] intValue];
        self.isRecv = YES;
        return;
    }
    
    //DATA
    GDataXMLElement *xmlElement = [data getPackageDataObject];
    
    if (!xmlElement)
    {
        self.model.xmlCode = [[data getReturnCode] intValue];
        
        if (self.model.xmlCode == 0)
        {
            //请求成功，但无body数据，服务器内部错误
            self.model.xmlCode = SYSTEM_INER_ERROR;
            self.isRecv = YES;
        }
    }
    
    //handle data
    [self handleDataFromServer:data];
}

//处理返回数据
- (void)handleDataFromServer:(SystemCommand *)data
{
    //DATA
    GDataXMLElement *dataElement = [data getPackageDataObject];
    
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithRootElement:dataElement];
    
    GDataXMLElement *element = [[doc nodesForXPath:@"/DATA/JSONDATA" error:nil] objectAtIndex:0];
    
    NSString *moudleId      = [data getModuleid];
    NSString *opCode        = [data getOpcode];
    long xmlCode            = [[data getReturnCode] intValue];
    NSString *errorDescribe = [data getErrorDescribe];
    NSString *sign          = @"111111111111111";
    
    //json转dictionary
    NSString *fileStream    = [element stringValue];
    
    //base64解码
    NSData *datas = [GTMBase64 decodeString:fileStream];
    
    NSLog(@"data length:%lu",(unsigned long)datas.length);
    
    [self.data appendData:datas];
    
    self.fileLength -= datas.length;
    
    if (self.fileLength == 0)
    {
        //写入文件流数据到本地
        [self.data writeToFile:self.filePath atomically:YES];
        self.data = nil;
        
        //判断是否加密文件，做相关处理
        BOOL iRet = [NSMutableData isEncryptFile:self.filePath];
        
        if (iRet)
        {
            NSLog(@"审批附件为加密文件");
            
            NSData *decryptedData = [NSData dataWithEncryptContentsOfNewApproveFile:self.filePath];
            BOOL isEncData = [decryptedData isEncryptNewApproveFileData];
            
            if (!isEncData)
            {
                NSData *data = [NSData dataWithData:decryptedData];
                [data writeToFile:self.filePath atomically:YES];
            }
            else
            {
                NSLog(@"审批附件解密失败");
            }
        }
        
        self.isRecv = YES;
        NSLog(@"文件下载成功,断掉socket");
    }
    
    //build model
    MCApproveFileModel *model = [MCApproveFileModel initWithObject:moudleId
                                                            opCode:opCode
                                                           xmlCode:xmlCode
                                                     errorDescribe:errorDescribe
                                                              sign:sign
                                                          filePath:self.filePath];
    
    self.model = model;
}

#pragma mark - 审批附件请求接口

- (void)requestProcessApprovalFileFromServer:(NSDictionary *)dictionary
                                  fileLength:(long long)fileLength
                                    filePath:(NSString *)filePath
                                 requestType:(RequestType)RequestType
                             completionBlock:(void(^)(long xmlCode,MCApproveFileModel *approvalFileModel))completionBlock
{
    //JSON
    NSString *jsonString = [MCApprovalConvertUtil dictionaryToJSON:dictionary];
    
    //base64编码
    /*
    NSData *base64Data = [GTMBase64 encodeData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    jsonString = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
    */
    
    SystemCommand *command = [MCApproveTCPParamProvider buildFileDownloadParamForTCPRequest:RequestType fileSize:[NSString stringWithFormat:@"%lld",fileLength] jsonString:jsonString];
    
    self.fileLength = fileLength; //文件字节长度
    self.filePath = filePath;     //文件本地保存路径
    
    if (!command)
    {
        if (completionBlock)
        {
            self.model.xmlCode = CLINET_CREATE_INIT_COMMAND_FAILED;
            completionBlock(self.model.xmlCode,self.model);
            return;
        }
    }
    
    self.isRecv = NO;
    
    //request (TCP)
    [self.acess commandRequest:command];
    
    while (!self.isRecv)
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    [self.acess disconnect];
    self.acess.delegate = nil;
    self.isRecv = NO;
    
    //callback
    if (completionBlock)
    {
        completionBlock(self.model.xmlCode,self.model);
    }
}

#pragma mark - 获取当前用户sid

- (NSString *)getActiveAccountSid
{
    AccountManagement* accountManager = [AccountManagement getInstance];
    SystemAccount* account = [accountManager getActiveAccount];
    
    return [account userSid];
}

@end
