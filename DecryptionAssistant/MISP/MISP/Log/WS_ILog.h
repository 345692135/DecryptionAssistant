//
//  MyLog.h
//  LogComponent
//
//  Created by nie on 12-7-24.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#define FILE_CONTENTS_MAX_VAULE 10*1024*1024   //Log max file size define

#import <Foundation/Foundation.h>

typedef enum 
{
    NSLogTypeConsle,        //  choice consle output
    NSlogTypeFile           //  choice file write in
}LogType;

typedef enum                //  level of log
{
    ERROR=10,                
    WARNNING=20,
    INFO=30,
}LogLevel;


@protocol WS_ILog <NSObject>

/*!
    @method writeLog:Level logText:Log,...
    @abstract Write log into file or output log on consle
    @param Level Log The log level and the content of log
    @result output log on consle or write log into file
 */
- (void)writeLog:(LogLevel)Level logText:(NSString*)Log,...;

/*!
    @method setlogPrintLevel:Level
    @abstract set log print level
    @parm Level the level of log
    @result set level of log to print
 */
- (void)setlogPrintLevel:(LogLevel)Level;

@end
