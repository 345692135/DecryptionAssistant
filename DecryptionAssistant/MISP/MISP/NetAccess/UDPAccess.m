//
//  UDPCommad.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-8-27.
//
//

#import "UDPAccess.h"
#import "PackageDefine.h"
#import "ConfigManager.h"
#import "IConfig.h"

@interface UDPAccess ()
{
    int nPackageLen;        //package  length
    NSMutableData* buffer;  //buffer
}

@property(atomic)int nPackageLen;
@property(atomic,retain) NSMutableData* buffer;

@end

@implementation UDPAccess

@synthesize delegate;
@synthesize socket;
@synthesize ipAddress;
@synthesize portNum;
@synthesize nPackageLen;
@synthesize buffer;


- (id)init
{
    self = [super init];
    if (self) {
        //AsyncUdpSocket* newSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
        GCDAsyncUdpSocket* newSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        [newSocket receiveWithTimeout:UDP_TIMEOUT tag:1];
        
        NSError *error = nil;
        
        if (![newSocket bindToPort:0 error:&error])
        {
            NSLog(@"Error binding: %@", error);
         }
        
        //-beginReceiving is implement in GCD
        if (![newSocket beginReceiving:&error])
        {
            NSLog(@"Error beginReceiving: %@", error);
         }
       
        
        self.socket = newSocket;
//        [newSocket release];
        
        NSMutableData* newBuffer = [[NSMutableData alloc]init];
        self.buffer = newBuffer;
        [newBuffer release]; newBuffer = nil;
    }
    return self;
}

-(void)dealloc
{
    TRACK(@"UdpSocket dealloc");
//    [self.socket setDelegate:nil];
    if (socket) {
        [socket disconnect];
        TRACK(@"udp socket close");
        [socket release];socket = nil;
    }
    
    [ipAddress release]; ipAddress = nil;
//    [delegate release]; delegate = nil;
    [buffer release]; buffer = nil;
    [super dealloc];
}

-(void)setResponseDelegate:(id<UdpCommandResponseDelegate>)responseDelegate
{
    [self setResponseDelegate:responseDelegate];
}

-(void)commandRequest:(SystemCommand*)command
{
    NSData* data = [self processSendCommand:command];
    if (data != nil) {
        if (self.ipAddress ==nil || self.portNum == 0){//get ip port value from DB
            id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
            self.ipAddress = [config getValueByKey:WSConfigItemIP];
            NSString* port = [config getValueByKey:WSConfigItemPort];
            self.portNum = ([port intValue]+1);
        }
        //        TRACK(@"IP is : [%@] port is [%d] ",ipAddress ,portNum);
        //        [socket receiveWithTimeout:UDP_TIMEOUT tag:1];
        
        if (self.socket == nil) {
            //AsyncUdpSocket* newSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
            GCDAsyncUdpSocket* newSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
            [newSocket bindToPort:0 error:nil];
            [newSocket receiveWithTimeout:UDP_TIMEOUT tag:1];
            self.socket = newSocket;
            [newSocket release];
            TRACK(@"udp socket will recreate")
        }
        
        [socket sendData:data toHost:ipAddress port:portNum withTimeout:UDP_TIMEOUT tag:1];
    }
}


#pragma mark AsyncUdpSocket Protocol Method
///**
// * Called when the datagram with the given tag has been sent.
// **/
//- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag
//{
//    
//}
//
///**
// * Called if an error occurs while trying to send a datagram.
// * This could be due to a timeout, or something more serious such as the data being too large to fit in a sigle packet.
// **/
//- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
//{
//    TRACK(@"UDP Send Time out");
//    
//    [self.socket setDelegate:nil];
//    if (socket) {
//        //        [socket disconnect];
//        TRACK(@"udp socket will close");
//        [socket close];
//        [socket release];socket = nil;
//    }
//}
//
///**
// * Called when the socket has received the requested datagram.
// *
// * Due to the nature of UDP, you may occasionally receive undesired packets.
// * These may be rogue UDP packets from unknown hosts,
// * or they may be delayed packets arriving after retransmissions have already occurred.
// * It's important these packets are properly ignored, while not interfering with the flow of your implementation.
// * As an aid, this delegate method has a boolean return value.
// * If you ever need to ignore a received packet, simply return NO,
// * and AsyncUdpSocket will continue as if the packet never arrived.
// * That is, the original receive request will still be queued, and will still timeout as usual if a timeout was set.
// * For example, say you requested to receive data, and you set a timeout of 500 milliseconds, using a tag of 15.
// * If rogue data arrives after 250 milliseconds, this delegate method would be invoked, and you could simply return NO.
// * If the expected data then arrives within the next 250 milliseconds,
// * this delegate method will be invoked, with a tag of 15, just as if the rogue data never appeared.
// *
// * Under normal circumstances, you simply return YES from this method.
// **/
//- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
//{
//    [socket receiveWithTimeout:UDP_TIMEOUT tag:1];
//    if (data != nil) {
//        [self processRecvData:data];
//    }
//    return YES;
//}
//
///**
// * Called if an error occurs while trying to receive a requested datagram.
// * This is generally due to a timeout, but could potentially be something else if some kind of OS error occurred.
// **/
//- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error
//{
//    TRACK(@"UDP Recv Time out");
//    
//    [self.socket setDelegate:nil];
//    if (socket) {
//        //        [socket disconnect];
//        TRACK(@"udp socket will close");
//        [socket close];
//        [socket release];socket = nil;
//    }
//}
//
///**
// * Called when the socket is closed.
// * A socket is only closed if you explicitly call one of the close methods.
// **/
//- (void)onUdpSocketDidClose:(AsyncUdpSocket *)sock
//{
//    TRACK(@"UDP Did close");
//}



#pragma mark GCDAsyncUdpSocket Protocol Method
-(void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address
{
    TRACK(@"did connect to address. address:%@",address);
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error
{
    TRACK(@"did not connect with error...");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    //TRACK(@"udp did send data..");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    TRACK(@"UDP Send Time out");
    
    [self.socket setDelegate:nil];
    if (socket) {
        //        [socket disconnect];
        TRACK(@"udp socket will close");
        [socket close];
        [socket release];socket = nil;
    }
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    //TRACK(@"did receive data from address.....");
    [socket receiveWithTimeout:UDP_TIMEOUT tag:1];
    if (data != nil) {
        [self processRecvData:data];
    }
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    //TRACK(@"UDP Did close");
}

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
//    TRACK(@"Send package length is : %d",head.dwTotalLen);
    NSMutableData* data = [NSMutableData dataWithBytes:&head length:sizeof(FRAMEHEADER)];
    [data appendData:body];
    return data;
}

- (void)processRecvData:(NSData*)data
{
    [buffer appendData:data];
    
    if ([buffer length] >= 16) {
        
        nPackageLen = [self getPackageSize:buffer];
        while (nPackageLen <= [buffer length]) {
            
            [self makeCommandAndUpdateBuffer:nPackageLen];
            
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
    //    TRACK(@"buffer len is : %d",count);
    NSData* cmdData = [buffer subdataWithRange:range];
    //    NSString* str = [NSString stringWithUTF8String:[cmdData bytes]];
    //    TRACK(@"cmd data is:%@",str);
    SystemCommand* cmd = [CommandHelper createCommandWithXMLData:cmdData isVerifyData:NO];
    
    if (self.delegate) {
        [delegate commandResponse:cmd];
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
