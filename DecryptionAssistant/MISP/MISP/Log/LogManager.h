//
//  LogManager.h
//  LogComponent
//
//  Created by nie on 12-7-24.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WS_ILog.h"

@interface LogManager : NSObject

/*!
    @method getInstance;
    @abstract Get the singleton object
    @param Null
    @result Return vaule singleton object 
 */
+ (LogManager*) getInstance;

/*!
    @method getLogPrivder:nType
    @abstract Get logPrivder value object with nType from item
    @param nType The type of Log whether consle output or file write in
    @result Return vaule object (Type maybe NSLogTypeConsle or NSLogTypeFile)
 */
-(id<WS_ILog>) getLogPrivder:(LogType)nType;

@end
