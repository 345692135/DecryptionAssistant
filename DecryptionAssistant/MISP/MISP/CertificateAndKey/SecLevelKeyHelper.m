//
//  SecLevelKeyHelper.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-11-19.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import "SecLevelKeyHelper.h"
#include "rsa.h"
#include "evp.h"
#include <string.h>

#include "ws_systemsecurity.h"

#define KEY_KEYLEN_SOFT 160
#define KEY_KEYLEN      128

void str2bin(const char* szSrc, unsigned char* bHex, int* nOut);

@interface SecLevelKeyHelper()
{
    RSA* rsa;
}
@property(nonatomic)RSA* rsa;

@end

@implementation SecLevelKeyHelper
@synthesize rsa;

unsigned char bE[4]={0x00,0x01,0x00,0x01};

- (id)initWithLevelKeyString:(NSString*)key
{
    long lRet = 0;
    self = [super init];
    if (self) {

        lRet =[self keytoRSA:key];
        if (lRet == -1) {
            return nil;
        }
    }
    return self;
}

- (void)dealloc
{
    if (NULL != rsa) RSA_free(rsa);
    rsa = nil;
//    [super dealloc];
}


#pragma mark make rsa

- (long)keytoRSA:(NSString*)key
{
    int iLen = 0;
    long lRet = 0;
    size_t nLen = 0;
    unsigned char bN[1024] = {0};
    unsigned char bD[1024] = {0};
    unsigned char bKeyHex[1024] = {0};
    
    OpenSSL_add_all_ciphers();
	OpenSSL_add_all_digests();
    OpenSSL_add_all_algorithms();
    
    //change key to byte
    if ([key length] == 0)
        return -1;
    str2bin1([key UTF8String], bKeyHex, &iLen);

    if (NULL != rsa) RSA_free(rsa);
    
    rsa = RSA_new();
	if (NULL == rsa)
        return -1;
    //set n
    lRet = Ikey_Decrypt(bKeyHex, KEY_KEYLEN_SOFT, bN, &nLen);
    if (lRet == -1) {
        RSA_free(rsa);
        rsa = nil;
        return lRet;
    }
    rsa->n=BN_bin2bn(bN,nLen,NULL);

    //set d
    nLen = 0;
    lRet = Ikey_Decrypt(bKeyHex+KEY_KEYLEN_SOFT, KEY_KEYLEN_SOFT, bD, &nLen);
    if (lRet == -1) {
        RSA_free(rsa);
        rsa = nil;
        return lRet;
    }
    rsa->d=BN_bin2bn(bD,nLen,NULL);
    
    //set e
    rsa->e=BN_bin2bn(bE,4,NULL);
    
    return lRet;
    
}



void str2bin1(const char* szSrc, unsigned char* bHex, int* nOut)
{
	int i = 0;
	int n = 0;
	int nlen = 0;
	char temp[3] = {0};
    
	// null point
	if (NULL == szSrc)
	{
		return ;
	}
    
	//get src string length
	nlen = strlen(szSrc);
    
	while(1)
	{
		memset(temp, 0, 3);
		memcpy(temp, szSrc+n, 2);
		*(bHex+i) = strtoul(temp, NULL, 16);
		++i;
		n+=2;
		if (i>(nlen/2))
		{
			break; // %02x is size x 2
		}
	}
    
	*nOut = (i-1);
	return;
}


#pragma mark encrypt method

- (long)levelKeyEncrypt:(const unsigned char*) plainText
                 length:(size_t) plainTextLen
             cipherText:(unsigned char*) cipherText
              outLength:(size_t*) cipherTextLen
{
    long lRet = 0;

    if (rsa == nil) {
        return -1;
    }
    
    lRet = RSA_public_encrypt(plainTextLen,plainText,cipherText,rsa,RSA_PKCS1_PADDING);
    
    if (lRet != -1) {
        *cipherTextLen = lRet;
    }
    
    return lRet;
}

- (long)levelKeyDecrypt:(const unsigned char*) cipherText
                 length:(size_t) cipherTextLen
              plainText:(unsigned char*) plainText
              outLength:(size_t*) plainTextLen
{
    long lRet = 0;
    
    if (rsa == nil) {
        return -1;
    }
    
    lRet = RSA_private_decrypt(cipherTextLen, cipherText, plainText, rsa, RSA_PKCS1_PADDING);
    if (lRet != -1) {
        *plainTextLen = lRet;
    }
    return lRet;
}



@end
