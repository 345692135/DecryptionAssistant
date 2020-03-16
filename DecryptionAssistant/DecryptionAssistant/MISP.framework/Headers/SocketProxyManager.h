//
//  SocketProxyManager.h
//  MISP
//
//  Created by Cooriyou on 13-7-16.
//  Copyright (c) 2013年 wondersoft. All rights reserved.
//

#import <MISP/WSBaseObject.h>

@interface SocketProxyManager : WSBaseObject



/*!
 @method getInstance
 @abstract Get context instance
 @result Return context singleton class object
 */
+ (SocketProxyManager*)getInstance;

-(BOOL)start;

-(BOOL)stop;

- (NSString*)getMAGIp;

- (void)sumBitOperation:(long long)count;

- (void)saveSafeTunnelFlow:(long long)count;

- (long long)getFlow;

@end
