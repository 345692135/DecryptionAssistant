//
//  IConfig.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-8-6.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

// This is a config Protocol class - see the class methods below

#import <Foundation/Foundation.h>


/*!
    @enum WSConfigItem
    @abstract Values for key
    @constant WSConfigItemIP v3 server IP address
    @constant WSConfigItemPort v3 Server port number
    @constant WSConfigItemProductKey product key
    @constant WSConfigItemSystemStrategy return system strategy object
    This is a config item
 */
typedef enum
{
    WSConfigItemIP = 0x10,                  //V3 Server IP address 
    WSConfigItemPort = 0x20,                //V3 Server port
    WSConfigItemProductKey = 0x30,          //System init with product key
    WSConfigItemSystemStrategy = 0x40,      //System strategy
    WSConfigItemSystemPermission = 0x50,    //System Permission
    WSConfigItemMacAddress = 0x60,          //System Address
    WSConfigItemGuid = 0x70,                //System guid
    WSConfigInit = 0x80,                    //System init
}WSConfigItem;

@protocol IConfig <NSObject>

- (id)getValueByKey:(WSConfigItem)key;

- (void)setValueByKey:(WSConfigItem)key value:(id)data;

@end
