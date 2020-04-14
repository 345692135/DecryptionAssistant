//
//  SystemAccount.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-7-19.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import "SystemAccount.h"
#import "tbStrategy.h"
#import "UserStrategy.h"

/*
 @interface PwdAccount  
 */

@implementation PwdAccount

@synthesize userName;
@synthesize userPassword;
@synthesize userPasswordSHA1;
@synthesize userPasswordMD5;

- (id)init
{
    self = [super init];
    if (self) {
        self.userName = nil;
        self.userPassword = nil;
        self.userPasswordSHA1 = nil;
        self.userPasswordMD5 = nil;
    }
    return self;
}

- (void)dealloc
{
    [userName release];userName = nil;
    [userPassword release];userPassword = nil;
    [userPasswordSHA1 release];userPasswordSHA1 = nil;
    [userPasswordMD5 release];userPasswordMD5 = nil;
    [super dealloc];
}

@end

/*
 @interface CerAccount
 */

@implementation CerAccount

@synthesize pin;
@synthesize certifykeyDelegate;

- (id)init
{
    self = [super init];
    if (self) {
        self.pin = nil;
    }
    return self;
}

- (void)dealloc
{
    [pin release];pin = nil;
    [certifykeyDelegate release]; certifykeyDelegate = nil;
    [super dealloc];
}

@end


/*
 @interface SystemAccount
 */

@implementation SystemAccount

@synthesize pwdAct;
@synthesize cerAct;
@synthesize account_st;
@synthesize token;
@synthesize sessionKey;
@synthesize userSid;
@synthesize activeTypeNow;
@synthesize isYuLogin;

- (id)init
{
    self = [super init];
    if (self) {
        self.pwdAct = nil;
        self.cerAct = nil;
        self.account_st = WSAccountStatusMistrust;
        self.token = nil;
        self.sessionKey =nil;
        self.userSid = nil;
        self.activeTypeNow = WSAccountActiveUnknow;
        self.isYuLogin = NO;
    }
    return self;
}

- (void)dealloc
{
    [pwdAct release];pwdAct = nil;
    [cerAct release];cerAct = nil;
    [token release];token = nil;
    [sessionKey release];sessionKey = nil;
    [userSid release];userSid = nil;
    [super dealloc];
}

- (UserStrategy *)getStrategy
{
    if (self.userSid == nil) {
        return nil;
    }
    
    NSString* sql = [NSString stringWithFormat:@"WHERE strategy_sid = '%@'",self.userSid];
    tbStrategy* strategy =(tbStrategy*)[tbStrategy findFirstByCriteria:sql];
    if (strategy == nil || [strategy xmlData] == nil) {
        return nil;
    }
    
    NSError* err = nil;
    UserStrategy* userStrategy = [[UserStrategy alloc]initWithStrategyData:[strategy xmlData] error:&err];
    if (userStrategy == nil) {
        TRACK(@"init UserStrategy error !");
    }
    
    return [userStrategy autorelease];
}
@end
