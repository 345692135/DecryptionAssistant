//
//  UpdateCheck.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-8-29.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//
// This is a update request class

#import "WSBaseObject.h"
#import "TCPAccess.h"


@interface UpdateCheck : WSBaseObject<CommandResponseDelegate>
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

-(long) updateCheck;

@end
