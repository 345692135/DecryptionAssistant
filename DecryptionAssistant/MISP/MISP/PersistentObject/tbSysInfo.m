//
//  tbSysInfo.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-8-7.
//
//

#import "tbSysInfo.h"

@implementation tbSysInfo

@synthesize deviceName;
@synthesize deviceSn;
@synthesize deviceMacAddress;
@synthesize deviceType;
@synthesize deviceOsVersion;
@synthesize deviceFlow3g;
@synthesize deviceFlowWifi;
@synthesize deviceFlowSafeTunnel;

- (void)dealloc
{
    [deviceName release];deviceName = nil;
    [deviceSn release];deviceSn = nil;
    [deviceMacAddress release];deviceMacAddress = nil;
    [deviceType release];deviceType = nil;
    [deviceOsVersion release];deviceOsVersion = nil;
    [deviceFlow3g release];deviceFlow3g = nil;
    [deviceFlowWifi release];deviceFlowWifi = nil;
    [deviceFlowSafeTunnel release];deviceFlowSafeTunnel = nil;
    [super dealloc];
}

@end
