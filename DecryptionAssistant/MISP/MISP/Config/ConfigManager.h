//
//  ConfigManager.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-8-6.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//
// This is a config management class ,is a singleton class object Can use to get Config Privder - see the class methods below

#import <Foundation/Foundation.h>
#import "IConfig.h"

@interface ConfigManager : NSObject

/*!
    @method getInstance
    @abstract Get config management instance
    @result Return config management singleton class object
 */
+ (ConfigManager*)getInstance;

/*!
    @method getConifgPrivder
    @abstract Get config privder instance
    @result return config privder singleton class object
 */
- (id<IConfig>)getConifgPrivder;

@end
