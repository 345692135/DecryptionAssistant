//
//  CertificateHelper.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-11-19.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KeyStore.h"
#import "pkcs12.h"

@interface CertificateHelper : NSObject



-(OSStatus)getCertificateFromPath:(NSString *)pCertPath 
                         password:(CFStringRef)pwd
                      certContent:(CFDataRef *)certContent
                          certLen:(size_t *)len;

-(OSStatus)getPublicKeyFromPath:(NSString *)pCertPath 
                       password:(CFStringRef)strPassword
                         pubKey:(SecKeyRef *)publicKey;

-(OSStatus)getPrivateKeyFromPath:(NSString *)pCertPath 
                        password:(CFStringRef)strPassword
                          prikey:(SecKeyRef *)privateKey;

-(SecKeyRef)getPublicKeyFromData:(NSData *)data;


-(X509 *)Certify_GetX509CertData:(unsigned char *)x509data dataLen:(int) Len;


-(int)Certify_Verify_RootCert:(NSString *)path x509Cert:(X509 *)pX509UserCert;

@end
