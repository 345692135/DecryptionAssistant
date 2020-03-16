//
//  Context.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-8-8.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

// This is a framework context class ,used by framework the only entrance - see the class methods below


#import "WSBaseObject.h"
#import "CertificateKeyDelegate.h"

#pragma mark 

@protocol ContextDelegate <NSObject>

- (void)statusNotify:(NSString*)domain code:(NSInteger)code;

@end

@interface Context : WSBaseObject
{
    id<ContextDelegate> delegate;
}

@property(atomic,assign)id<ContextDelegate> delegate;

//**************************************************************
// WARNING :system init must be set them at getInstance before!!
//
+ (void)setIp:(NSString*)ipAddress prot:(NSString*)port;

+ (void)setProductKey:(NSString*)productKey;

+ (void)setContextDelegate:(id<ContextDelegate>)delegate;
//
//**************************************************************

/*!
    @method getInstance
    @abstract Get context instance
    @result Return context singleton class object
 */
+ (Context*)getInstance;

/*!
    @method systemAlready
    @abstract Get context already init at frist
    @result Return context has init
 */
+ (BOOL)systemAlready;

/*!
    @method setKeyDriver:dirver:err
    @abstract Get driver instance
    @param dirver The driver privder for certify 
    @param err The error code
    @result Return 0 if success 
 */
- (long)setKeyDriver:(id<CertificateKeyDelegate>)dirver error:(NSError**)err;

/*!
    @method getKeyDriver
    @abstract Get driver instance
    @result Return driver privder for certify
 */
- (id<CertificateKeyDelegate>)getKeyDriver;

/*!
    @method changeIP:ipAddress:port
    @abstract Change ip address
    @param ipAddress The ip address
    @param portNumber The port number
    @result Return 0 if success
 */
- (long)changeIP:(NSString*)ipAddress port:(NSString*)portNumber;

/*!
    @method getIPAddress
    @abstract get ip address from system config
    @result Return ip address
 */
- (NSString*)getIPAddress;

/*!
    @method getPortNumber
    @abstract get port from config
    @result Return port number from system config
 */
- (NSString*)getPortNumber;

@end
