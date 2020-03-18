//
//  MCApprovalManager.m
//  MISP
//
//  Created by TanGuoLian on 17/5/16.
//  Copyright © 2017年 wondersoft. All rights reserved.
//

#import "MCApprovalManager.h"

#import "TCPAccess.h"
#import "IConfig.h"
#import "ConfigManager.h"
#import "AccountManagement.h"
#import "GTMBase64.h"

@interface MCApprovalManager ()<CommandResponseDelegate>

@property (nonatomic,assign)BOOL isRecv;
@property (nonatomic,strong)TCPAccess *acess;

@property (nonatomic,strong)MCApprovalModel *model;

@end

@implementation MCApprovalManager

#pragma mark - setter && getter

- (MCApprovalModel *)model
{
    if (!_model)
    {
        _model = [[MCApprovalModel alloc] init];
    }
    
    return _model;
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
        self.acess = [[TCPAccess alloc]init];
        
        [self.acess setIpAddress:ip];
        [self.acess setPortNum:[port intValue]];
        [self.acess setDelegate:self];
    }
    
    return self;
}

#pragma mark - CommandResponseDelegate

- (void)commandResponse:(SystemCommand *)data
{
    if (!data)
    {
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
    
    self.isRecv = YES;
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
    NSString *json          = [element stringValue];
    
    //bsae64解码
    /*
    NSData *decodeData      = [GTMBase64 decodeString:json];
    json                    = [[NSString alloc] initWithData:decodeData encoding:NSUTF8StringEncoding];
    */
    
    NSDictionary *dict      = [MCApprovalConvertUtil jsonToDictionary:json];
    
    //build model
    MCApprovalModel *model = [MCApprovalModel initWithObject:moudleId
                                                      opCode:opCode
                                                     xmlCode:xmlCode
                                               errorDescribe:errorDescribe
                                                        sign:sign
                                                    jsonDict:dict];
    
    self.model = model;
}

#pragma mark - 请求接口

- (void)requestProcessApprovalDataFromServer:(NSDictionary *)dictionary
                                 requestType:(RequestType)RequestType
                             completionBlock:(void(^)(long xmlCode,MCApprovalModel *approvalModel))completionBlock
{
    //JSON
    NSString *jsonString = [MCApprovalConvertUtil dictionaryToJSON:dictionary];
    
    //base64编码
    /*
    NSData *base64Data = [GTMBase64 encodeData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    jsonString = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
    */
    
    SystemCommand *command = [MCApproveTCPParamProvider buildParamForTCPRequest:RequestType jsonString:jsonString];
    
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
