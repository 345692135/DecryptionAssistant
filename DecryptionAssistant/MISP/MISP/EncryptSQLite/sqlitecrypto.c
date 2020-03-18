//
//  sqlitecrypto.c
//  WSSQLite
//
//  Created by Mr.Cooriyou on 12-7-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#include <stdio.h>
#include <string.h>
#include "sqlitecrypto.h"


int encryptFunc(unsigned char* data, unsigned int len , const char* key , unsigned int keylen)
{

//    unsigned char *dataEnc = NULL;
//    unsigned char dataTemp[4096] = {0};
//    size_t nLen = 0;
//    int nLoop = 0;
//    nLen = len;
//    dataEnc = data;
//    memcpy(dataTemp, dataEnc, nLen);
//    for (nLoop = 0; nLoop<nLen; nLoop++) {
//        REVERSE(dataTemp[nLoop],*dataEnc);
//        dataEnc++;
//    }
    
    unsigned int i;
    unsigned char val;
    for (i = 0; i < len; i++)
    {
        val = ~(*data);
        *data = val;
        data++;
    }
    
//    unsigned int i;
//    unsigned char val;
//    for (i = 0; i < len; i++)
//    {
//        REVERSE(*data,val);
//        *data = val;
//        data++;
//    }

   // printf("encrypt key is : [%s]\r\n",key);
    return 0;
}

int decryptFunc(unsigned char* data, unsigned int len , const char* key , unsigned int keylen)
{
//    unsigned char *dataEnc = NULL;
//    unsigned char dataTemp[4096] = {0};
//    size_t nLen = 0;
//    int nLoop = 0;
//    nLen = len;
//    dataEnc = data;
//    memcpy(dataTemp, dataEnc, nLen);
//    for (nLoop = 0; nLoop<nLen; nLoop++) {
//        REVERSE(dataTemp[nLoop],*dataEnc);
//        dataEnc++;
//    }
    
    unsigned int i;
    unsigned char val;
    for (i = 0; i < len; i++)
    {
        val = ~(*data);
        *data = val;
        data++;
    }
    
//    unsigned int i;
//    unsigned char val;
//    for (i = 0; i < len; i++)
//    {
//        REVERSE(*data,val);
//        *data = val;
//        data++;
//    }
    
//    printf("decrypt key is : [%s]\r\n",key);
    return 0;
}
