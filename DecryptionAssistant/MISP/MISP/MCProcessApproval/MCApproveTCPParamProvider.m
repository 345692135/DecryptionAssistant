//
//  MCApproveTCPParamProvider.m
//  MISP
//
//  Created by TanGuoLian on 17/5/16.
//  Copyright © 2017年 wondersoft. All rights reserved.
//

#import "MCApproveTCPParamProvider.h"
#import "SystemCommand.h"

@implementation MCApproveTCPParamProvider

+ (SystemCommand *)buildParamForTCPRequest:(RequestType)RequestType jsonString:(NSString *)jsonString
{
    NSString *xmlString = [self buildXMLString:jsonString];
    
    SystemCommand *command = [self buildCommandParamWithXMLString:[xmlString UTF8String]];
    
    return command;
}

#pragma mark - XML生成器

+ (NSString *)buildXMLString:(NSString *)jsonString
{
    NSString *xmlString = @"";
    
    xmlString = [NSString stringWithFormat:@"<HEAD><MODULEID>C00</MODULEID><OPCODE>405</OPCODE><SIGN>111111111111111111111111</SIGN></HEAD><DATA><JSONDATA>%@</JSONDATA></DATA>",jsonString];
    
    return xmlString;
}

#pragma mark - 构建请求对象 SystemCommand

+ (SystemCommand *)buildCommandParamWithXMLString:(const char *)UTF8String
{
    NSString *xmlString = [NSString stringWithUTF8String:UTF8String];
    
    if ([xmlString length] == 0)
    {
        return nil;
    }
    
    //head
    NSString *headxml = [xmlString subStringFromString:@"<HEAD>" to:@"</HEAD>"];
    
    if (headxml == nil)
    {
        TRACK(@"buildCommandParamWithXMLString error command xml format")
        return nil;
    }
    
    GDataXMLDocument* head = [[GDataXMLDocument alloc]initWithXMLString:headxml options:0 error:nil];
    if (head == nil)
    {
        TRACK(@"buildCommandParamWithXMLString head error");
        return nil;
    }
    
    SystemCommand *cmd = [[SystemCommand alloc]init];
    [cmd setHead:head];
    
    //body
    NSString *bodyxml = [xmlString subStringFromString:@"<DATA>" to:@"</DATA>"];
    if (bodyxml == nil)
    {
        bodyxml = [xmlString subStringFromString:@"<RESPONSE>" to:@"</RESPONSE>"];
    }
    
    if (bodyxml != nil)
    {
        GDataXMLDocument *body = [[GDataXMLDocument alloc]initWithXMLString:bodyxml options:0 error:nil];
        if (body != nil)
        {
            [cmd setBody:body];
        }
        else
        {
            [cmd setBody:nil];
        }
    }
    else
    {
        [cmd setBody:nil];
    }

    return cmd;
}

#pragma mark - 审批附件下载

+ (SystemCommand *)buildFileDownloadParamForTCPRequest:(RequestType)RequestType
                                              fileSize:(NSString *)fileSize
                                            jsonString:(NSString *)jsonString
{
    NSString *xmlString = [self buildFileDownloadXMLString:fileSize jsonString:jsonString];
    
    SystemCommand *command = [self buildCommandParamWithXMLString:[xmlString UTF8String]];
    
    return command;
}

#pragma mark - 审批附件下载请求参数XML生成器

+ (NSString *)buildFileDownloadXMLString:(NSString *)fileSize jsonString:(NSString *)jsonString
{
    NSString *xmlString = @"";
    
    xmlString = [NSString stringWithFormat:@"<HEAD><MODULEID>C00</MODULEID><OPCODE>407</OPCODE><SIGN>111111111111111111111111</SIGN><FILESIZE>%@</FILESIZE></HEAD><DATA><JSONDATA>%@</JSONDATA></DATA>",fileSize,jsonString];
    
    return xmlString;
}

@end
