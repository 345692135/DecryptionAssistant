//
//  SystemStrategy.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-7-20.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

// This is a system strategy class ,used by get system strategy to strategy data in memory object - see the class methods below

#import "StrategyBase.h"
#import "SystemStrategyItem.h"

@interface SystemStrategy : StrategyBase
{
    
}

/*!
    @method getItemByGroupId:grpId
    @abstract Get strategy item by gorup id to follow nearest match
    @param grpId The strategy row's group id
    @result Return SystemStrategyItem object 
 */
-(NSArray*)getItemByGroupId:(NSString*)grpId;

/*!
    @method getItemByName:name
    @abstract Get strategy item by name to follow nearest match
    @param name The strategy row's name
    @result Return SystemStrategyItem object 
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

-(NSArray*)getSecPubKeybyGroupId:(NSString*)grpId secLevel:(NSString*)level;

-(NSArray*)getSecPrvKeybyGroupId:(NSString*)grpId secLevel:(NSString*)level;

-(NSDictionary*)getLevelNameListWithRandID:(NSArray*)list;

-(NSDictionary*)getSS5ConfigWithAppID:(NSString*)appId;

-(BOOL) check3gFlowUpLoad;

//  0729 ADD
-(BOOL) checkSafeTunelFlowLoad;

@end
