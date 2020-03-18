//
//  ConfigManager.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-8-6.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import "ConfigManager.h"
#import "DefaultConfigPrivder.h"

@interface ConfigManager()
{
    id<IConfig> config;
}

@property(atomic,retain)id<IConfig> config;

@end

@implementation ConfigManager

static ConfigManager* cfgManagerInstance = nil;

@synthesize config;

#pragma mark singleton class method

+ (ConfigManager*)getInstance
{
    @synchronized(self) {
        if (!cfgManagerInstance) {
            cfgManagerInstance = [NSAllocateObject([self class], 0, NULL) init];
        }
    }
    return cfgManagerInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (cfgManagerInstance == nil) {
            cfgManagerInstance = [super allocWithZone:zone];
        }
    }
    return cfgManagerInstance;  // assignment and return on first allocation
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSIntegerMax;
}

- (id)autorelease
{
    return self;
}

- (oneway void)release
{
    //DO Nothing
}
- (id)copyWithZone:(NSZone*)zone
{
    return self;
}

- (void)dealloc
{
    [config release];config = nil;
    [super dealloc];
}

- (id<IConfig>)getConifgPrivder
{
    if (self.config != nil) {
        return [self config];
    }
    
    id<IConfig> configPrivder = [[DefaultConfigPrivder alloc]init];
    self.config = configPrivder;
    [configPrivder release];configPrivder = nil;
    return [self config];
}

@end
