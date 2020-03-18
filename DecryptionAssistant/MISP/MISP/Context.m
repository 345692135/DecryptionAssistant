//
//  Context.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-8-8.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import "Context.h"
#import "EncryptSQLiteManager.h"
#import "ConfigManager.h"
#import "IConfig.h"
#import "AccountManagement.h"
#import "Reachability.h"
#import "SystemSetup.h"
#include <arpa/inet.h>

#import "HeartBeat.h"
#import "SubmitSysteminformation.h"
#import "updateProcess.h"

@interface Context ()
{
    id<CertificateKeyDelegate> ckDelegate;
    
//    id<IConfig> config;
//    AccountManagement* accountManager;
//    EncryptSQLiteManager* sqlite;
}

@property(atomic,retain)id<CertificateKeyDelegate> ckDelegate;
@property(atomic,retain)HeartBeat* heartBeat;

@end

@implementation Context

static Context* contextInstance = nil;
static NSString* ip = nil;
static NSString* portNum = nil;
static NSString* key = nil;
static id<ContextDelegate> m_deleage = nil;
static bool isInit = NO;

@synthesize ckDelegate;
@synthesize delegate;
@synthesize heartBeat;

#pragma mark singleton class method

+ (void)setIp:(NSString*)ipAddress prot:(NSString*)port
{
    if(ipAddress != nil && port != nil){
        [ipAddress retain];
        [ip release];
        ip = ipAddress;
        
        [port retain];
        [portNum release];
        portNum = port;
    }
    
}

+ (void)setProductKey:(NSString*)productKey
{
    if(productKey != nil){
        [productKey retain];
        [key release];
        key = productKey;
    }
}

+ (void)setContextDelegate:(id<ContextDelegate>)delegate
{
    if (delegate != nil) {
//        [delegate retain];
//        [m_deleage release];
        m_deleage = delegate;
    }
}

+ (Context*)getInstance
{
    @synchronized(self) {
        if (!contextInstance) {
            contextInstance = [NSAllocateObject([self class], 0, NULL) init];
        }
    }
    return contextInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (contextInstance == nil) {
            contextInstance = [super allocWithZone:zone];
        }
    }
    return contextInstance;  // assignment and return on first allocation
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
    [ip release];
    [portNum release];
    [key release];
 
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        if (isInit == YES) {
            return self;
        }
        //TO DO MODULE INIT OPT
        printf("welecom to mobile information security platform\n\t\t copyright © 2012 wondersoft\r\n");
        long lRet = 0;
        self.ckDelegate = nil;
        printf("System Init:\n");
        
        if (m_deleage != nil) {
            self.delegate = m_deleage;
        }
        
        lRet = [self sysInit];
        if (lRet == 0) {
            if (self.delegate != nil) {
                printf("System Init SUCCESS\n");
                [delegate statusNotify:@"Syetem init is successed" code:0];
            }else{
                printf("System Init SUCCESS\n");
            }
        }else{
            if (self.delegate != nil) {
                printf("System Init FAILED\n");
                [delegate statusNotify:@"Syetem init is failed" code:lRet];
                return nil;
            }else{
                printf("System Init FAILED\n");
                return nil;
            }
        }
        
    }
    isInit = YES;
    return self;
}

- (long)setKeyDriver:(id<CertificateKeyDelegate>)dirver error:(NSError**)err
{
    long lRet = 0;
    if (![dirver conformsToProtocol:@protocol(CertificateKeyDelegate)]) {
        [self makeError:err domain:@"it must conform to the 'CertificateKeyDelegate' protocol" errCode:0x1001];
        lRet = -1;
    }else{
        self.ckDelegate = dirver;
    }
    return lRet;
}

- (id<CertificateKeyDelegate>)getKeyDriver
{
    return self.ckDelegate;
}

- (long)changeIP:(NSString*)ipAddress port:(NSString*)portNumber
{
    if ([ipAddress length] == 0 || [portNumber length] == 0) {
        return -1;
    }
    [Context setIp:ipAddress prot:portNumber];
    
    long lRet = [self updateIpAddress];
    if (lRet == 0) {
        //add notification for change ip/port
        NSString* strMessage = @"IP and Port is change !";
        NSNotification* notify = [NSNotification notificationWithName:@"IP_PORT_CHANGED" object:strMessage];
        NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
        [notifyCenter postNotification:notify];
    }
    
    return lRet;
}

- (NSString*)getIPAddress
{
    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
    return [config getValueByKey:WSConfigItemIP];
}

- (NSString*)getPortNumber
{
    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
    return [config getValueByKey:WSConfigItemPort];
}

#pragma mark business process

- (long)sysInit
{
    long lRet = 0;
    
    //step 1
    printf("\tSQLite start.............................");
    [EncryptSQLiteManager getInstance];
    printf("OK\n");
    
    //step 2
    printf("\tSystem config start......................");
    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
    printf("OK\n");
    
    //step 3
    printf("\tSet ip and port start....................");
    lRet = [self updateIpAddress];
    if (lRet == 0) {
        printf("OK\n");
    }else{
        printf("ERROR\n");
        return SYSTEM_IP_PORT_ERROR; //ip is null
    }
    
    //step 4
    printf("\tSystem self detect start.................");
    NSNumber* hasInit = [config getValueByKey:WSConfigInit];
    printf("OK\n");
    if ([hasInit boolValue] == NO) { //init with server

        printf("\tSystem check product key.................");
        lRet = [self setProductKey];
        if (lRet != 0) {
            printf("ERROR\n");
            return SYSTEM_GET_PRODUCT_KEY_ERROR;
        }
        printf("OK\n");
        
        printf("\tSystem register to server start..........");
        
        //check wifi 3G
        lRet = [self checkNetwork];
        if (lRet != 0) {
            printf("ERROR\n");
            return SYSTEM_CANNOT_CONTENT_TO_INIT_SERVER;
        }
        
        //system setup with server
        SystemSetup* sysSetup =  [[SystemSetup alloc]init];
        lRet = [sysSetup beginSetup];
        //[sysSetup release];sysSetup = nil;
        if (lRet != 0) {
            printf("ERROR\n");
            return lRet;
        }
        
        printf("=================\t");
        SystemSetup* sysSetup2 =  [[SystemSetup alloc]init]; //add by yyf 20160419
        lRet = [sysSetup2 getMainServerIP];
        //[sysSetup2 release];sysSetup = nil;
        printf("lRet: %ld\n",lRet);
        if (lRet != 0) {
            printf("ERROR: getMainServerIP-%ld\n",lRet);
            //return lRet;
        }
        
        
        printf("OK\n");
        
    }
    
    //step 5
    printf("\tAccount management start.................");
    [AccountManagement getInstance];
    printf("OK\n");
    
    //step 6
    
    lRet = 0;
     if ([hasInit boolValue] == NO) {
         printf("\tSubmit system info start.................");
         SubmitSysteminformation* submitsysinfo = [[SubmitSysteminformation alloc]init];
         lRet = [submitsysinfo submit];
         if (lRet == 0) {
             //[submitsysinfo release];submitsysinfo=nil;
             printf("OK\n");
         }else{
             printf("ERROR\n");
             //[submitsysinfo release];submitsysinfo=nil;
             return lRet;
         }
     }
    //system init success
    [config setValueByKey:WSConfigInit value:[NSNumber numberWithBool:YES]];
    
    
    //step 7
    printf("\tStart heart beat start...................");
    HeartBeat* tmpHeartBeat = [[HeartBeat alloc]init];
    [tmpHeartBeat start];
    self.heartBeat = tmpHeartBeat;
    //[tmpHeartBeat release];tmpHeartBeat = nil;
    printf("OK\n");
    
    return 0;
}

#pragma mark tools method

- (long)setProductKey
{
    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
    if (key == nil) {
        return -1;
    }
    [config setValueByKey:WSConfigItemProductKey value:key];
    return 0;
}

- (long)updateIpAddress
{
    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];

    if (ip == nil && [config getValueByKey:WSConfigItemIP] == nil) {
        return -1;
    }

    if (portNum == nil && [config getValueByKey:WSConfigItemPort] == nil) {
        return -1;
    }
    
    if (ip != nil) {
        [config setValueByKey:WSConfigItemIP value:ip];
    }
    
    if (portNum != nil) {
        [config setValueByKey:WSConfigItemPort value:portNum];
    }
    
    if ([config getValueByKey:WSConfigItemIP] == nil || [config getValueByKey:WSConfigItemPort] == nil) {
        return -1;
    }
    return 0;
}

+ (BOOL)systemAlready
{
    [EncryptSQLiteManager getInstance];
    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
    NSNumber* hasInit = [config getValueByKey:WSConfigInit];
    return [hasInit boolValue];
}

- (long)checkNetwork
{
    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
    NSString* ip0 = [config getValueByKey:WSConfigItemIP];
    NSString* port0 = [config getValueByKey:WSConfigItemPort];
    
//    TRACK(@"ip: [%@] port : [%@]",ip0,port0);
    
    struct sockaddr_in address;
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
    address.sin_port = htons([port0 integerValue]);
    address.sin_addr.s_addr = inet_addr([ip0 UTF8String]);

    Reachability *reach = [Reachability reachabilityWithAddress:&address];
    if ([reach currentReachabilityStatus] == NotReachable) {
        return -1;
    }
    
    return 0;
}


@end
