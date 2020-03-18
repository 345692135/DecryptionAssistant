//
//  SocketProxy.m
//  ScoketProxy
//
//  Created by Cooriyou on 13-7-1.
//  Copyright (c) 2013年 wondersoft. All rights reserved.
//

#import "SocketProxy2.h"
#import <CFNetwork/CFNetwork.h>
#import <sys/socket.h>
#import <unistd.h>
#import <netinet/in.h>
#import <arpa/inet.h>

#import "ForwardOperation2.h"

//#define PORT 20000
#define PORT 3128

@interface SocketProxy2()
{
    CFSocketRef listenScoket;
    CFRunLoopSourceRef sourceRef;
}

//@property(atomic,retain)NSOperationQueue* queue;

@end

@implementation SocketProxy2

@synthesize remoteIp;
@synthesize remotePort;
@synthesize queue;

//NSOperationQueue* _queue;

#pragma mark accept call back function

static void AcceptCallBack2(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    //haeve a client
    
    /* Here is a "Dead store" LSZ*/
//    char* ip = NULL;
//    struct sockaddr_in* addr;
//    NSData* clientAddr = (NSData*)address;
//    addr = (struct sockaddr_in*)[clientAddr bytes];
//    ip = (char*)inet_ntoa(addr->sin_addr);
    
    //printf("IP %s socket ＝ %p\r",ip,socket);
    //begin forward
    SocketProxy2* sp = (SocketProxy2*)info;
    printf("ForwardOperation Create to ip:<%s> prot:<%ld>\r",[[sp remoteIp] UTF8String],[sp remotePort]);
    //    ForwardOperation* forwardOperation = [[ForwardOperation alloc]initWithHandle:*(CFSocketNativeHandle *) data];
    
    ForwardOperation2* forwardOperation = [[ForwardOperation2 alloc]initWithHandle:*(CFSocketNativeHandle *) data remoteIp:[sp remoteIp] remotePort:[sp remotePort]];
    [sp.queue addOperation:forwardOperation];
    
    ///printf("ForwardOperation OK\r");
    
    [forwardOperation release];
    
    NSLog(@"队列中操作的个数是：%ld",sp.queue.operationCount);
    
    //forwardOperation = nil;
    
    
//    if([[NSThread currentThread]isMainThread]){
//        NSLog(@"Current thread is main thread!");
//    }else{
//        NSLog(@"Current thread is not main thread!");
//    }
    
}

#pragma mark - start listen

- (BOOL)startListen:(NSInteger)port
{
    int yes = 1;
    
//    char punchline[] = "Proxy";
    CFSocketContext CTX = {0, self, NULL, NULL, NULL};
    
    listenScoket = CFSocketCreate(kCFAllocatorDefault,
                                  PF_INET, SOCK_STREAM,
                                  IPPROTO_TCP,
                                  kCFSocketAcceptCallBack,
                                  (CFSocketCallBack)&AcceptCallBack2,
                                  &CTX);
    
    if (listenScoket == NULL)return NO;
    
    /* Re-use local addresses, if they're still in TIME_WAIT */
    setsockopt(CFSocketGetNative(listenScoket), SOL_SOCKET, SO_REUSEADDR, (void *)&yes, sizeof(yes));
    
    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_len = sizeof(addr);
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port); addr.sin_addr.s_addr = htonl(INADDR_ANY);
    
    NSData *address = [NSData dataWithBytes: &addr length:sizeof(addr)];
    if (CFSocketSetAddress(listenScoket, (CFDataRef)address) != kCFSocketSuccess) {
        fprintf(stderr, "[ERROR]CFSocketSetAddress() failed\n");
        CFRelease(listenScoket);
        listenScoket = NULL;
        return NO;
    }
    
    sourceRef = CFSocketCreateRunLoopSource(kCFAllocatorDefault, listenScoket, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), sourceRef, kCFRunLoopCommonModes);
    CFRelease(sourceRef);
    
    NSLog(@"Socket proxy is working on port <%d>",port);
    
    //CFRunLoopRun();
    return YES;
}


#pragma mark - init

- (id)init
{
    self = [super init];
    if (self) {
        queue = [[NSOperationQueue alloc]init];
        [self startListen:PORT];
        
    }
    return self;
}

- (id)initWithAcceptPort:(NSInteger)port
{
    self = [super init];
    if (self) {
        queue = [[NSOperationQueue alloc]init];
        [self startListen:port];
    }
    return self;
}


- (id)initWithAcceptPort:(NSInteger)port remoteIp:(NSString*)rip remotePort:(NSInteger)rport
{
    self = [super init];
    if (self) {
        remoteIp = [rip retain];
        remotePort = rport;
        queue = [[NSOperationQueue alloc]init];
        [self startListen:port];
    }
    return self;
}

#pragma mark - dealloc

- (void)dealloc
{
    CFRunLoopRemoveSource(CFRunLoopGetCurrent(), sourceRef, kCFRunLoopCommonModes);
    
    CFSocketInvalidate(listenScoket);  //closes the socket, unless you set the option to not close on invalidation
    CFRelease(listenScoket);  //balance the create
    
    [queue cancelAllOperations];
    [queue release];
    queue = nil;
    
    [remoteIp release];
     remoteIp = nil;
    NSLog(@"Socket proxy is not working on port <%d>",3128);
    [super dealloc];
}

@end
