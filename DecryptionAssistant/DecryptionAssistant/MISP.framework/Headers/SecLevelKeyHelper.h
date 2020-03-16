//
//  SecLevelKeyHelper.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-11-19.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//  

#import "WSBaseObject.h"

@interface SecLevelKeyHelper : WSBaseObject


- (id)initWithLevelKeyString:(NSString*)key;

- (long)levelKeyEncrypt:(const unsigned char*) plainText
                 length:(size_t) plainTextLen
             cipherText:(unsigned char*) cipherText
              outLength:(size_t*) cipherTextLen;


- (long)levelKeyDecrypt:(const unsigned char*) cipherText
                 length:(size_t) cipherTextLen
              plainText:(unsigned char*) plainText
              outLength:(size_t*) plainTextLen;



@end
