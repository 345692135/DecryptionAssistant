//
//  SystemStrategyItem.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-7-21.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

// This is a system strategy item class ,used by system strategy for get strategy item's strategy param value object  - see the class methods below

#import "StrategyItemBase.h"

@interface SystemStrategyItem : StrategyItemBase
{
    
}

/*!
    @method getParamValueObject
    @abstract Get param value from item
    @result Return value object (Type is maybe NSArray or NSDictionary)
 */
- (id)getParamValueObject;

@end
