//
//  FlowStatistics.m
//  MISP
//
//  Created by Mr.Cooriyou on 13-3-16.
//
//

#import "FlowStatistics.h"
#import "ConfigManager.h"
#import "IConfig.h"
#import "CommandHelper.h"
#import "tbStrategy.h"
#import "AccountManagement.h"
#import "DeviceInfo.h"
#import "tbSysInfo.h"
#import "SystemStrategy.h"

#import "arpa/inet.h"
#import "net/if.h"
#import "ifaddrs.h"
#import "net/if_dl.h"
#import "ifaddrs.h"
#import "SocketProxyManager.h"

@interface FlowStatistics(){

}

@property(atomic) BOOL  isUpLoadSafeTunelFlow;
@property(atomic) BOOL  isUpLoad3GFlow;
@end

@implementation FlowStatistics
@synthesize access;
@synthesize step;
@synthesize err;
@synthesize isRecv;
@synthesize isUpLoadSafeTunelFlow;
@synthesize isUpLoad3GFlow;

- (void)commandResponse:(SystemCommand *)data
{
    if (data == nil) {
        err = SYSTEM_NETWORK_TIMEOUT;
        [NSThread detachNewThreadSelector:@selector(wakeup) toTarget:self withObject:nil];
        isRecv = YES;
        return;
    }
    
    //set 3g flow value from database
    
    uint32_t ui_3gFlowValue = [self getCurrentNetworkflow];
    if (ui_3gFlowValue != 0) {
        
        tbSysInfo* info = (tbSysInfo*)[tbSysInfo findByPK:1];
        info.deviceFlow3g = [NSString stringWithFormat:@"%u",ui_3gFlowValue];
        [info save];
        [tbSysInfo clearCache];
        
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

-(long) submit
{
    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
    SystemStrategy* sysStrategy = [config getValueByKey:WSConfigItemSystemStrategy];
    
    isUpLoad3GFlow = [sysStrategy check3gFlowUpLoad];
    /* 0729 ADD */
    isUpLoadSafeTunelFlow = [sysStrategy checkSafeTunelFlowLoad];
    
    if (isUpLoad3GFlow == NO && isUpLoadSafeTunelFlow == NO) {
        TRACK(@"do not upload 3G Flow")
        TRACK(@"do not upload SafeTunel Flow")
        [access disconnect];
        return err;
    }
    TRACK(@"upload 3G Flow")
    
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
    
    // 0729 ADD 
    if (isUpLoadSafeTunelFlow  && err == 0){
        //comit 成功 清除数据库数据
        [[SocketProxyManager getInstance]saveSafeTunnelFlow:0];
        NSLog(@"comit 成功 清除数据库数据");
    }
    
    return err;
}

-(SystemCommand*)createCommand
{
    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
    NSString* guid = [config getValueByKey:WSConfigItemGuid];
    
    AccountManagement* accountManager = [AccountManagement getInstance];
    NSString* userSid = nil;
    userSid = [[accountManager getActiveAccount] userSid];
   
    //get 3g flow value from database
    
    tbSysInfo* info = (tbSysInfo*)[tbSysInfo findByPK:1];
    

    NSString* g3FlowValue = @"0.0";
    if(self.isUpLoad3GFlow == YES){
       g3FlowValue = [info deviceFlow3g];
    }
    uint32_t uint_3gFlowValue = 0;
    float f_3gFlowValue = 0;
    
    if ([g3FlowValue length] != 0) {
        uint_3gFlowValue = (uint32_t)[g3FlowValue longLongValue];
    }
    
    [tbSysInfo clearCache];

    if (isUpLoad3GFlow == YES){
        f_3gFlowValue = [self g3flowIncrement:uint_3gFlowValue];
    }
    //  0729 ADD
    float f_safeTunleFlowValue = 0;
    if (YES == isUpLoadSafeTunelFlow){
       long long safeTunelValue = [[SocketProxyManager getInstance] getFlow];
        NSLog(@"createCommand safeTunelValue:%lli",safeTunelValue);
        f_safeTunleFlowValue = (float)(safeTunelValue / (1024.0f * 1024.0f));
        NSLog(@"createCommand f_safeTunleFlowValue:%0.2f",f_safeTunleFlowValue);

    }
    
    
    NSString* xmlStr = [NSString stringWithFormat:@"<HEAD>\
                        <SIGN/>\
                        <MODULEID>900</MODULEID>\
                        <OPCODE>905</OPCODE>\
                        </HEAD>\
                        <DATA>\
                        <CHANNEL>%0.2f</CHANNEL>\
                        <G3>%f</G3>\
                        <TIMEUTC/>\
                        <GUID>%@</GUID>\
                        <USERSID>%@</USERSID>\
                        </DATA>\
                        ",f_safeTunleFlowValue,f_3gFlowValue,guid,userSid];
    
    TRACK(@"%@",xmlStr)
    
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
-(uint32_t)getCurrentNetworkflow//得到当前的流量值，即是每次从系统中统计出来的流量值
{
    struct ifaddrs *ifa_list = 0, *ifa;
    if (getifaddrs(&ifa_list) == -1)
    {
        NSLog(@"获取失败");
        return -1;
    }
    uint32_t wwanIBytes = 0;
    uint32_t wwanOBytes = 0;
    uint32_t wwanFlow   = 0;
    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next)
    {
        if (AF_LINK != ifa->ifa_addr->sa_family)
            continue;
        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING))
            continue;
        if (ifa->ifa_data == 0)
            continue;
        if (!strcmp(ifa->ifa_name, "pdp_ip0"))
        {
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            wwanIBytes += if_data->ifi_ibytes;
            wwanOBytes += if_data->ifi_obytes;
            wwanFlow    = wwanIBytes + wwanOBytes;
        }
    }
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd-HH-mm-ss"];
    [formatter release];
    return wwanFlow;//在调用的时候，需要判断一下返回的值，如果是零的话....数据库中的值就不变(防止的是用一段时间后，将3G模式关闭，然后再开启)
}

-(float) g3flowIncrement:(uint32_t) fromDatabaseValue//返回增量,需要传从数据库读出来的数据
{
    uint32_t currentFlowValue = [self getCurrentNetworkflow];
    
    if (currentFlowValue == 0) {
        return 0;
    }
    
    if(fromDatabaseValue > [self getCurrentNetworkflow])//数据库里面的值大于当前流量值
    {
        return (float)currentFlowValue/(1024*1024);
    }
    else//当数据库里面的值小于等于当前流量的值时
    {
        return (float)(currentFlowValue - fromDatabaseValue)/(1024*1024);//返回的是M
    }
    
}

@end
