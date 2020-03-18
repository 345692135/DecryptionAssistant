//
//  PackageDefine.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-8-28.
//
//

#ifndef MISP_PackageDefine_h
#define MISP_PackageDefine_h

#pragma pack(4)

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

#endif
