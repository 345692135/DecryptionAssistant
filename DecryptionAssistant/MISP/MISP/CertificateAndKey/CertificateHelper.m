//
//  CertificateHelper.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-11-19.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import "CertificateHelper.h"

@implementation CertificateHelper

//init
-(id)init{

    if (self = [super init]) {
        //initialize param here
        
    }
    
    return self;
}

/*
 *extract identity and trust for using privateKey and publicKey
 *Method:ExtractIdentityAndTrustFromPath
 *@param:pCertPath client pfx cert path
 *       pwd:pfx cert's password
 *       pIdentity:SecIdentityRef point for getting privateKey and certificate content
 *       pTrust:SecTrustRef point for getting publicKey 
 *auther:yangli wondersoft
 */
-(OSStatus)ExtractIdentityAndTrustFromPath:(NSString *)pCertPath
                                  password:(CFStringRef)pwd
                                  identity:(SecIdentityRef *)pIdentity 
                                     trust:(SecTrustRef *)pTrust{
    OSStatus status = noErr;
    if (*pIdentity != NULL) {
        *pIdentity = NULL;
    }
    if (*pTrust != NULL) {
        *pTrust = NULL;
    }
    if (pCertPath != nil) {
        //cert path is exist
        NSData *certData = [NSData dataWithContentsOfFile:pCertPath];
        CFDataRef certDataRef = (__bridge CFDataRef)certData;
        const void *keys[] = { kSecImportExportPassphrase };
        const void *values[] = { pwd };
        CFDictionaryRef options = CFDictionaryCreate( NULL, keys, values, 1, NULL, NULL );
        
        CFArrayRef items = CFArrayCreate( NULL, 0, 0, NULL );
        status = SecPKCS12Import( certDataRef, options, &items );
        if ( noErr == status ) 
        {                                          
            CFDictionaryRef dict = CFArrayGetValueAtIndex( items, 0 );
            
            *pIdentity = (SecIdentityRef)CFDictionaryGetValue( dict, kSecImportItemIdentity );
            
            
            *pTrust = (SecTrustRef)CFDictionaryGetValue( dict, kSecImportItemTrust );
            
        }
        
        CFRelease( options );
        
    }else{
        
        return -1;
    }
    return status;
    
}

/*
 *Method:getCertificateFromPath
 *@param:pCertPath[in]  :pfx cert full path,when you input certPath,please make sure certType is right for certPath
 *       pwd [in]       :pfx password
 *       certContent[in/out]:output cert content x509 DER formet
 *       len[in/out]    :output certData length
 *author                :yangli wondersoft
 *Description           :get cert content from xx.pfx
 */
-(OSStatus)getCertificateFromPath:(NSString *)pCertPath 
                         password:(CFStringRef)pwd
                      certContent:(CFDataRef *)certContent
                          certLen:(size_t *)len{
    OSStatus status =noErr;
    SecCertificateRef certificate = NULL;
    SecIdentityRef myIdentity;
    SecTrustRef myTrust;
    
    status = [self ExtractIdentityAndTrustFromPath:pCertPath 
                                          password:pwd
                                          identity:&myIdentity
                                             trust:&myTrust];
    if (status != noErr) {
        return status;
    }
    status = SecIdentityCopyCertificate( myIdentity, &certificate );
    
    if (status == noErr) {
        *certContent = SecCertificateCopyData(certificate);
        if (*certContent != nil) {
            
            NSData *certData = (NSData *)CFBridgingRelease(*certContent);
            *len = [certData length];
            // NSLog(@"cert content is<%@> len = %lu",certData,*len);
            
        }else{
            NSLog(@"get cert content falure");
        }
    }
    if (certificate) {
        CFRelease(certificate);
    }
    if (myTrust) {
        CFRelease(myTrust);
    }
    if (myIdentity) {
        CFRelease(myIdentity);
    }
    return status;
}
/*
 *get public key from server translate data
 *Method:getServerPublicKeyFromData
 *@param:data
 *@return:SecKeyRef publicKey
 *author:yangli wondersoft
 */
-(SecKeyRef)getPublicKeyFromData:(NSData *)data{
    
    OSStatus status = noErr;
    SecKeyRef serverPubKey = NULL;
    SecCertificateRef myCert = NULL;
    SecPolicyRef myPolicy = NULL;
    SecTrustRef serverTrust = NULL;
    SecTrustResultType trustResult;
    CFDataRef certData = (CFDataRef)CFBridgingRetain(data);
    myCert = SecCertificateCreateWithData(NULL, certData);
    //NSLog(@"myCert is (%@)",myCert);
    myPolicy = SecPolicyCreateBasicX509();
    SecCertificateRef certArray[1] = { myCert };
    CFArrayRef myCerts = CFArrayCreate(NULL, (void *)certArray,1, NULL);
    status = SecTrustCreateWithCertificates(myCerts,myPolicy,&serverTrust); 
    if (myCerts != nil) {
        CFRelease(myCerts);
        myCerts = nil;
    }
    if (status == noErr) {
        status = SecTrustEvaluate(serverTrust, &trustResult);      
        if (status == noErr) {
            
        }
    }
    if ((trustResult = kSecTrustResultRecoverableTrustFailure)) {
        NSLog( @"kSecTrustResultRecoverableTrustFailure, do something" );
    }
    serverPubKey = SecTrustCopyPublicKey( serverTrust );
    
    
    if (myCert) {
        CFRelease(myCert);
    }
    if (myPolicy) {
        CFRelease(myPolicy);
    }
    if (serverTrust) {
        CFRelease(serverTrust);
    }
    return serverPubKey;
}
/*
 *get public key from pfx
 *Method:getPublicKeyFromDevice
 *@param:pCertPath［in］:pfx cert full path
 strPassword［in］：pfx password
 publicKey［in／out］publicKey
 *@return:SecKeyRef publicKey
 *author:yangli wondersoft
 */
-(OSStatus)getPublicKeyFromPath:(NSString *)pCertPath 
                       password:(CFStringRef)strPassword
                         pubKey:(SecKeyRef *)publicKey{
    
    OSStatus status =noErr;
    SecTrustResultType trustResult;
    SecIdentityRef myIdentity;
    SecTrustRef myTrust;
    
    status = [self ExtractIdentityAndTrustFromPath:pCertPath
                                          password:strPassword
                                          identity:&myIdentity
                                             trust:&myTrust];
    if (status != noErr) {
        return status;
    }
    status = SecTrustEvaluate( myTrust, &trustResult );
    
    if ( kSecTrustResultRecoverableTrustFailure == trustResult ){
        
        NSLog( @"kSecTrustResultRecoverableTrustFailure, do something" );
    }
    *publicKey = SecTrustCopyPublicKey( myTrust );
    
    if (publicKey!=NULL) {
        status = noErr;
    }
    
    if (myIdentity) {
        CFRelease(myIdentity);
    }
    if (myTrust) {
        CFRelease(myTrust);
    }
    return status;
}
/*
 *get private key from pfx
 *Method:getPublicKeyFromDevice
 *@param:deviceType <0:CERTTYPE_PFX_USER 1:CERTTYPE_PFX_PRODUCT>
 *       pCertPath:pfx cert full path
 *       strPassword:pfx cert's password
 privateKey[out]:private key
 *@return:SecKeyRef publicKey
 *author:yangli wondersoft
 */
-(OSStatus)getPrivateKeyFromPath:(NSString *)pCertPath 
                        password:(CFStringRef)strPassword
                          prikey:(SecKeyRef *)privateKey{
    
    OSStatus status =noErr;
    SecIdentityRef myIdentity;
    SecTrustRef myTrust;
    
    status = [self ExtractIdentityAndTrustFromPath:pCertPath
                                          password:strPassword
                                          identity:&myIdentity
                                             trust:&myTrust];
    if (status != noErr) {
        return status;
    }
    status = SecIdentityCopyPrivateKey( myIdentity, privateKey );
    if (myIdentity) {
        CFRelease(myIdentity);
    }
    if (myTrust) {
        CFRelease(myTrust);
    }
    return status;
}

-(int)Certify_Verify_RootCert:(NSString *)path x509Cert:(X509 *)pX509UserCert
{
    int rv;
    X509 *pX509RootCert = NULL; //X509证书结构体，保存根证书
    X509_STORE_CTX *pStoreCTX = NULL;         //证书存储区句柄 
    X509_STORE *rootCertStore = NULL;   //证书存储区
    X509_LOOKUP *lookup = NULL;
    
    const char *rootCertPath = [path UTF8String];
    //新建X509证书存储区   
    rootCertStore = X509_STORE_new(); 
    
    lookup = X509_STORE_add_lookup(rootCertStore, X509_LOOKUP_file());
    if(!X509_LOOKUP_load_file(lookup, rootCertPath, X509_FILETYPE_ASN1))
    {
        if(!X509_LOOKUP_load_file(lookup, rootCertPath, X509_FILETYPE_PEM))
        {
            return -1;
        }
    }
    
    //添加根证书到证书存储区   
    /* X509_STORE_add_cert(rootCertStore,pX509RootCert);*/
    
    //设置检查CRL标志位，如果设置此标志位，则检查CRL，否则不检查CRL。   
    //X509_STORE_set_flags(rootCertStore,X509_V_FLAG_CRL_CHECK);
    X509_STORE_set_flags(rootCertStore,0);
    //添加CRL到证书存储区   
    //X509_STORE_add_crl(rootCertStore,Crl); 
    
    //新建证书存储区句柄   
    pStoreCTX = X509_STORE_CTX_new();  
    //初始化根证书存储区、用户证书1   
    rv = X509_STORE_CTX_init(pStoreCTX,rootCertStore,pX509UserCert,NULL);   
    if(rv != 1)   
    {         
        X509_free(pX509RootCert);   
        X509_STORE_CTX_cleanup(pStoreCTX);   
        X509_STORE_CTX_free(pStoreCTX);   
        X509_STORE_free(rootCertStore);   
        return -1;   
    }   
    //验证用户证书1   
    rv = X509_verify_cert(pStoreCTX);    
    if(rv != 1)   
    {   
        //rv = ERR_get_error();
        return -1;  
    }   
    
    else   
    {   
        NSLog(@"verify server cert OK");  
    }   
    
    //释放内存   
    X509_free(pX509RootCert);   
    X509_STORE_CTX_cleanup(pStoreCTX);   
    X509_STORE_CTX_free(pStoreCTX);   
    
    X509_STORE_free(rootCertStore); 
    return 0;
}

-(X509 *)Certify_GetX509CertData:(unsigned char *)x509data dataLen:(int) Len{
    
    BIO *pBIO_Cert = NULL;
    X509 *pX509Cert = NULL;
    
    unsigned long rv = 0;
//    unsigned long uRet = 0;
    
    pBIO_Cert = BIO_new(BIO_s_mem());
    if (NULL == pBIO_Cert)
    {
        
        if (NULL != pBIO_Cert) 
        {
            BIO_free(pBIO_Cert);
        }
        return NULL;
    }
    
    rv = BIO_write(pBIO_Cert, x509data, Len);
    if ( rv <= 0 ) 
    {
//        uRet = -1;
        if (NULL != pBIO_Cert) 
        {
            BIO_free(pBIO_Cert);
        }
        
        return NULL;
    }
    pX509Cert = d2i_X509_bio(pBIO_Cert, NULL);
    
    if (NULL == pX509Cert)
    {
//        uRet = -1;
        if (NULL != pBIO_Cert) 
        {
            BIO_free(pBIO_Cert);
        }
        return NULL;
    }

    return pX509Cert;
}




@end
