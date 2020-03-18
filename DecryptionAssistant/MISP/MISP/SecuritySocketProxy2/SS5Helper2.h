//
//  SS5Helper.h
//  MISP
//
//  Created by Cooriyou on 13-7-16.
//
//

#import "WSBaseObject.h"

#pragma pack(1)
typedef struct _tag_Frame_Header_
{
    union{
        struct{
            
            BYTE    bVer;               //协议版本号:  8 bits
            BYTE    bTos;               //产品编号:    8 bits
            BYTE    bZip;               //是否加密
            BYTE    bReserved;          //保留数据1
            unsigned int   dwTotalLen;  //帧总长度:   32 bits （字节为单位，包括自身头的总长度）
            WORD    wKeyLen;            //加密通讯密钥实际长度: 16 bits （字节为单位）
            WORD    wFrameChksum;       //包校验值:   16 bits
            unsigned int    dwOrgLen;   //原始数据长度（字节为单位，应用层头+内容压缩前长度）
            
        };
        BYTE bBuffer[16];
    };
    
} FRAMEHEADER,*PFRAMEHEADER;
#pragma pack()

@interface SS5Helper2 : WSBaseObject

//+(BOOL)SS5IdentifyWithServer:(NSInputStream*)inputStream outStream:(NSOutputStream*)outputStream remoteIp:(NSString*) ip remotePort:(NSInteger)port;

/**
 *  与服务器进行认证
 *
 *  @param inputStream  数据输入流
 *  @param outputStream 数据输出流
 *
 *  @return 认证成功返回TRUE
 */
+(BOOL)Identify:(NSInputStream*)inputStream outStream:(NSOutputStream*)outputStream;

/**
 *  加密数据
 *
 *  @param szSrc   明文数据
 *  @param iSrcLen 明文数据长度
 *  @param szDst   加密后返回的密文数据
 *  @param iDstLen 加密后返回的密文长度
 *  @param iZip    标识
 *
 *  @return 成功返回TRUE
 */
+(BOOL)SS5_Proxy_Enc:(unsigned char* )szSrc isSrcLen:(unsigned long )iSrcLen sZDst:(unsigned char*)szDst isDstLen:(unsigned long *)iDstLen izip:(int)iZip;

/**
 *  解密数据
 *
 *  @param szSrc   密文数据
 *  @param iSrcLen 密文长度
 *  @param szDst   解密后返回的明文数据
 *  @param iDstLen 解密后返回的明文长度
 *  @param iZip    标识
 *
 *  @return 成功返回TRUE
 */
+(BOOL)SS5_Proxy_Dec:(unsigned char* )szSrc isSrcLen:(unsigned long )iSrcLen sZDst:(unsigned char*)szDst isDstLen:(unsigned long *)iDstLen izip:(int)iZip;
@end
