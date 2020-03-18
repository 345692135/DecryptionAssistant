#ifndef _ENGINE_COMMON_H
#define _ENGINE_COMMON_H

#include "openssl/engine.h"
#include "Cryptohelper.h"

#ifndef WS_NID_sm4_128_cbc
#define WS_NID_sm4_128_cbc		NID_camellia_128_cfb128
#define WS_NID_sw_128_cbc		NID_camellia_128_ofb128
#define WS_NID_test_1_cbc		NID_seed_ofb128
#endif

ERRORINT Eng_Init(char* cSetting);

/****************************************************************************
 *			 Constants used when creating the ENGINE						*
 ***************************************************************************/
static const char *ws_engine_id =	"SW-Crypto-Engine";
static const char *ws_engine_name = "SW-Crypto-Engine";

static int ws_engine_destroy(ENGINE *e);
static int ws_engine_init(ENGINE *e);
static int ws_engine_finish(ENGINE *e);

/****************************************************************************
 *			RSA functions													*
*****************************************************************************/
static int ws_rsa_public_encrypt(int len, const unsigned char *from,
								 unsigned char *to, RSA *rsa, int padding);

static int ws_rsa_public_decrypt(int len, const unsigned char *from,
							 unsigned char *to, RSA *rsa, int padding);

static int ws_rsa_private_encrypt(int len, const unsigned char *from,
							  unsigned char *to, RSA *rsa, int padding);

static int ws_rsa_private_decrypt(int len, const unsigned char *from,
								  unsigned char *to, RSA *rsa, int padding);

static int ws_rsa_mod_exp(BIGNUM *r0,const BIGNUM *I,RSA *rsa,BN_CTX *ctx);

static int ws_rsa_bn_mod_exp(BIGNUM *r, const BIGNUM *a, const BIGNUM *p,
								const BIGNUM *m, BN_CTX *ctx,
								BN_MONT_CTX *m_ctx);

static int ws_rsa_init(RSA *rsa);

static int ws_rsa_finish(RSA *rsa);

static int ws_rsa_sign(int type,
				const unsigned char *m, unsigned int m_length,
				unsigned char *sigret, unsigned int *siglen, const RSA *rsa);

static int ws_rsa_verify(int dtype,
				  const unsigned char *m, unsigned int m_length,
				  const unsigned char *sigbuf, unsigned int siglen, const RSA *rsa);

/****************************************************************************
*			Symetric cipher and digest function registrars (COMMON)			*
*****************************************************************************/
#define CRYPTO_ALGORITHM_MAX 10

//making the array of cipher parameters. nid is defined here.
static struct {
	int	id;
	int	nid;
	int	ivmax;
	int	keylen;
} ciphers[] = {
	{ 1,		WS_NID_sm4_128_cbc,	16,	16, },
	{ 2,		WS_NID_sw_128_cbc,	16,	16, },
	{ 3,		WS_NID_test_1_cbc,	1,	1, },
	{ 0,				NID_undef,		0,	 0, },
};

//分发函数
static int ws_ciphers_distribute(ENGINE *e, const EVP_CIPHER **cipher,
									const int **nids, int nid);

static int ws_ciphers_max_iv(int cipher);
static int ws_ciphers_key_length_valid(int cipher, int len);
static int ws_ciphers_nid_to_cryptodev(int nid);
static int ws_ciphers_get_cryptodev_ciphers(const int **cnids);

//相关的一些结构体
typedef struct
{
	int iEnc;
	unsigned char key[32];
	unsigned char iv[32];
	UINT rk[32];	//SM4用
} CTX_DATA;
#define GetEncData(ctx) ((CTX_DATA *)(ctx)->cipher_data)

#endif //_ENGINE_COMMON_H