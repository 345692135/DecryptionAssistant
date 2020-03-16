//
//  LogUpload.h
//  MISP
//
//  Created by wondersoft on 16/4/19.
//  Copyright © 2016年 wondersoft. All rights reserved.
//

#import "WSBaseObject.h"
#import "TCPAccess.h"
#import <Foundation/Foundation.h>

@interface LogUpload : WSBaseObject<CommandResponseDelegate,NSXMLParserDelegate>
{
    int step;
    long err;
    BOOL isRecv;
    TCPAccess* access;
}

@property(atomic,retain)TCPAccess* access;
@property(atomic)int step;
@property(atomic)BOOL isRecv;
@property(atomic)long err;

-(long) logUpload:(NSArray*)log withType:(NSString*)type;

@end
