//
//  LogUploadInterface.h
//  MISP
//
//  Created by lijuan on 17/5/8.
//  Copyright © 2017年 wondersoft. All rights reserved.
//
#import "WSBaseObject.h"
#import "TCPAccess.h"
#import <Foundation/Foundation.h>


@interface LogUploadInterface : WSBaseObject<CommandResponseDelegate, NSXMLParserDelegate>
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
