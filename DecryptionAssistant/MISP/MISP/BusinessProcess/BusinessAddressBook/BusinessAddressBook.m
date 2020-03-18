//
//  BusinessAddressBook.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-12-28.
//
//

#import "BusinessAddressBook.h"
#import "ConfigManager.h"
#import "IConfig.h"
#import "Context+Notify.h"
#import "CommandHelper.h"
#import "tbSysConfig.h"
#import "tbStrategy.h"


@implementation BusinessAddressBook
@synthesize access;
@synthesize step;
@synthesize err;
@synthesize isRecv;
@synthesize addressBook;

- (void)commandResponse:(SystemCommand *)data
{
    if (data == nil) {
        err = SYSTEM_NETWORK_TIMEOUT;
        isRecv = YES;
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
    if ([[data getReturnCode]intValue] != 0) {
        err = [[data getReturnCode]intValue];
        isRecv = YES;
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
    
    GDataXMLElement* element = [data getPackageDataObject];

    if (element == nil) {
        err = [[data getReturnCode]intValue];
        if (err == 0) {
            err = SYSTEM_INER_ERROR;
        }
        isRecv = YES;
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
    
    addressBook = [[GDataXMLElement alloc]initWithXMLString:[element XMLString] error:nil];

    err = 0;

    isRecv = YES;
    [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
    isRecv = YES;
}


- (GDataXMLElement* )getBusinessAddressBook
{
    @synchronized(self){
        err = 0;
        step = 0;
        isRecv = NO;
        
        //update system strategy
        SystemCommand* cmd = [self createCommand];
        if (cmd == nil) {
            return nil;
        }
        isRecv = NO;
        [access commandRequest:cmd];
        
        //wait recv
        while (!isRecv)
        {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        
//        Context* ctx = [Context getInstance];
//        if (err != 0) {
//            [ctx statusNotifyMessage:@"get business address book is failed" code:err];
//        }else{
//            [ctx statusNotifyMessage:@"get business address book is successed" code:err];
//        }
        
        [access disconnect];
    }
    TRACK(@"Package is %@",[self.addressBook XMLString]);
    return addressBook;
}

- (SystemCommand*)createCommand
{

    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
    NSString* guid = [config getValueByKey:WSConfigItemGuid];
    
    NSString* xmlStr = [NSString stringWithFormat:@"<HEAD>\
                        <SIGN>null</SIGN>\
                        <MODULEID>700</MODULEID>\
                        <OPCODE>703</OPCODE>\
                        </HEAD>\
                        <DATA>\
                        <LASTCHANGETIME>0</LASTCHANGETIME>\
                        <USERSID>%@</USERSID>\
                        <GUID>%@</GUID>\
                        </DATA>\
                        ",SYSTEM_DEFAULT_USER_SID,guid];
    
    TRACK(@"%@",xmlStr);
    
    NSData* xml = [NSData dataWithBytes:[xmlStr UTF8String] length:strlen([xmlStr UTF8String])];
    SystemCommand* command = [CommandHelper createCommandWithXMLData:xml isVerifyData:NO];
    
    return command;
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
    [addressBook release];addressBook = nil;
    [super dealloc];
}

-(void) wakeup
{
    //NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
    [self performSelectorOnMainThread:@selector(setRecv) withObject:nil waitUntilDone:YES];
    //[pool release];
}

-(void)setRecv
{
    step++;
}


@end
