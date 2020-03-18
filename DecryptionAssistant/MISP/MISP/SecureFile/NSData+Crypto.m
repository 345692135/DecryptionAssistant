//
//  NSData+Crypto.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-9-12.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import "NSData+Crypto.h"

#define   REVERSE(X,Y)   Y=((((X)&0x0F)<< 4) | (((X)&0xF0)>>4))

@implementation NSData (Crypto)

- (BOOL)writeToEncFile:(NSString*)path
{
    if (path == nil)return NO;
    
    unsigned int i;
    unsigned char val;
    unsigned char* plainText = (unsigned char*)[self bytes];
    NSUInteger len = [self length];
    
    for (i = 0; i < len; i++)
    {
        val = ~(*plainText);
        *plainText = val;
        plainText++;
    }
    return [self writeToFile:path atomically:YES];
}

+ (id)dataWithContentsOfEncFile:(NSString *)path
{
    
    NSData* encData = [[NSData alloc]initWithContentsOfFile:path];
    if (encData == nil) {
        return nil;
    }
    unsigned char* plainText = (unsigned char*)[encData bytes];
    NSUInteger len = [encData length];
    unsigned int i;
    unsigned char val;
    
    for (i = 0; i < len; i++)
    {
        val = ~(*plainText);
        *plainText = val;
        plainText++;
    }
    return [encData autorelease];
}

+ (id)dataWithEncContentsOfURL:(NSURL *)url
{
    NSData* encData = [[NSData alloc]initWithContentsOfURL:url];
    if (encData == nil) {
        return nil;
    }
    unsigned char* plainText = (unsigned char*)[encData bytes];
    NSUInteger len = [encData length];
    unsigned int i;
    unsigned char val;
    
    for (i = 0; i < len; i++)
    {
        val = ~(*plainText);
        *plainText = val;
        plainText++;
    }
    
    return [encData autorelease];
}

@end
