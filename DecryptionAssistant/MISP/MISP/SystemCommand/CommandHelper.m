//
//  CommandHelper.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-8-5.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import "CommandHelper.h"
#import "NSString+SubString.h"

@implementation CommandHelper


+ (NSData*)createXMLDataWithCommand:(SystemCommand*)command isSignData:(BOOL)b;
{
    NSMutableData* data = nil;
    if (command.head == nil) {
        return data;
    }
    
    data = [NSMutableData dataWithData:[[command head]XMLData]];
    
    if (command.body != nil) {
        [data appendData:[[command body]XMLData]];
    }
    return data;
}


+ (SystemCommand*)createCommandWithXMLData:(NSData*)data isVerifyData:(BOOL)b;
{
    if ([data length] == 0) {
        return nil;
    }
    
    NSString* xml = [[NSString alloc]initWithUTF8String:[data bytes]];
    //NSLog(@"xml3forHeader: %@",xml);
    
    
    //set head
    NSString* headxml = [xml subStringFromString:@"<HEAD>" to:@"</HEAD>"];

    if (headxml == nil) {
        [xml release];xml = nil;
        TRACK(@"createCommandWithXMLData error command xml format")
        return nil;
    }
    
    GDataXMLDocument* head = [[GDataXMLDocument alloc]initWithXMLString:headxml options:0 error:nil];    
    if (head == nil) {
        [xml release];xml = nil;
        TRACK(@"createCommandWithXMLData head error");
        return nil;
    }

    SystemCommand* cmd = [[SystemCommand alloc]init];
    [cmd setHead:head];
    [head release];head = nil;

    //set body
    NSString* bodyxml = [xml subStringFromString:@"<DATA>" to:@"</DATA>"];
    if (bodyxml == nil) {//20160426 add by yyf, for approve list info
        bodyxml = [xml subStringFromString:@"<RESPONSE>" to:@"</RESPONSE>"];
    }
    
    if (bodyxml != nil) {
        GDataXMLDocument* body = [[GDataXMLDocument alloc]initWithXMLString:bodyxml options:0 error:nil];
        if (body != nil) {
            [cmd setBody:body];
            [body release]; body = nil;
        }else
        {
            [cmd setBody:nil];
        }
    }else{
        [cmd setBody:nil];
    }
    [xml release];xml = nil;
   
    
    return [cmd autorelease];
}

@end
