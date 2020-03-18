//
//  SocketProxyManager.m
//  MISP
//
//  Created by Cooriyou on 13-7-16.
//  Copyright (c) 2013年 wondersoft. All rights reserved.
//

#import "SocketProxyManager.h"
#import "SocketProxy2.h"
#import "SocketProxy.h"
#import "ConfigManager.h"
#import "IConfig.h"
#import "SystemStrategy.h"
#import "AccountManagement.h"
#import "tbSysInfo.h"
#import "AppProxyCap.h"
#import "CredentialsManager.h"
#import "CustomHTTPProtocol.h"

#import <UIKit/UIKit.h>

#define LISTEN_PORT 3128
#define SS5_CONFIG_IN_USER_STRATEGY @"269025288"

@interface SocketProxyManager ()<CustomHTTPProtocolDelegate>


@property(nonatomic,retain) NSMutableDictionary* servicesList;
@property(atomic)BOOL isStart;
@property(atomic,retain)NSString* magip;
@property(atomic)long long safeTunleFlow;
@property (nonatomic, strong, readwrite) CredentialsManager *   credentialsManager; //tjw

@end

static SocketProxyManager* socketProxyManager = nil;

@implementation SocketProxyManager
@synthesize servicesList;
@synthesize isStart;
@synthesize magip;
@synthesize safeTunleFlow;

+ (SocketProxyManager*)getInstance
{
    @synchronized(self) {
        if (!socketProxyManager) {
            socketProxyManager = [NSAllocateObject([self class], 0, NULL) init];
        }
    }
    return socketProxyManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (socketProxyManager == nil) {
            socketProxyManager = [super allocWithZone:zone];
        }
    }
    return socketProxyManager;  // assignment and return on first allocation
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
    [self.servicesList removeAllObjects];
    self.servicesList = nil;
    self.magip = nil;
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self) {
        isStart = NO;
//        NSString*  systemVersion =  [[UIDevice currentDevice] systemVersion];
//        if ([systemVersion floatValue] <8)
//        {
//            [AppProxyCap activate];
//            [AppProxyCap setProxy:AppProxy_HTTP Host:@"127.0.0.1" Port:LISTEN_PORT];
//        }
//        else
        {
            [self CustomHTTPProtocolStart];
        }
        servicesList = [[NSMutableDictionary alloc]init];
        id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
        self.magip = [config getValueByKey:WSConfigItemIP];
        
    }
    return self;
}
#pragma mark -

-(BOOL)start{
    
    /* 0729 ADD ：设置初始值 */
    self.safeTunleFlow = self.getFlow;
    NSLog(@"SocketProxyManager safeTunleFlow:%lli",safeTunleFlow);
    
    if (isStart == YES) {
        return NO;
    }
    SocketProxy2* sp = [[SocketProxy2 alloc]initWithAcceptPort:LISTEN_PORT];
    NSNumber * port = [NSNumber numberWithInteger:LISTEN_PORT];
    [self.servicesList setObject:sp forKey:[port stringValue]];
    [sp release];
    
    /*目前只开一个端口
    NSArray* applist = [self getApplicationList];
    if ([applist count] == 0) {
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
      
      //  });
        
    }else{
        for(NSDictionary * dict in applist){
            
            NSString* localPort = [dict objectForKey:@"MOB_LOCAL_PORT_NUM_00"];
            NSString* remoteIp = [dict objectForKey:@"MOB_REMOTE_IP_ADDR_04"];
            NSString* remotePort = [dict objectForKey:@"MOB_REMOTE_PORT_NUM_00"];
            NSLog(@"LOCAL_PORT:<%@>, REMOTE_IP:<%@>, REMOTE_PORT:<%@>",localPort,remoteIp,remotePort);
            
            SocketProxy* sp = [[SocketProxy alloc]initWithAcceptPort:[localPort integerValue] remoteIp:remoteIp remotePort:[remotePort integerValue]];
            [self.servicesList setObject:sp forKey:localPort];
            
            [sp release];
        }

    }
     */
    
    isStart = YES;
    return YES;
}

-(BOOL)stop{
    [servicesList removeAllObjects];
    
    isStart = NO;
    
    /* 0729 ADD */
    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
    SystemStrategy* sysStrategy = [config getValueByKey:WSConfigItemSystemStrategy];
    
    BOOL isUpLoadSafeTunel = [sysStrategy checkSafeTunelFlowLoad];
    
    if (!isUpLoadSafeTunel){
        NSLog(@"dont save safe thnnel flow because not having upload safe tunel strategy!");
    }else if (self.safeTunleFlow <= 0){
        NSLog(@"通道stop时，通道流量 <= 0，不进行保存！");
    }else{
        NSLog(@"通道stop，保存通道流量。");
        [self saveSafeTunnelFlow:self.safeTunleFlow];   
    }
    
//    NSString*  systemVersion =  [[UIDevice currentDevice] systemVersion];
//    if ([systemVersion floatValue] <8)
//    {
//        [AppProxyCap setNoProxy];
//    }
//    else
    {
        [self CustomHTTPProtocolStop];
    }
    return YES;
}


- (NSString*)getMAGIp{

    return self.magip;
    
}

#pragma mark- 

//TODO:get application list
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

/* 0729 ADD */
#pragma mark - Logic

- (void)sumBitOperation:(long long)count{
    @synchronized(self)
    {
        if( count <=0 ||count > 4097){
            return;
        }
        self.safeTunleFlow += count;
        NSLog(@"^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^当前通道流量是： %llu !",self.safeTunleFlow);
    }
}

/**
    保存代理流量
 */
- (void)saveSafeTunnelFlow:(long long)count{
    @synchronized(self){
        tbSysInfo* info = (tbSysInfo*)[tbSysInfo findByPK:1];
        info.deviceFlowSafeTunnel = [NSString stringWithFormat:@"%lli",count ];
        NSLog(@"SocketProxyManager saveSafeTunnelFlow info.deviceFlowSafeTunnel:%@",info.deviceFlowSafeTunnel);
        [info save];
        [tbSysInfo clearCache];
    }
}


- (long long)getFlow{
    @synchronized(self){
        tbSysInfo* info = (tbSysInfo*)[tbSysInfo findByPK:1];
        long long tunleFlow_ = [info.deviceFlowSafeTunnel longLongValue] ;
        NSLog(@"SocketProxyManager getFlow:%lli",safeTunleFlow);
        [tbSysInfo clearCache];
        return tunleFlow_;
    }
}

#pragma - mark start customHTTPProtocol

- (void)CustomHTTPProtocolStart
{
//    NSString*  systemVersion =  [[UIDevice currentDevice] systemVersion];
//    if ([systemVersion floatValue] <8)
//    {
//        return;
//    }
    
    NSDictionary *dict = @{
                           @"SOCKSEnable" : @1,
                           @"SOCKSProxy" : @"127.0.0.1",
                           @"SOCKSPort" : @3128,
                           @"SOCKSProxyAuthenticated" : @0,
                           @"HTTPEnable" : @1,
                           @"HTTPProxy" :  @"127.0.0.1",
                           @"HTTPPort" :  @3128,
                           @"HTTPSEnable" : @1,
                           @"HTTPSProxy" :  @"127.0.0.1",
                           @"HTTPSPort" :  @3128,
                           
                           
                           };
    
    [CustomHTTPProtocol setProxyConfig:dict];
    self.credentialsManager = [[CredentialsManager alloc] init];
    [CustomHTTPProtocol setDelegate:self];
    if (YES) {
        [CustomHTTPProtocol start];
    }
    
}
- (void)CustomHTTPProtocolStop
{
//    NSString*  systemVersion =  [[UIDevice currentDevice] systemVersion];
//    if ([systemVersion floatValue] <8)
//    {
//        return;
//    }
    
    [CustomHTTPProtocol stop];
    
}

- (BOOL)customHTTPProtocol:(CustomHTTPProtocol *)protocol canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    NSLog(@"----------------canAuthenticateAgainstProtectionSpace---------" );
    
    assert(protocol != nil);
#pragma unused(protocol)
    assert(protectionSpace != nil);
    
    return [[protectionSpace authenticationMethod] isEqual:NSURLAuthenticationMethodServerTrust];
}

/*! Called by an CustomHTTPProtocol instance to request that the delegate process on authentication
 *  challenge. Will be called on the main thread. Unless the challenge is cancelled (see below)
 *  the delegate must eventually resolve it by calling -resolveAuthenticationChallenge:withCredential:.
 *  \param protocol The protocol instance itself; will not be nil.
 *  \param challenge The authentication challenge; will not be nil.
 */

- (void)customHTTPProtocol:(CustomHTTPProtocol *)protocol didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    NSLog(@"----------------didReceiveAuthenticationChallenge---------" );
    
    OSStatus            err;
    NSURLCredential *   credential;
    SecTrustRef         trust;
    SecTrustResultType  trustResult;
    
    // Given our implementation of -customHTTPProtocol:canAuthenticateAgainstProtectionSpace:, this method
    // is only called to handle server trust authentication challenges.  It evaluates the trust based on
    // both the global set of trusted anchors and the list of trusted anchors returned by the CredentialsManager.
    
    assert(protocol != nil);
    assert(challenge != nil);
    assert([[[challenge protectionSpace] authenticationMethod] isEqual:NSURLAuthenticationMethodServerTrust]);
    assert([NSThread isMainThread]);
    
    credential = nil;
    
    // Extract the SecTrust object from the challenge, apply our trusted anchors to that
    // object, and then evaluate the trust.  If it's OK, create a credential and use
    // that to resolve the authentication challenge.  If anything goes wrong, resolve
    // the challenge with nil, which continues without a credential, which causes the
    // connection to fail.
    
    trust = [[challenge protectionSpace] serverTrust];
    if (trust == NULL) {
        assert(NO);
    } else {
        err = SecTrustSetAnchorCertificates(trust, (__bridge CFArrayRef) self.credentialsManager.trustedAnchors);
        if (err != noErr) {
            assert(NO);
        } else {
            err = SecTrustSetAnchorCertificatesOnly(trust, false);
            if (err != noErr) {
                assert(NO);
            } else {
                err = SecTrustEvaluate(trust, &trustResult);
                if (err != noErr) {
                    assert(NO);
                } else {
                    if ( (trustResult == kSecTrustResultProceed) || (trustResult == kSecTrustResultUnspecified) ) {
                        credential = [NSURLCredential credentialForTrust:trust];
                        assert(credential != nil);
                    }
                    //credential = [NSURLCredential credentialForTrust:trust];
                }
            }
        }
    }
    
    [protocol resolveAuthenticationChallenge:challenge withCredential:credential];
}

/*! Called by an CustomHTTPProtocol instance to cancel an issued authentication challenge.
 *  Will be called on the main thread.
 *  \param protocol The protocol instance itself; will not be nil.
 *  \param challenge The authentication challenge; will not be nil; will match the challenge
 *  previously issued by -customHTTPProtocol:canAuthenticateAgainstProtectionSpace:.
 */

- (void)customHTTPProtocol:(CustomHTTPProtocol *)protocol didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    NSLog(@"----------------didCancelAuthenticationChallenge---------" );
    
    
}

/*! Called by the CustomHTTPProtocol to log various bits of information.
 *  Can be called on any thread.
 *  \param protocol The protocol instance itself; nil to indicate log messages from the class itself.
 *  \param format A standard NSString-style format string; will not be nil.
 *  \param arguments Arguments for that format string.
 */

- (void)customHTTPProtocol:(CustomHTTPProtocol *)protocol logWithFormat:(NSString *)format arguments:(va_list)arguments {
    
    return;
    NSString *  prefix;
    
    // protocol may be nil
    assert(format != nil);
    
    if (protocol == nil) {
        prefix = @"protocol ";
    } else {
        prefix = [NSString stringWithFormat:@"protocol %p ", protocol];
    }
    [self logWithPrefix:prefix format:format arguments:arguments];
}


- (void)logWithPrefix:(NSString *)prefix format:(NSString *)format arguments:(va_list)arguments
{
    assert(prefix != nil);
    assert(format != nil);
    NSString *body = [[NSString alloc] initWithFormat:format arguments:arguments];
    NSLog(@"%@ - %@", prefix, body);
    //    if (sAppDelegateLoggingEnabled) {
    //        NSTimeInterval  now;
    //        ThreadInfo *    threadInfo;
    //        NSString *      str;
    //        char            elapsedStr[16];
    //
    //        now = [NSDate timeIntervalSinceReferenceDate];
    //
    //        threadInfo = [self threadInfoForCurrentThread];
    //
    //        str = [[NSString alloc] initWithFormat:format arguments:arguments];
    //        assert(str != nil);
    //
    //        snprintf(elapsedStr, sizeof(elapsedStr), "+%.1f", (now - sAppStartTime));
    //
    //        fprintf(stderr, "%3zu %s %s%s\n", (size_t) threadInfo.number, elapsedStr, [prefix UTF8String], [str UTF8String]);
    //    }
}

#pragma - mark end customHTTPProtocol


@end
