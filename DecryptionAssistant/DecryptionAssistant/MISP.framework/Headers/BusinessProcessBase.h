//
//  BusinessProcessBase.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-7-21.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

// This is a Business Process base class - see the class methods below

#import "WSBaseObject.h"


@interface BusinessProcessBase : WSBaseObject
{
    
}

/*!
    @method getModuleId
    @abstract Get Module ID
    @result Return Module ID 
 */
+ (MODULEID)getModuleId;

void WSLog(NSString*format, ...);

@end
