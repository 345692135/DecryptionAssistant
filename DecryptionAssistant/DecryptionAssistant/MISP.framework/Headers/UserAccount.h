//
//  UserAccount.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-7-26.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

// This is a user account class ,used by create System Account object - see the class methods below

#import "WSBaseObject.h"

/*!
    @enum NSAccountStatus
    @abstract Values for the different cookie accept policies
    @constant WSAccountTypeUnknow account status unkonw type
    @constant WSAccountTypePassword user name and password type
    @constant WSAccountTypeCertificate certificate user type
 This is a user account type
 */
typedef enum
{
    WSAccountTypeUnknow = 0x100,            // unkonw type username password and pin is all null
    WSAccountTypePassword = 0x200,          // username password type
    WSAccountTypeCertificate = 0x300,       // certificate user type
}WSAccountType;

@interface UserAccount : WSBaseObject

/*!
    @method initWithUserName:name:pwd
    @abstract Init user account with username and password
    @param uname The user name
    @param pwd The user password
    @result Return user account object 
 */
- (id)initWithUserName:(NSString*)name password:(NSString*)pwd;

/*!
    @method initWithPin:pin
    @abstract Init user account with pin
    @param uname The user pin
    @result Return user account object 
 */
- (id)initWithPin:(NSString*)pin;

/*!
    @method getUserName
    @abstract Get user name
    @result Return user name string if account type is  WSAccountTypePassword
 */
- (NSString*)getUserName;

/*!
    @method getPassword
    @abstract Get user password
    @result Return user password string if account type is  WSAccountTypePassword
 */
- (NSString*)getPassword;

/*!
    @method getPin
    @abstract Get user pin
    @result Return user pin string if account type is  WSAccountTypeCertificate
 */
- (NSString*)getPin;

/*!
    @method getAccountType
    @abstract Get account type
    @result Return user account type
 */
- (WSAccountType)getAccountType;

@end
