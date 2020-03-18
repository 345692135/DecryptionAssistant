//
//  MobileApproveAction.h
//  MISP
//
//  Created by wondersoft on 16/4/7.
//  Copyright © 2016年 wondersoft. All rights reserved.
//

#import "WSBaseObject.h"
#import "TCPAccess.h"

@protocol MobileApproveActionDelegate
@required
- (void)actionResult:(NSArray*)itemInfo;

@end

@interface MobileApproveAction : WSBaseObject<CommandResponseDelegate,NSXMLParserDelegate>
{
    int step;
    long err;
    BOOL isRecv;
    TCPAccess* access;
    int toGetCount;
    int session; //1-第一次，2-第二次
}

@property(atomic,retain) id <MobileApproveActionDelegate> mobileApproveActionDelegate;
@property(atomic,retain) TCPAccess* access;
@property(atomic)int step;
@property(atomic)BOOL isRecv;
@property(atomic)long err;
@property(nonatomic,retain) NSMutableArray* approveItemInfo;

- (id)initWithDelegate:(id)delegate;
- (long)approveAction1:(NSArray*)Info;//拒绝

- (long)approveAction21:(NSArray*)Info;//同意
- (long)approveAction22:(NSArray*)Info;//同意


@end

