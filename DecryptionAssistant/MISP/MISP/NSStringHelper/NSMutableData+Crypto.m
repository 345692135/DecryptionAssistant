//
//  NSMutableData+Crypto.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-12-7.
//
//

#import "NSMutableData+Crypto.h"
#import "CryptoCoreData.h"
#import "Cryptohelper.h"




@implementation NSMutableData (Crypto)

- (BOOL)encryptWriteToFile:(NSString *)path level:(NSString*)levelId
{
    if (path == nil)return NO;
    if ([levelId length] == 0) return NO;
    long ret = 0;
    BOOL isOk = NO;
    int outLen = 0,outLen2 =0;
    unsigned char* buffer =nil;
    unsigned char* plainText = (unsigned char*)[self bytes];
    unsigned char final[128] = {0};
    NSUInteger len = [self length];
    
    CryptoCoreData* crypto = [[CryptoCoreData alloc]initWithLevel:levelId total:len];
    //    CryptoCoreData* crypto = [[CryptoCoreData alloc]initWithLevel:@"u9NgvABx-xb1WBaUN-QX1F3KPW-K9YMsFEv" total:len];
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
        return [encData autorelease];
    }
    
    memset(buffer, 0, len+1);
    
    
    CryptoCoreData* crypto = [[CryptoCoreData alloc]initWithElectronLabelHead:encData];
    
    //>>>>>>>>>>>>>>>>>>>>>>>>>>>>20160301
    if (crypto.isInit == NO) {
        NSLog(@"密级不对，无法解密");
        return [encData autorelease];//返回密文
    }
    //<<<<<<<<<<<<<<<<<<<<<<<<20160301
    
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

//-(NSDictionary*) getLevelKeysDictionary
//{
//    SystemAccount* account = [[AccountManagement getInstance]getActiveAccount];
//    if (account == nil) {
//        return nil;
//    }
//    
//    UserStrategy* userStrategy = [account getStrategy];
//    
//    NSArray* array = [userStrategy getItemByGroupId:LEVEL_KEY_GROUPID_IN_USER_STRATEGY];
//    if ([array count] == 0) {
//        TRACK(@"encrypt level key list is null group is 268763137");
//        return nil;
//    }
//    NSArray* levels = [userStrategy analysisStrategyForLevelKey:array];
//    if ([levels count] == 0) {
//        return nil;
//    }
//    
//    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
//    SystemStrategy* systemStrategy = [config getValueByKey:WSConfigItemSystemStrategy];
//    
//    return [systemStrategy getLevelNameListWithRandID:levels];
//}

#pragma mark - judge whether the file is encrypted.
//add at 20150808 00:51
+ (BOOL)isEncryptFile:(NSString*)path
{
    NSData* encData = [[NSData alloc]initWithContentsOfFile:path];
    if (encData == nil) {
        return NO;
    }
    
    if ([encData length] <= 4096) {
        return NO;
    }
    
    ELECTRON_LABEL_HEAD head;
    char eLable[16] = {0};
    
    NSRange range;
    range.location = 0;
    range.length = sizeof(ELECTRON_LABEL_HEAD);
    NSData* headLabel = [encData subdataWithRange:range];
    memcpy(&head, [headLabel bytes], sizeof(ELECTRON_LABEL_HEAD));
    
    w2c_t(eLable, (const char*)head.elecHead_BaseInfo.bFlag, 16);
    
    NSString* e_Lable = [NSString stringWithUTF8String:eLable];
    //NSLog(@"e_Lable: %@",e_Lable);
    if ([e_Lable isEqualToString:@"E-LABLE-00000010"]) {
        return YES;
    }
    return NO;
}

int w2c_t(char *outb,const char *inb, int inlenb)
{
    if (inlenb <= 0) {
        return -1;
    }
    
    for(int n = 0;n<=inlenb;n++){
        //should not leak any byte...
//        if(n%2 != 0){
//            inb++;
//            continue;
//        }
        memccpy(outb, inb, 1, 1);
        outb++;
        inb++;
    }
    return 0;
}

@end
