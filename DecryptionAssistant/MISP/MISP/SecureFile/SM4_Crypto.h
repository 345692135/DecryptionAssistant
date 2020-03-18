#ifndef _SM4_CRYPTO_H
#define _SM4_CRYPTO_H

#include <openssl/engine.h>
#include "EngineCommon.h"

#define KEYLEN_sm4	16

static ERRORINT ws_cipher_sm4_init();
static ERRORINT ws_cipher_sm4_finish();

/****************************************************************************
*			Functions to handle the engine									*
*****************************************************************************/

int ws_cipher_sm4_init_key(EVP_CIPHER_CTX *ctx, const unsigned char *key,
								  const unsigned char *iv, int enc);

int ws_cipher_sm4_cleanup(EVP_CIPHER_CTX *ctx);

int ws_cipher_sm4_cipher(EVP_CIPHER_CTX *ctx, unsigned char *out,
								const unsigned char *in, size_t inl);


//SM4���㷨ԭ��
// =================== �ڶ��ַ��� =============================================
// SMS4�ļӽ��ܺ���    
// ����˵����InputΪ������Ϣ���飬OutputΪ������飬rkΪ����Կ    
void SMS4Crypt(unsigned char *Input, unsigned char *Output, unsigned int *rk) ;

// SMS4����Կ��չ�㷨    
// ����˵����KeyΪ������Կ��rkΪ����Կ��CryptFlagΪ�ӽ��ܱ�־    
void SMS4KeyExt(unsigned char *Key, unsigned int *rk, unsigned int CryptFlag) ;

#endif //_SM4_CRYPTO_H