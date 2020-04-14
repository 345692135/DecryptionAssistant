//
//  SystemAccount.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-7-19.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

// This is a system account class ,used by System Account Management to handle user data in memory object - see the class methods below


#import "WSBaseObject.h"
#import "UserStrategy.h"
#import "CertificateKeyDelegate.h"



/*!
    @enum WSAccountStatus
    @abstract Values for account status
    @constant WSAccountStatusMistrust account status (need to online certify)
    @constant WSAccountStatusOnline trust account online status
    @constant WSAccountStatusOffine trust account offline status
    @constant WSAccountStatusUnknow trust account nuknow status (need to online certify again)
 This is a user account status
*/
typedef enum
{   
    WSAccountStatusMistrust = 0x10,    //mistrust account status (need to online certify)
    WSAccountStatusOnline = 0x20,      //trust account online status
    WSAccountStatusOffine = 0x30,      //trust account offline status
    WSAccountStatusUnknow = 0x40       //trust account nuknow status (need to online certify again)
}WSAccountStatus;

/*!
    @enum WSAccountActive
    @abstract Values for the certify type
    @constant WSAccountActivePassword account status (need to online certify)
    @constant WSAccountActivecertificate trust account online status
    @constant WSAccountActiveUnknow trust account offline status
 This is a user account status
 */
typedef enum
{   
    WSAccountActivePassword = 0x100,         //password mode is activities
    WSAccountActivecertificate = 0x200,      //certificate mode is activities
    WSAccountActiveUnknow = 0x300,           //unknow type (Uninit success)
}WSAccountActive;


//This a password type account data in systemAccount memory object ,used by certification with "username+password"

@interface PwdAccount : WSBaseObject
{
    NSString* userName;         //user name
    NSString* userPassword;     //user password
    NSString* userPasswordSHA1; //user password(SHA1 encode)
    NSString* userPasswordMD5;  //user password(MD5 encode)
}

@property(atomic,retain)NSString* userName;
@property(atomic,retain)NSString* userPassword;
@property(atomic,retain)NSString* userPasswordSHA1;
@property(atomic,retain)NSString* userPasswordMD5;

@end


//This a password type account data in systemAccount memory object ,used by certification with "certificate"

@interface CerAccount : WSBaseObject
{
    NSString* pin;                                      //PFX's pin or key's pin
    id<CertificateKeyDelegate> certifykeyDelegate;      //the class to follow certify key protocol
}

@property(atomic,retain)NSString* pin;
@property(atomic,retain)id<CertificateKeyDelegate> certifykeyDelegate; 

@end


// This is a system account class ,used by System Account Management

@interface SystemAccount : WSBaseObject
{
    PwdAccount* pwdAct;             //password object 
    CerAccount* cerAct;             //certificate object
    WSAccountStatus account_st;     //account status
    NSString* token;                //certification success return token
    NSData* sessionKey;             //session key
    NSString* userSid;              //usersid in V3
    WSAccountActive activeTypeNow; //active Type (user password or certificate)
    BOOL isYuLogin;
}

@property(atomic,retain)PwdAccount* pwdAct;
@property(atomic,retain)CerAccount* cerAct;
@property(atomic)WSAccountStatus account_st;
@property(atomic,retain)NSString* token;
@property(atomic,retain)NSData* sessionKey;
@property(atomic,retain)NSString* userSid;
@property(atomic)WSAccountActive activeTypeNow;
@property(atomic)BOOL isYuLogin;

- (UserStrategy*)getStrategy;

@end
