//
//  LogManager.m
//  LogComponent
//
//  Created by nie on 12-7-24.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import "LogManager.h"
#import "ConsleLog.h"
#import "FileLog.h"
@implementation LogManager

static LogManager* logManager=nil;      //log manager instance
static id<WS_ILog> logPrivder=nil;      //log privder instance

#pragma mark realize singleton class method

+ (LogManager*)getInstance
{
    @synchronized(self){
        if (!logManager) {
            logManager = [NSAllocateObject([self class], 0, NULL) init];
        }
    }
    return logManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self){
        if (logManager==nil) {
            logManager = [super allocWithZone:zone];
        }
    }
    return logManager;      //  assingment and return first allocation
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSIntegerMax;
}

- (id)autorelease
{
    return self;
}

- (oneway void)release
{
    //  Do Nothing
}

-(id)copyWithZone:(NSZone*)zone
{
    return self;
}


#pragma mark getLogPrivder class method

- (id<WS_ILog>)getLogPrivder:(LogType)nType
{
    if (nType==NSLogTypeConsle) {
        logPrivder = [ConsleLog getTypeConsleInstance];
    }else if(nType==NSlogTypeFile){
        logPrivder = [FileLog getTypeFileInstance];
    }
    return logPrivder;
}


@end

