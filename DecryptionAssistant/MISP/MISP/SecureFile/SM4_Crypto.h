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


//SM4的算法原文
// =================== 第二种方法 =============================================
// SMS4的加解密函数    
// 参数说明：Input为输入信息分组，Output为输出分组，rk为轮密钥    
void SMS4Crypt(unsigned char *Input, unsigned char *Output, unsigned int *rk) ;

// SMS4的密钥扩展算法    
// 参数说明：Key为加密密钥，rk为子密钥，CryptFlag为加解密标志    
void SMS4KeyExt(unsigned char *Key, unsigned int *rk, unsigned int CryptFlag) ;

#endif //_SM4_CRYPTO_H