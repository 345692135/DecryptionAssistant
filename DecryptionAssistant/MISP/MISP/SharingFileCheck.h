//
//  SharingFileCheck.h
//  MISP
//
//  Created by wondersoft on 16/4/7.
//  Copyright © 2016年 wondersoft. All rights reserved.
//

#import "WSBaseObject.h"
#import "TCPAccess.h"

@protocol SharingFileCheckDelegate
@required
- (void)getSharingFilesInfoSucceed:(NSArray*)filesInfo;
- (void)downloadResultsReported:(BOOL)succeed;

@end

@interface SharingFileCheck : WSBaseObject<CommandResponseDelegate,NSXMLParserDelegate>
{
    int step;
    long err;
    BOOL isRecv;
    TCPAccess* access;
}

@property(atomic,retain) id <SharingFileCheckDelegate> sharingFileCheckDelegate;
@property(atomic,retain) TCPAccess* access;
@property(atomic)int step;
@property(atomic)BOOL isRecv;
@property(atomic)long err;
@property(nonatomic,retain) NSMutableArray* sharingFilesInfoList;

- (id)initWithDelegate:(id)delegate;
- (long)sharingFileCheck;
- (long)sendDownloadResults:(NSArray*)resultsInfo;

@end

