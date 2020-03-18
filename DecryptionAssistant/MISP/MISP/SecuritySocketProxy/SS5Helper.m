//
//  SS5Helper.m
//  MISP
//
//  Created by Cooriyou on 13-7-16.
//
//

#import "SS5Helper.h"
#import <arpa/inet.h>

#define ENCRYPT  0
#define DECRYPT  1
#include "SM4_Crypto.h"

#define TIME_OUT_COUNT 66


#pragma mark-
#pragma mark SS5Helper

@implementation SS5Helper

+(BOOL)SS5IdentifyWithServer:(NSInputStream*)inputStream outStream:(NSOutputStream*)outputStream remoteIp:(NSString*) ip remotePort:(NSInteger)port
{
    char szBuffer[1024] = {0};
    unsigned long dwRemoteIP = 0;
    unsigned short wRemotePort = 0;
    szBuffer[0] = 0x5;
    szBuffer[1] = 0x1;
    szBuffer[3] = 's';
    szBuffer[4] = ':';
    memcpy(szBuffer+5, "11111111111111111111111111111111", 32);
   // NSLog(@"-------- 51[1]-----------");
    if(![SS5Helper sendRecv:(uint8_t*)szBuffer inStream:inputStream outStream:outputStream length:37]){
        NSLog(@"第一次认证失败");
        return NO;
    }
   // NSLog(@"-------- 50[1]-----------");
    memset(szBuffer, 0,  sizeof(szBuffer));
    szBuffer[0] = 0x5;
    szBuffer[1] = 0x1;
    szBuffer[3] = 0x1;
    dwRemoteIP  = inet_addr([ip UTF8String]);
    szBuffer[7] = (dwRemoteIP&0xFF000000)>>24;
    szBuffer[6] = (dwRemoteIP&0xFF0000)>>16;
    szBuffer[5] = (dwRemoteIP&0xFF00)>>8;
    szBuffer[4] = (dwRemoteIP&0xFF);
    wRemotePort = port;
    szBuffer[8] = (wRemotePort&0xFF00)>>8;
    szBuffer[9] = (wRemotePort&0xFF);
    //NSLog(@"-------- 51[2]-----------");
    if(![SS5Helper sendRecv:(uint8_t*)szBuffer inStream:inputStream outStream:outputStream length:10]){
        NSLog(@"第二次认证失败");
        return NO;
    }
    //NSLog(@"-------- 50[2]-----------");
    return YES;
}
+(BOOL)sendRecv:(uint8_t *)szBuffer inStream:(NSInputStream*)inputStream outStream:(NSOutputStream*)outputStream length:(int)len
{
    int  n = 0;
    int  reValueInt = 0;
    char readBuffer[1024] = {0};
    reValueInt = [(NSOutputStream*)outputStream write:szBuffer maxLength:len];
    if(reValueInt > 0){
        while (n <= TIME_OUT_COUNT ){
            if(inputStream.streamStatus == NSStreamStatusError ){
                return NO;
            }
            if ([inputStream hasBytesAvailable] == YES) {
                if([inputStream read:(uint8_t*)readBuffer maxLength:10] <= 0){
                    printf("readData failed\n");
                }
                if(readBuffer[0] == 0x5 && readBuffer[1] == 0x0){
                    //printf("success\n");
                    return YES;
                }
            }
            n++;
            sleep(0.5);
            [NSThread sleepForTimeInterval:0.5];
        }
        if(n > TIME_OUT_COUNT){
            printf("readData failed result in time out\n");
        }
        
        
        if([inputStream read:(uint8_t*)readBuffer maxLength:10] <= 0){
            printf("readData failed\n");
        }
        if(readBuffer[0] == 0x5 && readBuffer[1] == 0x0){
            //printf("success\n");
            return YES;
        }
        
    }else{
        printf("sendData failed result in <%i>\n",reValueInt);
    }
    
    return NO;
    
}

+(BOOL)SS5_Proxy_Enc:(unsigned char* )szSrc isSrcLen:(unsigned long )iSrcLen sZDst:(unsigned char*)szDst isDstLen:(unsigned long *)iDstLen izip:(int)iZip
{
	int iPos = 0;
	FRAMEHEAD head;
	int iHeadSize = sizeof(FRAMEHEAD);//16
	int iCount = iSrcLen;
    unsigned char bFillUp = 0x10;
	char cSm1Key[255] = {0};
	//char privateKey[17] = {0};
	unsigned char Encrk[128] = {0};
    
	int iFillUp = 0;
	int encryptLength = 0;
    
	memset(&head, 0, iHeadSize);
	head.bVer = 0x1;
	head.bTos = 0x2;
    
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
	iFillUp = (iSrcLen % 16);
	if(0 == iFillUp){
		iFillUp = 16;
	}
	iCount = iSrcLen + 16 -  iFillUp;//不足16的倍数将其补齐
	head.dwTotalLen = iCount + iHeadSize;
	head.dwOrgLen   = iSrcLen;//本来包的大小
    
	memcpy(szDst, &head, iHeadSize);
	iPos = iHeadSize;
    
	if(iFillUp > 0){
		bFillUp = 16 - iFillUp;
		memset(szSrc + iSrcLen, bFillUp, 16 - iFillUp);
	}
    head.wKeyLen = 0;
    head.wFrameChksum = 0;
    memcpy(cSm1Key, "1111111111111111", 16);
    memset(Encrk, 0, sizeof(Encrk));
    SMS4KeyExt((unsigned char *)cSm1Key, Encrk, ENCRYPT);
    while(encryptLength < iCount){
        SMS4Crypt(szSrc + encryptLength, szDst + iPos + encryptLength, Encrk);
        encryptLength += 16;
    }
    memcpy(szDst, &head, iHeadSize);
    *iDstLen = head.dwTotalLen;
    return YES;
}




/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////


+(BOOL)SS5_Proxy_Dec:(unsigned char* )szSrc isSrcLen:(unsigned long )iSrcLen sZDst:(unsigned char*)szDst isDstLen:(unsigned long *)iDstLen izip:(int)iZip
{
	int iPos = 0;
	FRAMEHEAD head;
	int iHeadSize = sizeof(FRAMEHEAD);
	int iCount = iSrcLen;
	unsigned char szDstTmp[3200] = {0};
	//int iDstLenTmp = sizeof(szDstTmp);
	int encryptLength = 0;
    
	char cSm1Key[255] = {0};
    
	//char privateKey[17] = {0};
    
	unsigned char Decrk[128] = {0};
    
    
	memset(&head,0, iHeadSize);
	memcpy(&head,( unsigned char*)szSrc,iHeadSize);
	iPos = iHeadSize;
    
	*iDstLen = iSrcLen - iPos;
	iCount -= iPos;
    memcpy(cSm1Key, "1111111111111111", 16);
    memset(Decrk, 0, sizeof(Decrk));
    SMS4KeyExt((unsigned char *)cSm1Key, Decrk, DECRYPT);
    while (encryptLength < iCount)
    {
        SMS4Crypt(szSrc + iPos +encryptLength, szDstTmp + encryptLength, Decrk);
        encryptLength += 16;
    }
    memcpy(szDst, szDstTmp, iCount-(16 - head.dwOrgLen%16));
    
    *iDstLen = iCount-(16 - head.dwOrgLen%16);
    return YES;
}


@end
