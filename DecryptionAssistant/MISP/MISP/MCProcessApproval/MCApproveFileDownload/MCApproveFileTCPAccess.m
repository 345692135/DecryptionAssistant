//
//  MCApproveFileTCPAccess.m
//  MISP
//
//  Created by TanGuoLian on 17/6/10.
//  Copyright © 2017年 wondersoft. All rights reserved.
//

#define k_tcp_connect_timeout 15 //tcp连接超时时间
#define k_tcp_timeout 20         //tcp读取超时时间

#import "MCApproveFileTCPAccess.h"
#import "ConfigManager.h"
#import "IConfig.h"
#import "PackageDefine.h"

@interface MCApproveFileTCPAccess ()
{
    int nPackageLen;        //package  length
    NSMutableData* buffer;  //buffer
}

@property(atomic)int nPackageLen;
@property(atomic,retain) NSMutableData* buffer;

@end

@implementation MCApproveFileTCPAccess

@synthesize delegate;
@synthesize socket;
@synthesize ipAddress;
@synthesize portNum;
@synthesize nPackageLen;
@synthesize buffer;

- (id)init
{
    self = [super init];
    
    if (self)
    {
        GCDAsyncSocket* newSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        
        self.socket = newSocket;
        [newSocket release];
        
        NSMutableData* newBuffer = [[NSMutableData alloc]init];
        self.buffer = newBuffer;
        [newBuffer release]; newBuffer = nil;
        
    }
    return self;
}

-(void)dealloc
{
    [self.socket setDelegate:nil];
    if (socket != nil) {
        [socket disconnect];
        [socket release];socket = nil;
    }
    
    [ipAddress release]; ipAddress = nil;
    [buffer release]; buffer = nil;
    [super dealloc];
}

-(void)disconnect
{
    if (socket != nil)
    {
        [socket disconnect];
    }
}

-(void)setResponseDelegate:(id<CommandResponseDelegate>)responseDelegate
{
    [self setResponseDelegate:responseDelegate];
}

-(void)connect
{
    //@synchronized(self)
    {
        
        //NSLog(@"---- Tcp Socket Connect. ip:%@, port:%d",self.ipAddress,self.portNum);
        
        if (self.ipAddress !=nil && self.portNum != 0) {// set ip and port ready
            @try {
                //设置连接超时15s
                if (![socket connectToHost:ipAddress onPort:portNum withTimeout:k_tcp_connect_timeout error:nil]) {
                    TRACK(@"connect host error...");
                }
                
            }
            @catch (NSException *exception) {
                TRACK(@"connect exception %@,%@", [exception name], [exception description]);
                
                if (self.delegate) { //exception
                    [delegate commandResponse:self data:nil];
                }
            }
        }else{//get ip port value from DB
            
            id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
            self.ipAddress = [config getValueByKey:WSConfigItemIP];
            NSString* port = [config getValueByKey:WSConfigItemPort];
            self.portNum = [port intValue];
            
            @try {
                NSLog(@"socket connectToHost Connect. ip:%@, port:%d",ipAddress,portNum);
                
                if (![socket connectToHost:ipAddress onPort:portNum error:nil]) {
                    TRACK(@"connect host error....");
                }
            }
            @catch (NSException *exception) {
                TRACK(@"connect exception %@,%@", [exception name], [exception description]);
                
                if (self.delegate) { //exception
                    [delegate commandResponse:self data:nil];
                }
            }
        }
        
    }
}

-(void)commandRequest:(SystemCommand*)command
{
    if ([socket isConnected] == NO) {
        [self performSelectorOnMainThread:@selector(connect) withObject:nil waitUntilDone:YES];
    }
    
    NSData* data = [self processSendCommand:command];
    
    if (data != nil) {
        [socket readDataWithTimeout:TCP_TIMEOUT tag:1];
        [socket writeData:data withTimeout:TCP_TIMEOUT tag:1];
    }
    
}

//*
#pragma mark GCDAsycSocket Protocol Method
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    //TRACK(@"did connect to host. %@:%d", host, port);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    //TRACK(@"did read date.");
    if (data != nil)
    {
        [self processRecvData:data];//&&2
    }
    
    [socket readDataWithTimeout:k_tcp_timeout tag:1];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    //TRACK(@"did Write Data.");
}

-(BOOL)socketWillConnect:(GCDAsyncSocket *)sock
{
    //TRACK(@"socket will connect");
    return YES;
}

-(void)socket:(GCDAsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    //TRACK(@"socket will disconnect, %@", [err localizedDescription]);
    if (self.delegate)
    {   //Time out
        [delegate commandResponse:self data:nil];
    }
}

-(void)socketDidCloseReadStream:(GCDAsyncSocket *)sock
{
    TRACK(@"GCD, socket Did Close Read Stream");
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if (self.delegate) { //Time out
        [delegate commandResponse:self data:nil];
    }
    //TRACK(@"GCD, socket did disconnect with error: %@", err);
}

-(NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length
{
    TRACK(@"socket read time out");
    if (self.delegate) { //Time out
        [delegate commandResponse:self data:nil];
    }
    return 0;
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length
{
    TRACK(@"socket write time out");
    if (self.delegate) { //Time out
        [delegate commandResponse:self data:nil];
    }
    return 0;
}

////add
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    NSLog(@"didAcceptNewSocket////");
}
//*/


#pragma mark tools method

- (NSData*)processSendCommand:(SystemCommand*)command
{
    FRAMEHEADER head;
    memset(&head, 0, sizeof(FRAMEHEADER));
    NSData* body = [CommandHelper createXMLDataWithCommand:command isSignData:NO];
    head.dwTotalLen = ([body length]+sizeof(FRAMEHEADER));
    head.dwOrgLen = [body length];
    head.bVer = 3;
    head.bTos = 3;
    //TRACK(@"Send package length is : %d",head.dwTotalLen);
    NSMutableData* data = [NSMutableData dataWithBytes:&head length:sizeof(FRAMEHEADER)];
    [data appendData:body];
    return data;
}

- (void)processRecvData:(NSData*)data
{
    //TRACK(@"Recv len : %d" ,[data length]);
    [buffer appendData:data];
    
    if ([buffer length] >= 16) {
        
        nPackageLen = [self getPackageSize:buffer];
        while (nPackageLen <= [buffer length]) {
            
            [self makeCommandAndUpdateBuffer:nPackageLen];//&&3
            
            if ([buffer length]>=16) {
                nPackageLen = [self getPackageSize:buffer];
            }else{
                break;
            }
        }
    }
}

- (long)getPackageSize:(NSData*)package
{
    long len = 0;
    if ([package length]<16) {
        return 0;
    }
    NSRange range;
    range.length = 16;
    range.location = 0;
    NSData* head = [package subdataWithRange:range];
    if ( head!=nil ) {
        PFRAMEHEADER pframe_header =(PFRAMEHEADER)[head bytes];
        len = pframe_header->dwTotalLen;
    }
    return len;
}

- (void)makeCommandAndUpdateBuffer:(int)count
{
    NSRange range;
    range.length = (count - 16);
    range.location = 16;
    
    NSData* cmdData = [buffer subdataWithRange:range];
    
    NSMutableData* dataTmp = [[NSMutableData alloc]initWithBytes:[cmdData bytes] length:[cmdData length]];
    [dataTmp appendBytes:"\0" length:1];
    SystemCommand* cmd = [CommandHelper createCommandWithXMLData:dataTmp isVerifyData:NO];
    [dataTmp release];
    dataTmp = nil;
    
    if (self.delegate) {
        [delegate commandResponse:self data:cmd];//&&4
    }
    
    range.length = ([buffer length] - count);
    range.location = count;
    
    NSData* tmp = [buffer subdataWithRange:range];
    [tmp retain];
    [buffer release];buffer =nil;
    buffer = [[NSMutableData alloc]initWithData:tmp];
    [tmp release];
    
}

@end
