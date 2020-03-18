//
//  LogUploadAttachedFile.h
//  MISP
//
//  Created by lijuan on 16/4/19.
//  Copyright © 2016年 wondersoft. All rights reserved.
//

#import "WSBaseObject.h"
#import "TCPAccess.h"
#import <Foundation/Foundation.h>

@interface LogUploadAttachedFile : WSBaseObject<CommandResponseDelegate,NSXMLParserDelegate>
{
    int step;
    long err;
    __block BOOL isRecv;
    TCPAccess* access;
}

@property(atomic,retain)TCPAccess* access;
@property(atomic)int step;
@property(atomic) __block BOOL isRecv;
@property(atomic)long err;
@property(atomic)BOOL isGuidRequest;


-(long) logUpload:(NSArray*)log withType:(NSString*)type withGUID:(BOOL) guidFlag;
@end

