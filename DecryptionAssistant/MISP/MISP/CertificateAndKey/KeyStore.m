//
//  KeyStore.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-11-19.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import "KeyStore.h"
#import "CertificateHelper.h"

@interface KeyStore (){

    NSString *certPath;
    NSString *certPin;
    
    CertificateHelper *certificatInstane;
    
@private
    SecKeyRef           publicKeyRef;
    SecKeyRef           privateKeyRef;
    
}

@property(nonatomic,retain)NSString *certPath;
@property(nonatomic,retain)NSString *certPin;



-(OSStatus)loadFromP12CertPath;

@end

@implementation KeyStore

@synthesize certType = _certType;
@synthesize certPath,certPin;


-(id)initWithType:(int)type{
    
    if (self = [super init]) {
        
        _certType = type;
        NSLog(@"self.certType = [%d]",self.certType);
        
        certificatInstane = [[CertificateHelper alloc] init];
        
    }
    
    return self;
}

-(long)load:(NSString *)path password:(NSString *)pwd{

    //check path and pwd
    if (path != NULL) {
        
        switch (self.certType) {
                
            case kCERTIFICATE_PKCS12:
            {
                //process p12 certificate from cert path
                if (!self.certPath) {
                    
                    self.certPath = path;
                    NSLog(@"certPath = <%@>\n",certPath);
                    NSLog(@"certPath count = [%ld]",[certPath retainCount]);
                }
                if (!self.certPin) {
                    self.certPin = pwd;
                    NSLog(@"certPin = <%@>\n",certPin);
                }
                
                OSStatus status = [self loadFromP12CertPath];
                if (status != noErr) {
                    return -1;
                }
                
                break;
            }
            case kCERTIFICATE_PKCS7:
            {
                return kUNSURPORTCERTTYPE;
            }
                
            default:
                break;
        }
        
    }
    
    return 0;
    
}

-(SecKeyRef)returnPublicKey{

    return publicKeyRef;
    
}

-(SecKeyRef)returnPrivateKey{

    return privateKeyRef;
}


-(OSStatus)loadFromP12CertPath{

    OSStatus status = noErr;
    status = [certificatInstane getPublicKeyFromPath:self.certPath password:(CFStringRef)self.certPin pubKey:&publicKeyRef];
    if (status != noErr) {
        return status;
    }
    status = [certificatInstane getPrivateKeyFromPath:self.certPath password:(CFStringRef)self.certPin prikey:&privateKeyRef];
    if (status != noErr) {
        return status;
    }
    
    return status;
}

-(void)dealloc{
    
    [certPath release];
    [certPin release];
    
    
    if(privateKeyRef) CFRelease(privateKeyRef);
    
    if(publicKeyRef) CFRelease(publicKeyRef);
    
    [certificatInstane release];

    [super dealloc];
}

@end
