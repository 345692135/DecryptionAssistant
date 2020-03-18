//
//  MobileApproveDetail.h
//  MISP
//
//  Created by wondersoft on 16/4/7.
//  Copyright © 2016年 wondersoft. All rights reserved.
//

#import "WSBaseObject.h"
#import "TCPAccess.h"

@protocol MobileApproveDetailDelegate
@required
- (void)getApproveItemSucceed1:(NSArray*)itemInfo;
- (void)getApproveItemSucceed2:(NSArray*)itemInfo;

@end

@interface MobileApproveDetail : WSBaseObject<CommandResponseDelegate,NSXMLParserDelegate>
{
    int step;
    long err;
    BOOL isRecv;
    TCPAccess* access;
    int toGetCount;
    int session; //1-第一次，2-第二次
}

@property(atomic,retain) id <MobileApproveDetailDelegate> mobileApproveDetailDelegate;
@property(atomic,retain) TCPAccess* access;
@property(atomic)int step;
@property(atomic)BOOL isRecv;
@property(atomic)long err;
@property(nonatomic,retain) NSMutableArray* approveItemInfo;

- (id)initWithDelegate:(id)delegate;
- (long)getApproveItem:(NSString*)requestID withRequestType:(NSString*)requestType;

@end

