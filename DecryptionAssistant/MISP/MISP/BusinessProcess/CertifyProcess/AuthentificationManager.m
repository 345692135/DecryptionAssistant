//
//  AuthentificationManager.m
//  MISP
//
//  Created by yangli on 12-8-6.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import "AuthentificationManager.h"
#import "UserNameCertifyPrivder.h"
#import "CertificationCertifyPrivder.h"

@interface AuthentificationManager ()
{
    UserNameCertifyPrivder* userNamePrivder;
    CertificationCertifyPrivder* certificationPrivder;
}

@property(atomic,retain)UserNameCertifyPrivder* userNamePrivder;
@property(atomic,retain)CertificationCertifyPrivder* certificationPrivder;

@end

@implementation AuthentificationManager
static AuthentificationManager* authentification = nil;

@synthesize userNamePrivder;
@synthesize certificationPrivder;

#pragma mark singleton class method

+ (AuthentificationManager*)getInstance
{
    @synchronized(self) {
        if (!authentification) {
            authentification = [NSAllocateObject([self class], 0, NULL) init];
        }
    }
    return authentification;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (authentification == nil) {
            authentification = [super allocWithZone:zone];
        }
    }
    return authentification;  // assignment and return on first allocation
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSIntegerMax;
}

- (id)autorelease
{
    return self;
}

- (oneway void)release
{
    //DO Nothing
}
- (id)copyWithZone:(NSZone*)zone
{
    return self;
}

- (void)dealloc
{
    self.userNamePrivder = nil;
    self.certificationPrivder = nil;
    [super dealloc];
}

#pragma mark business method

- (id<ICertify>)getUserNameCertifyPrivder
{
    if (self.userNamePrivder != nil) {
        return self.userNamePrivder;
    }
    UserNameCertifyPrivder* tmpPrivder = [[UserNameCertifyPrivder alloc]init];
    self.userNamePrivder = tmpPrivder;
    [tmpPrivder release];tmpPrivder = nil;
    return self.userNamePrivder;
}

@end
