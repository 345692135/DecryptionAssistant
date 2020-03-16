//
//  UserStrategyItem.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-7-21.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

// This is a user strategy item class ,used by user strategy for get strategy item's strategy condition and target condition or action object  - see the class methods below

#import "StrategyItemBase.h"

@interface UserStrategyItem : StrategyItemBase
{
    
}

/*!
    @method getStrategyConditionObject
    @abstract Get strategy condition from item
    @result Return value object (Type is maybe NSArray or NSDictionary)
 */
- (id)getStrategyConditionObject;

/*!
    @method getTargetConditionObject
    @abstract Get target condition from item
    @result Return value object (Type is maybe NSArray or NSDictionary)
 */
- (id)getTargetConditionObject;

/*!
    @method getActionObject
    @abstract Get action from item
    @result Return value object (Type is maybe NSArray or NSDictionary)
 */
- (id)getActionObject;


@end
