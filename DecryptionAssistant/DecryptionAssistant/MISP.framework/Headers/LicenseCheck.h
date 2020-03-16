//
//  LicenseCheck.h
//  MISP
//
//  Created by YouGik on 15-9-21.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//
// This is a license request class

#import "WSBaseObject.h"
#import "TCPAccess.h"


@interface LicenseCheck : WSBaseObject<CommandResponseDelegate,NSXMLParserDelegate>
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

-(long) licenseCheck;

@end
