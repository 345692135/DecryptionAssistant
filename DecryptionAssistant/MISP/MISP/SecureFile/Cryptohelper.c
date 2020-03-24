
#include "Cryptohelper.h"
#include "EngineCommon.h"



static int m_iEngineLoaded = 0;


//Debug text
//ERRORINT Eng_Init(char* cSetting)
//{
//	return E_SUCCESS;
//}

//***********************************************
//Function Name: Update_all_ciphers
//Function Ability:	Update_all_ciphers
//
//Parameter Description
//
//NONE
//
//ReturnValue: NONE
//***********************************************
void Update_all_ciphers()
{
	OpenSSL_add_all_ciphers();
	OpenSSL_add_all_digests();
	OpenSSL_add_all_algorithms();
}


//***********************************************
//Function Name: Crypt_Init
//Function Ability:	Init EVP_CIPHER_CTX with CRYPTCONTEXT
//
//Parameter Description
//
//pContex         : CRYPTCONTEXT object point
//
//ReturnValue: E_SUCCESS
//***********************************************
ERRORINT Crypt_Init(PCRYPTCONTEXT pContext)
{

	ERRORINT eRet=E_SUCCESS;
	const EVP_CIPHER *pCipher =NULL;

	if (0 == m_iEngineLoaded)
	{
		eRet = Eng_Init("Test");

		if (E_SUCCESS != eRet)
		{
			return eRet;
		}
		m_iEngineLoaded = 1;
	}

	//���ȸ�ݼ����㷨��ʶ���ҵ��㷨
	pCipher = EVP_get_cipherbynid(pContext->dwCipherId);
	if (NULL == pCipher)
	{
		return E_CRYPT_CIPHER_NOTFOUND;
	}

	//��ʼ���㷨
	if (!EVP_CipherInit(&pContext->ctx,pCipher,pContext->bKey,pContext->biv,pContext->dwEncMode))
	{
		return E_CRYPT_CIPHER_NOTFOUND;
	}

	//���㷨����д����
	pContext->dwKeyBlock = EVP_CIPHER_CTX_block_size(&pContext->ctx);
	if (0 == pContext->dwKeyBlock) pContext->dwKeyBlock = 1;

	return eRet;
}

//***********************************************
//Function Name: Crypt_Update
//Function Ability: Call it When Encry or Decry Context process
//
//Parameter Description
//
//pContex	: CRYPTCONTEXT object point
//inData  	: input source Data
//inLen		: inData len (OUT)
//outData	: output Encry or Decry Data
//outLen	: outData len (OUT)
//
//ReturnValue: E_SUCCESS 
//***********************************************

ERRORINT Crypt_Update(PCRYPTCONTEXT pContext,BYTE* inData,int inLen,BYTE* outData,int* outLen)
{

	if (NULL == pContext || NULL == inData || NULL == outData || 0 == inLen)
	{
		return E_CRYPT_CIPHER_PARAM_ERROR;
	}
	if (CRYPT_STATUS_INIT != pContext->dwStatus &&  CRYPT_STATUS_UPDATE != pContext->dwStatus)
	{
		return E_CRYPT_CRYPTCONTEXT_ERROR;
	}

	pContext->dwStatus = CRYPT_STATUS_UPDATE;

	//����ģʽ
	if (0 == pContext->dwCipherId)
	{
		memcpy(outData,inData,inLen);
		*outLen=inLen;
		//add count
		pContext->ullCountIn+=inLen;
		pContext->ullCountOut+=(*outLen);

		return E_SUCCESS;
	}

	
	//int	EVP_CipherUpdate(EVP_CIPHER_CTX *ctx, unsigned char *out, int *outl, const unsigned char *in, int inl);
	if (!EVP_CipherUpdate(&pContext->ctx,outData,outLen,inData,inLen) )
	{
		return E_CRYPT_CIPHER_UPDATE_ERROR;
	}

	//add count
	pContext->ullCountIn+=inLen;
	pContext->ullCountOut+=(*outLen);

	return E_SUCCESS;
}

//***********************************************
//Function Name: Crypt_Final
//Function Ability: Call it When Encry Decry Context to finish 
//
//Parameter Description
//
//pContex	: CRYPTCONTEXT object point
//outData	: output Surplus Data in CTX Buf
//outLen	: outData len (OUT)
//
//ReturnValue: E_SUCCESS 
//***********************************************
ERRORINT Crypt_Final(PCRYPTCONTEXT pContext,BYTE* outData,int* outLen)
{
	if (NULL == outData || NULL == pContext)
	{
		return E_CRYPT_CIPHER_PARAM_ERROR;
	}
	//״̬����
	if (CRYPT_STATUS_UPDATE != pContext->dwStatus)
	{
		return	E_CRYPT_CRYPTCONTEXT_ERROR;
	}

	//����ģʽ
	if (0 == pContext->dwCipherId)
	{
		return E_SUCCESS;
	}
	
	if (!EVP_CipherFinal(&pContext->ctx,outData,outLen) )
	{
		return E_CRYPT_CIPHER_FINAL_ERROR;
	}

	pContext->dwStatus=CRYPT_STATUS_FINAL;

	pContext->ullCountOut+=(*outLen);
	
	return E_SUCCESS;

}

//***********************************************
//Function Name: Crypt_Cleanup
//Function Ability: Cleanup Crypto Context struct
//
//Parameter Description
//
//pContex	: CRYPTCONTEXT object point
//
//ReturnValue: E_SUCCESS 
//***********************************************
ERRORINT Crypt_Cleanup(PCRYPTCONTEXT pContext)
{
	if (NULL == pContext)
	{
		return E_CRYPT_CIPHER_PARAM_ERROR;
	}

	EVP_CIPHER_CTX_cleanup(&pContext->ctx);

	pContext->dwStatus=CRYPT_STATUS_INIT;

	return E_SUCCESS;
}

//***********************************************
//Function Name: Init_Digest_Contents
//Function Ability: Init Digest Context struct
//
//Parameter Description
//
//pContext		: CDIGESTCONTEXT object point
//
//ReturnValue: E_SUCCESS 
//***********************************************

ERRORINT Digest_Init(PCDIGESTCONTEXT pContext)
{
	const EVP_MD* md=NULL;
	if (NULL == pContext)
	{
		return E_CRYPT_CIPHER_PARAM_ERROR;
	}
	
	md=EVP_get_digestbynid(pContext->dwDigestId);
	if (NULL == md)
	{
		return E_CRYPT_DIGEST_NOTFOUND;
	}

	EVP_MD_CTX_init(&pContext->ctx);

	if (!EVP_DigestInit_ex(&pContext->ctx,md,NULL) )
	{
		return E_CRYPT_DIGEST_NOTFOUND;
	}
	return E_SUCCESS;
}

//***********************************************
//Function Name: Digest_Update
//Function Ability: Call it When Digest Context process
//
//Parameter Description
//
//pContext		: CDIGESTCONTEXT object point
//inData			: input source Data
//inLen			: inData len (OUT)
//
//ReturnValue: E_SUCCESS 
//***********************************************
ERRORINT Digest_Update(PCDIGESTCONTEXT pContext,BYTE* inData,size_t inLen)
{
	if (NULL == pContext || NULL == inData || 0 == inLen)
	{
		return E_CRYPT_CIPHER_PARAM_ERROR;
	}
	if (CRYPT_STATUS_INIT != pContext->dwStatus &&  CRYPT_STATUS_UPDATE != pContext->dwStatus)
	{
		return E_CRYPT_CDIGESTCONTEXT_ERROR;
	}
	
	pContext->dwStatus=CRYPT_STATUS_UPDATE;

	if (!EVP_DigestUpdate(&pContext->ctx,inData,inLen))
	{
		return E_CRYPT_DIGEST_UPDATE_ERROR;
	}

	return E_SUCCESS;
}


//***********************************************
//Function Name: Digest_Final
//Function Ability: Call it When Digest Context to finish 
//
//Parameter Description
//
//CONT		: CDIGESTCONTEXT object point
//outData	: output Value in CTX 
//outLen	: outData len (OUT)
//
//ReturnValue: E_SUCCESS 
//***********************************************

ERRORINT Digest_Final(PCDIGESTCONTEXT pContext,BYTE* outData,unsigned int* outLen)
{

	if (NULL == outData || NULL == pContext)
	{
		return E_CRYPT_CIPHER_PARAM_ERROR;
	}

	//״̬����
	if (CRYPT_STATUS_UPDATE != pContext->dwStatus)
	{
		return	E_CRYPT_CDIGESTCONTEXT_ERROR;
	}

	if(!EVP_DigestFinal_ex(&pContext->ctx,outData,outLen))
	{
		return E_CRYPT_DIGEST_FINAL_ERROR;
	}

	pContext->dwStatus=CRYPT_STATUS_FINAL;


	return E_SUCCESS;
}


//***********************************************
//Function Name: Crypt_Cleanup
//Function Ability: Cleanup Digest Contexts struct
//
//Parameter Description
//
//pContex	: CRYPTCONTEXT object point
//
//ReturnValue: E_SUCCESS 
//***********************************************
ERRORINT Digest_Cleanup(PCDIGESTCONTEXT pContext)
{
	if (NULL == pContext)
	{
		return E_CRYPT_CIPHER_PARAM_ERROR;
	}

	EVP_MD_CTX_cleanup(&pContext->ctx);

	pContext->dwStatus=CRYPT_STATUS_INIT;

	return E_SUCCESS;
}



//Function Tools
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



//***********************************************
//Function Name: Init_CRYPTCONTEXT
//Function Ability: Init struct CRYPTCONTEXT point
//
//Parameter Description
//
//pContext      : PCRYPTCONTEXT point
//dwCipherId    : Cipher NID  Will be use Cipher Mode
//dwEncMode     : 1 Encrypt    0 Decrypt
//key			: Encrypt Key
//nKeyLen		:Key Length
//iv			: Will be used in ecb mode
//nivLen		: iv Length
//ReturnValue: E_SUCCESS
//***********************************************
ERRORINT Init_CRYPTCONTEXT(PCRYPTCONTEXT pContext,
						   UINT dwCipherId ,
						   UINT dwEncMode,
						   BYTE* pkey , 
						   int nKeyLen,
						   BYTE* piv,
						   int nivLen
						   )
{
	const EVP_CIPHER *pCipher = NULL;
	if (NULL == pkey || NULL == pContext  ||  NULL == piv || 0 == nKeyLen)
	{
		return E_CRYPT_CIPHER_PARAM_ERROR;
	}

	pContext->dwEncMode = 0;
	pContext->dwCipherId = 0;
	pContext->dwKeyBlock = 0;
	pContext->ullCountIn = 0;
	pContext->ullCountOut = 0;
	pContext->dwStatus = CRYPT_STATUS_INIT;
	memset(pContext->bKey,0,sizeof(pContext->bKey));
	memset(pContext->biv,0,sizeof(pContext->biv));
	memset(&pContext->ctx,0,sizeof(pContext->ctx));

//    if(NID_camellia_128_cfb128 == dwCipherId) dwCipherId = NID_aes_256_cfb128;
	pContext->dwCipherId=dwCipherId;
	//Check NID
	pCipher = EVP_get_cipherbynid(pContext->dwCipherId);
	if (NULL == pCipher)
	{
		return E_CRYPT_CIPHER_NOTFOUND;
	}

	//1 Encrypt    0 Decrypt
	pContext->dwEncMode=dwEncMode;
	//key
	memcpy(pContext->bKey,pkey,nKeyLen);
	//iv  ecb  need
	memcpy(pContext->biv,piv,nivLen);

	return E_SUCCESS;
}
/*

ERRORINT Get_CipherKey(BYTE* pData,int nDataLen,DWORD dwCipherId, BYTE* key , BYTE* iv)
{

	const EVP_CIPHER *pCipher=NULL;
	int nROUND_FOR_KEY=3;
	int nRet=0;
	if (NULL == pData || 0 == nDataLen )
	{
		return E_CRYPT_CIPHER_PARAM_ERROR;
	}

	pCipher = EVP_get_cipherbynid(dwCipherId);

	if (NULL == pCipher)
	{
		return E_CRYPT_CIPHER_NOTFOUND;
	}

	nRet=EVP_BytesToKey(pCipher,EVP_md5(),NULL,pData,nDataLen,nROUND_FOR_KEY,key,iv);
	if (nRet==0)
	{
		return E_CRYPT_INIT_KEY_ERROR;
	}

	return E_SUCCESS;
}
*/
//***********************************************
//Function Name: Init_CDIGESTCONTEXT
//Function Ability: Init struct CDIGESTCONTEXT point
//
//Parameter Description
//
//pContext			: PCRYPTCONTEXT point
//dwCipherId		: Cipher NID  Will be use Cipher Mode
//dwEncMode         : 1 Encrypt    0 Decrypt
//key				: Encrypt Key
//iv				: Will be used in ecb mode
//ReturnValue: E_SUCCESS
//***********************************************
ERRORINT Init_CDIGESTCONTEXT(PCDIGESTCONTEXT pContext, UINT dwDigestId)
{
	const EVP_MD* md=NULL;
	pContext->dwDigestId=dwDigestId;
	//Check NID
	md=EVP_get_digestbynid(pContext->dwDigestId);
	if (NULL == md)
	{
		return E_CRYPT_DIGEST_NOTFOUND;
	}

	return E_SUCCESS;
}










