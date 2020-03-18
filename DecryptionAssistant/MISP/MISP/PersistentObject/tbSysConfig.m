//
//  tbSysConfig.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-8-6.
//
//

#import "tbSysConfig.h"

@implementation tbSysConfig

@synthesize sysInitialized;
@synthesize systemStrategyData;
@synthesize systemAuthority;
@synthesize ip;
@synthesize prot;
@synthesize productKey;
@synthesize guid;

- (void)dealloc
{
    [systemStrategyData release];systemStrategyData = nil;
    [systemAuthority release];systemAuthority = nil;
    [ip release];ip = nil;
    [prot release];prot = nil;
    [productKey release];productKey = nil;
    [guid release];guid = nil;
    [super dealloc];
}

@end
