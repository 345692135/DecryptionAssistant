//
//  StrategyItemBase.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-7-21.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import "StrategyItemBase.h"

@implementation StrategyItemBase

@synthesize itemData;

- (id)getObjectWithKey:(NSString*)key
{
    return nil;
}   

- (NSString*)getLastModifyUserSid
{
    return nil;
}

- (NSString*)getModifyTime
{
    return nil;
}

- (void)dealloc
{
    [itemData release];itemData = nil;
    [super dealloc];
}
@end
