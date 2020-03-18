//
//  ConsleLog.m
//  LogComponent
//
//  Created by nie on 12-7-24.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import "ConsleLog.h"

#import "ConsleLog.h"

@implementation ConsleLog

static ConsleLog* consleLogIntstace=nil;

+ (ConsleLog*)getTypeConsleInstance
{
    @synchronized(self){
        if (!consleLogIntstace) {
            consleLogIntstace=[NSAllocateObject([self class], 0, NULL)init];
        }
    }
    return consleLogIntstace;
}
+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self){
        if (consleLogIntstace==nil) {
            consleLogIntstace=[super allocWithZone:zone];
        }
    }
    return consleLogIntstace;       //  assingment and return first
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
    return  self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setlogPrintLevel:INFO];
    }
    return self;
}

-(void)setlogPrintLevel:(LogLevel)Level
{
    logPrintLevel = Level;
}

- (void)writeLog:(LogLevel)Level logText:(NSString *)Log, ...
{
    //step 1 get param format log string
    NSString *strLog = nil;
    va_list logList;
    @synchronized(self){
        if (Level<=logPrintLevel)
        {
            if ([Log length]!=0) {
                va_start(logList, Log);
                strLog=[[NSString alloc]initWithFormat:Log arguments:logList];
                va_end(logList);
            }
            //step 2 to print log with level
            if (Level==INFO) {
                NSLog(@"Level: [INFO] Info: %@",strLog);
            }else if (Level==WARNNING) {
            NSLog(@"Level: [WARN] Info: %@",strLog);
            }else if(Level==ERROR) {
                NSLog(@"Level: [ERRO] Info: %@",strLog);
            }
            [strLog release];
        }//else do nothing
    }
}

@end
