//
//  ForwardOperation.m
//  ScoketProxy
//
//  Created by Cooriyou on 13-7-2.
//  Copyright (c) 2013年 wondersoft. All rights reserved.
//

#import "ForwardOperation2.h"
#import "SS5Helper2.h"
#import "ConfigManager.h"
#import "IConfig.h"
#import "SocketProxyManager.h"

@interface ForwardOperation2()
{
    CFSocketNativeHandle client_socket;
    
    BOOL running;
}

@property(atomic,retain)NSInputStream*  client_inputStream;
@property(atomic,retain)NSOutputStream* client_outputStream;
@property(atomic,retain)NSInputStream*  server_inputStream;
@property(atomic,retain)NSOutputStream* server_outputStream;

@property(atomic,retain)NSMutableData* buffer;


- (BOOL)isReady;
- (BOOL)isExecuting;
- (BOOL)isFinished;
- (BOOL)isCancelled;
- (BOOL)isConcurrent;

@end

@implementation ForwardOperation2

@synthesize client_inputStream;
@synthesize client_outputStream;
@synthesize server_inputStream;
@synthesize server_outputStream;

@synthesize remoteIp;
@synthesize remotePort;

@synthesize buffer;

#pragma mark-
#pragma mark Init

- (id)initWithHandle:(CFSocketNativeHandle) socket;
{
    self = [super init];
    if (self) {
        
        _isCancelled = NO;
        _isExecuting = NO;
        _isFinished = NO;
        _isReady = YES;
        
        CFReadStreamRef readStream = NULL;
        CFWriteStreamRef writeStream = NULL;
        
        CFReadStreamRef readStream2 = NULL;
        CFWriteStreamRef writeStream2 = NULL;
        
        //Create socket to server
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,(CFStringRef)[[SocketProxyManager getInstance]getMAGIp], 50022, &readStream2, &writeStream2);
        if (!readStream2 || !writeStream2) {
            close(client_socket);
            fprintf(stderr, "CFStreamCreatePairWithSocketToHost()create socket to server failed\n");
            running = NO;
            [self finish];
            return self;
        }
        
        server_inputStream = (NSInputStream* )readStream2;
        server_outputStream = (NSOutputStream* )writeStream2;
        
        [server_inputStream open];
        [server_outputStream open];
        
        [server_inputStream setDelegate:self];
        [server_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        [server_outputStream setDelegate:self];
        [server_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        client_socket = socket;
        
        CFStreamCreatePairWithSocket(kCFAllocatorDefault, client_socket, &readStream, &writeStream);
        if (!readStream || !writeStream) {
            close(client_socket);
            fprintf(stderr, "CFStreamCreatePairWithSocket() failed\n");
            running = NO;
            [self finish];
            return self;
        }
        
        client_inputStream = (NSInputStream* )readStream;
        client_outputStream = (NSOutputStream* )writeStream;
        
        //        [client_inputStream setProperty:NSStreamNetworkServiceTypeVoIP forKey:NSStreamNetworkServiceType];
        //        [client_outputStream setProperty:NSStreamNetworkServiceTypeVoIP forKey:NSStreamNetworkServiceType];
        
        [client_inputStream setDelegate:self];
        [client_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        [client_outputStream setDelegate:self];
        [client_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        [client_inputStream open];
        [client_outputStream open];
        
        
        buffer = [[NSMutableData alloc]init];
        
        
        running = YES;
    }
    return self;
}

- (id)initWithHandle:(CFSocketNativeHandle) socket remoteIp:(NSString*) ip remotePort:(NSInteger) port
{
    self = [super init];

    if (self) {
        
        _isCancelled = NO;
        _isExecuting = NO;
        _isFinished = NO;
        _isReady = YES;
        
        //The native socket, used for various operations
        client_socket = socket;
        self.remoteIp = ip;
        self.remotePort = port;
    }
    return self;
}

#pragma mark-
#pragma mark do start

- (void)start
{
    @autoreleasepool {
        NSLog(@"ForwardOperation:create completed %@",[NSThread currentThread]);
        NSLog(@"IP = %@ PORT %ld",remoteIp,(long)remotePort);
        
        if([[NSThread currentThread]isMainThread]){
            NSLog(@"Current thread is main thread!");
        }else{
            NSLog(@"Current thread is not main thread!");
        }
        
        [self willChangeValueForKey:@"isExecuting"];
        _isExecuting = YES;
        [self didChangeValueForKey:@"isExecuting"];
        
        if ([self isCancelled]) {
            [self finish];
            return;
        }
        
        CFReadStreamRef readStream = NULL;
        CFWriteStreamRef writeStream = NULL;
        
        CFReadStreamRef readStream2 = NULL;
        CFWriteStreamRef writeStream2 = NULL;
        
        BOOL isIdentify = NO;
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,(CFStringRef)[[SocketProxyManager getInstance]getMAGIp], 10888, &readStream2, &writeStream2);
        if (!readStream2 || !writeStream2) {
            close(client_socket);
            fprintf(stderr, "CFStreamCreatePairWithSocketToHost()create socket to server failed\n");
            running = NO;
            [self finish];
            return;
        }
        
        server_inputStream = (NSInputStream* )readStream2;
        server_outputStream = (NSOutputStream* )writeStream2;
        
        [server_inputStream open];
        [server_outputStream open];
        //        memcpy(g_PrivateKey, "1111111111111111", 16);
        
        isIdentify = [SS5Helper2 Identify:server_inputStream outStream:server_outputStream];
        
        if (isIdentify == NO) {
            close(client_socket);
            fprintf(stderr, "IdentifyWithServer() failed\n");
            running = NO;
            [self finish];
            return;
        }
        
        [server_inputStream setDelegate:self];
        [server_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        [server_outputStream setDelegate:self];
        [server_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        //Create the read and write streams for the socket
        CFStreamCreatePairWithSocket(kCFAllocatorDefault, client_socket, &readStream, &writeStream);
        if (!readStream || !writeStream) {
            close(client_socket);
            fprintf(stderr, "CFStreamCreatePairWithSocket() failed\n");
            running = NO;
            [self finish];
            return ;
        }
        
        client_inputStream = (NSInputStream* )readStream;
        client_outputStream = (NSOutputStream* )writeStream;
        
        //        [client_inputStream setProperty:NSStreamNetworkServiceTypeVoIP forKey:NSStreamNetworkServiceType];
        //        [client_outputStream setProperty:NSStreamNetworkServiceTypeVoIP forKey:NSStreamNetworkServiceType];
        
        [client_inputStream setDelegate:self];
        [client_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        [client_outputStream setDelegate:self];
        [client_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        [client_inputStream open];
        [client_outputStream open];
        
        
        buffer = [[NSMutableData alloc]init];
        
        
        running = YES;
        CFRunLoopRun();
    }
}

#pragma mark-
//TODO:send and recv process

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    @synchronized(self)
    {
        @autoreleasepool
        {
            if (_isCancelled == YES && _isExecuting == YES)
            {
                [self finish];
                return;
            }
            
            switch (eventCode)
            {
                case NSStreamEventOpenCompleted:
                    break;
                case NSStreamEventHasBytesAvailable:
                {
                    if (aStream == client_inputStream)
                    {
                        @autoreleasepool
                        {
                            uint8_t buf[4097] = {0};        //接收客户端数据流
                            long len = 0;                   //输入流长度
                            uint8_t encBuffer[5120] = {0};  //加密后的数据流
                            unsigned long encLen = 0;       //加密后数据长度
                            
                            len = [(NSInputStream *)aStream read:buf maxLength:4096];

                            if (len <=0 || len > 4097)
                            {
                                NSLog(@"client_inputStream=================================长度异常");
                                return;
                            }
                            
                            //统计通道流量
                            [[SocketProxyManager getInstance]sumBitOperation:len];
                            
                            //加密客户端数据流
                            [SS5Helper2 SS5_Proxy_Enc:buf isSrcLen:len sZDst:encBuffer isDstLen:&encLen izip:2];
                            
                            //将加密后的数据发送给服务器
                            [(NSOutputStream*)server_outputStream write:encBuffer maxLength:encLen];
                        }
                    }
                    else if (aStream == server_inputStream)
                    {
                        @autoreleasepool
                        {
                            int nPackageLen;                //加密包总大小
                            uint8_t buf[4097] = {0};        //服务器传过来的buf
                            long len = 0;                   //buf长度
                            uint8_t decBuf[5120] = {0};     //解密后的buf
                            unsigned long decLen = 0;       //解密后buf的长度
                            
                            len = [(NSInputStream *)aStream read:buf maxLength:4096];
                            
                            if (len <= 0 || len > 4097)
                            {
                                NSLog(@"server_inputStream=================================长度异常");
                                return;
                            }
                            
                            //计算通道流量
                            [[SocketProxyManager getInstance]sumBitOperation:len];
                            
                            //将接收到的buf不断的累加到一个全局的buffer中
                            [buffer appendData:[NSData dataWithBytes:buf length:len]];
                            
                            //当全局buffer长度满足16字节包头大小时进行处理
                            if ([buffer length] >= 16)
                            {
                                //获取一个完整包的大小
                                nPackageLen = [self getPackageSize:buffer];
                                NSLog(@"mark-------------buffer length = %lu", (unsigned long)[buffer length]);
                                NSLog(@"mark-------------nPackageLen = %d", nPackageLen);
                                //当buffer长度满足一个完整包大小时进行解密处理
                                while (nPackageLen <= [buffer length])
                                {
                                    @autoreleasepool
                                    {
                                        //返回一个完整的加密包
                                        NSData *data = [self getData:nPackageLen];
                                        const char *buf=[data bytes];
                                        
                                        //将加密包进行解密
                                        BOOL isDec = [SS5Helper2 SS5_Proxy_Dec:(unsigned char *)buf isSrcLen:[data length] sZDst:decBuf isDstLen:&decLen izip:2];

                                        if (!isDec)
                                        {
                                            NSLog(@"======================解密失败");
                                            close(client_socket);
                                            running = NO;
                                            [self finish];
                                        }
                                        
                                        //将解密后的数据返回
                                        [(NSOutputStream*)client_outputStream write:decBuf maxLength:decLen];
                                        
                                        //接着判断当前buffer长度是否满足16字节包头大小
                                        if ([buffer length]>= 16)
                                        {
                                            nPackageLen = [self getPackageSize:buffer];
                                        }
                                        else
                                        {
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                    break;
                case NSStreamEventHasSpaceAvailable:
                    break;
                case NSStreamEventErrorOccurred:
                {
                    NSLog(@"=============================NSStreamEventErrorOccurred");
                    [self finish];
                    running = NO;
                }
                    break;
                case NSStreamEventEndEncountered:
                {
                    NSLog(@"=============================NSStreamEventEndEncountered");
                    [self finish];
                    running = NO;
                }
                    break;
                default:
                    break;
            }
        }
    }
}

/*
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    @synchronized(self){
        @autoreleasepool {
            
            
            if (_isCancelled == YES && _isExecuting == YES) {
                
                [self finish];
                return;
            }
            switch (eventCode) {
                case NSStreamEventOpenCompleted: {
                    
                } break;
                case NSStreamEventHasBytesAvailable: {
                    
                    if (aStream == client_inputStream) {
                        @autoreleasepool {
                            uint8_t buf[4097] = {0};
                            unsigned int len = 0;
                            
                            unsigned char encBuffer[5120] = {0};
                            unsigned long encLen = 0;
                            
                            NSLog(@"============ Data From Client ..");
                            
                            len = [(NSInputStream *)aStream read:buf maxLength:4096];
                            
                            //  0729 ADD
                            if(len < 4098){
                                [[SocketProxyManager getInstance]sumBitOperation:len];
                            }else{
                                NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!*****************&&&&&&&&&&&&&&&&&&&################$$$ client_inputStream 长度异常：%iu",len);
                                return;
                            }
                            //                    SS5_Proxy_Enc(buf, len, encBuffer,&encLen , 2);
                            [SS5Helper2 SS5_Proxy_Enc:(unsigned char *)buf isSrcLen:len sZDst:encBuffer isDstLen:&encLen izip:2];
                            [(NSOutputStream*)server_outputStream write:encBuffer maxLength:encLen];// upload enclen
                            
                            NSLog(@"============ Send To Server ..");
                        }
                        
                        
                    }else if (aStream == server_inputStream){
                        @autoreleasepool {
                            
                            int nPackageLen;
                            uint8_t buf[4097] = {0};
                            unsigned long len = 0;
                            uint8_t decBuf[5120] = {0};
                            unsigned long encLen = 0;
                            NSLog(@"************* Data From Server ..");
                            //@synchronized(self){
                            
                            len = [(NSInputStream *)aStream read:buf maxLength:4096];//读取从服务器传过来的的buf
                            
                            if(len<=0 ){
                                NSLog(@"the buf length <=0 !!!");
                                return;
                            }
                            if (len > 4096) {
                                NSLog(@"the buf length > 4096 !!!");
                                return;
                            }
                            
                            NSLog(@"len is:%lu",len);
                            
                            //download len
                            
                            //  0729 ADD
                            [[SocketProxyManager getInstance]sumBitOperation:len];
                            
                            [buffer appendData:[NSData dataWithBytes:buf length:len]];
                            
                            if([buffer length] >= 16){
                                nPackageLen = [self getPackageSize:buffer];//获取一个包的大小
                                printf("PACK Len = %d, %d\r\n",nPackageLen, [buffer length]);
                                
                                while (nPackageLen <= [buffer length]){
                                    @autoreleasepool {
                                        
                                        NSData *data = [self getData:nPackageLen]; //返回来的就是原来一个包的大小
                                        const char *buf=[data bytes];
                                        char* encBufer = (char*)malloc([data length]+32);
                                        
                                        memset(encBufer, 0, [data length]+32);
                                        memcpy(encBufer, buf, [data length]);
                                        [SS5Helper2 SS5_Proxy_Dec:(unsigned char *)buf isSrcLen:[data length] sZDst:decBuf isDstLen:&encLen izip:2];
                                        free(encBufer);
                                        encBufer = NULL;
                                        
                                        [(NSOutputStream*)client_outputStream write:decBuf maxLength:encLen];
                                        if ([buffer length]>=16){
                                            nPackageLen = [self getPackageSize:buffer];
                                        }else{
                                            break;
                                        }
                                        
                                    }
                                }
                                
                                
                            }
                            //}
                            
                            NSLog(@"***************** Send To Client ..");
                        }
                    }
                } break;
                case NSStreamEventHasSpaceAvailable: {
                    //            NSLog(@"ForwardOperation:NSStreamEventHasSpaceAvailable");
                    
                } break;
                case NSStreamEventErrorOccurred: {
                    NSLog(@"ForwardOperation:NSStreamEventErrorOccurred");
                    [self finish];
                    running = NO;
                } break;
                case NSStreamEventEndEncountered: {
                    NSLog(@"ForwardOperation:NSStreamEventEndEncountered");
                    
                    [self finish];
                    running = NO;
                } break;
                default: {
                    
                } break;
            }
            
            
        }
    }
}
*/
#pragma mark -
#pragma mark Operation Management & Super Class Methods

- (BOOL)isConcurrent
{
    return YES;
}


- (BOOL)isExecuting {
    
    return _isExecuting;
}


- (BOOL)isFinished {
    
    return _isFinished;
}

- (BOOL)isReady {
    
    return _isReady;
}

- (BOOL)isCancelled {
    
    return _isCancelled;
}


- (void)finish {
    
    if (_isFinished == YES || _isExecuting == NO) {
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    _isExecuting = NO;
    _isFinished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    CFRunLoopStop(CFRunLoopGetCurrent());

}


- (void)cancel {
    
    [self willChangeValueForKey:@"isCancelled"];
    _isCancelled = YES;
    [self didChangeValueForKey:@"isCancelled"];
    
    if ([self isExecuting] == YES) {
        [self finish];
    }
}

// TODO: clean resource
- (void)dealloc
{
    
    //Server inputStream close
    [server_inputStream setDelegate:nil];
    [server_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop]forMode:NSDefaultRunLoopMode];
    [server_inputStream close];
    
    //Client outputStream close
    [server_outputStream setDelegate:nil];
    [server_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop]forMode:NSDefaultRunLoopMode];
    [server_outputStream close];
    
    self.server_inputStream = nil;
    self.server_outputStream = nil;
    ///////////////////////////////////////////////////////////////////////////////////////////////
    //Client inputStream close
    [client_inputStream setDelegate:nil];
    [client_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop]forMode:NSDefaultRunLoopMode];
    [client_inputStream close];
    
    //Client outputStream close
    [client_outputStream setDelegate:nil];
    [client_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop]forMode:NSDefaultRunLoopMode];
    [client_outputStream close];
    
    
    //Close socket descriptor
    if( client_socket > -1 )
        close(client_socket);
    
    self.client_inputStream = nil;
    self.client_outputStream = nil;
    
    self.buffer = nil;
    self.remoteIp = nil;
    //Close completed
    CFRunLoopStop(CFRunLoopGetCurrent());
    NSLog(@"ForwardOperation:close completed %@",[NSThread currentThread]);
    [super dealloc];
}

#pragma mark-
// TODO:  get frame package

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

-(NSData *)getData:(long)packageSize
{
    NSRange range;
    range.length = (packageSize);
    range.location = 0;
    NSData* cmdData = [buffer subdataWithRange:range];
    
    
    range.length = ([buffer length] - packageSize);
    NSLog(@"mark-----------range.length = %ld", (unsigned long)range.length);
    range.location = packageSize;
    if (range.length <= 0) {
        [buffer release];buffer =nil;
        buffer = [[NSMutableData alloc]init];
        NSLog(@"the range length <=0 !!!");

    }else{
        NSData* tmp = [[NSData alloc]initWithData:[buffer subdataWithRange:range]];
        [buffer release];buffer =nil;
        buffer = [[NSMutableData alloc] initWithData:tmp];
        [tmp release];
    }
    return cmdData;
}



@end
