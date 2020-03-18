//
//  SS5Helper.m
//  MISP
//
//  Created by Cooriyou on 13-7-16.
//
//

#import "SS5Helper2.h"
#import <arpa/inet.h>
#import "SystemAccount.h"
#import "AccountManagement.h"
#import "NSData+Degist.h"
#import "NSData+HMACMD5.h"

#include <string.h>

#define ENCRYPT  0
#define DECRYPT  1
#include "SM4_Crypto.h"

#define TIME_OUT_COUNT 66


#pragma mark-
#pragma mark SS5Helper

@implementation SS5Helper2

+(BOOL)Identify:(NSInputStream*)inputStream outStream:(NSOutputStream*)outputStream
{
    AccountManagement* accountManager = [AccountManagement getInstance];
    SystemAccount* accountNow = [accountManager getActiveAccount];
    NSString * strToKen = [NSString stringWithFormat:@"<TOKEN>%@</TOKEN>", [accountNow token]];
    NSLog(@"strToken ==== %@", strToKen);
    const char * toKen = [strToKen UTF8String];
    
    FRAMEHEADER head;
    int iHeadSize = sizeof(FRAMEHEADER);//16
    memset(&head, 0, iHeadSize);
    head.bReserved = 0x01;
    head.bTos = 0x2;
    head.dwTotalLen = strlen(toKen) + iHeadSize;
    
    char writeBuffer[1024] = {0};
    char readBuffer[1024] = {0};
    
    memcpy(writeBuffer, &head, iHeadSize);
    memcpy(writeBuffer+iHeadSize, toKen, strlen(toKen));
    
    int n = 0;
    int reValueInt = [(NSOutputStream*)outputStream write:(uint8_t*)writeBuffer maxLength:63];
    int buffLen = 0;
    
    if(reValueInt > 0)
    {
        while (n <= TIME_OUT_COUNT )
        {
            if(inputStream.streamStatus == NSStreamStatusError )
            {
                return NO;
            }
            
            if ([inputStream hasBytesAvailable] == YES)
            {
                if((buffLen = [inputStream read:(uint8_t*)readBuffer maxLength:63]) <= 0)
                {
                    printf("readData failed\n");
                }
            }
            
            FRAMEHEADER head2;
            memset(&head2, 0, iHeadSize);
            memcpy(&head2, readBuffer, iHeadSize);
        
            if (head2.bReserved == 0x01)
            {
                readBuffer[buffLen] = '\0';
                if (strcmp("<TOKEN>0</TOKEN>", readBuffer + sizeof(head)) == 0)
                {
                    NSLog(@"认证已通过");
                    return YES;
                }
            }
            
            
            n++;
            [NSThread sleepForTimeInterval:0.5];
        }
        
        if(n > TIME_OUT_COUNT)
        {
            printf("readData failed result in time out\n");
        }
    }
    
    return  NO;
}

+(BOOL)SS5_Proxy_Enc:(unsigned char* )szSrc isSrcLen:(unsigned long )iSrcLen sZDst:(unsigned char*)szDst isDstLen:(unsigned long *)iDstLen izip:(int)iZip
{
    int iCount = iSrcLen;
	int iFillUp = 0;
	int encryptLength = 0;
    unsigned char bFillUp = 0x10;
	unsigned int Encrk[128] = {0};

    //获取会话ID
    AccountManagement* accountManager = [AccountManagement getInstance];
    SystemAccount* accountNow = [accountManager getActiveAccount];
    NSData* sessionKey = [accountNow sessionKey];
    NSLog(@"mark--------ENC---sessionKey = %@", [[[NSString alloc] initWithData:sessionKey encoding:NSUTF8StringEncoding] autorelease]);
    //生成0-65535随机数
    int random = arc4random() % 65535;
    
    //根据会话ID与随机数生成加密密钥
    NSData * HMACMD5 = [sessionKey MD5HMACWithKey:[NSString stringWithFormat:@"%d", random]];
    unsigned char * encKey = (unsigned char *)[HMACMD5 bytes];
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:32];
    for (int i = 0; i<16; i++) {
        [ret appendFormat:@"%02x", encKey[i]];
    }
    NSLog(@"mark--------加密密钥 = %@", ret);
    
    //加密数据长度需要满足16的倍数
	iFillUp = (iSrcLen % 16);
	if(0 == iFillUp)
    {
		iFillUp = 16;
	}
	iCount = iSrcLen + 16 -  iFillUp;
//    NSLog(@"mark--------ENC---iCount = %d", iCount);
    //不足16的倍数，缺n就补n个n
	if(iFillUp > 0)
    {
		bFillUp = 16 - iFillUp;
		memset(szSrc + iSrcLen, bFillUp, 16 - iFillUp);
	}
    
    //进行加密
    memset(Encrk, 0, sizeof(Encrk));
    SMS4KeyExt(encKey, Encrk, ENCRYPT);
    while(encryptLength < iCount)
    {
        SMS4Crypt(szSrc + encryptLength, szDst + encryptLength, Encrk);
        encryptLength += 16;
    }
    
    //对加密数据做摘要
    NSData *szDstData = [NSData dataWithBytes:szDst length:iCount];
    unsigned char*szDstMD5 = (unsigned char*)[[szDstData MD5WithBytes] bytes];
//    int szDstMD5Len = strlen((const char*)szDstMD5);    //加密数据摘要长度
    
    //设置包头字段值
    FRAMEHEADER head;
	int iHeadSize = sizeof(FRAMEHEADER);//16
    memset(&head, 0, iHeadSize);
    head.bVer = 0x1;
	head.bTos = 0x2;
    head.bReserved = 0x00;
    head.wKeyLen = random;  //设置生成的随机数
    head.wFrameChksum = 0;
    head.dwTotalLen = iHeadSize + 16 + iCount;   //总包大小
	head.dwOrgLen   = iSrcLen;//本来包的大小

	switch(iZip){
        case 0:{
			head.bZip = 0x00;
		}
            break;
        case 1:{
			head.bZip = 0x01;
		}
            break;
        default:{
			head.bZip = 0x02;
		}
            break;
	}
    
    //将包头+加密数据摘要+加密数据拼成一个完整的包
    unsigned char* temp = malloc(head.dwTotalLen);
    memcpy(temp, &head, iHeadSize);
    memcpy(temp + iHeadSize, szDstMD5, 16);
    memcpy(temp + iHeadSize + 16, szDst, iCount);
    memset(szDst, 0, head.dwTotalLen);
    memcpy(szDst, temp, head.dwTotalLen);
    free(temp);
    *iDstLen = head.dwTotalLen;

    return YES;
}

+(BOOL)SS5_Proxy_Dec:(unsigned char* )szSrc isSrcLen:(unsigned long )iSrcLen sZDst:(unsigned char*)szDst isDstLen:(unsigned long *)iDstLen izip:(int)iZip
{
    int iCount = iSrcLen;
	int decryptLength = 0;
    int iOrgLen = 0;
    int iHeadSize = 0;
	unsigned int Decrk[128] = {0};
    unsigned char szDstTmp[5120] = {0};
    
    //取出16字节包头
    FRAMEHEADER head;
	iHeadSize = sizeof(FRAMEHEADER);
    memset(&head,0, iHeadSize);
	memcpy(&head,( unsigned char*)szSrc,iHeadSize);
    iOrgLen = head.dwOrgLen;
    NSLog(@"mark--------DEC---iOrgLen = %d", iOrgLen);
    //取出服务器传过来的加密数据摘要值
    unsigned char iDstMD5[17] = {0};
    memset(iDstMD5, 0, 16);
    memcpy(iDstMD5, szSrc + iHeadSize, 16);
    iDstMD5[16] = '\0';
    
    //取出加密数据并在本地做摘要
    int encLen = head.dwTotalLen - iHeadSize - 16;
//    NSLog(@"mark--------DEC---encLen = %d", encLen);
//    NSData *serverEncData = [NSData dataWithBytes:(const void *)szSrc+iHeadSize+16 length:encLen];
//    const char* szSrcMD5 = [[serverEncData MD5WithBytes] bytes];
    
    //对比本地算出的摘要值与服务器传过来的摘要值,
    //如果不一样表示包已经被改变，不做解密处理
//    if (strcmp(szSrcMD5, (char *)iDstMD5) != 0)
//    {
//        NSLog(@"数据包已被更改，不做处理");
//        return NO;
//    }
    
    //获取会话ID
    AccountManagement* accountManager = [AccountManagement getInstance];
    SystemAccount* accountNow = [accountManager getActiveAccount];
    NSData* sessionKey = [accountNow sessionKey];
    
    //获取服务器传过来的随机数
    int random = head.wKeyLen;
    NSLog(@"mark--------DEC---random = %d", random);
    //根据会话密钥与HMAC算出解密密钥
    NSData * HMACMD5 = [sessionKey MD5HMACWithKey:[NSString stringWithFormat:@"%d", random]];
    unsigned char * decKey = (unsigned char *)[HMACMD5 bytes];
//    
//    NSMutableString *ret = [NSMutableString stringWithCapacity:32];
//    for (int i = 0; i<16; i++) {
//        [ret appendFormat:@"%02x", decKey[i]];
//    }
//    NSLog(@"mark--------DEC---decKey = %@", ret);
    
    //计算实际加密包长度
	iCount -= iHeadSize + 16;
//    NSLog(@"mark--------DEC---iCount = %d", iCount);
    //进行解密
    memset(Decrk, 0, sizeof(Decrk));
    SMS4KeyExt(decKey, Decrk, DECRYPT);
    while (decryptLength < encLen)
	{
		SMS4Crypt(szSrc + iHeadSize + 16 + decryptLength, szDstTmp + decryptLength, Decrk);
		decryptLength += 16;
	}
    
    int len;
    //将补齐的数据截取掉
    if (iOrgLen%16 != 0)
    {
        len = iCount-(16 - iOrgLen%16);
    }
    else
    {
        len = iCount;
    }
    //将补齐的数据截取掉
	memcpy(szDst, szDstTmp, len);
//    NSLog(@"mark--------DEC---szDst = %s", szDst);
    *iDstLen = iOrgLen;
    return YES;
}
@end
