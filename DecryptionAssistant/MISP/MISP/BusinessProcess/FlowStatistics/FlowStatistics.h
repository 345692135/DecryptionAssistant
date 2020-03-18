//
//  FlowStatistics.h
//  MISP
//
//  Created by Mr.Cooriyou on 13-3-16.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//
// This is a system  flow statistics class ,used by upload flow - see the class methods below

#import "WSBaseObject.h"
#import "TCPAccess.h"

@interface FlowStatistics : WSBaseObject<CommandResponseDelegate>
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

-(long) submit;

@end
