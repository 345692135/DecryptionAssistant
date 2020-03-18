//
//  CertificationCertifyPrivder.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-9-4.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import "CertificationCertifyPrivder.h"
#import "AccountManagement.h"

@implementation CertificationCertifyPrivder

#pragma mark delegate method

- (long)loginWithUserAccountAfterFirstlogin:(UserAccount*)account
{
    @synchronized(self) {
        
    }
    return 0;
}

- (long)loginWithUserAccount:(UserAccount*)account
{
    @synchronized(self) {
        
    }
    return 0;
}


- (long)logoutWithUserAccount:(UserAccount*)account
{
    @synchronized(self) {
        
    }
    return 0;
}


- (long)changePassword:(NSString*)oldPwd newPassword:(NSString*)newPwd
{
    @synchronized(self) {
        
    }
    return 0;
}

- (int)getLoginAccoutStutus
{
    return 0;
}

- (long)activeAccountReOnlinelogin
{
    return 0;
}

- (NSString*)getActiveAccountSID
{
    AccountManagement* accountManager = [AccountManagement getInstance];
    SystemAccount* account = [accountManager getActiveAccount];
    return [account userSid];
}

@end
