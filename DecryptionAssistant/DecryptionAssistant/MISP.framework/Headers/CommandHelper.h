//
//  CommandHelper.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-8-5.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

// This is a command helper class ,used by to cope with system command object helper class -see the class methods below

#import "WSBaseObject.h"
#import "SystemCommand.h"

@interface CommandHelper : WSBaseObject

/*!
    @method createXMLDataWithCommand:command:b
    @abstract create xml data with command object
    @param command The command object
    @param b The yes is means to add command body sign filed
    @result Return xml data
 */
+ (NSData*)createXMLDataWithCommand:(SystemCommand*)command isSignData:(BOOL)b;

/*!
    @method createCommandWithXMLData:data:b
    @abstract create command command obeject
    @param data The xml data
    @param b The yes is means to verify command body sign filed
    @result Return command object
 */
+ (SystemCommand*)createCommandWithXMLData:(NSData*)data isVerifyData:(BOOL)b;

@end
