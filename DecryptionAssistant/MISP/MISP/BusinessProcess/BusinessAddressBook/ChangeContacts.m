//
//  ChangeContacts.m
//  MISP
//
//  Created by Mr.Cooriyou on 13-3-4.
//
//

#import "ChangeContacts.h"
#import "ConfigManager.h"
#import "IConfig.h"
#import "CommandHelper.h"
#import "tbStrategy.h"
#import "AccountManagement.h"
#import "DeviceInfo.h"

@implementation ChangeContacts
@synthesize access;
@synthesize step;
@synthesize err;
@synthesize isRecv;

- (void)commandResponse:(SystemCommand *)data
{
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



-(long) changeContactsWithPhone:(NSString*)number mailbox:(NSString*)address
{
    SystemCommand* cmd = [self createCommandWithPhone:number mailbox:address];
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

-(SystemCommand*)createCommandWithPhone:(NSString*)number mailbox:(NSString*)address
{
    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
    NSString* guid = [config getValueByKey:WSConfigItemGuid];
    
    AccountManagement* accountManager = [AccountManagement getInstance];
    NSString* userSid = nil;
    userSid = [[accountManager getActiveAccount] userSid];
    
    NSString* xmlStr = [NSString stringWithFormat:@"<HEAD>\
                        <SIGN>null</SIGN>\
                        <MODULEID>700</MODULEID>\
                        <OPCODE>705</OPCODE>\
                        </HEAD>\
                        <DATA>\
                        <USERSID>%@</USERSID>\
                        <PHONENUM>%@</PHONENUM>\
                        <EMAIL>%@</EMAIL>\
                        <GUID>%@</GUID>\
                        </DATA>\
                        ",userSid,number,address,guid];
    
    //    TRACK(@"%@",xmlStr)
    
    NSData* xml = [NSData dataWithBytes:[xmlStr UTF8String] length:strlen([xmlStr UTF8String])];
    SystemCommand* command = [CommandHelper createCommandWithXMLData:xml isVerifyData:NO];
    
    return command;
}


-(void) wakeup
{
    //NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
    [self performSelectorOnMainThread:@selector(setRecv) withObject:nil waitUntilDone:YES];
    //[pool release];
}

-(void)setRecv
{
    self.isRecv = YES;
}

@end
