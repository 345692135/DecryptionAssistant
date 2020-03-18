//
//  NSData+Degist.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-8-13.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import "NSData+Degist.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (Degist)

-(NSString*)md5
{
    if ([self length] == 0) {
        return nil;
    }
    const char *original_str = [self bytes];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, [self length], result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [hash appendFormat:@"%02X", result[i]];
    return hash;
}

- (NSData*)MD5WithBytes
{
    if ([self length] == 0) {
        return nil;
    }
    const char *original_str = [self bytes];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, strlen(original_str), result);
    NSData *md5Bytes = [NSData dataWithBytes:result length:CC_MD5_DIGEST_LENGTH];
    return md5Bytes;
}

- (NSString*)sha1
{
    if ([self length] == 0) {
        return nil;
    }
    const char *original_str = [self bytes];
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(original_str, [self length], result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [hash appendFormat:@"%02X", result[i]];
    return hash;
}

@end
