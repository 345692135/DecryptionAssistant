//
//  ws_systemsecurity.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-10-25.
//
//

#ifndef MISP_ws_systemsecurity_h
#define MISP_ws_systemsecurity_h


void cryptoInit();

long Ikey_Encrypt(unsigned char* plainText,size_t plainTextLen,unsigned char* cipherText,size_t* cipherTextLen);

long Ikey_Decrypt(unsigned char* cipherText,size_t cipherTextLen,unsigned char* plainText,size_t* plainTextLen);

long IKeyRawSignSha1(unsigned char* dataToSign,size_t dataToSignLen,unsigned char* sig,size_t* sigLen);

long IKeyRawVerifySha1(unsigned char* signedData, size_t signedDataLen,unsigned char* sig,size_t sigLen);


long LevelKey_Encrypt(const char* key,unsigned char* plainText,size_t plainTextLen,unsigned char* cipherText,size_t* cipherTextLen);

long LevelKey_Decrypt(const char* key,unsigned char* cipherText,size_t cipherTextLen,unsigned char* plainText,size_t* plainTextLen);

#endif
