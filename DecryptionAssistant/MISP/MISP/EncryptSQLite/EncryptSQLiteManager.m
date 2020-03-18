//
//  EncryptSQLiteManager.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-8-7.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import "EncryptSQLiteManager.h"
#import "SQLiteInstanceManager.h"
#import "DeviceInfo.h"
#import "tbSysConfig.h"
#import "tbAccount.h"
#import "tbStrategy.h"
#import "tbSysInfo.h"
#import "SvUDIDTools.h"

@implementation EncryptSQLiteManager
@synthesize bInitialized;

static EncryptSQLiteManager* encsqliteInstance = nil;

#pragma mark singleton class method

+ (EncryptSQLiteManager*)getInstance
{
    @synchronized(self) {
        if (!encsqliteInstance) {
            encsqliteInstance = [NSAllocateObject([self class], 0, NULL) init];
        }
    }
    return encsqliteInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (encsqliteInstance == nil) {
            encsqliteInstance = [super allocWithZone:zone];
        }
    }
    return encsqliteInstance;  // assignment and return on first allocation
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

- (id)init
{
    self = [super init];
    if (self) {
        //To do init system database
        NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory=[paths objectAtIndex:0];
        NSString *dbPath=[NSString stringWithFormat:@"%@/%@",documentsDirectory,@"sys.db"];
        //step 1 init database
        [[SQLiteInstanceManager sharedManager] setDatabaseFilepath:dbPath];
        //step 2 init sys config table
        [self initSysConfigTable];
        //step 3 init account table
        [self initAccountTable];
        //step 4 init system info table
        [self initSystemInfoTable];
        //step 5 init user strategy table
        [self initStrategyTable];
    }
    return self;
}

- (void)initSysConfigTable
{
    //step 1 check database is never init
    NSArray* arry = [tbSysConfig allObjects];
    if ([arry count] != 0) {
        return;
    }
    //step 2 init system config table
    tbSysConfig* sysconfig = [[tbSysConfig alloc]init];
    sysconfig.sysInitialized = 0;
    [sysconfig save];
    [sysconfig release];
    sysconfig = nil;
    [tbSysConfig clearCache];
}

- (void)initAccountTable
{
    //step 1 check database is never init
    NSArray* arry = [tbAccount allObjects];
    if ([arry count] != 0) {
        return;
    }
    //step 2 init system config table
    tbAccount* account = [[tbAccount alloc]init];
    account.userSid = [NSString stringWithFormat:@"%@",@"86108274-39398501-00000000-00000000"]; //system default user
    account.userCertMd5 = @"00000000000000000000000000000000";
    account.userAccountName = @"86108274-39398501-00000000-00000000";
    account.userAccountPasswordMd5 = @"00000000000000000000000000000000";
    account.userCertCn = @"00000000000000000000000000000000";
    account.userAccountPasswordSha1 = @"00000000000000000000000000000000";
    [account save];
    [tbAccount clearCache];
    [account release];
    account = nil;
}

- (void)initStrategyTable
{
    //step 1 check database is never init
    NSArray* arry = [tbStrategy allObjects];
    if ([arry count] != 0) {
        return;
    }
    //step 2 init user strategy table
    tbStrategy* strategy = [[tbStrategy alloc]init];
    strategy.strategySid = [NSString stringWithFormat:@"%@",@"86108274-39398501-00000000-00000000"];
    [strategy save];
    [tbStrategy clearCache];
    [strategy release];
    strategy = nil;
}

- (void)initSystemInfoTable
{
    //step 1 check database is never init
    NSArray* arry = [tbSysInfo allObjects];
    if ([arry count] != 0) {
        return;
    }
    //step 2 get system info
    DeviceInfo* devInfo = [DeviceInfo getInstance];
    NSDictionary* dic = [devInfo getDeviceBaseInfo];
    //step 3 init system config table
    tbSysInfo* sysInfo = [[tbSysInfo alloc]init];
    sysInfo.deviceName = [dic objectForKey:@"LOCALIZED_MODEL"];
    sysInfo.deviceType = [dic objectForKey:@"MODEL"];
    sysInfo.deviceOsVersion = [dic objectForKey:@"SYSTEM_VERSION"];
    sysInfo.deviceSn = [dic objectForKey:@"UNIQUE_ID"];
    sysInfo.deviceFlow3g = [NSString stringWithFormat:@"0"];
    sysInfo.deviceFlowSafeTunnel = [NSString stringWithFormat:@"0"];
    sysInfo.deviceFlowWifi = [NSString stringWithFormat:@"0"];
    //modify by liguixi 解决ios7设备关联问题
    if ([[[UIDevice currentDevice]systemVersion]floatValue]>=7.0) {
        sysInfo.deviceMacAddress = [SvUDIDTools UDID];
    }
    else
    {
        sysInfo.deviceMacAddress = [devInfo getMacAddress];
    }
    NSLog(@"sysInfo.deviceMacAddress。。。。。%@",sysInfo.deviceMacAddress);
    [sysInfo save];
    [sysInfo release];
    sysInfo = nil;
    [tbSysInfo clearCache];
}

@end
