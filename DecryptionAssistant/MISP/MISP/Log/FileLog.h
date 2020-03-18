//
//  FileLog.h
//  LogComponent
//
//  Created by nie on 12-7-24.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WS_ILog.h"

@interface FileLog : NSObject<WS_ILog>
{
    LogLevel logPrintLevel;      //log print level
    int nSize;                  //log file size
}

/*!
    @method getTypeFileInstance;
    @abstract Get the singleton object
    @param Null
    @result Return vaule singleton object 
 */
+ (FileLog*) getTypeFileInstance;


@end