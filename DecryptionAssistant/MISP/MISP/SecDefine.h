//
//  SecDefine.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-9-12.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#ifndef MISP_SecDefine_h
#define MISP_SecDefine_h


/************************************************************************/
/*  文档权限 */
/************************************************************************/
#define WEB_PERMISSION_READ						    1	/// 读
#define WEB_PERMISSION_WRITE						2	/// 写
#define WEB_PERMISSION_PRINT_WATER			        4	/// 带水印打印
#define WEB_PERMISSION_COPY						    8	/// 拷贝
#define WEB_PERMISSION_SNAP						    16  /// 截屏
#define WEB_PERMISSION_PRINT_WATER_NO		        32  /// 无水印打印
#define WEB_PERMISSION_SAVE_AS					    64  /// 另存
#define WEB_PERMISSION_DECRYPT					    128 /// 脱密
#define WEB_PERMISSION_OFFLINE					    256 /// 离线
#define WEB_PERMISSION_BRING_OUT				    512 /// 外带


/************************************************************************/
/*  算法ID */
/************************************************************************/
#define  WS_NID_aes_128_ecb                         418 //AES算法
#define  WS_NID_aes_128_cbc                         419
#define  CRYPT_DIGEST_METHOD_MD5                    0x0200


/************************************************************************/
/*  返回值 */
/************************************************************************/
#define WS_SUCCESS                                  0x00000000				//成功

#define WS_ERROR									0x00080000
#define WS_NULL_PTR                                 (WS_ERROR|0x0001)		//空指针的错误
#define WS_CANNOT_GET_CERT_KEY_INFO                 (WS_ERROR|0x0002)		//不能获取证书与密钥的错误
#define WS_PIN_ERROR								(WS_ERROR|0x0003)		//Pin码错误
#define WS_CRYPT_CIPHER_NOTFOUND                    (WS_ERROR|0x0004)		//找不到算法
#define WS_CRYPT_CONTEXT_CANNOT_INIT                (WS_ERROR|0x0005)		//上下文初始化失败
#define WS_NO_MEMORY                                (WS_ERROR|0x0006)		//分配不出来内存
#define WS_KEY_CIPHER_RSA_ERROR                     (WS_ERROR|0x0007)		//RSA 加解密错误
#define WS_CRYPT_UPDATE_ERROR                       (WS_ERROR|0x0008)		//加解密错误
#define WS_CRYPT_FINAL_ERROR                        (WS_ERROR|0x0009)		//加解密错误(最后一段数据)
#define WS_NO_CRYPT_FILE_TYPE                       (WS_ERROR|0x000A)		//非密文数据
#define WS_CANNOT_SUPPORT_OPT                       (WS_ERROR|0x000B)		//不支持的操作
#define WS_CRYPT_FILE_TYPE                          (WS_ERROR|0x000C)

//加密库信息
#define E_CRYPTOPT                                  0x0600
#define E_CRYPTOPT_KEYID_NOTSUPPORT                 (E_CRYPTOPT | 0x01)
#define E_CRYPTOPT_KEYVERIFY_ERROR                  (E_CRYPTOPT | 0x02)
#define E_CRYPTOPT_RSA_OPT                          (E_CRYPTOPT | 0x03)
#define E_CRYPTOPT_SECULEVEL_ERROR                  (E_CRYPTOPT | 0x04)
#define E_CRYPTOPT_BUFFER_ERROR                     (E_CRYPTOPT | 0x05)
#define E_CRYPTOPT_POINT_NULL_ERROR                 (E_CRYPTOPT | 0x06)

//通用错误
#define E_COMMON_ERROR                              0x0100
#define E_PARAM_IS_NULL                             (E_COMMON_ERROR|0x01)
#define E_LOADLIB_ERROR                             (E_COMMON_ERROR|0x02)
#define E_LOADLIB_FUN_NULL                          (E_COMMON_ERROR|0x03)
#define E_BUFFER_SMALL                              (E_COMMON_ERROR|0x04)
#define E_STRUCT_SIZE                               (E_COMMON_ERROR|0x05)
#define E_MEM_FULL                                  (E_COMMON_ERROR|0x06)
#define E_TARGET_NOTFOUND                           (E_COMMON_ERROR|0x07)
#define E_LICENSE                                   (E_COMMON_ERROR|0x08)
#define E_PARAM_NOTSUPPORT                          (E_COMMON_ERROR|0x09)
#define E_MODULE_DLL_NOTFOUND                       (E_COMMON_ERROR|0x0A)
#define E_XMLCMD_NOTSUPPORT                         (E_COMMON_ERROR|0x0B)
#define E_GLOBAL_MEM_NULL                           (E_COMMON_ERROR|0x0C)
#define E_TIME_ERROR                                (E_COMMON_ERROR|0x0D)
#define E_MALLOCMEM_ERROR                           (E_COMMON_ERROR|0x0E)	//分配内存错
#define E_OVER_MAX_SIZE                             (E_COMMON_ERROR|0x0F)	//超过大小限制

//打开文件方式（创建；打开）
#define FILE_OPEN_TYPE_OPEN_EXISTING                0x0001
#define FILE_OPEN_TYPE_OPEN_ALWAYS                  0x0002
#define FILE_OPEN_TYPE_CREATE_ALWAYS                0x0008

#define  FILE_READ_OPEN_EXISTING_OPEN_MODE          (FILE_OPEN_TYPE_OPEN_EXISTING|FILE_ACCESS_READ|FILE_SHARE_ATTR_READ)
#define  FILE_WRITE_CREATE_ALWAYS_OPEN_MODE         (FILE_OPEN_TYPE_CREATE_ALWAYS|FILE_ACCESS_WRITE|FILE_SHARE_ATTR_READ)
#define  FILE_WRITE_OPEN_EXISTING_OPEN_MODE         (FILE_OPEN_TYPE_OPEN_EXISTING|FILE_ACCESS_WRITE|FILE_SHARE_ATTR_READ)

/*
 文件解密方式
 */
#define  DECRYPT_FILE_MODE_ALL                      0x14 // 解密所有文件
#define  DECRYPT_FILE_MODE_MULTI_INDEX              0x15 // 多文件加密时， 解密指定索引的文件
#define  DECRYPT_FILE_MODE_MULTI_NAME               0x16 // 多文件加密时， 解密指定文件名的文件

/*
 系统临时文件名
 */
#define  SYSTEMPFILENAME                            L"_EncDec."
//#define  WCHAR_SIZE      (sizeof(wchar_t))

//文件的访问权限
#define FILE_ACCESS_READ                            0x0010
#define FILE_ACCESS_WRITE                           0x0020

//文件共享权限
#define FILE_SHARE_ATTR_READ                        0x0040
#define FILE_SHARE_ATTR_WRITE                       0x0080
#define FILE_SHARE_ATTR_DELETE                      0x0100

//文件FLAG权限
#define FILE_FLAG_ATTR_NO_BUFFER                    0x0200
#define FILE_FLAG_ATTR_RANDOM_ACCESS                0x0400

#define ENCBUFFER_LEN                               4096*10     //40960 //加解密分组长度
#define SECTOR_SIZE                                 512         //扇区大小（读取的数据必须是扇区大小的倍数）
#define ENCUSERKEY_LEN                              32          //用户密钥长度
#define FILEINFO_MAX_FILE_COUNT                     16          //（必须是16倍数）
#define USERINFO_MAX_USER_COUNT                     16          //（必须是16倍数）单个用户结构中最大支持16个用户
#define ELABEL_FILE_FLAG                            ("E-LABLE-00000010")//密文标志
#define ELABEL_FILE_FLAG_EXTERN_1                   ("SCDSA002")//外部支持的加密密文标志（韩国DRM）

#define ELABEL_FILE_TYPE_SINGLE_NOENC               0x01		// 文件加密类型：单个脱密文件，主要用于穿透或者本来就是明文
#define ELABEL_FILE_TYPE_SINGLE_GRADE               0x04		// 文件加密类型：单个密级加密文档，用密级加密的
#define ELABEL_FILE_TYPE_SINGLE_PERSONAL            0x03		// 文件加密类型：单个加密文档，用个人密钥加密的（提权以后的）
#define ELABEL_FILE_TYPE_SINGLE_REMOTE              0x02		// 文件加密类型：远程文档（内容在服务器上）
#define ELABEL_FILE_TYPE_ONLY_ENC                   0x10		//（驱动里面的，需要确认）不带权限的加密文件，无需权限控制，直接透明解密
#define ELABEL_FILE_TYPE_MULTI                      0x20		// 多文档

#define ELABEL_FILE_SUBTYPE_UNKNOWN					0x00		//文件子类型：未知类型
#define ELABEL_FILE_SUBTYPE_SINGLE_GRADE_MANU		0x0201		//文件子类型：主动加密的单个密级文档
#define ELABEL_FILE_SUBTYPE_SINGLE_GRADE_AUTO		0x0202		//文件子类型：自动加密的单个密级文档
#define ELABEL_FILE_SUBTYPE_SINGLE_GRADE_APS		0x0203		//文件子类型：APS下载加密的单个密级文档

#define ELABEL_FILE_SUBTYPE_SINGLE_PERSONAL_APPROVE 0x0301		//文件子类型：权限提升后的文档
#define ELABEL_FILE_SUBTYPE_SINGLE_DOCSOF			0x0302		//文件子类型：外带以后的文档（只有密码）
#define ELABEL_FILE_SUBTYPE_SINGLE_APPROVE          0x0303      //文件子类型：权限审批中的文档。

#define ELABEL_FILE_HEAD_ENCHEAD                    0x12		// 加密文件头：加密头部分
#define ELABEL_FILE_HEAD_USERINFO                   0x13		// 加密文件头：用户权限部分
#define ELABEL_FILE_HEAD_FILEINFO                   0x14		// 加密文件头：待加密文件信息部分
#define ELABEL_FILE_HEAD_LOGINFO                    0x15		// 加密文件头：日志信息部分

#define ELABEL_FILE_HEAD_SUBTYPE_ALL                0x16        //（设置的头顺序必须是ELABEL_FILE_HEAD_SUBTYPE_BASEINFO，ELABEL_FILE_HEAD_SUBTYPE_BASEINFO)
#define ELABEL_FILE_HEAD_SUBTYPE_BASEINFO           0x17        // 密文标识，密级Id，加密文件来源，文件子类型，明文文件大小等信息）
#define ELABEL_FILE_HEAD_SUBTYPE_FILEINFO           0x18        // 的文档docid, docversion,docguid,最后修改人，最后修改时间等信息）
#define ELABEL_FILE_HEAD_SUBTYPE_ALGORITHMINFO      0x19        // 保存了4k加密头中的算法摘要信息

//进度状态
#define PROCESS_STATUS_START                        0x20		// 开始
#define PROCESS_STATUS_RUN                          0x21        // 进行中（加解密操作进行时，程序设置状态为该值）
#define PROCESS_STATUS_CANCEL                       0x22		// 取消（如果想取消操作，用户可设置该值）
#define PROCESS_STATUS_FINISH                       0x23		// 完成（加解密操作完成后，程序自动设置状态为该值）

//定义默认的密钥长度
#define KEY_KEYLEN_SOFT                             160         //默认的内置密钥的长度
#define KEY_KEYLEN                                  128         //用户密钥长度

//定义算法标识
#define CRYPT_OPT_KEY_TYPE_ENC                      0x00
#define CRYPT_OPT_KEY_TYPE_DEC                      0x01
#define CRYPT_OPT_KEY_TYPE_PUB                      0x00
#define CRYPT_OPT_KEY_TYPE_PRI                      0x02

//定义使用的密钥类型
#define CRYPT_KEYID_PKEY                            0x01        //使用【P-KEY】进行运算
#define CRYPT_KEYID_IKEY                            0x02        //使用【I-KEY】进行运算
#define CRYPT_KEYID_INPUTKEY                        0x03        //使用输入的KEY，明文
#define CRYPT_KEYID_INPUTKEY_ENCED                  0x04        //使用输入的KEY，但是这个KEY是经过了【I-KEY.Public】加密的
#define CRYPT_KEYID_CONFIGKEY                       0x05        //为和之前的兼容，使用一个固定的3DES密钥进行运算

// 紧急密钥类型（内置类型；口令类型）
enum EmergencyKeyType
{
	EMERGENCYKEY_TYPE_INNER_CONFIG = 0,
	EMERGENCYKEY_TYPE_HARD_CONFIG  = 1
};

// 加解密文件的密钥类型（密级密钥；用户sid密钥）
enum EncryptKeyType
{
	ENCRYPTKEY_TYPE_ENCLEVEL  = 0, // 密级密钥采用非对称算法对真正密钥加密
	ENCRYPTKEY_TYPE_USER_SID  = 1, // 用户sid采用非对称算法对真正密钥加密
	ENCRYPTKEY_TYPE_DOC_SOF   = 2, // 口令密码SHA1值采用对称算法对真正密钥加密
};

// 解密文件类型（紧急密钥；密级密钥）
enum DecryptFileKeyType
{
	DECRYPTFILEKEY_TYPE_EMERGENCYKEY = 0,
	DECRYPTFILEKEY_TYPE_ENCLEVEL     = 1
};

// 加密头版本信息
enum EncHead_Version_Info
{
	ENCHEAD_VERSION_BASE  = 0, // 该版本的加密头中不设置文件内容的摘要信息
	ENCHEAD_VERSION_V1    = 1,
	ENCHEAD_VERSION_V2    = 2
};



typedef void* CRYPTOHANDLE;

typedef struct _file_contex_
{
	unsigned char bContext[1200];
    
}FILECONTEXT,*PFILECONTEXT;

#endif
