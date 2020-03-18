//
//  SubmitSysteminformation.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-11-6.
//
//

#import "SubmitSysteminformation.h"
#import "ConfigManager.h"
#import "IConfig.h"
#import "CommandHelper.h"
#import "tbStrategy.h"
#import "AccountManagement.h"
#import "DeviceInfo.h"
#include <ftw.h>

static const char* jailbreak_apps[] =
{
    "/Applications/Cydia.app",
    "/Applications/limera1n.app",
    "/Applications/greenpois0n.app",
    "/Applications/blackra1n.app",
    "/Applications/blacksn0w.app",
    "/Applications/redsn0w.app",
    "/Applications/Absinthe.app",
    NULL,
};

@implementation SubmitSysteminformation
@synthesize access;
@synthesize step;
@synthesize err;
@synthesize isRecv;

- (void)commandResponse:(SystemCommand *)data
{
    @synchronized(self)
    {
        NSLog(@"submit system infomation commandResponse...");
        if (data == nil) {
            err = SYSTEM_NETWORK_TIMEOUT;
            [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
            isRecv = YES;
            return;
        }
        
        //wake up
        err = [[data getReturnCode]intValue];
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;

    }
    
}

- (id)init
{
    self = [super init];
    if (self) {
        id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
        NSString* ip0 = [config getValueByKey:WSConfigItemIP];
        NSString* port0 = [config getValueByKey:WSConfigItemPort];
        
        if (ip0 == nil || port0 == nil) {
            return nil;
        }
        TCPAccess* newAccess = [[TCPAccess alloc]init];
        self.access = newAccess;
        [newAccess release];
        
        [access setIpAddress:ip0];
        [access setPortNum:[port0 intValue]];
        [access setDelegate:self];
        step = 0;
        err = 0;
    }
    return self;
}


- (void)dealloc
{
    [access setDelegate:nil];
    [access release];access = nil;
    [super dealloc];
}

-(long) submit
{

    SystemCommand* cmd = [self createCommand];
    if (cmd == nil) {
        return SYSTEM_SETUP_CREATE_INIT_COMMAND_ERROR;
    }
    isRecv = NO;
    [access commandRequest:cmd];
    
    while (!isRecv)
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    [access disconnect];
    
    return err;
}

-(SystemCommand*)createCommand
{
    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
    NSString* guid = [config getValueByKey:WSConfigItemGuid];
    
    AccountManagement* accountManager = [AccountManagement getInstance];
    NSString* userSid = nil;
    userSid = [[accountManager getActiveAccount] userSid];
    
    DeviceInfo* devInfo = [DeviceInfo getInstance];
    
    NSDictionary* dev = [devInfo getDeviceBaseInfo];
    NSString* deviceName = [dev objectForKey:@"LOCALIZED_MODEL"];
    NSString* deviceType = [dev objectForKey:@"MODEL"];
    NSString* deviceOsVersion = [dev objectForKey:@"SYSTEM_VERSION"];
    
    NSString* xmlStr = [NSString stringWithFormat:@"<HEAD>\
                        <SIGN>111111111111111111111111111</SIGN>\
                        <MODULEID>900</MODULEID>\
                        <OPCODE>901</OPCODE>\
                        </HEAD>\
                        <DATA>\
                        <CLIENTTYPE>1</CLIENTTYPE>\
                        <DEVICETYPE>1000</DEVICETYPE>\
                        <ROM>1024M</ROM>\
                        <GUID>%@</GUID>\
                        <HASCRACK>%d</HASCRACK>\
                        <RAM>160000</RAM>\
                        <DEVICESIGN>%@</DEVICESIGN>\
                        <CPU>ARMv7</CPU>\
                        <OSSUBTYPE>IOS %@</OSSUBTYPE>\
                        <OSVERSION>%@</OSVERSION>\
                        <CLIENTVERSION>%@</CLIENTVERSION>\
                        <USERSID>%@</USERSID>\
                        <DEVICENAME>%@</DEVICENAME>\
                        <OSTYPE>1</OSTYPE>\
                        <DEVICESTATE/>\
                        <MANUFACTURER>Apple</MANUFACTURER>\
                        </DATA>\
                        ",guid,[self checkIsJailBroken],deviceType,deviceOsVersion,deviceOsVersion,SYSTEM_VERSION,userSid,deviceName];
    
    //TRACK(@"%@",xmlStr)
    
    NSData* xml = [NSData dataWithBytes:[xmlStr UTF8String] length:strlen([xmlStr UTF8String])];
    SystemCommand* command = [CommandHelper createCommandWithXMLData:xml isVerifyData:NO];
    
    return command;
}


-(void) wakeup
{
    [self setRecv];
//    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
//    [self performSelectorOnMainThread:@selector(setRecv) withObject:nil waitUntilDone:YES];
//    [pool release];
}

-(void)setRecv
{
    self.isRecv = YES;
}

#pragma mark --



//method 1
- (BOOL)hasAPT
{
    NSString *aptPath = @"/private/var/lib/apt/";
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:aptPath]) {
        return YES;
    }
    
    return NO;
}

//method 2
- (BOOL)isJailBroken
{
    // Now check for known jailbreak apps. If we encounter one, the device is jailbroken.
    
    for (int i = 0; jailbreak_apps[i] != NULL; ++i)
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:jailbreak_apps[i]]])
        {
            //NSLog(@"isjailbroken: %s", jailbreak_apps[i]);
            
            return YES;
        }
    }
    
    // TODO: Add more checks? This is an arms-race we're bound to lose.
    
    return NO;
}

//method 3
- (BOOL)successCallSystem
{
    return YES;
//    return (system("ls") == 0) ? YES : NO;
}

- (BOOL)checkIsJailBroken
{
    
    if ([self isJailBroken] == YES
        ||[self hasAPT] == YES
        ||[self successCallSystem] == YES) {
        return YES;
    }else
        return NO;
    
}



@end
