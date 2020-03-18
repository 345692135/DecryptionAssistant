//
//  ConsleLog.h
//  LogComponent
//
//  Created by nie on 12-7-24.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WS_ILog.h"

@interface ConsleLog : NSObject<WS_ILog>
{
    LogLevel logPrintLevel;         //log print level
}


/*!
    @method getTypeConsleInstance;
    @abstract Get the singleton object
    @param Null
    @result Return vaule singleton object 
 */
+ (ConsleLog*)getTypeConsleInstance;

@end
