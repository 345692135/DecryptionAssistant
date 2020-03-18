//
//  KeyStore.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-11-19.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kUNSURPORTCERTTYPE 0x10001

typedef enum {

    kCERTIFICATE_PKCS7,
    kCERTIFICATE_PKCS10,
    kCERTIFICATE_PKCS12
    
}CERTIFY_TYPE;



@interface KeyStore : NSObject{

    int _certType;

    
}

@property(nonatomic,assign)int certType;


-(id)initWithType:(int)type;
-(long)load:(NSString *)path password:(NSString *)pwd;
-(SecKeyRef)returnPublicKey;
-(SecKeyRef)returnPrivateKey;

@end
