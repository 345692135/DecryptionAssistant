//
//  UserNameCertifyPrivder.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-9-4.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import "BaseCertifyProcessProvider.h"
#import "TCPAccess.h"
#import "ICertify.h"

@class TCPAccess;
@class SystemAccount;

@interface UserNameCertifyPrivder : BaseCertifyProcessProvider<ICertify,CommandResponseDelegate>
{
    int step;
    long err;
    BOOL isRecv;
    TCPAccess* access;
}

@property(atomic,retain)TCPAccess* access;
@property(atomic)int step;
@property(atomic)BOOL isRecv;
@property(atomic)long err;

@end
