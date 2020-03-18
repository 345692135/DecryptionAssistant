//
//  MobileApprove.h
//  MISP
//
//  Created by wondersoft on 16/4/7.
//  Copyright © 2016年 wondersoft. All rights reserved.
//

#import "WSBaseObject.h"
#import "TCPAccess.h"

@protocol MobileApproveDelegate
@required
- (void)getApproveListSucceed:(NSArray*)ListInfo isEnd:(int)toGetCount;//=-1表示取完了

//- (void)downloadResultsReported:(BOOL)succeed;

@end

@interface MobileApprove : WSBaseObject<CommandResponseDelegate,NSXMLParserDelegate>
{
    int step;
    long err;
    BOOL isRecv;
    TCPAccess* access;
    int toGetCount;
}

@property(atomic,retain) id <MobileApproveDelegate> mobileApproveDelegate;
@property(atomic,retain) TCPAccess* access;
@property(atomic)int step;
@property(atomic)BOOL isRecv;
@property(atomic)long err;
@property(nonatomic,retain) NSMutableArray* approveListInfo;

- (id)initWithDelegate:(id)delegate;
- (long)getApproveList:(NSString*)type withPage:(int)page;//0-我的申请，1-我的待办，2-我的已办

@end

