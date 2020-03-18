//
//  NSData+HMACMD5.m
//  MISP
//
//  Created by iBlock on 13-12-2.
//
//

#import "NSData+HMACMD5.h"
#include <openssl/hmac.h>

@implementation NSData (HMACMD5)

-(NSData *)MD5HMACWithKey:(NSString*)key
{
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cMessage = [self bytes];
    unsigned char* digest;
    digest = HMAC(EVP_md5(), cKey, strlen(cKey), (unsigned char*)cMessage, 32, NULL, NULL);
    
//    NSMutableString *ret = [NSMutableString stringWithCapacity:32];
//    
//    for (int i = 0; i<16; i++)
//    {
//        [ret appendFormat:@"%02x", digest[i]];
//    }
//    
//    NSLog(@"mark-----------HMAC = %@", ret);
    return [NSData dataWithBytes:digest length:16];
}

@end
