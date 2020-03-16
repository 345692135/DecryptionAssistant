//
//  CertificateKeyDelegate.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-7-24.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import <Foundation/Foundation.h>

/*  padding Mode
 */
typedef uint32_t PaddingMode;
enum
{
    kNoPadding            = 0x2010,              //no padding mode
    kPKCS1Padding         = 0x2020               //pksc1 padding mode
};

/* digest Mode
 */
typedef uint32_t DigestMode;
enum
{
    kMD5Digest            = 0x3010,              //MD5 digest
    kSHA1Digest           = 0x3020               //SHA1 digest
};

@protocol CertificateKeyDelegate <NSObject>

/*!
    @method verifyPin:pin
    @abstract The interface for verify pin 
    @param pin The pin for verify
    @result If success return YES
 */
- (BOOL)verifyPin:(NSString*)pin;

/*!
    @method changePin:pin
    @abstract change pin interface
    @param oldPin The old pin
    @param newPin The new pin
    @result If success return YES
 */
- (BOOL)changePin:(NSString*)oldPin
           newPin:(NSString*)newPin;

/*!
    @method getCertificateData:pin
    @abstract Get certificate bytes interface
    @result Return certificate data
 */
- (NSData*)getCertificateData;

/*!
    @method getCipherBlockSize
    @abstract Get cipher blok size or key size
    @result Return blok size
 */
- (long)getCipherBlockSize;

/*!
    @method encryptData:data:mode
    @abstract Encrypt data with plain data
    @param data The plain data
    @param padding The padding mode
    @result Return encrypt data
 */
- (NSData*)encryptData:(NSData*)data 
               padding:(PaddingMode)padding;

/*!
    @method decryptData:data:mode
    @abstract Decrypt data with encrypt data
    @param data The encrpty data
    @param padding The padding mode
    @param pin The pin
    @result Return plain data
 */
- (NSData*)decryptData:(NSData*)data 
               padding:(PaddingMode) padding 
                   pin:(NSString*)pin;

/*!
    @method rawSignData:data:padding:digest:pin
    @abstract Signed data with padding and disgest
    @param data The plain data
    @param padding The padding mode
    @param digest The signed mode
    @param pin The pin
    @result Return sign data
 */
- (NSData*)rawSignData:(NSData*)data 
               padding:(PaddingMode) padding 
                digest:(DigestMode)digest
                   pin:(NSString*)pin;

/*!
    @method verifyData:data:signdata:padding:digest
    @abstract Verify to signed data
    @param data The plain data
    @param signdata The signed data
    @param padding The padding mode
    @param padding The digest mode
    @result Return value if sucess return YES
 */
- (BOOL)verifyData:(NSData*)data 
            verify:(NSData*)signdata 
           padding:(PaddingMode)padding 
            digest:(DigestMode)digest;


@end
