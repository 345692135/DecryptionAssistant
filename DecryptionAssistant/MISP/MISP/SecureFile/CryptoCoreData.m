//
//  CryptoCoreData.m
//  Security
//
//  Created by Mr.Cooriyou on 12-11-27.
//
//

#import "CryptoCoreData.h"
#import"Cryptohelper.h"
#import "SecDefine.h"
#include <openssl/rand.h>
#import "ws_systemsecurity.h"
#import "SecLevelKeyHelper.h"
#import "ConfigManager.h"
#import "ICertify.h"
#import "SystemStrategy.h"

#import "AccountManagement.h"
#import "ConfigManager.h"
#import "IConfig.h"
#import "SystemAccount.h"
#import "UserStrategy.h"
#import "SystemStrategy.h"

#import "AuthentificationManager.h"//0415

#define LEVEL_KEY_GROUPID_IN_SYSTEM_STRATEGY @"537001985"
#define LEVEL_KEY_GROUPID_IN_USER_STRATEGY @"268763137"
#define MAIL_IN_DECRYPT_IN_USER_STRATEGY @"268566593"
#define SECRET_LEVEL_STRATEGY_GROUP_ID @"268500993"

@interface CryptoCoreData()


@property(atomic)ELECTRON_LABEL_HEAD head;
@property(atomic)CRYPTCONTEXT context;

@end

@implementation CryptoCoreData
@synthesize isInit;
@synthesize head;
@synthesize context;

- (id)init
{
    self = [super init];
    if (self) {
        isInit = NO;
    }
    return self;
}

- (id)initWithLevel:(NSString*)name total:(long long)size
{
    self = [super init];
    if (self) {
        
        Update_all_ciphers();
        
        memset(&head, 0, sizeof(ELECTRON_LABEL_HEAD));
        memset(&context, 0, sizeof(CRYPTCONTEXT));
        
        if ([name length] == 0) {
            isInit = NO;
            return self;
        }else{
            NSString* value = nil;
            
            if ([name isEqualToString:@"00000000-00000000-00000000-00000000"] == YES) {
                value = @"088D270E8064C205303794CA6063EC28BC22F83FF1ED7B8155C3156E30F5C1DC8C58299F1AD5CA704BBEEAB2C7A659D95E3F9F2A89AADC8871FE09631590CC19F1F223E3826C05A991BA5AFCB50632D4A810A153A1A703A0D67127198E1D4A692D8AFADEA5B29D7121BE74BFA4A042B89DD1027C58C7F4CCBE4A1397D6D61D38941A4D03A522012F787F9B2776AE40A339B4342497A3CEB4E02097A2320D9D837293773F6B0D6AC36F4B696FC33C21CB071C4E3CEDA7C3E4AC2CDC85CA5C9A347AD8DFA31E2256927EB418EC1AE08600788C34EFA54344CB13CA765B02493C91E069259326F4CFBC0D665E6AAF7E955AAAAD53E7FC71B345868D044843F9D342026FFFC615DE75709078F370C5CDF977C6D4419C43858BC731653E60735DA98FEC4C2F0AF0D3887826366E856A71ABB0300BEB634556C190B1EC515DCA1AC343";
            }else{
            
                id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
                SystemStrategy* systemStrategy = [config getValueByKey:WSConfigItemSystemStrategy];
        
                NSArray* arry = [systemStrategy getSecPubKeybyGroupId:LEVEL_KEY_GROUPID_IN_SYSTEM_STRATEGY secLevel:name];
                if ([arry count] == 0) {
                    isInit = NO;
                    return self;
                }
                value = [[arry objectAtIndex:0]stringValue];
            }

            BOOL isSuccess = [self initEncrypt:&context Level:name key:value total:size];
            if (isSuccess == NO) {
                isInit = NO;
                memset(&head, 0, sizeof(ELECTRON_LABEL_HEAD));
                memset(&context, 0, sizeof(CRYPTCONTEXT));
            }else{
                isInit = YES;
            }
        }
        
        
    }
    return self;
}

- (id)initWithAttachedFileLabelHead:(NSData*)label
{
    
    self = [super init];
    if (self) {
        Update_all_ciphers();
        if ([label length] < 4096) {
            isInit = NO;
        }else{
            BOOL isSuccess = [self initDecryptWithAttachedFile:label];
            if (isSuccess == NO) {
                isInit = NO;
                memset(&head, 0, sizeof(ELECTRON_LABEL_HEAD));
                memset(&context, 0, sizeof(CRYPTCONTEXT));
            }else{
                isInit = YES;
            }
        }
    }
    return self;
}

- (id)initWithElectronLabelHead:(NSData*)label
{
    
    self = [super init];
    if (self) {
        Update_all_ciphers();
        if ([label length] < 4096) {
            isInit = NO;
        }else{
           BOOL isSuccess = [self initDecrypt:label];
            if (isSuccess == NO) {
                isInit = NO;
                memset(&head, 0, sizeof(ELECTRON_LABEL_HEAD));
                memset(&context, 0, sizeof(CRYPTCONTEXT));
            }else{
                isInit = YES;
            }
        }
    }
    return self;
}

/* 流程审批附件处理 */
- (id)initWithApproveFileElectronLabelHead:(NSData*)label
{
    
    self = [super init];
    if (self) {
        Update_all_ciphers();
        if ([label length] < 4096) {
            isInit = NO;
        }else{
            BOOL isSuccess = [self initDecryptWithApproveFile:label];
            if (isSuccess == NO) {
                isInit = NO;
                memset(&head, 0, sizeof(ELECTRON_LABEL_HEAD));
                memset(&context, 0, sizeof(CRYPTCONTEXT));
            }else{
                isInit = YES;
            }
        }
    }
    return self;
}

//0625 check cpu little-endian or big-endian
-(void)CheckCPU
{
    union
    {
        int a;
        char b;
    }c;
    c.a = 1;
    if(c.b == 1){
    	printf("\n##-->Little_endian<--##\n");
    }
    else{
    	printf("\n##-->Big_endian<--##\n");
    }
}


- (BOOL)initDecrypt:(NSData*)label
{
    long lRet = 0;
    char levelName[256] = {0};
    size_t nOutLen = 0;
    unsigned char key[150] = {0};
	unsigned char iv[16] = {0};
    ERRORINT ret = 0;
    NSRange range;
    range.location = 0;
    range.length = sizeof(ELECTRON_LABEL_HEAD);
    NSData* headLabel = [label subdataWithRange:range];
    memcpy(&head, [headLabel bytes], sizeof(ELECTRON_LABEL_HEAD));

    w2c(levelName, (const char*)head.elecHead_BaseInfo.bEncLevelId, 128);
    
    NSString* level = [NSString stringWithUTF8String:levelName];

    //[self CheckCPU];
    //NSLog(@"head.dwEncKeyLen:%lu",head.dwEncKeyLen);
    NSLog(@"head.levelName-%@",level);
    
    NSString* value = nil;
    
    if ([level isEqualToString:@"00000000-00000000-00000000-00000000"] == YES) {
        value = @"088D270E8064C205303794CA6063EC28BC22F83FF1ED7B8155C3156E30F5C1DC8C58299F1AD5CA704BBEEAB2C7A659D95E3F9F2A89AADC8871FE09631590CC19F1F223E3826C05A991BA5AFCB50632D4A810A153A1A703A0D67127198E1D4A692D8AFADEA5B29D7121BE74BFA4A042B89DD1027C58C7F4CCBE4A1397D6D61D38941A4D03A522012F787F9B2776AE40A339B4342497A3CEB4E02097A2320D9D837293773F6B0D6AC36F4B696FC33C21CB071C4E3CEDA7C3E4AC2CDC85CA5C9A347AD8DFA31E2256927EB418EC1AE08600788C34EFA54344CB13CA765B02493C91E069259326F4CFBC0D665E6AAF7E955AAAAD53E7FC71B345868D044843F9D342026FFFC615DE75709078F370C5CDF977C6D4419C43858BC731653E60735DA98FEC4C2F0AF0D3887826366E856A71ABB0300BEB634556C190B1EC515DCA1AC343";
    }else{
        
    
        id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
        SystemStrategy* systemStrategy = [config getValueByKey:WSConfigItemSystemStrategy];
        
        //add by wangbingyang 2012/1/7
        SystemAccount* account = [[AccountManagement getInstance]getActiveAccount];
        if (account == nil) {
            return NO;
        }
        UserStrategy* userStrategy = [account getStrategy];
        
        NSArray* array = [userStrategy getItemByGroupId:MAIL_IN_DECRYPT_IN_USER_STRATEGY];
        if ([array count] == 0) {
            TRACK(@"encrypt level key list is null, group is 268566593");
            //[self iNNNsaveLog:@"encrypt level key list is null group is 268566593 -- 1 --" withFileName:@"decryptLog.txt"];
            return NO;
        }
        NSArray* levels = [userStrategy analysisStrategyForEmailKey:array];
        if ([levels count] == 0) {
            TRACK(@"encrypt level key list for DECALL is null, group is 268566593");
            //[self iNNNsaveLog:@"[levels count] == 0 -- 1 --" withFileName:@"decryptLog.txt"];
            return NO;
        }
        
        BOOL isOK = NO;
        for (NSString *key in levels) {
            //NSString* mss = [NSString stringWithFormat:@"has keys:-%@- -- 1 --",key];
            //[self iNNNsaveLog:mss withFileName:@"decryptLog.txt"];

//            if ([key isEqualToString:level] == YES) {
                isOK = YES;
                break;
//            }
        }
        
        if (isOK == YES) {
            TRACK(@"encrypt level <%@> is permission in user strategy",level);
        }else{
            TRACK(@"encrypt level <%@> is can not permission in user strategy",level);
            return NO;
        }
        

        
        //end
        
        NSArray* arry = [systemStrategy getSecPubKeybyGroupId:LEVEL_KEY_GROUPID_IN_SYSTEM_STRATEGY secLevel:level];
//        NSArray *arry = [systemStrategy getSecPrvKeybyGroupId:LEVEL_KEY_GROUPID_IN_SYSTEM_STRATEGY secLevel:level];
        if ([arry count] == 0) {
            return NO;
        }
        value = [[arry objectAtIndex:0]stringValue];
    }
    
    
    SecLevelKeyHelper* levelKey = [[SecLevelKeyHelper alloc]initWithLevelKeyString:value];
    
    lRet = [levelKey levelKeyDecrypt:head.bEncKeyInfo length:head.dwEncKeyLen plainText:key outLength:&nOutLen];
    if (lRet == -1) {
        [levelKey release];levelKey = nil;
        return NO;
    }
    [levelKey release];levelKey = nil;
    
    ret = Init_CRYPTCONTEXT(&context, WS_NID_aes_128_ecb, CRYPT_MODE_DECRYPT, key, 64, iv, 16);
    if (ret != E_SUCCESS) {
        return NO;
    }
    
    ret = Crypt_Init(&context);
    if (ret != E_SUCCESS) {
        return NO;
    }
    return YES;
    
}

- (BOOL)initDecryptWithAttachedFile:(NSData*)label
{
    long lRet = 0;
    char levelName[256] = {0};
    size_t nOutLen = 0;
    unsigned char key[150] = {0};
	unsigned char iv[16] = {0};
    ERRORINT ret = 0;
    NSRange range;
    range.location = 0;
    range.length = sizeof(ELECTRON_LABEL_HEAD);
    NSData* headLabel = [label subdataWithRange:range];
    memcpy(&head, [headLabel bytes], sizeof(ELECTRON_LABEL_HEAD));
    
    w2c(levelName, (const char*)head.elecHead_BaseInfo.bEncLevelId, 128);
    
    NSString* level = [NSString stringWithUTF8String:levelName];
    NSLog(@"%@",level);
    
    NSString* value = nil;
    
    if ([level isEqualToString:@"00000000-00000000-00000000-00000000"] == YES) {
        value = @"088D270E8064C205303794CA6063EC28BC22F83FF1ED7B8155C3156E30F5C1DC8C58299F1AD5CA704BBEEAB2C7A659D95E3F9F2A89AADC8871FE09631590CC19F1F223E3826C05A991BA5AFCB50632D4A810A153A1A703A0D67127198E1D4A692D8AFADEA5B29D7121BE74BFA4A042B89DD1027C58C7F4CCBE4A1397D6D61D38941A4D03A522012F787F9B2776AE40A339B4342497A3CEB4E02097A2320D9D837293773F6B0D6AC36F4B696FC33C21CB071C4E3CEDA7C3E4AC2CDC85CA5C9A347AD8DFA31E2256927EB418EC1AE08600788C34EFA54344CB13CA765B02493C91E069259326F4CFBC0D665E6AAF7E955AAAAD53E7FC71B345868D044843F9D342026FFFC615DE75709078F370C5CDF977C6D4419C43858BC731653E60735DA98FEC4C2F0AF0D3887826366E856A71ABB0300BEB634556C190B1EC515DCA1AC343";
    }else{
        
        id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
        SystemStrategy* systemStrategy = [config getValueByKey:WSConfigItemSystemStrategy];
        
        //add by wangbingyang 2012/1/7
        SystemAccount* account = [[AccountManagement getInstance]getActiveAccount];
        if (account == nil) {
            return NO;
        }
        UserStrategy* userStrategy = [account getStrategy];
        NSLog(@"userStrategy:%@",userStrategy);
//        NSArray* array = [userStrategy getItemByGroupId:MAIL_IN_DECRYPT_IN_USER_STRATEGY];
//        if ([array count] == 0) {
//            TRACK(@"encrypt level key list is null, group is 268566593");
//              //[self iNNNsaveLog:@"encrypt level key list is null group is 268566593 -- 2 --" withFileName:@"decryptLog.txt"];
//            return NO;
//        }
//        NSArray* levels = [userStrategy analysisStrategyForEmailAttachedFileKey:array];
//        if ([levels count] == 0) {
//            TRACK(@"encrypt level key list for DECATT is null, group is 268566593");
//            //[self iNNNsaveLog:@"[levels count] == 0 -- 2 --" withFileName:@"decryptLog.txt"];
//            return NO;
//        }
//        
//        BOOL isOK = NO;
//        for (NSString *key in levels) {
//            //NSString* mss = [NSString stringWithFormat:@"has keys:-%@- -- 2 --",key];
//            //[self iNNNsaveLog:mss withFileName:@"decryptLog.txt"];
//            if ([key isEqualToString:level] == YES) {
//                isOK = YES;
//                break;
//            }
//        }
        
//        if (isOK == YES) {
//            TRACK(@"encrypt level <%@> is permission in user strategy",level);
//        }else{
//            TRACK(@"encrypt level <%@> is can not permission in user strategy",level);
//            return NO;
//        }
        
        
        //end
        
        NSArray* arry = [systemStrategy getSecPubKeybyGroupId:LEVEL_KEY_GROUPID_IN_SYSTEM_STRATEGY secLevel:level];
        if ([arry count] == 0) {
            return NO;
        }
        value = [[arry objectAtIndex:0]stringValue];
    }
    
    
    SecLevelKeyHelper* levelKey = [[SecLevelKeyHelper alloc]initWithLevelKeyString:value];
    
    lRet = [levelKey levelKeyDecrypt:head.bEncKeyInfo length:head.dwEncKeyLen plainText:key outLength:&nOutLen];
    if (lRet == -1) {
        [levelKey release];levelKey = nil;
        return NO;
    }
    [levelKey release];levelKey = nil;
    //Ret=Init_CRYPTCONTEXT(pContext, pHead->elecHead_AlgorithmInfo.dwEncryptAlgID, CRYPT_MODE_DECRYPT, key, 64, iv, 16, pRSAEncKey);
    ret = Init_CRYPTCONTEXT(&context, head.elecHead_AlgorithmInfo.dwEncryptAlgID, CRYPT_MODE_DECRYPT, key, 64, iv, 16);
    if (ret != E_SUCCESS) {
        return NO;
    }
    
    ret = Crypt_Init(&context);
    if (ret != E_SUCCESS) {
        return NO;
    }
    return YES;
    
}

/* 流程审批附件处理 */
- (BOOL)initDecryptWithApproveFile:(NSData*)label
{
    long lRet = 0;
    char levelName[256] = {0};
    size_t nOutLen = 0;
    unsigned char key[150] = {0};
    unsigned char iv[16] = {0};
    ERRORINT ret = 0;
    NSRange range;
    range.location = 0;
    range.length = sizeof(ELECTRON_LABEL_HEAD);
    NSData* headLabel = [label subdataWithRange:range];
    memcpy(&head, [headLabel bytes], sizeof(ELECTRON_LABEL_HEAD));
    
    w2c(levelName, (const char*)head.elecHead_BaseInfo.bEncLevelId, 128);
    
    NSString* level = [NSString stringWithUTF8String:levelName];
    
    //[self CheckCPU];
    //NSLog(@"head.dwEncKeyLen:%lu",head.dwEncKeyLen);
    NSLog(@"head.levelName-%@",level);
    
    NSString* value = nil;
    
    if ([level isEqualToString:@"00000000-00000000-00000000-00000000"] == YES) {
        value = @"088D270E8064C205303794CA6063EC28BC22F83FF1ED7B8155C3156E30F5C1DC8C58299F1AD5CA704BBEEAB2C7A659D95E3F9F2A89AADC8871FE09631590CC19F1F223E3826C05A991BA5AFCB50632D4A810A153A1A703A0D67127198E1D4A692D8AFADEA5B29D7121BE74BFA4A042B89DD1027C58C7F4CCBE4A1397D6D61D38941A4D03A522012F787F9B2776AE40A339B4342497A3CEB4E02097A2320D9D837293773F6B0D6AC36F4B696FC33C21CB071C4E3CEDA7C3E4AC2CDC85CA5C9A347AD8DFA31E2256927EB418EC1AE08600788C34EFA54344CB13CA765B02493C91E069259326F4CFBC0D665E6AAF7E955AAAAD53E7FC71B345868D044843F9D342026FFFC615DE75709078F370C5CDF977C6D4419C43858BC731653E60735DA98FEC4C2F0AF0D3887826366E856A71ABB0300BEB634556C190B1EC515DCA1AC343";
    }else{
        
        
        id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
        SystemStrategy* systemStrategy = [config getValueByKey:WSConfigItemSystemStrategy];
        
        //add by wangbingyang 2012/1/7
        SystemAccount* account = [[AccountManagement getInstance]getActiveAccount];
        if (account == nil) {
            return NO;
        }
        UserStrategy* userStrategy = [account getStrategy];
        
        NSArray* array = [userStrategy getItemByGroupId:SECRET_LEVEL_STRATEGY_GROUP_ID]; //密级使用权限策略
        if ([array count] == 0) {
            TRACK(@"encrypt level key list is null, group is 268500993");
            //[self iNNNsaveLog:@"encrypt level key list is null group is 268566593 -- 1 --" withFileName:@"decryptLog.txt"];
            return NO;
        }
        NSArray* levels = [userStrategy analysisStrategyForApproveFileKey:array];
        if ([levels count] == 0) {
            TRACK(@"encrypt level key list for DECALL is null, group is 268500993");
            //[self iNNNsaveLog:@"[levels count] == 0 -- 1 --" withFileName:@"decryptLog.txt"];
            return NO;
        }
        
        BOOL isOK = NO;
        for (NSString *key in levels) {
            //NSString* mss = [NSString stringWithFormat:@"has keys:-%@- -- 1 --",key];
            //[self iNNNsaveLog:mss withFileName:@"decryptLog.txt"];
            
            if ([key isEqualToString:level] == YES) {
                isOK = YES;
                break;
            }
        }
        
        if (isOK == YES) {
            TRACK(@"encrypt level <%@> is permission in user strategy",level);
        }else{
            TRACK(@"encrypt level <%@> is can not permission in user strategy",level);
            return NO;
        }
        
        
        
        //end
        
        NSArray* arry = [systemStrategy getSecPubKeybyGroupId:LEVEL_KEY_GROUPID_IN_SYSTEM_STRATEGY secLevel:level];
        if ([arry count] == 0) {
            return NO;
        }
        value = [[arry objectAtIndex:0]stringValue];
    }
    
    
    SecLevelKeyHelper* levelKey = [[SecLevelKeyHelper alloc]initWithLevelKeyString:value];
    
    lRet = [levelKey levelKeyDecrypt:head.bEncKeyInfo length:head.dwEncKeyLen plainText:key outLength:&nOutLen];
    if (lRet == -1) {
        [levelKey release];levelKey = nil;
        return NO;
    }
    [levelKey release];levelKey = nil;
    
    ret = Init_CRYPTCONTEXT(&context, WS_NID_aes_128_ecb, CRYPT_MODE_DECRYPT, key, 64, iv, 16);
    if (ret != E_SUCCESS) {
        return NO;
    }
    
    ret = Crypt_Init(&context);
    if (ret != E_SUCCESS) {
        return NO;
    }
    return YES;
    
}

//获取保存审批文件的目录
-(void)iNNNsaveLog:(NSString*)log withFileName:(NSString*)fileName
{
    AuthentificationManager* actManager = [AuthentificationManager getInstance];
    id<ICertify> certify = [actManager getUserNameCertifyPrivder];
    NSString *accountSID = [certify getActiveAccountSID];//当前账户（域账户）路径下保存
    NSString *documentsDirectory= [NSHomeDirectory()
                                   stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@/FileManager/TemporaryFilesFolder",accountSID]];//保存日志
    
    NSFileManager* fm = [NSFileManager defaultManager];
    NSError* error = nil;
    if (![fm fileExistsAtPath:[NSString stringWithFormat:@"%@", documentsDirectory]]) {//目录不存在，创建目录
        [fm createDirectoryAtPath: [NSString stringWithFormat:@"%@", documentsDirectory] withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    //创建子目录，
    NSString *savePath= [NSString stringWithFormat:@"%@/%@",documentsDirectory,fileName];//@"log.txt"
    
    NSData* data = [log dataUsingEncoding:NSUTF8StringEncoding];
    
    BOOL iRet = [data writeToFile:savePath atomically:YES];
    if (iRet) {
        NSLog(@"log succeed.");
        return;
    }
    NSLog(@"log failed.");
    
}


- (BOOL)initEncrypt:(PCRYPTCONTEXT)pCtx Level:(NSString*)name key:(NSString*)value total:(LONGLONG)size
{
    int nRet = 0;
    int nLevelLength = 0;
    long lRet = 0;
    ERRORINT ret = 0;
    size_t nOutLen = 0;
    const char* encLevel = nil;
    unsigned char key[150] = {0};
	unsigned char iv[16] = {0};
	unsigned char bEncLevelKey[256] ={0};
    
    nRet = RAND_pseudo_bytes(key, 128);
    if (nRet == -1) {
        return NO;
    }
    
    ret = Init_CRYPTCONTEXT(pCtx, WS_NID_aes_128_ecb, CRYPT_MODE_ENCRYPT, key, 64, iv, 16);
    if (ret != E_SUCCESS) {
        return NO;
    }
    
    ret = Crypt_Init(pCtx);
    if (ret != E_SUCCESS) {
        return NO;
    }
    
    //encrypt key with ikey
    
    SecLevelKeyHelper* levelKey = [[SecLevelKeyHelper alloc]initWithLevelKeyString:value];

    lRet = [levelKey levelKeyEncrypt:key length:64 cipherText:bEncLevelKey outLength:&nOutLen];
    if (lRet == -1) {
        [levelKey release];levelKey = nil;
        return NO;
    }
    [levelKey release];levelKey = nil;
    
    
    nLevelLength = ([name length]*2);

    encLevel = [name cStringUsingEncoding:NSUTF16StringEncoding];
    
    //init electron label
    memset(&head, 0, sizeof(ELECTRON_LABEL_HEAD));
    memcpy(head.elecHead_BaseInfo.bFlag, "E-LABLE-00000010", 16);
    
    head.elecHead_BaseInfo.dwHeadVersion = ENCHEAD_VERSION_BASE;
    head.elecHead_BaseInfo.dwFileType = ELABEL_FILE_TYPE_SINGLE_GRADE;
	head.elecHead_BaseInfo.dwFileSubType = ELABEL_FILE_SUBTYPE_SINGLE_GRADE_MANU;
    
    memcpy(head.elecHead_BaseInfo.bEncLevelId, encLevel, nLevelLength);
    
    NSString* guid = [self gen_uuid];
	if ([guid length] != 0)
	{
		memcpy(head.elecHead_FileInfo.bDocGUID, [guid UTF8String], [guid length]);
	}
    NSLog(@"文档的guid:%@",guid);

	head.elecHead_FileInfo.dwDocVersion = 0;
	head.elecHead_AlgorithmInfo.dwHashMethod = CRYPT_DIGEST_METHOD_MD5 ;
	head.elecHead_AlgorithmInfo.dwEncryptAlgID = WS_NID_aes_128_ecb ;
    head.elecHead_AlgorithmInfo.dwEncKeyType = ENCRYPTKEY_TYPE_ENCLEVEL;
    head.dwOffset_Text = 4096;
    head.elecHead_BaseInfo.liFileSize = size;
    
    memcpy( head.bEncKeyInfo, bEncLevelKey, nOutLen);
    head.dwEncKeyLen = nOutLen;
    
    return YES;
}


- (NSData*)getElectronLabel
{
    if (isInit == NO) {
        return nil;
    }
    return [NSData dataWithBytes:(const char*)&head length:sizeof(ELECTRON_LABEL_HEAD)];
}


- (long)cryptUpdateData:(unsigned char*)inData inLength:(int)inlen outData:(unsigned char*)outData outLen:(int*) outLen
{
	ERRORINT Ret = 0;
	
	if (NULL == inData || NULL == outData)
	{
		return WS_NULL_PTR;
	}
    
	Ret = Crypt_Update(&context, inData, inlen, outData, outLen);
	if (Ret != E_SUCCESS)
	{
		return WS_CRYPT_UPDATE_ERROR;
	}
    
	return WS_SUCCESS;
}

- (long)cryptFinalData:(unsigned char*) outData outLen:(int*)outLen
{
	ERRORINT Ret = 0;
	if (NULL == outData)
	{
		return WS_NULL_PTR;
	}
	
	Ret = Crypt_Final(&context, outData, outLen);
	if (Ret != E_SUCCESS)
	{
		return WS_CRYPT_FINAL_ERROR;
	}
    
    head.elecHead_BaseInfo.liFileSize = context.ullCountIn;
    
	return WS_SUCCESS;
}


+(NSDictionary*) getLevelKeysDictionary
{
    SystemAccount* account = [[AccountManagement getInstance]getActiveAccount];
    if (account == nil) {
        return nil;
    }
    
    UserStrategy* userStrategy = [account getStrategy];
    
    NSArray* array = [userStrategy getItemByGroupId:LEVEL_KEY_GROUPID_IN_USER_STRATEGY];
    if ([array count] == 0) {
        TRACK(@"encrypt level key list is null group is 268763137");
        return nil;
    }
    NSArray* levels = [userStrategy analysisStrategyForLevelKey:array];
    if ([levels count] == 0) {
        return nil;
    }
    
    id<IConfig> config = [[ConfigManager getInstance]getConifgPrivder];
    SystemStrategy* systemStrategy = [config getValueByKey:WSConfigItemSystemStrategy];
    
    return [systemStrategy getLevelNameListWithRandID:levels];
}


#pragma mark tools method

- (NSString*)gen_uuid
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(NSString*)uuid_string_ref];
    
    CFRelease(uuid_string_ref);
    return uuid;
}

int w2c(char *outb,const char *inb, int inlenb)
{
    if (inlenb <= 0) {
        return -1;
    }
    
    for(int n = 0;n<=inlenb;n++){
        if(n%2 != 0){
            inb++;
            continue;
        }
        memccpy(outb, inb, 1, 1);
        outb++;
        inb++;
    }
    return 0;
}


@end
