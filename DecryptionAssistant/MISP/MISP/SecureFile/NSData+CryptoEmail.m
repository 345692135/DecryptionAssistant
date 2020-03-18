//
//  NSData+CryptoEmail.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-12-1.
//
//

#import "NSData+CryptoEmail.h"
#import "CryptoCoreData.h"

@implementation NSData (CryptoEmail)

- (BOOL)encryptWriteToFile:(NSString *)path withLevel:(NSString *)levelName
{
    if (path == nil)return NO;
    long ret = 0;
    BOOL isOk = NO;
    int outLen = 0,outLen2 =0;
    unsigned char* buffer =nil;
    unsigned char* plainText = (unsigned char*)[self bytes];
    unsigned char final[128] = {0};
    NSUInteger len = [self length];
    
//    CryptoCoreData* crypto = [[CryptoCoreData alloc]initWithLevel:@"ccVQCG0o-tQEZkor8-IEkMYE6C-Wue2K0DF" total:len];
    CryptoCoreData* crypto = [[CryptoCoreData alloc]initWithLevel:levelName total:len];
    
    NSData* head = [crypto getElectronLabel];
    
    buffer = malloc(len+1);
    if (buffer == nil) {//no memory
        [crypto release];
        return NO;
    }
    
    memset(buffer, 0, len+1);
    ret = [crypto cryptUpdateData:plainText inLength:len outData:buffer outLen:&outLen];
    if (ret != 0) {
        free(buffer);
        buffer = nil;
        [crypto release];
        return NO;
    }
    
    ret = [crypto cryptFinalData:final outLen:&outLen2];
    if (ret != 0) {
        free(buffer);
        buffer = nil;
        [crypto release];
        return NO;
    }
    
    NSMutableData* encryptData = [[NSMutableData alloc]initWithData:head];
    [encryptData appendBytes:buffer length:outLen];
    [encryptData appendBytes:final length:outLen2];
    
    isOk = [encryptData writeToFile:path atomically:YES];
    free(buffer);
    buffer = nil;
    [crypto release];
    [encryptData release];
    
    return isOk;
}

- (NSData *)encryptDataWithLevel:(NSString *)levelName
{
    long ret = 0;
    int outLen = 0,outLen2 =0;
    unsigned char* buffer =nil;
    unsigned char* plainText = (unsigned char*)[self bytes];
    unsigned char final[128] = {0};
    NSUInteger len = [self length];
    
    //    CryptoCoreData* crypto = [[CryptoCoreData alloc]initWithLevel:@"ccVQCG0o-tQEZkor8-IEkMYE6C-Wue2K0DF" total:len];
    CryptoCoreData* crypto = [[CryptoCoreData alloc]initWithLevel:levelName total:len];
    
    NSData* head = [crypto getElectronLabel];
    
    buffer = malloc(len+1);
    if (buffer == nil) {//no memory
        [crypto release];
        return nil;
    }
    
    memset(buffer, 0, len+1);
    ret = [crypto cryptUpdateData:plainText inLength:len outData:buffer outLen:&outLen];
    if (ret != 0) {
        free(buffer);
        buffer = nil;
        [crypto release];
        return nil;
    }
    
    ret = [crypto cryptFinalData:final outLen:&outLen2];
    if (ret != 0) {
        free(buffer);
        buffer = nil;
        [crypto release];
        return nil;
    }
    
    NSMutableData* encryptData = [[NSMutableData alloc]initWithData:head];
    [encryptData appendBytes:buffer length:outLen];
    [encryptData appendBytes:final length:outLen2];
    
    free(buffer);
    buffer = nil;
    [crypto release];
    
    return [encryptData autorelease];
}


+ (id)dataWithEncryptContentsOfFile:(NSString *)path
{
    NSData* encData = [[NSData alloc]initWithContentsOfFile:path];
    if (encData == nil) {
        return nil;
    }
    
    if ([encData length] <= 4096) {
        return [encData autorelease];
    }
    
    int outLen = 0,outLen2 =0;
    long ret = 0;
    unsigned char* buffer =nil;
    unsigned char final[128] = {0};
    NSUInteger len = [encData length];
    buffer = malloc(len+1);
    if (buffer == nil) {//no memory
        if (buffer != NULL) free(buffer);
        return [encData autorelease];
    }
    
    memset(buffer, 0, len+1);
    
    
    CryptoCoreData* crypto = [[CryptoCoreData alloc]initWithElectronLabelHead:encData];

    if ([crypto isInit] == NO) {// no permission is strategy
        if (buffer != NULL) free(buffer);
        return [encData autorelease];
    }
    
    NSRange range;
    range.location = 4096;
    range.length = (len-4096);
    NSData* filedata = [encData subdataWithRange:range];
    
    ret = [crypto cryptUpdateData:(unsigned char*)[filedata bytes] inLength:[filedata length] outData:buffer outLen:&outLen];
    if (ret != 0) {
        free(buffer);
        buffer = nil;
        [crypto release];
        TRACK(@"cryptUpdateData is fail ,code = %lu",ret)
        return [encData autorelease];
    }
    
    [crypto cryptFinalData:final outLen:&outLen2];
    if (ret != 0) {
        free(buffer);
        buffer = nil;
        TRACK(@"cryptFinalData is fail ,code = %lu",ret)
        [crypto release];
        return [encData autorelease];
    }
    
    [encData release];encData = nil;
    NSMutableData* decryptData = [[NSMutableData alloc]initWithBytes:buffer length:outLen];
    [decryptData appendBytes:final length:outLen2];
    free(buffer);
    buffer = nil;
    [crypto release];
    return [decryptData autorelease];
}

+ (id)dataWithEncryptContentsOfAttachedFile:(NSString *)path
{
    NSData* encData = [[NSData alloc]initWithContentsOfFile:path];
    if (encData == nil) {
        return nil;
    }
    
    if ([encData length] <= 4096) {
        return [encData autorelease];
    }
    
    int outLen = 0,outLen2 =0;
    long ret = 0;
    unsigned char* buffer =nil;
    unsigned char final[128] = {0};
    NSUInteger len = [encData length];
    buffer = malloc(len+1);
    if (buffer == nil) {//no memory
        if (buffer != NULL) free(buffer);
        return [encData autorelease];
    }
    
    memset(buffer, 0, len+1);
    
    
    CryptoCoreData* crypto = [[CryptoCoreData alloc]initWithAttachedFileLabelHead:encData];
    
    if ([crypto isInit] == NO) {// no permission is strategy
        if (buffer != NULL) free(buffer);
        return [encData autorelease];
    }
    
    NSRange range;
    range.location = 4096;
    range.length = (len-4096);
    NSData* filedata = [encData subdataWithRange:range];
    
    ret = [crypto cryptUpdateData:(unsigned char*)[filedata bytes] inLength:[filedata length] outData:buffer outLen:&outLen];
    if (ret != 0) {
        free(buffer);
        buffer = nil;
        [crypto release];
        TRACK(@"cryptUpdateData is fail ,code = %lu",ret)
        return [encData autorelease];
    }
    
    [crypto cryptFinalData:final outLen:&outLen2];
    if (ret != 0) {
        free(buffer);
        buffer = nil;
        TRACK(@"cryptFinalData is fail ,code = %lu",ret)
        [crypto release];
        return [encData autorelease];
    }
    
    [encData release];encData = nil;
    NSMutableData* decryptData = [[NSMutableData alloc]initWithBytes:buffer length:outLen];
    [decryptData appendBytes:final length:outLen2];
    free(buffer);
    buffer = nil;
    [crypto release];
    return [decryptData autorelease];
}

+ (id)dataWithEncryptContentsOfURL:(NSURL *)url
{
    NSData* encData = [[NSData alloc]initWithContentsOfURL:url];
    if (encData == nil) {
        return nil;
    }
    
    if ([encData length] <= 4096) {
        return [encData autorelease];
    }
    
    int outLen = 0,outLen2 =0;
    long ret = 0;
    unsigned char* buffer =nil;
    unsigned char final[128] = {0};
    NSUInteger len = [encData length];
    buffer = malloc(len+1);
    if (buffer == nil) {//no memory
        return [encData autorelease];
    }
    
    memset(buffer, 0, len+1);
    
    
    CryptoCoreData* crypto = [[CryptoCoreData alloc]initWithElectronLabelHead:encData];
    
    NSRange range;
    range.location = 4096;
    range.length = (len-4096);
    NSData* filedata = [encData subdataWithRange:range];
    
    ret = [crypto cryptUpdateData:(unsigned char*)[filedata bytes] inLength:[filedata length] outData:buffer outLen:&outLen];
    if (ret != 0) {
        free(buffer);
        buffer = nil;
        [crypto release];
        return [encData autorelease];
    }
    
    [crypto cryptFinalData:final outLen:&outLen2];
    if (ret != 0) {
        free(buffer);
        buffer = nil;
        [crypto release];
        return [encData autorelease];
    }
    
    [encData release];encData = nil;
    NSMutableData* decryptData = [[NSMutableData alloc]initWithBytes:buffer length:outLen];
    [decryptData appendBytes:final length:outLen2];
    free(buffer);
    buffer = nil;
    [crypto release];
    return [decryptData autorelease];
}


+ (id)dataWithEncryptContentsOfAttachedData:(NSData *)data
{
    NSData* encData = data;
    if (encData == nil) {
        return nil;
    }
    
    if ([encData length] <= 4096) {
        return encData;
    }
    
    int outLen = 0,outLen2 =0;
    long ret = 0;
    unsigned char* buffer =nil;
    unsigned char final[128] = {0};
    NSUInteger len = [encData length];
    buffer = malloc(len+1);
    if (buffer == nil) {//no memory
        if (buffer != NULL) free(buffer);
        return encData;
    }
    
    memset(buffer, 0, len+1);
    
    
    CryptoCoreData* crypto = [[CryptoCoreData alloc]initWithAttachedFileLabelHead:encData];
    
    if ([crypto isInit] == NO) {// no permission is strategy
        if (buffer != NULL) free(buffer);
        return encData;
    }
    
    NSRange range;
    range.location = 4096;
    range.length = (len-4096);
    NSData* filedata = [encData subdataWithRange:range];
    
    ret = [crypto cryptUpdateData:(unsigned char*)[filedata bytes] inLength:[filedata length] outData:buffer outLen:&outLen];
    if (ret != 0) {
        free(buffer);
        buffer = nil;
        [crypto release];
        TRACK(@"cryptUpdateData is fail ,code = %lu",ret)
        return encData;
    }
    
    [crypto cryptFinalData:final outLen:&outLen2];
    if (ret != 0) {
        free(buffer);
        buffer = nil;
        TRACK(@"cryptFinalData is fail ,code = %lu",ret)
        [crypto release];
        return encData;
    }
    
//    [encData release];encData = nil;
    NSMutableData* decryptData = [[NSMutableData alloc]initWithBytes:buffer length:outLen];
    [decryptData appendBytes:final length:outLen2];
    free(buffer);
    buffer = nil;
    [crypto release];
    return [decryptData autorelease];
}


@end
