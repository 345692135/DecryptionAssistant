//
//  AccountManagement.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-7-21.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

// This is a Account Management class ,is a singleton class object ，used by create account or get account object and get account status- see the class methods below

#import "BusinessProcessBase.h"
#import "SystemAccount.h"
#import "UserStrategyItem.h"
#import "UserAccount.h"

@interface AccountManagement : BusinessProcessBase
{
    
}

/*!
    @method getInstance
    @abstract Get AccountManagement instance
    @result Return AccountManagement singleton class object 
 */
+ (AccountManagement*)getInstance;

#pragma mark Business method

/*!
    @method registerAccountWithUserAccount:account
    @abstract Create account with user account
    @param account The user account
    @param error The error describe
    @result Return sys account object 
 */
- (SystemAccount*)registerAccountWithUserAccount:(UserAccount*)account error:(NSError**)err;


/*!
    @method unregisterAccountWithUserAccount:account
    @abstract Logoff account with user account
    @param account The account handle
    @result Return value if success retrun 0 
 */
- (long)unregisterAccountWithUserAccount:(UserAccount*)account;

/*!
    @method getActiveAccount
    @abstract Get now active account 
    @result Return sys account object
 */
- (SystemAccount*)getActiveAccount;

/*!
 @method getDefaultAccount
 @abstract Get now default account
 @result Return default account object
 */
- (SystemAccount*)getDefaultAccount;

/*!
    @method unregisterActiveAccount
    @abstract unregister now active account
    @result Return void
 */
- (void)unregisterActiveAccount;

/*!
    @method changePassword
    @abstract change password
    @result Return void
 */
- (void)changePassword;

/*!
    @method changeAccountStatus:status
    @abstract change status now
    @result Return void
 */
- (void)changeAccountStatus:(WSAccountStatus)status;

/*!
    @method setActiveAccountUsersid:sid:token:key
    @abstract setActiveAccount sid token and key
    @result Return void
 */
- (void)setActiveAccountUsersid:(NSString*)sid token:(NSString*)token key:(NSData*)key;

/*!
    @method getActiveAccountCount
    @abstract get active account count
    @result Return count
 */
- (int)getActiveAccountCount;


/*!
 @method getAccountCountInDatabase
 @abstract get account count in database
 @result Return count
 */
- (int)getAccountCountInDatabase;


#pragma mark User Strategy method

///*!
//    @method getItemsByGroupId:grpId
//    @abstract Get strategy items by gorup id to follow nearest match
//    @param grpId The strategy row's group id
//    @result Return SystemStrategyItem object 
// */
//-(UserStrategyItem*)getItemsByGroupId:(NSString*)grpId;
//
///*!
//    @method getItemsByName:name
//    @abstract Get strategy items by name to follow nearest match
//    @param name The strategy row's name
//    @result Return SystemStrategyItem object 
// */
//-(UserStrategyItem*)getItemsByName:(NSString*)name;



@end
