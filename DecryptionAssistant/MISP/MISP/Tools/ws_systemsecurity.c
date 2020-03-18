//
//  ws_systemsecurity.c
//  MISP
//
//  Created by Mr.Cooriyou on 12-10-25.
//
//

#include <stdio.h>
#include <string.h>
#include "ws_systemsecurity.h"
#include "rsa.h"
#include "evp.h"

#define KEY_KEYLEN_SOFT 160

const unsigned char g_bIKey[] = {
	0xFD,0xD0,0x48,0xC5,0x59,0xBC,0xE6,0x25,0x9D,0xB5,0x17,0x69,0x4C,0x9E,0xC9,0x5D,0xC2,0x57,0xCC,0x7F,0xE6,0x49,0x3F,0x1B,0xDC,0x3B,0x02,0x0B,0x14,0xC5,0x3B,0x2B
	,0x46,0x98,0x4C,0x95,0xAC,0xCD,0x6D,0xE9,0xE3,0xF6,0xFF,0xA8,0x8C,0xA5,0x58,0xEE,0x16,0xE2,0xE5,0x88,0xB6,0xDD,0x61,0x2B,0xFA,0x01,0xC8,0x0F,0xF3,0x55,0xBC,0xF4
	,0xF8,0x3A,0xC9,0x10,0x1F,0x5A,0x72,0x3E,0x71,0x7F,0xFB,0x86,0x6D,0xC1,0x5D,0xEF,0x42,0x74,0x3A,0x58,0x2F,0x10,0x16,0x59,0xD5,0xCA,0x20,0x27,0x27,0xF5,0xA4,0xC6
	,0xC7,0xC5,0x8E,0x7A,0xE9,0x62,0xFF,0xFF,0x4C,0xAC,0x5E,0xB5,0xA1,0xB7,0x3C,0x78,0xA3,0x7B,0x8D,0x22,0x6A,0x66,0x56,0x90,0x49,0x80,0x97,0xE6,0x3C,0x88,0x3C,0x92
	,0xC3,0x8F,0x87,0xEB,0x05,0x5A,0xDC,0x29,0x14,0xA4,0x0F,0xEF,0x2F,0xC6,0xFC,0xF5,0x8B,0xCB,0x37,0x27,0xE5,0xA6,0xD0,0x2B,0xC0,0x97,0xE8,0x91,0x75,0x98,0xE1,0x51
    
	,0x90,0x0D,0xC2,0xFF,0x9F,0x6B,0x03,0x04,0x9E,0x79,0xC5,0x8B,0xD2,0x1C,0xDD,0x15,0x05,0xD4,0x67,0x10,0xC0,0x57,0x1A,0x26,0x69,0xDC,0x63,0xD0,0x7E,0x3D,0x62,0xD3
	,0xB1,0x01,0x87,0x95,0xFB,0xB9,0xAC,0x84,0x6F,0x0A,0x25,0x18,0x38,0x9B,0x2F,0xDA,0x11,0xCB,0x3D,0x93,0x56,0x96,0x57,0x2C,0x6A,0x7C,0xD0,0x5B,0x9D,0x34,0x30,0x46
	,0xA9,0x0C,0x54,0x49,0x7E,0x42,0x0B,0x4D,0x3D,0x85,0xF1,0xEF,0xDE,0x23,0x3D,0x78,0x08,0xD9,0xD7,0x0B,0xB3,0xFC,0x95,0xD1,0xCC,0xD2,0xAE,0x5A,0x5B,0x00,0x64,0x2F
	,0x9F,0x63,0x17,0x59,0x7B,0x77,0xE1,0xBC,0xD4,0x7C,0xDC,0x18,0xF6,0x00,0xF5,0xC7,0x11,0xEB,0x4F,0xA5,0xB2,0xDA,0x7A,0x54,0x1E,0x5D,0xF1,0x62,0x28,0xDE,0x2B,0xA1
	,0x3D,0x98,0xE7,0x37,0xA0,0xC9,0x7F,0xAA,0x95,0x07,0x96,0xB6,0x68,0xC0,0x5E,0xFA,0x3D,0x37,0xCD,0x96,0x89,0x10,0x2A,0xCE,0x73,0xE9,0x9F,0xF8,0x74,0x37,0xFF,0x71
};

unsigned char eNow[4]={0x00,0x01,0x00,0x01};

void str2bin(const char* szSrc, unsigned char* bHex, int* nOut);

void cryptoInit()
{
    OpenSSL_add_all_ciphers();
	OpenSSL_add_all_digests();
    OpenSSL_add_all_algorithms();
}

long Ikey_Encrypt(unsigned char* plainText,size_t plainTextLen,unsigned char* cipherText,size_t* cipherTextLen)
{
    long lRet = 0;
    RSA *pRsaKey = NULL;
    
    OpenSSL_add_all_ciphers();
	OpenSSL_add_all_digests();
    OpenSSL_add_all_algorithms();
    
    pRsaKey = RSA_new();
    if (pRsaKey == NULL) {
        return -1;
    }
    pRsaKey->e=BN_bin2bn(eNow,4,NULL);
    pRsaKey->n=BN_bin2bn(g_bIKey,KEY_KEYLEN_SOFT,NULL);
    pRsaKey->d=BN_bin2bn(g_bIKey+KEY_KEYLEN_SOFT,KEY_KEYLEN_SOFT,NULL);
    
    lRet = RSA_public_encrypt(plainTextLen,plainText,cipherText,pRsaKey,RSA_PKCS1_PADDING);
    
    if (lRet != -1) {
        *cipherTextLen = lRet;
    }
    RSA_free(pRsaKey);
    pRsaKey = NULL;
    
    return lRet;
}

long Ikey_Decrypt(unsigned char* cipherText,size_t cipherTextLen,unsigned char* plainText,size_t* plainTextLen)
{
    long lRet = 0;
    RSA *pRsaKey = NULL;
    OpenSSL_add_all_ciphers();
	OpenSSL_add_all_digests();
    OpenSSL_add_all_algorithms();
    
    pRsaKey = RSA_new();
    if (pRsaKey == NULL) {
        return -1;
    }
    pRsaKey->e=BN_bin2bn(eNow,4,NULL);
    pRsaKey->n=BN_bin2bn(g_bIKey,KEY_KEYLEN_SOFT,NULL);
    pRsaKey->d=BN_bin2bn(g_bIKey+KEY_KEYLEN_SOFT,KEY_KEYLEN_SOFT,NULL);
    
    lRet = RSA_private_decrypt(cipherTextLen, cipherText, plainText, pRsaKey, RSA_PKCS1_PADDING);
    
    if (lRet != -1) {
        *plainTextLen = lRet;
    }
    
    RSA_free(pRsaKey);
    pRsaKey = NULL;
    
    return lRet;
}

//long IKeyRawSignSha1(unsigned char* dataToSign,size_t dataToSignLen,unsigned char* sig,size_t* sigLen)
//{
//    long lRet = 0;
//    RSA *pRsaKey = NULL;
//    
//    OpenSSL_add_all_ciphers();
//	OpenSSL_add_all_digests();
//    OpenSSL_add_all_algorithms();
//    
//    pRsaKey = RSA_new();
//    if (pRsaKey == NULL) {
//        return -1;
//    }
//    pRsaKey->e=BN_bin2bn(eNow,4,NULL);
//    pRsaKey->n=BN_bin2bn(g_bIKey,KEY_KEYLEN_SOFT,NULL);
//    pRsaKey->d=BN_bin2bn(g_bIKey+KEY_KEYLEN_SOFT,KEY_KEYLEN_SOFT,NULL);
//    
//    lRet = RSA_sign(NID_sha1, dataToSign, dataToSignLen, sig, (unsigned int*)sigLen, pRsaKey);
//    
//    RSA_free(pRsaKey);
//    pRsaKey = NULL;
//    
//    return lRet;
//}

long IKeyRawSignSha1(unsigned char* dataToSign,size_t dataToSignLen,unsigned char* sig,size_t* sigLen)
{
    long lRet = 0;
    RSA *pRsaKey = NULL;
    EVP_MD_CTX md_ctx;
    
    
    OpenSSL_add_all_ciphers();
	OpenSSL_add_all_digests();
    OpenSSL_add_all_algorithms();
    
    pRsaKey = RSA_new();
    if (pRsaKey == NULL) {
        return -1;
    }
    pRsaKey->e=BN_bin2bn(eNow,4,NULL);
    pRsaKey->n=BN_bin2bn(g_bIKey,KEY_KEYLEN_SOFT,NULL);
    pRsaKey->d=BN_bin2bn(g_bIKey+KEY_KEYLEN_SOFT,KEY_KEYLEN_SOFT,NULL);
    
//    lRet = RSA_sign(NID_sha1, dataToSign, dataToSignLen, sig, (unsigned int*)sigLen, pRsaKey);
    
    EVP_PKEY *evpKey = EVP_PKEY_new(); //新建一个EVP_PKEY变量
    if (evpKey == NULL) {
        return -1;
    }
    
    EVP_PKEY_set1_RSA(evpKey, pRsaKey);  //保存RSA结构体到EVP_PKEY结构体
    
    EVP_SignInit(&md_ctx, EVP_sha1()); 
    EVP_SignUpdate (&md_ctx, dataToSign, dataToSignLen);
    lRet = EVP_SignFinal(&md_ctx, sig, (unsigned int*)sigLen,evpKey);
    
    EVP_PKEY_free(evpKey);
    RSA_free(pRsaKey);
    pRsaKey = NULL;
    
    return lRet;
}

long IKeyRawVerifySha1(unsigned char* signedData, size_t signedDataLen,unsigned char* sig,size_t sigLen)
{
    long lRet = 0;
    RSA *pRsaKey = NULL;
    EVP_MD_CTX md_ctx;
    
    OpenSSL_add_all_ciphers();
	OpenSSL_add_all_digests();
    OpenSSL_add_all_algorithms();
    
    pRsaKey = RSA_new();
    if (pRsaKey == NULL) {
        return -1;
    }
    pRsaKey->e=BN_bin2bn(eNow,4,NULL);
    pRsaKey->n=BN_bin2bn(g_bIKey,KEY_KEYLEN_SOFT,NULL);
    pRsaKey->d=BN_bin2bn(g_bIKey+KEY_KEYLEN_SOFT,KEY_KEYLEN_SOFT,NULL);
    
//    lRet = RSA_verify(NID_sha1, signedData, signedDataLen, sig, (unsigned int)sigLen, pRsaKey);
    
    EVP_PKEY *evpKey = EVP_PKEY_new(); //新建一个EVP_PKEY变量
    if (evpKey == NULL) {
        return -1;
    }
    
    EVP_PKEY_set1_RSA(evpKey, pRsaKey);  //保存RSA结构体到EVP_PKEY结构体
    
    EVP_SignInit(&md_ctx, EVP_sha1());
    /* Verify the signature */
	EVP_VerifyUpdate(&md_ctx, sig, sigLen);
	lRet = EVP_VerifyFinal (&md_ctx, signedData, signedDataLen, evpKey);
    
    EVP_PKEY_free(evpKey);
    RSA_free(pRsaKey);
    pRsaKey = NULL;
    
    return lRet;
}

/*
long LevelKey_Encrypt(const char* key,unsigned char* plainText,size_t plainTextLen,unsigned char* cipherText,size_t* cipherTextLen)
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
    
    
    str2bin(key, bKeyHex, &iLen);
    
    
    RSA* rsa1 = RSA_new();
	if (NULL == rsa1)
        return -1;
    
    printf("XXXXXXXXX");
    //set n
    lRet = Ikey_Decrypt(bKeyHex, KEY_KEYLEN_SOFT, bN, &nLen);
    if (lRet == -1) {
        RSA_free(rsa1);
        rsa1 = NULL;
        return lRet;
    }
    rsa1->n=BN_bin2bn(bN,nLen,NULL);
    printf("XXXXXXXXX");
    //set d
    nLen = 0;
    lRet = Ikey_Decrypt(bKeyHex+KEY_KEYLEN_SOFT, KEY_KEYLEN_SOFT, bD, &nLen);
    if (lRet == -1) {
        RSA_free(rsa1);
        rsa1 = NULL;
        return lRet;
    }
    rsa1->d=BN_bin2bn(bD,nLen,NULL);
    
    //set e
    rsa1->e=BN_bin2bn(eNow,4,NULL);
    
    if (rsa1 == NULL) {
        return -1;
    }
    
    lRet = RSA_public_encrypt(plainTextLen,plainText,cipherText,rsa1,RSA_PKCS1_PADDING);
    
    if (lRet != -1) {
        *cipherTextLen = lRet;
    }
    
    RSA_free(rsa1);
    rsa1 = NULL;
    
    return lRet;
}

long LevelKey_Decrypt(const char* key,unsigned char* cipherText,size_t cipherTextLen,unsigned char* plainText,size_t* plainTextLen)
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
    
    
    str2bin(key, bKeyHex, &iLen);
    
    
    RSA* rsa1 = RSA_new();
	if (NULL == rsa1)
        return -1;
    
    
    //set n
    lRet = Ikey_Decrypt(bKeyHex, KEY_KEYLEN_SOFT, bN, &nLen);
    if (lRet == -1) {
        RSA_free(rsa1);
        rsa1 = NULL;
        return lRet;
    }
    rsa1->n=BN_bin2bn(bN,nLen,NULL);
    
    //set d
    nLen = 0;
    lRet = Ikey_Decrypt(bKeyHex+KEY_KEYLEN_SOFT, KEY_KEYLEN_SOFT, bD, &nLen);
    if (lRet == -1) {
        RSA_free(rsa1);
        rsa1 = NULL;
        return lRet;
    }
    rsa1->d=BN_bin2bn(bD,nLen,NULL);
    
    //set e
    rsa1->e=BN_bin2bn(eNow,4,NULL);
    
    if (rsa1 == NULL) {
        return -1;
    }
    
    lRet = RSA_private_decrypt(cipherTextLen, cipherText, plainText, rsa1, RSA_PKCS1_PADDING);
    if (lRet != -1) {
        *plainTextLen = lRet;
    }
    
    RSA_free(rsa1);
    rsa1 = NULL;
    
    return lRet;
    
}

void str2bin(const char* szSrc, unsigned char* bHex, int* nOut)
{
	int i = 0;
	int n = 0;
	size_t nlen = 0;
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

*/
