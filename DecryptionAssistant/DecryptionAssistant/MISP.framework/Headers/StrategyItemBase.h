//
//  StrategyItemBase.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-7-21.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

// This is a strategy item Base class - see the class methods below

#import "WSBaseObject.h"

@interface StrategyItemBase : WSBaseObject
{
    NSData* itemData; //strategy item data
}

@property(atomic,retain)NSData* itemData;

/*!
    @method GetObjectWithKey:key
    @abstract Get strategy value object with key from item
    @param key The xml node's tag name
    @result Return value object (Type is maybe NSArray or NSDictionary)
 */
- (id)getObjectWithKey:(NSString*)key;

/*!
    @method getLastModifyUserSid
    @abstract Get last modify user's sid value from item
    @result Return user's sid string
 */
- (NSString*)getLastModifyUserSid;

/*!
    @method getModifyTime
    @abstract Get last modify time from item
    @result Return time string with format eg. 2012-05-11 15:48:56
 */
- (NSString*)getModifyTime;



@end
