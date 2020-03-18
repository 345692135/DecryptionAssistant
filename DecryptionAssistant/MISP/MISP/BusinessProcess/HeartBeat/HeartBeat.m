//
//  HeartBeat.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-9-12.
//
//

#import "HeartBeat.h"
#import "ConfigManager.h"
#import "IConfig.h"
#import "SystemStrategy.h"
#import "AccountManagement.h"
#import "UserAccount.h"
#import "UserSrategyHelper.h"

#define DELETE_DATA_ENABLE_KEY_GROUPID_IN_SYSTEM_STRATEGY @"537460738"
#define DEVICE_IS_LOST                          4214 //心跳中的设备挂失标记

@implementation HeartBeat
@synthesize udp;
@synthesize timer;
@synthesize count;

#pragma mark UDP protocol

-(void)commandResponse:(SystemCommand *)data
{
    //TRACK(@"mark---------------%@",[[[data body]rootElement]stringValue]);
    NSString* head = [[[data head]rootElement]XMLString];
    if ([head length] == 0) {
        count = 0;
        return;
    }
    
    //TRACK(@"HEART HEAD:%@",head)
    //TRACK(@"HEART BODY:%@",[[[data body]rootElement]XMLString])
    
    NSRange range;
    //NSString * responseString =[NSString stringWithFormat:@"<RESPONSE>4214</RESPONSE>",DEVICE_IS_LOST];
    BOOL deleteEnable = NO;;//记录是否需要擦除数据
    //NSLog(@"responseString:%@\n head:%@",responseString,head);
    
    range = [head rangeOfString:@"<RESPONSE>4214</RESPONSE>"];
    /* Step 3:根据相应策略数据返回结果 */
    if (range.length > 0) {
        NSLog(@"range.length>0");
        deleteEnable = [self deleteDataIsEnableOfSystemStrategy];
        //擦出数据后，通知相关组建。
        if(deleteEnable){
            NSLog(@"deleteEnable Value is YES");
            [self noticeHaveDeleteAllContents];
        }
        //如果没有删除策略
        else{
            NSLog(@"without delete strategy..");
            return;
        }
    }
    
    range = [head rangeOfString:@"<RESPONSE>0</RESPONSE>"];
    if (range.length == 0) {
        TRACK(@"HEART_ERROR:%@",head)
        NSString* strMessage = @"heart beat error !";
        NSNotification* notify = [NSNotification notificationWithName:@"HEART_BEAT_ERROR" object:strMessage];
        NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
        [notifyCenter postNotification:notify];
        [self stop];
    }
    count = 0;
    return;
}

#pragma mark

- (id)init
{
    self = [super init];
    if (self) {
        
        id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
        NSString* ip0 = [config getValueByKey:WSConfigItemIP];
        NSString* port0 = [config getValueByKey:WSConfigItemPort];
        NSInteger port1 = ([port0 integerValue]+1);
                
        UDPAccess* tmpUdp = [[UDPAccess alloc]init];
        [tmpUdp setIpAddress:ip0];
        [tmpUdp setPortNum:port1];
        [tmpUdp setDelegate:self];
        self.udp = tmpUdp;
        [tmpUdp release];
        tmpUdp = nil;
        
        //add observer
        NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
        [notifyCenter addObserver:self selector:@selector(restart) name:@"IP_PORT_CHANGED" object:nil];
        
    }
    return self;
}

- (void)dealloc
{
    self.udp = nil;
    [timer invalidate];
    self.timer = nil;
    [super dealloc];
}

#pragma mark heart beat control

- (void)start
{
    [self setHeartBeatTimer];
}

- (void)stop
{
    [timer invalidate];
}

- (void)restart
{
    [self stop];
    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
    NSString* ip0 = [config getValueByKey:WSConfigItemIP];
    NSString* port0 = [config getValueByKey:WSConfigItemPort];
    NSInteger port1 = ([port0 integerValue]+1);
    [self.udp setIpAddress:ip0];
    [self.udp setPortNum:port1];
    
    [self start];
    
    printf("\n\theart beat is restart................OK\nIP:[%s],Port:[%ld]\n",[ip0 UTF8String],port1);
}

#pragma mark heart beat set timer

-(void) setHeartBeatTimer
{
    count = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(sendCommand) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (long)sendCommand
{
    NSLog(@"Heart Beat Every 30s...(After Start)");
    if (count < 10) {
        id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
        NSString* guid = [config getValueByKey:WSConfigItemGuid];
        
        NSString* utc = [NSString stringWithFormat:@"%0.f",[[NSDate date]timeIntervalSince1970]];
        
        NSString* sid = nil;
        AccountManagement* accountManager = [AccountManagement getInstance];
        
        if ([[accountManager getActiveAccount] account_st] == WSAccountStatusOnline ) {
            sid = [[accountManager getActiveAccount]userSid];
        }else{
            sid = SYSTEM_DEFAULT_USER_SID;
        }
        
        NSString* xmlStr = [NSString stringWithFormat:@"<HEAD>\
                            <OPCODE>201</OPCODE>\
                            <MODULEID>200</MODULEID>\
                            </HEAD>\
                            <DATA>\
                            <TIMEUTC>%@</TIMEUTC>\
                            <AUTHORSTRATEGYSHA1>6A28F2090D8F84D979B204261A5C7502D577CF5D</AUTHORSTRATEGYSHA1>\
                            <GUID>%@</GUID>\
                            <USERSID>%@</USERSID>\
                            <USERLIST>%@</USERLIST>\
                            </DATA>",utc,guid,sid,[self makeUserList]];
 
        //NSString* xmlStr1 = [NSString stringWithFormat:@"123"];
                //TRACK(@"%@",xmlStr);
        NSData* xml = [NSData dataWithBytes:[xmlStr UTF8String] length:strlen([xmlStr UTF8String])];

        SystemCommand* command = [CommandHelper createCommandWithXMLData:xml isVerifyData:NO];
        
        [self.udp commandRequest:command];

        //        TRACK(@"heart beat is send");
        ++count;
    }else{
        [timer invalidate];
        TRACK(@"heart beat time out");
        
        //add notification for heart beat time out
        NSString* strMessage = @"heart beat time out !";
        NSNotification* notify = [NSNotification notificationWithName:@"HEART_BEAT_TIMEOUT" object:strMessage];
        NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
        [notifyCenter postNotification:notify];
        
    }
    
    
    return 0;
}


#pragma mark tools function

- (NSString*)makeUserList
{
    
    NSString* userList = nil;
    
    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
    SystemStrategy* systemStrategy = [config getValueByKey:WSConfigItemSystemStrategy];
    
    AccountManagement* accountManager = [AccountManagement getInstance];
    
    NSString* defaultUserStrategySha1 = [[[accountManager getDefaultAccount]getStrategy]getStrategySHA1];
    NSString* systemStrategySha1 = [systemStrategy getStrategySHA1];
    NSString* userStrategySha1 = nil;
    NSString* userSid = nil;
    
    //TRACK(@"System Sha1 is :%@",[systemStrategy getStrategySHA1]);
    //TRACK(@"Default user Sha1 is :%@",defaultUserStrategySha1);
    
    if ([accountManager getActiveAccountCount] != 0) {
        
        if ([[accountManager getActiveAccount] account_st] == WSAccountStatusOnline ) {
            
            userStrategySha1 = [[[accountManager getActiveAccount]getStrategy]getStrategySHA1];
            userSid = [[accountManager getActiveAccount] userSid];
            //            TRACK(@"User Sha1 is :%@",userStrategySha1);
        }else{
            userStrategySha1 = nil;
            userSid = nil;
        }
        
    }
    
    //make user list
    
    if (defaultUserStrategySha1 == nil || systemStrategySha1 == nil) {
        return @"<USER>\
        <USERSID encode=\"\">86108274-39398501-00000000-10000000</USERSID>\
        <USERSTRATEGYSHA1 encode=\"\">1111111111111111111111111111111111111111</USERSTRATEGYSHA1>\
        </USER>\
        <USER>\
        <USERSID encode=\"\">86108274-39398501-00000000-00000000</USERSID>\
        <USERSTRATEGYSHA1 encode=\"\">0000000000000000000000000000000000000000</USERSTRATEGYSHA1>\
        </USER>\
        ";
        
    }
    
    if ([[accountManager getActiveAccount] account_st] != WSAccountStatusOnline) {
        userList = [NSString stringWithFormat:@"<USER>\
                    <USERSID encode=\"\">86108274-39398501-00000000-10000000</USERSID>\
                    <USERSTRATEGYSHA1 encode=\"\">%@</USERSTRATEGYSHA1>\
                    </USER>\
                    <USER>\
                    <USERSID encode=\"\">86108274-39398501-00000000-00000000</USERSID>\
                    <USERSTRATEGYSHA1 encode=\"\">%@</USERSTRATEGYSHA1>\
                    </USER>\
                    ",systemStrategySha1,defaultUserStrategySha1];
    }else{
        if (userStrategySha1 == nil || userSid == nil) {
            //            TRACK(@"!!!!!!!!!!!!!!!!!!!!!!!!")
            userList = [NSString stringWithFormat:@"<USER>\
                        <USERSID encode=\"\">86108274-39398501-00000000-10000000</USERSID>\
                        <USERSTRATEGYSHA1 encode=\"\">%@</USERSTRATEGYSHA1>\
                        </USER>\
                        <USER>\
                        <USERSID encode=\"\">86108274-39398501-00000000-00000000</USERSID>\
                        <USERSTRATEGYSHA1 encode=\"\">%@</USERSTRATEGYSHA1>\
                        </USER>\
                        ",systemStrategySha1,defaultUserStrategySha1];
        }else{
            //            TRACK(@"?????????????????????????")
            userList = [NSString stringWithFormat:@"<USER>\
                        <USERSID encode=\"\">86108274-39398501-00000000-10000000</USERSID>\
                        <USERSTRATEGYSHA1 encode=\"\">%@</USERSTRATEGYSHA1>\
                        </USER>\
                        <USER>\
                        <USERSID encode=\"\">86108274-39398501-00000000-00000000</USERSID>\
                        <USERSTRATEGYSHA1 encode=\"\">%@</USERSTRATEGYSHA1>\
                        </USER>\
                        <USER>\
                        <USERSID encode=\"\">%@</USERSID>\
                        <USERSTRATEGYSHA1 encode=\"\">%@</USERSTRATEGYSHA1>\
                        </USER>\
                        ",systemStrategySha1,defaultUserStrategySha1,userSid,userStrategySha1];
        }//end userStrategySha1 == nil || userSid == nil
        
    }//[[accountManager getActiveAccount] account_st] == WSAccountStatusOnline
    
    
    return userList;
}

/**
 *  NOTE:ADD by LSZ ——2013.05.29
 *  设备挂失状态下检测是否需要擦除数据
 */
- (BOOL)deleteDataIsEnableOfSystemStrategy
{
    /* Step 1 :获取系统策略 */
    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
    SystemStrategy* systemStrategy = [config getValueByKey:WSConfigItemSystemStrategy];
    NSLog(@"systemStrategy:%@",systemStrategy);
    NSArray* array = [systemStrategy getItemByGroupId:DELETE_DATA_ENABLE_KEY_GROUPID_IN_SYSTEM_STRATEGY];
    NSLog(@"array:%@",array);
    if ([array count] == 0) {
        return NO;
    }
    
    /* Step 2:解析用户策略 */
    GDataXMLElement* element = (GDataXMLElement*)[array objectAtIndex:0];
    NSRange range = [[element XMLString]rangeOfString:@"<MOB_DELETE_DATA_ENABLE_00>1</MOB_DELETE_DATA_ENABLE_00>"];
    NSLog(@"element strin value:%@",element.XMLString);
    /* Step 3:根据相应策略数据返回结果 */
    if (range.length == 0) {
        return NO;
    }
    return YES;
}

/**
 *  NOTE:ADD by LSZ ——2013.05.29
 *  通知界面
 */
- (void)noticeHaveDeleteAllContents{
    /* Step 1：clear data */
    NSLog(@"notification send out");
    NSString *libraryDirectory = [NSHomeDirectory()
                                  stringByAppendingPathComponent:@"Library"];
    NSString *documentsDirectory = [NSHomeDirectory()
                                    stringByAppendingPathComponent:@"Documents"];
    [UserSrategyHelper clearAllContentsOfPath:documentsDirectory];
    [UserSrategyHelper clearAllContentsOfPath:libraryDirectory];
    
    NSString* strMessage = @"need to clear data";
    NSNotification* notify = [NSNotification notificationWithName:@"CLEAR_DATA_SYSTEM_STRATEGY" object:strMessage];
    NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
    [notifyCenter postNotification:notify];
}

@end
