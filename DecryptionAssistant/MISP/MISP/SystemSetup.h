//
//  SystemSetup.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-8-29.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//
// This is a system  init setup class ,used by system init - see the class methods below

#import "WSBaseObject.h"
#import "TCPAccess.h"


@interface SystemSetup : WSBaseObject<CommandResponseDelegate>
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

-(long) beginSetup;
-(long) getMainServerIP;

@end
