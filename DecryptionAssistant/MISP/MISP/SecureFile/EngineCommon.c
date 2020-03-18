
#include "EngineCommon.h"
//#include "SW_Crypto.cpp"
#include "SM4_Crypto.h"


static int ws_cipher_test1_init_key(EVP_CIPHER_CTX *ctx, const unsigned char *key,
								  const unsigned char *iv, int enc)
{
	GetEncData(ctx)->iEnc = enc;
	if (NULL != key) memcpy(GetEncData(ctx)->key,key,sizeof(GetEncData(ctx)->key));
	if (NULL != iv) memcpy(GetEncData(ctx)->iv,key,sizeof(GetEncData(ctx)->iv));
	return 1;
}

static int ws_cipher_test1_cleanup(EVP_CIPHER_CTX *ctx)
{
	return 1;
}

static int ws_cipher_test1_cipher(EVP_CIPHER_CTX *ctx, unsigned char *out,
								const unsigned char *in, size_t inl)
{
	size_t nNow = 0;
	for(nNow = 0; nNow<inl; nNow++)
	{
		if (GetEncData(ctx)->iEnc)
		{//加密
			*(out+nNow) = (*(in+nNow) ^ GetEncData(ctx)->key[(nNow%32)]) + 7;
		}
		else
		{//解密
			*(out+nNow) = (*(in+nNow) - 7) ^ GetEncData(ctx)->key[(nNow%32)];
		}
	}
	return 1;
}


const EVP_CIPHER ws_cipher_struct_sw_cbc = {
	WS_NID_sw_128_cbc,
	16,  16, 16,
	EVP_CIPH_CBC_MODE,
	NULL,
	NULL,
	NULL,
	5*1024,
	NULL,
	NULL,
	NULL,
	NULL
};

const EVP_CIPHER ws_cipher_struct_sm4_cbc = {
	WS_NID_sm4_128_cbc,
	16,  16, 16,
	EVP_CIPH_CBC_MODE,
	ws_cipher_sm4_init_key,
	ws_cipher_sm4_cipher,
	ws_cipher_sm4_cleanup,
	5*1024,
	NULL,
	NULL,
	NULL,
	NULL
};

const EVP_CIPHER ws_cipher_struct_test_1 = {
	WS_NID_test_1_cbc,
	1,  1, 1,
	EVP_CIPH_CBC_MODE,
	ws_cipher_test1_init_key,
	ws_cipher_test1_cipher,
	ws_cipher_test1_cleanup,
	5*1024,
	NULL,
	NULL,
	NULL,
	NULL
};

static RSA_METHOD ws_rsa =
{
	"SW-Crypto's RSA Functions",
		ws_rsa_public_encrypt,
		ws_rsa_public_decrypt,
		ws_rsa_private_encrypt,
		ws_rsa_private_decrypt,
		ws_rsa_mod_exp,
		ws_rsa_bn_mod_exp,
		ws_rsa_init,
		ws_rsa_finish,
		0,//RSA_FLAG_SIGN_VER,
		NULL,
		ws_rsa_sign,
		ws_rsa_verify
};

void ws_engine_ERR_load_P11_strings()
{
	return;
}

static int ws_engine_bind(ENGINE *e)
{
	if(!ENGINE_set_id(e, ws_engine_id)
		|| !ENGINE_set_name(e, ws_engine_name)
		//|| !ENGINE_set_RSA(e, &ws_rsa)
		|| !ENGINE_set_ciphers(e, ws_ciphers_distribute)
		//|| !ENGINE_set_digests(e, p11_digests)
		|| !ENGINE_set_destroy_function(e, ws_engine_destroy)
		|| !ENGINE_set_init_function(e, ws_engine_init)
		|| !ENGINE_set_finish_function(e, ws_engine_finish)
		/* || !ENGINE_set_ctrl_function(e, p11_ctrl) */
		/* || !ENGINE_set_cmd_defns(e, p11_cmd_defns) */)
	{
//		CLog::WriteLog2(L"ws_engine_bind Error");
		return 0;
	}

	/* Ensure the p11 error handling is set up */
	ws_engine_ERR_load_P11_strings();
//	CLog::WriteLog2(L"ws_engine_bind OK");
	return 1;
}


//#ifdef ENGINE_DYNAMIC_SUPPORT
static int ws_engine_bind_helper(ENGINE *e, const char *id)
{
	if(id && (strcmp(id, ws_engine_id) != 0))
		return 0;
	if(!ws_engine_bind(e))
		return 0;
	return 1;
}       

IMPLEMENT_DYNAMIC_CHECK_FN();

IMPLEMENT_DYNAMIC_BIND_FN(ws_engine_bind_helper)

//#else
static ENGINE *ws_engine(void)
{
	ENGINE *ret = ENGINE_new();
	if(!ret) return NULL;
	if(!ws_engine_bind(ret))
	{
		ENGINE_free(ret);
		return NULL;
	}
	return ret;
}

static int display_engine_list()
{
	ENGINE *h;
	int loop;
	
	h = ENGINE_get_first();
	loop = 0;
 //   CLog::WriteLog2(L"listing available engine types <%d>",__LINE__);
	while(h)
	{
//		CLog::WriteLog2(L"engine %i, id = \"%S\", name = \"%S\"",
	//		loop++, ENGINE_get_id(h), ENGINE_get_name(h));
		h = ENGINE_get_next(h);
	}
//	CLog::WriteLog2(L"end of list");
	/* ENGINE_get_first() increases the struct_ref counter, so we 
	must call ENGINE_free() to decrease it again */
	ENGINE_free(h);

	return loop;
}

ERRORINT Eng_Init(char* cSetting)
{
	ERRORINT eRet = E_SUCCESS;

	ENGINE *engine=NULL;
//	USES_CONVERSION;

//	CLog::WriteLog2(L"ENGINE Eng_Init Settings=%s",A2W(cSetting));

	ERR_load_ENGINE_strings();

	//加载引擎
	engine = ws_engine();
//	CLog::WriteLog2(L"ws_engine result:%X",engine);
	if (NULL == engine)
	{
		eRet = E_CRYPT;
		goto __Eng_Init_End;
	}

	if (!ENGINE_add(engine))
	{
	//	CLog::WriteLog2(L"ws_engine ENGINE_add Failed");
	//	eRet = MakeErrorCode(ERR_get_error(),E_CRYPT_CIPHER_ENGINE);
		eRet = E_CRYPT;
		goto __Eng_Init_End;
	}

	if (!ENGINE_set_default(engine,ENGINE_METHOD_CIPHERS))
	{
	//	CLog::WriteLog2(L"ws_engine ENGINE_set_default Failed");
	//	eRet = MakeErrorCode(ERR_get_error(),E_CRYPT_CIPHER_ENGINE);
		eRet =E_CRYPT;
		goto __Eng_Init_End;
	}

	if (!ENGINE_register_ciphers(engine))
	{
	//	CLog::WriteLog2(L"ws_engine ENGINE_register_ciphers Failed");
//		eRet = MakeErrorCode(ERR_get_error(),E_CRYPT_CIPHER_ENGINE);
		eRet =E_CRYPT;
		goto __Eng_Init_End;
	}

__Eng_Init_End:

	if (NULL != engine) ENGINE_free(engine);

	ERR_clear_error();

	display_engine_list();

//	CLog::WriteLog2(L"ENGINE Eng_Init return 0x%I64X",eRet);
	return eRet;
}
//#endif


/****************************************************************************
*			 Constants used when creating the ENGINE						*
***************************************************************************/

static int ws_engine_init(ENGINE *e)
{
	int iRet = 1;
//	ERRORINT eRet = E_SUCCESS;
//	eRet = ws_cipher_sw_init();
//	CLog::WriteLog2(L"ws_engine_init return %I64X %X",eRet,iRet);
	return iRet;
}

static int ws_engine_finish(ENGINE *e)
{
	int iRet = 1;
//	ERRORINT eRet = E_SUCCESS;
//	eRet = ws_cipher_sw_finish();
//	CLog::WriteLog2(L"ws_engine_finish return %I64X %X",eRet,iRet);
	return iRet;
}

static int ws_engine_destroy(ENGINE *e)
{
//	CLog::WriteLog2(L"ws_engine_destroy  OK");
	return 1;
}

/****************************************************************************
 *			RSA functions													*
*****************************************************************************/
static int ws_rsa_public_encrypt(int len, const unsigned char *from,
							 unsigned char *to, RSA *rsa, int padding)
{
	return RSA_PKCS1_SSLeay()->rsa_pub_enc(len, from, to, rsa, padding);
}

static int ws_rsa_public_decrypt(int len, const unsigned char *from,
							 unsigned char *to, RSA *rsa, int padding)
{
	return RSA_PKCS1_SSLeay()->rsa_pub_dec(len, from, to, rsa, padding);
}

static int ws_rsa_private_encrypt(int len, const unsigned char *from,
							  unsigned char *to, RSA *rsa, int padding)
{
	return RSA_PKCS1_SSLeay()->rsa_priv_enc(len, from, to, rsa, padding);
}

static int ws_rsa_private_decrypt(int len, const unsigned char *from,
							  unsigned char *to, RSA *rsa, int padding)
{
	return RSA_PKCS1_SSLeay()->rsa_priv_dec(len, from, to, rsa, padding);
}

static int ws_rsa_mod_exp(BIGNUM *r0,const BIGNUM *I,RSA *rsa,BN_CTX *ctx)
{
	return RSA_PKCS1_SSLeay()->rsa_mod_exp(r0,I,rsa,ctx);
}

static int ws_rsa_bn_mod_exp(BIGNUM *r, const BIGNUM *a, const BIGNUM *p,
						 const BIGNUM *m, BN_CTX *ctx,
						 BN_MONT_CTX *m_ctx)
{
	return RSA_PKCS1_SSLeay()->bn_mod_exp(r,a,p,m,ctx,m_ctx);
}

static int ws_rsa_init(RSA *rsa)
{
	return RSA_PKCS1_SSLeay()->init(rsa);
}

static int ws_rsa_finish(RSA *rsa)
{
	return RSA_PKCS1_SSLeay()->finish(rsa);
}

static int ws_rsa_sign(int type,
					   const unsigned char *m, unsigned int m_length,
					   unsigned char *sigret, unsigned int *siglen, const RSA *rsa)
{
	return RSA_PKCS1_SSLeay()->rsa_sign(type,m,m_length,sigret,siglen,rsa);
}

static int ws_rsa_verify(int dtype,
						 const unsigned char *m, unsigned int m_length,
						 const unsigned char *sigbuf, unsigned int siglen, const RSA *rsa)
{
	return RSA_PKCS1_SSLeay()->rsa_verify(dtype,m,m_length,sigbuf,siglen,rsa);
}


/****************************************************************************
*			Symetric cipher and digest function registrars (COMMON)			*
*****************************************************************************/

static void ctrl()
{
	return;
}

static int ws_ciphers_distribute(ENGINE *e, const EVP_CIPHER **cipher,
						 const int **nids, int nid)
{
	if (!cipher)
	{
		return (ws_ciphers_get_cryptodev_ciphers(nids));
	}

	switch (nid) {
		case WS_NID_sw_128_cbc:
			*cipher = &ws_cipher_struct_sw_cbc;
			break;
		case WS_NID_sm4_128_cbc:
			*cipher = &ws_cipher_struct_sm4_cbc;
			break;
		case WS_NID_test_1_cbc:
			*cipher = &ws_cipher_struct_test_1;
			break;
	default:
		*cipher = NULL;
		break;
	}
	return (*cipher != NULL);
}

static int
ws_ciphers_max_iv(int cipher)
{
	int i;

	for (i = 0; ciphers[i].id; i++)
		if (ciphers[i].id == cipher)
			return (ciphers[i].ivmax);
	return (0);
}

static int
ws_ciphers_key_length_valid(int cipher, int len)
{
	int i;

	for (i = 0; ciphers[i].id; i++)
		if (ciphers[i].id == cipher)
			return (ciphers[i].keylen == len);
	return (0);
}

/* convert libcrypto nids to cryptodev */
static int ws_ciphers_nid_to_cryptodev(int nid)
{
	int i;

	for (i = 0; ciphers[i].id; i++)
		if (ciphers[i].nid == nid)
			return (ciphers[i].id);
	return (0);
}

/*
* Find out what ciphers /dev/crypto will let us have a session for.
* XXX note, that some of these openssl doesn't deal with yet!
* returning them here is harmless, as long as we return NULL
* when asked for a handler in the cryptodev_engine_ciphers routine
*/
static int ws_ciphers_get_cryptodev_ciphers(const int **cnids)
{
	static int nids[CRYPTO_ALGORITHM_MAX];
	int i, count = 0;

	for (i = 0; ciphers[i].id && count < CRYPTO_ALGORITHM_MAX; i++) {
		if (ciphers[i].nid == NID_undef)
			continue;
		nids[count] = ciphers[i].nid;
		count++;
	}
	if (count > 0)
		*cnids = nids;
	else
		*cnids = NULL;
	return (count);
}
