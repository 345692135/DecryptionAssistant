//
//  UserStrategy.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-7-20.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

// This is a user strategy class ,used by get user strategy to strategy data in memory object - see the class methods below

#import "StrategyBase.h"
#import "UserStrategyItem.h"

@interface UserStrategy : StrategyBase
{
    
}

/*!
    @method getItemByGroupId:grpId
    @abstract Get strategy item by gorup id to follow nearest match
    @param grpId The strategy row's group id
    @result Return GDataElements object 
 */
-(NSArray*)getItemByGroupId:(NSString*)grpId;

/*!
    @method getItemByName:name
    @abstract Get strategy item by name to follow nearest match
    @param name The strategy row's name
    @result Return GDataElements object 
 */
-(NSArray*)getItemByName:(NSString*)name;

/*!
    @method getItemByXpathString:str
    @abstract Get strategy item by Xpath to match
    @param str The strategy xpath
    @result Return GDataElements object
 */
-(NSArray*)getItemByXpathString:(NSString*)str;


#pragma mark Tools method

-(NSArray*)getSecLevelbyGroupId:(NSString*)grpId level:(NSString*)name;

-(NSArray*) analysisStrategyForLevelKey:(NSArray*)rows;

-(NSArray*) analysisStrategyForEmailKey:(NSArray*)rows;

-(NSArray*) analysisStrategyForEmailAttachedFileKey:(NSArray*)rows;

-(NSArray*) analysisStrategyForSS5Key:(NSArray*)rows;

@end
