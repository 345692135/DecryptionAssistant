//
//  SafeTunnel.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-12-17.
//
//

#import "SafeTunnel.h"
#import "ConfigManager.h"
#import "IConfig.h"

#import "stdafx.h"
#import "Main.h"

#import "SystemStrategy.h"
#import "AccountManagement.h"

#define SS5_CONFIG_IN_USER_STRATEGY @"269025288"

@interface SafeTunnel()

@property(atomic)BOOL isStart;

@end


static SafeTunnel* safeTunnelInstance = nil;
int st;
@implementation SafeTunnel
@synthesize isStart;

#pragma mark singleton class method

+ (SafeTunnel*)getInstance
{
    @synchronized(self) {
        if (!safeTunnelInstance) {
            safeTunnelInstance = [NSAllocateObject([self class], 0, NULL) init];
        }
    }
    return safeTunnelInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (safeTunnelInstance == nil) {
            safeTunnelInstance = [super allocWithZone:zone];
        }
    }
    return safeTunnelInstance;  // assignment and return on first allocation
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
    [super dealloc];
}

#pragma mark -

- (id)init
{
    self = [super init];
    if (self) {
        self.isStart = NO;
    }
    return self;
}

-(void)start
{
    if (isStart == YES) {
        [self stop];
    }
    
    [NSThread detachNewThreadSelector:@selector(proxyStart) toTarget:self withObject:nil];
    isStart = YES;
}

-(void)stop
{
    isStart = NO;
    [NSThread detachNewThreadSelector:@selector(proxyStop) toTarget:self withObject:nil];
}

-(void) proxyStart
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
    NSString* ip = [config getValueByKey:WSConfigItemIP];
    
    const char* server_ip = [ip UTF8String];
    NSLog(@"proxy server ip:%@",ip);
    char* server_port = "50022";
    char *sessonID = "11111111111111111111111111111111";
    char *key = "1111111111111111";
    
    //get ss5 config
    
    SystemAccount* account = [[AccountManagement getInstance]getActiveAccount];
    if (account == nil) {
        [pool release];
        return;
    }
    
    UserStrategy* userStrategy = [account getStrategy];
    
    NSArray* array = [userStrategy getItemByGroupId:SS5_CONFIG_IN_USER_STRATEGY];
    if ([array count] == 0) {
        TRACK(@"ss5 config list is null group is 269025288");
        [pool release];
        return;
    }
    
    NSArray* appIds = [userStrategy analysisStrategyForSS5Key:array];
    if ([appIds count] == 0) {
         TRACK(@"ss5 config appids is null group is 269025288");
        [pool release];
        return;
    }
    SystemStrategy* systemStrategy = [config getValueByKey:WSConfigItemSystemStrategy];
    NSMutableString* configString = [[NSMutableString alloc]init];
    for (NSObject* obj in appIds)
    {
        NSDictionary* dic = [systemStrategy getSS5ConfigWithAppID:(NSString*)obj];
        TRACK(@"%@",dic)
        if ([dic count] == 0) {
            continue;
        }
        //9999 192.168.4.239 80 1 ssss /servlet
        [configString appendFormat:@"%@ %@ %@ 1 %@ %@\r\n",
         [dic objectForKey:@"MOB_LOCAL_PORT_NUM_00"],
         [dic objectForKey:@"MOB_REMOTE_IP_ADDR_04"],
         [dic objectForKey:@"MOB_REMOTE_PORT_NUM_00"],
         [dic objectForKey:@"MOB_APP_NAME_10"],
         [dic objectForKey:@"MOB_APP_ATTACH_PATH_10"]];
    }
    
    if ([configString length] == 0) {
        [pool release];
        return;
    }
    
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory=[paths objectAtIndex:0];
    NSString *configmapPath=[NSString stringWithFormat:@"%@/%@",documentsDirectory,@"configmap.ini"];
    NSError* err = nil;
    [configString writeToFile:configmapPath atomically:YES encoding:NSUTF8StringEncoding error:&err];
    [configString release];

    
    VPN_PROXY_CONFIGINI pConfigInfo;
    memset(&pConfigInfo, 0,sizeof(VPN_PROXY_CONFIGINI));
    memcpy(pConfigInfo.serverip, server_ip, strlen(server_ip));
    memcpy(pConfigInfo.serverport, server_port, strlen(server_port));
    
    NSString* path = [[NSBundle mainBundle]resourcePath];
    
    tisProxyStart(&pConfigInfo, (char*)[documentsDirectory UTF8String], sessonID, key, &st);
    
    [pool release];
}

-(void) proxyStop
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//    tisProxyStop();
    [pool release];
}

-(NSArray*)getApplicationList
{

    NSMutableArray* applicationlist = [[[NSMutableArray alloc]init]autorelease];
    
    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
    //get ss5 config
    SystemAccount* account = [[AccountManagement getInstance]getActiveAccount];
    if (account == nil) {
        return nil;
    }
    
    UserStrategy* userStrategy = [account getStrategy];
    NSArray* array = [userStrategy getItemByGroupId:SS5_CONFIG_IN_USER_STRATEGY];
    if ([array count] == 0) {
        TRACK(@"ss5 config list is null group is 269025288");
        return nil;
    }
    
    NSArray* appIds = [userStrategy analysisStrategyForSS5Key:array];
    if ([appIds count] == 0) {
        TRACK(@"ss5 config appids is null group is 269025288");
        return nil;
    }
    
    SystemStrategy* systemStrategy = [config getValueByKey:WSConfigItemSystemStrategy];
    
    for (NSObject* obj in appIds)
    {
        NSDictionary* dic = [systemStrategy getSS5ConfigWithAppID:(NSString*)obj];
        TRACK(@"%@",dic)
        if ([dic count] == 0) {
            continue;
        }
//         [dic objectForKey:@"MOB_LOCAL_PORT_NUM_00"],
//         [dic objectForKey:@"MOB_REMOTE_IP_ADDR_04"],
//         [dic objectForKey:@"MOB_REMOTE_PORT_NUM_00"],
//         [dic objectForKey:@"MOB_APP_NAME_10"],
//         [dic objectForKey:@"MOB_APP_ATTACH_PATH_10"]];
        [applicationlist addObject:dic];
    }
    
    return applicationlist;
}

@end
