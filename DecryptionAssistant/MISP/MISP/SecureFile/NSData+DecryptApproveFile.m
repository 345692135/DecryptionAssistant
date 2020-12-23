//
//  NSData+DecryptApproveFile.m
//  MISP
//
//  Created by TanGuoLian on 17/6/8.
//  Copyright © 2017年 wondersoft. All rights reserved.
//

#import "NSData+DecryptApproveFile.h"
#import "CryptoCoreData.h"

@implementation NSData (DecryptApproveFile)

- (BOOL)isEncryptNewApproveFileData
{
    if(self == nil)
    {
        return NO;
    }
    
    //首先判断_data长度，小于7肯定不是密文，加密存储
    if ([self length] < 7)
    {
        return NO;
    }
    
    //取出前7字节，判断是否是E-LABLE,是则表示是密文
    NSRange range = NSMakeRange(0, 7);
    NSData *tempData = [self subdataWithRange:range];
    NSString *compareStr = [[NSString alloc] initWithData:tempData encoding:NSASCIIStringEncoding];
    
    if (![compareStr isEqualToString:@"E-LABLE"])
    {
        return NO;
    }
    
    [compareStr release];
    compareStr = nil;
    return YES;
}

+ (id)dataWithEncryptContentsOfNewApproveFile:(NSString *)filePath
{
    NSData* encData = [[NSData alloc]initWithContentsOfFile:filePath];
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
    
    
    CryptoCoreData* crypto = [[CryptoCoreData alloc] initWithApproveFileElectronLabelHead:encData];
    
    if ([crypto isInit] == NO) {// no permission is strategy
        if (buffer != NULL) free(buffer);
        return [encData autorelease];
    }
    
    NSRange range;
    range.location = 4096;
    range.length = (len-4096);
    NSData* filedata = [encData subdataWithRange:range];
    ret = [crypto cryptUpdateData:(unsigned char*)[filedata bytes] inLength:(int)[filedata length] outData:buffer outLen:&outLen];
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

@end
