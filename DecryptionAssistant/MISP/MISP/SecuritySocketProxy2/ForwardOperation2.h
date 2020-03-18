//
//  ForwardOperation.h
//  ScoketProxy
//
//  Created by Cooriyou on 13-7-2.
//  Copyright (c) 2013年 wondersoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ForwardOperation2 : NSOperation<NSStreamDelegate>
{
    BOOL _isReady;
    BOOL _isCancelled;
    BOOL _isExecuting;
    BOOL _isFinished;
}

@property(atomic,retain) NSString* remoteIp;
@property(atomic) NSInteger remotePort;

- (id)initWithHandle:(CFSocketNativeHandle) socket;

- (id)initWithHandle:(CFSocketNativeHandle) socket remoteIp:(NSString*) ip remotePort:(NSInteger) port;

@end
