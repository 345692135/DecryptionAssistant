//
//  MCApproveFileTCPAccess.h
//  MISP
//
//  Created by TanGuoLian on 17/6/10.
//  Copyright © 2017年 wondersoft. All rights reserved.
//

#import "NetAccessBase.h"
#import "GCDAsyncSocket.h"
#import "CommandHelper.h"

@class MCApproveFileTCPAccess;

@protocol CommandResponseDelegate <NSObject>

-(void)commandResponse:(MCApproveFileTCPAccess *)tcpAccess data:(SystemCommand *)data;

@end

@interface MCApproveFileTCPAccess : NetAccessBase<GCDAsyncSocketDelegate>

{
    GCDAsyncSocket *socket;
    id<CommandResponseDelegate> delegate;
    NSString* ipAddress;
    UInt16 portNum;
}

@property (atomic, retain) GCDAsyncSocket *socket;
@property (atomic, assign) id<CommandResponseDelegate> delegate;
@property (atomic,retain) NSString* ipAddress;
@property (atomic)UInt16 portNum;

-(void)setResponseDelegate:(id<CommandResponseDelegate>)responseDelegate;

-(void)commandRequest:(SystemCommand*)command;

-(void)disconnect;

@end
