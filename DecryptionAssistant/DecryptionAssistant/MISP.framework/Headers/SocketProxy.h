//
//  SocketProxy.h
//  ScoketProxy
//
//  Created by Cooriyou on 13-7-1.
//  Copyright (c) 2013年 wondersoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SocketProxy : NSObject


@property(atomic,retain)NSString* remoteIp;
@property(atomic)NSInteger remotePort;
@property(atomic,retain)NSOperationQueue* queue;

- (id)initWithAcceptPort:(NSInteger)port;

- (id)initWithAcceptPort:(NSInteger)port remoteIp:(NSString*)rip remotePort:(NSInteger)rport;

@end
