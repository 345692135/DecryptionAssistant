//
//  HeartBeat.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-9-12.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//
// This is a heart beat class - see the class methods below

#import "WSBaseObject.h"
#import "UDPAccess.h"
#import "CommandHelper.h"

@interface HeartBeat : WSBaseObject<UdpCommandResponseDelegate>
{
    
}

@property(atomic,retain)UDPAccess* udp;
@property(atomic,retain)NSTimer* timer;
@property(atomic)int count;

- (void)start;

- (void)stop;

@end
