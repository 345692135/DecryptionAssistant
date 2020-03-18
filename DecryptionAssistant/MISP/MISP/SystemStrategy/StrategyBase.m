//
//  StategyBase.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-7-19.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import "StrategyBase.h"


@implementation StrategyBase

@synthesize strategyXMLData;

- (void)dealloc
{
    [strategyXMLData release];strategyXMLData = nil;
    [super dealloc];
}

- (id)initWithStrategyData:(NSData*)data error:(NSError**) err
{
    self = [super init];
    if (self) {
        //To do init Xml object
        GDataXMLDocument* xml = [[GDataXMLDocument alloc]initWithData:data options:0 error:err];
        self.strategyXMLData = xml;
        [xml release];
    }
    return self;
}


- (NSString *)getStrategySHA1
{
    if (strategyXMLData == nil) {
        return nil;
    }
    
    GDataXMLElement* element = (GDataXMLElement*)[[strategyXMLData nodesForXPath:@"/RESPONSE/CMD" error:nil] objectAtIndex:0];
//    NSLog(@"%@",[element XMLString]);
    
    GDataXMLNode* node = [element attributeForName:@"ProcessInfo"];
    
    NSString* sha1 = [node stringValue];
    
    sha1 = [sha1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
//    TRACK(@"%@",[sha1 substringWithRange:NSMakeRange(20, 40)]);
    
    return [sha1 substringWithRange:NSMakeRange(20, 40)];
}

@end
