//
//  UserAccount.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-7-26.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import "UserAccount.h"
@interface UserAccount()
{
    WSAccountType actType;
    NSString* username;
    NSString* password;
    NSString* kpin;
}
@property(atomic,retain)NSString* username;
@property(atomic,retain)NSString* password;
@property(atomic,retain)NSString* kpin;
@property(atomic)WSAccountType actType;
@property(atomic)BOOL isYuLogin;

@end

@implementation UserAccount

@synthesize username;
@synthesize password;
@synthesize kpin;
@synthesize actType;

- (id)init
{
    self = [super init];
    if (self) {
        self.username = nil;
        self.password = nil;
        self.kpin = nil;
        actType = WSAccountTypeUnknow;
    }
    return self;
}

- (id)initWithUserName:(NSString*)name password:(NSString*)pwd
{
    self = [super init];
    if (self) {
        if ([name length] != 0 && [pwd length] != 0) {
            self.password = pwd;
            self.username = name;
            self.kpin = nil;            //release pin
            actType = WSAccountTypePassword;
        }
    }
    return self;
}

- (id)initWithUserName:(NSString*)name password:(NSString*)pwd isYuLogin:(BOOL)isYuLogin
{
    self = [super init];
    if (self) {
        if ([name length] != 0 && [pwd length] != 0) {
            self.password = pwd;
            self.username = name;
            self.kpin = nil;            //release pin
            actType = WSAccountTypePassword;
            self.isYuLogin = isYuLogin;
        }
    }
    return self;
}

- (id)initWithPin:(NSString*)pin
{
    self = [super init];
    if (self) {
        if ([pin length] != 0) {
            self.username = nil;
            self.password = nil;        //release username and password
            self.kpin = pin;
            actType = WSAccountTypeCertificate;
        }
    }
    return self;
}

- (NSString*)getUserName
{
    if (self.actType == WSAccountTypePassword ) {
        return self.username;
    }
    return nil;
}

- (NSString*)getPassword
{
    if (self.actType == WSAccountTypePassword ) {
        return self.password;
    }
    return nil;
}

- (NSString*)getPin
{
    if (self.actType == WSAccountTypeCertificate ) {
        return self.kpin;
    }
    return nil;
}

- (WSAccountType)getAccountType
{
    return (self.actType);
}

-(BOOL)getIsYuLogin {
    return (self.isYuLogin);
}

- (void)dealloc
{
    [username release]; username = nil;
    [password release]; password = nil;
    [kpin release]; kpin = nil;
    [super dealloc];
}

@end
