//
//  ICertify.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-9-4.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserAccount.h"

//obsevr define
/**
 USER_OFFINE_LOGIN 用户离线身份认证成功
 
 */

@protocol ICertify <NSObject>

//add by lijuan 20170206
- (long)loginWithUserAccountAfterFirstlogin:(UserAccount *)account;

//login with user Account
- (long)loginWithUserAccount:(UserAccount*)account;

//logout
- (long)logoutWithUserAccount:(UserAccount*)account;

//change password
- (long)changePassword:(NSString*)oldPwd newPassword:(NSString*)newPwd;

//get login accout stutus
- (int)getLoginAccoutStutus;

//active account relogin
- (long)activeAccountReOnlinelogin;

//get active account SID
- (NSString*)getActiveAccountSID;

//获取策略😆
- (void)fetchStrategyWithCompletion:(void (^)(BOOL ifSuccess))completion;

@end
