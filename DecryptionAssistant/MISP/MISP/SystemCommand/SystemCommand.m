//
//  SystemCommand.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-8-5.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import "SystemCommand.h"

@implementation SystemCommand

@synthesize head;
@synthesize body;

- (void)dealloc
{
    [head release];head = nil;
    [body release];body = nil;
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.head = nil;
        self.body = nil;
        
        //set head XMLDocument
        GDataXMLDocument* ehead = [[GDataXMLDocument alloc]initWithXMLString:@"<HEAD><MODULEID></MODULEID><OPCODE></OPCODE></HEAD>" options:0 error:nil];
        self.head = ehead;
        [ehead release];
        
        //set body XMLDocument
        GDataXMLDocument* ebody = [[GDataXMLDocument alloc]initWithXMLString:@"<DATA></DATA>" options:0 error:nil];

        if ([[self getModuleid]isEqualToString:@"COO"]) {
            //NSLog(@"COO:%@",ebody);
            ebody = [[GDataXMLDocument alloc]initWithXMLString:@"<RESPONSE></RESPONSE>" options:0 error:nil];
        }
        
        self.body = ebody;
        [ebody release];
    }
    return self;
}

- (void)setModuleId:(NSString*)module opcode:(NSString*)code
{
    if ([module length] == 0 || [code length] == 0) {
        return;
    }
    
    //set module value
    GDataXMLElement* moduleid = (GDataXMLElement*)[[self.head nodesForXPath:@"/HEAD/MODULEID" error:nil]objectAtIndex:0];
    if (moduleid != nil) {
        [moduleid setStringValue:module];
    }
    
    //set opcode value
    GDataXMLElement* opcode = (GDataXMLElement*)[[self.head nodesForXPath:@"/HEAD/OPCODE" error:nil]objectAtIndex:0];
    if (opcode != nil) {
        [opcode setStringValue:code];
    }

}

- (long)setPackageDataObejectWithXmlString:(NSString*)xml error:(NSError**)err
{
    if (self.body == nil) {
        [self makeError:err domain:@"command body is nil" errCode:0x3801];
        return -1;
    }
    
    //set body data
    GDataXMLElement* element = (GDataXMLElement*)[[self.body nodesForXPath:@"/DATA" error:nil]objectAtIndex:0];
    
    GDataXMLElement* data = [[GDataXMLElement alloc]initWithXMLString:xml error:err];
    if (data == nil) {
        TRACK(@"setPackageDataObejectWithXmlString error");
        return -1;
    }
    [element addChild:data];
    [data release];
    
    return 0;
}

- (long)setPackageDataObejectWithElement:(GDataXMLElement*)element error:(NSError**)err
{
    if (self.body == nil) {
        [self makeError:err domain:@"command body is nil" errCode:0x3801];
        return -1;
    }
    if (element == nil) {
        [self makeError:err domain:@"element is null point" errCode:0x3802];
        return -1;
    }
    
    //set body data
    GDataXMLElement* data = (GDataXMLElement*)[[self.body nodesForXPath:@"/DATA" error:nil]objectAtIndex:0];
    if (data == nil) {
        return -1;
    }
    [data addChild:element];
    
    return 0;
}

- (NSString*)getModuleid
{
    if (self.head == nil) {
        return nil;
    }
    
    NSArray* arr = [self.head nodesForXPath:@"/HEAD/MODULEID" error:nil];
    if ([arr count] == 0) {
        return nil;
    }
    
    GDataXMLElement* moduleid = (GDataXMLElement*)[arr objectAtIndex:0];
    return [moduleid stringValue];
    
}

- (NSString*)getOpcode
{
    if (self.head == nil) {
        return nil;
    }
    
    NSArray* arr = [self.head nodesForXPath:@"/HEAD/OPCODE" error:nil];
    if ([arr count] == 0) {
        return nil;
    }
    
    GDataXMLElement* opcode = (GDataXMLElement*)[arr objectAtIndex:0];
    return [opcode stringValue];
    
}

- (NSString*)getReturnCode
{
    if (self.head == nil) {
        return nil;
    }
    
    NSArray* arr = [self.head nodesForXPath:@"/HEAD/RESPONSE" error:nil];
    if ([arr count] == 0) {
        return nil;
    }
    
    GDataXMLElement* opcode = (GDataXMLElement*)[arr objectAtIndex:0];
    return [opcode stringValue];
}

- (NSString*)getErrorDescribe
{
    if (self.head == nil) {
        return nil;
    }
    
    NSArray* arr = [self.head nodesForXPath:@"/HEAD/ERRORDESCRIBE" error:nil];
    if ([arr count] == 0) {
        return nil;
    }
    
    GDataXMLElement* error = (GDataXMLElement*)[arr objectAtIndex:0];
    return [error stringValue];
}

- (GDataXMLElement*)getPackageDataObject
{
    if (self.body == nil) {
        return nil;
    }
    
    NSArray* arr = [self.body nodesForXPath:@"/DATA" error:nil];
    if ([arr count] == 0) {
        return nil;
    }
    
    GDataXMLElement* data = (GDataXMLElement*)[arr objectAtIndex:0];
    return data;
}

- (GDataXMLElement*)getPackageDataObject2
{
    //NSLog(@"getPackageDataObject2:%@",self.body);
    if (self.body == nil) {
        return nil;
    }
    
    NSArray* arr = [self.body nodesForXPath:@"/RESPONSE" error:nil];
    if ([arr count] == 0) {
        return nil;
    }
    
    GDataXMLElement* data = (GDataXMLElement*)[arr objectAtIndex:0];
    return data;
}

@end
