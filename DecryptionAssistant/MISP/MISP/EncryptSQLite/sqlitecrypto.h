//
//  sqlitecrypto.h
//  WSSQLite
//
//  Created by Mr.Cooriyou on 12-7-27.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#ifndef WSSQLite_sqlitecrypto_h
#define WSSQLite_sqlitecrypto_h

#define   REVERSE(X,Y)   Y=((((X)&0x0F)<< 4) | (((X)&0xF0)>>4))

int encryptFunc(unsigned char* data, unsigned int len , const char* key , unsigned int keylen);

int decryptFunc(unsigned char* data, unsigned int len , const char* key , unsigned int keylen);

#endif
