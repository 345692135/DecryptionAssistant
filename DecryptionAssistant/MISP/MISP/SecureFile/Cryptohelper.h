#ifndef _CRYPTO_HELPER_H
#define _CRYPTO_HELPER_H

#include <stdio.h>
#include "openssl/evp.h"
#include "string.h"


#ifndef ERRORINT
	typedef unsigned long long ERRORINT;
#endif

#ifndef BYTE
	typedef unsigned char BYTE;
#endif

#ifndef UINT
	//typedef unsigned long DWORD;
    typedef unsigned int UINT;//0625-ulong在pc上是32位，在iPhone5s之后是64位，占位不同

#endif

#ifndef LONGLONG
	typedef  long long  LONGLONG ;
#endif

#ifndef ULONGLONG
	typedef unsigned long long  ULONGLONG ;
#endif



#ifndef CRYPT_MODE_ENCRYPT
#define  CRYPT_MODE_ENCRYPT     1
#endif

#ifndef CRYPT_MODE_DECRYPT
#define  CRYPT_MODE_DECRYPT		0
#endif

#ifndef E_SUCCESS
#define E_SUCCESS               0
#endif

//加密解密错误
#define E_CRYPT                 0x1500

#define E_CRYPT_CIPHER_PARAM_ERROR              (E_CRYPT|0x01)
#define E_CRYPT_CIPHER_UPDATE_ERROR				(E_CRYPT|0x02)
#define E_CRYPT_CIPHER_FINAL_ERROR              (E_CRYPT|0x03)
#define E_CRYPT_CIPHER_NOTFOUND                 (E_CRYPT|0x04)

#define E_CRYPT_INIT_KEY_ERROR                  (E_CRYPT|0x05)
#define E_CRYPT_CRYPTCONTEXT_ERROR              (E_CRYPT|0x06)

#define E_CRYPT_DIGEST_NOTFOUND                 (E_CRYPT|0x07)
#define E_CRYPT_DIGEST_UPDATE_ERROR             (E_CRYPT|0x08)
#define E_CRYPT_DIGEST_FINAL_ERROR              (E_CRYPT|0x09)
#define E_CRYPT_CDIGESTCONTEXT_ERROR            (E_CRYPT|0x10)


/*
加密辅助函数，提供流式分组加密的算法库
 */
#define CRYPT_STATUS_INIT                       0x00
#define CRYPT_STATUS_UPDATE                     0x01
#define CRYPT_STATUS_FINAL                      0x02


//密钥算法，采用标准OpenSSL的定义，一般使用ecb模式，不用初始向量
typedef struct  _crypt_context_
{
	UINT dwEncMode;                            //加密解密的模式		1 加密   0 解密
	UINT dwCipherId;                           //加密解密的算法
	UINT dwKeyBlock;                           //分组算法的分组长度
	UINT dwStatus;                             //0 起始 1 Update 2Final
	ULONGLONG ullCountIn;                       //加密解密的总计大小
	ULONGLONG ullCountOut;                      //加密解密的总计大小
	BYTE  bKey[512];                            //加密、解密的密钥
	BYTE  biv[512];                             //加密、解密的初始向量
	EVP_CIPHER_CTX ctx;                         //OpenSSL加密时候用的context
}CRYPTCONTEXT,*PCRYPTCONTEXT;


typedef struct _digest_context_
{
	EVP_MD_CTX ctx;
	UINT dwDigestId;
	UINT dwStatus;
}CDIGESTCONTEXT,*PCDIGESTCONTEXT;

/*
 文件外发对应结构，控制外发文件的使用权限：
 使用时，保存到加密文件头中的bEncryptIdentify[256]字节数组中，
 对应的加密文件头dwEncryptSubType = ELABEL_FILE_SUBTYPE_DOCSOF
 */
//typedef struct _Document_Sof
//{
//	union
//	{
//		struct
//		{
//			wchar_t   wsUserName[G_LEN_USER_NAME]; // 认证用户名
//			wchar_t   wsPassword[G_LEN_PWD]; // 认证用户密码
//			UINT     dwDocId;		  // 外发文档id
//			UINT     dwUseCount;	  // 允许使用次数
//			ULONGLONG ullPermissionId;// 允许的文件权限
//			ULONGLONG ullStartTime;	  // 有效开始时间
//			ULONGLONG ullEndTime;	  // 有效结束时间
//		};
//		BYTE bBuffer[256];
//	};
//}DOCUMENTSOF,*PDOCUMENTSOF;

// 权限提升结构体
typedef struct _Permission_Approve
{
	union
	{
		struct
		{
			unsigned short   strUserSid[64];  // 提权用户Sid
			ULONGLONG ullPermissionId;// 提升的文件权限
		};
		BYTE bBuffer[256];
	};
}PERMISSIONAPPROVE,*PPERMISSIONAPPROVE;

typedef struct ElectronLabel_Head_BaseInfo
{
	union
	{
		struct
		{
			BYTE  bFlag[16];  // 设置标志位，标识是否是密文驱动层需要此常值来判断是我们的加密格式文件, 和驱动层约定好一个常值串即可,目前采用E-LABLE-00000010
			BYTE  bUserDefine[512]; // 标签用户定义字段，一般用于显示一些提示信息，标识此文件的注意事项（备注信息）如机密文档；绝密文档；一般文档，加密理由信息等
			BYTE  bEncFileSource[128]; // 标识加密文件的来源。一般会在应用层使用。如：APS加密得到；/主动加密得到。
			BYTE  bEncLevelId[128];    // 加密密级的唯一标识:标识加密文件等级（一般文档；保密文档；机密文档；绝密文档）
			UINT dwLicenseId;         // 记录认证信息，确保只有特定的厂家才可加解密
			UINT dwHeadVersion;       //ENCHEAD_VERSION_BASE  //加密头版本信息，加密头中结构（如用户权限结构）可以变更。版本号取值方式可以为：1,2,...N<<16
			UINT dwFileType;          // 文件的加密类型：未加密；在线加密；离线加密；
			UINT dwFileSubType;       // 文件子类型，通常用于定义bFileIdentify里面的解释,如文件外发类型；FileNet类型；明文外带等
			LONGLONG liFileSize;       // 待加密文件的原始大小
            
			UINT dwFileCount;         // 记录当前需要加密文档的个数;(多文件加密情况必须填写）
			UINT dwUserCount;         // 记录用户权限头用户个数（设置用户权限信息情况）
		};
		BYTE bBuffer[1024];            // 目前仅使用了304+512=816字节
	};
}ELECTRON_LABEL_HEAD_BASEINFO;

typedef struct ElectronLabel_Head_FileInfo
{
	union
	{
		struct
		{
			BYTE      bDocGUID[128];      // 文档唯一性标识信息,记录文档的guid
			UINT     dwDocVersion;		  // 文档的版本信息
			UINT     dwDocId;	          // 文档的Id, 驱动层需要此ID,在验证阶段, 和驱动层约定一个常值
			UINT     dwLastModifyUserId; // 最后修改人：UINT 驱动可以直接写入
			ULONGLONG ullLastModifyTime;  // 最后修改时间：ULONGLONG 驱动就可以直接写入
		};
		BYTE bBuffer[256];                // 目前仅使用了148字节
	};
    
}ELECTRON_LABEL_HEAD_FILEINFO;


// 算法密钥相关信息
typedef struct ElectronLabel_Head_AlgorithmInfo
{
	union
	{
		struct
		{
			UINT dwHashMethod;	         // CRYPT_DIGEST_METHOD_MD5 // 摘要算法
			UINT dwEncryptAlgID;        //WS_NID_aes_128_ecb  // 文档加密算法标识：AES, DES
			UINT dwEmergencyKeyType;    // EMERGENCYKEY_TYPE_INNER_CONFIG   //// // 紧急加密密钥类型（内置密钥|令牌密钥）
			UINT dwEmergencyKeyNum;     // 记录紧急密钥的序号
			UINT dwEncKeyType;          // ENCRYPTKEY_TYPE_ENCLEVEL；ENCRYPTKEY_TYPE_USER_SID   // 文件加密密钥类型（密级密钥|用户SID密钥）
			UINT dwEncKeyNum;           // 记录文件加密密钥的序号
		};
		BYTE bBuffer[128];               // 目前仅使用24字节
	};
}ELECTRON_LABEL_HEAD_ALGORITHMINFO;


/*
定义了加解密文件必须的数据信息，如加密算法信息；产品验证信息；
 文档唯一性标识，用户权限，子文件信息，日志等信息在密文中的偏移量；
 */
typedef struct _tag_ElectronLabel_Head
{
	union
	{
		//标签头域为固定长度字节
		struct
		{
			BYTE bReserve[4094];// 目前使用了2472字节
			BYTE bCheck1;		// 文件标签头校验位，恒定为0x79
			BYTE bCheck2;		// 文件标签头校验位，恒定为0x68
		};
		struct
		{
			ELECTRON_LABEL_HEAD_BASEINFO      elecHead_BaseInfo;      // 4k加密头中的基本信息（密文标识，密级Id， 文档加密来源等）
			ELECTRON_LABEL_HEAD_FILEINFO      elecHead_FileInfo;      // 4k加密头中的文件信息（文件guid, DocID,DocVersion, 最后修改人等）（只可以获取，不可以修改）
			ELECTRON_LABEL_HEAD_ALGORITHMINFO elecHead_AlgorithmInfo; // 加解密文件信息（加密算法标识，摘要算法标识，密钥类型等）
            
			BYTE  bUserSid[128];          // 用户的唯一标识(加密时需要更新这个字段）
            
			BYTE  bSignInfo[128];         // 签名信息：128BYTE采用系统内置私钥，加密摘要信息
			BYTE  bEncKeyInfo[256];       // 用户加密密钥信息
			BYTE  bEmergencyKeyInfo[256]; // 紧急密钥信息：256BYTE。采用系统内置（令牌）公钥，加密文件密钥，做为应急解密使用
			UINT dwEmergencyKeyLen;      // 记录紧急密钥的有效长度
			UINT dwEncKeyLen;            // 记录文件加密密钥的有效长度
            
			BYTE  bFileIdentify[256];     // 存放与dwFileSubType相关的结构体内容，如文件外发结构体DOCUMENTSOF内容等；
            
			LONGLONG  liAllocationSize;  // 文件的占用空间  （liFileSize）
			LONGLONG  liValidDataLength; // 文件有效的数据区（liFileSize）
            
			// 设置加密头偏移量
			UINT dwOffset_Text;     // 正文偏移：标识正文的起始位置，加速文档操作
			UINT dwOffset_LogInfo;  // 日志域偏移
			UINT dwOffset_UserInfo; // 用户权限域偏移
			UINT dwOffset_FileInfo; // 待加密文件信息偏移
		};
	};
}ELECTRON_LABEL_HEAD ,*PELECTRON_LABEL_HEAD;


//刷新算法
void Update_all_ciphers();

//=========加解密相关==========

//加解密 初始化
ERRORINT Crypt_Init(PCRYPTCONTEXT pContext);

//加密内容 可循环调用
ERRORINT Crypt_Update(PCRYPTCONTEXT pContext,BYTE* inData,int inLen,BYTE* outData,int* outLen);

//加密/解密完成，需要进行填充数据的处理
ERRORINT Crypt_Final(PCRYPTCONTEXT pContext,BYTE* outData,int* outLen);

//完成后 清理 ctx
ERRORINT Crypt_Cleanup(PCRYPTCONTEXT pContext);


//==========摘要相关==========

//摘要初始化
ERRORINT Digest_Init(PCDIGESTCONTEXT pContext);

//摘要内容 可循环调用
ERRORINT Digest_Update(PCDIGESTCONTEXT pContext,BYTE* inData,size_t inLen);

//摘要内容 完成 输出结果
ERRORINT Digest_Final(PCDIGESTCONTEXT pContext,BYTE* outData,unsigned int* outLen);

//完成后 清理 ctx
ERRORINT Digest_Cleanup(PCDIGESTCONTEXT pContext);



//Function Tools   工具函数
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//初始化 CRYPTCONTEXT 结构体 并校验 是否存在 算法
ERRORINT Init_CRYPTCONTEXT(PCRYPTCONTEXT pContext,
						   UINT dwCipherId ,
						   UINT dwEncMode,
						   BYTE* pkey ,
						   int nKeyLen,
						   BYTE* piv,
						   int nivLen
						   );


ERRORINT Init_CDIGESTCONTEXT(PCDIGESTCONTEXT pContext,
                             UINT dwDigestId);


#endif  //_CRYPTO_HELPER_H






