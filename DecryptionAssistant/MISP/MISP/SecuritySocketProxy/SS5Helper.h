//
//  SS5Helper.h
//  MISP
//
//  Created by Cooriyou on 13-7-16.
//
//

#import "WSBaseObject.h"

typedef struct _tag_Frame_Header_
{
	unsigned char    bVer;
	unsigned char    bTos;
	unsigned char    bZip;
	unsigned char    bReserved;
	unsigned long   dwTotalLen;
	unsigned short    wKeyLen;
	unsigned short    wFrameChksum;
	unsigned long   dwOrgLen;
}FRAMEHEAD,*LPFRAMEHEAD;


@interface SS5Helper : WSBaseObject

+(BOOL)SS5IdentifyWithServer:(NSInputStream*)inputStream outStream:(NSOutputStream*)outputStream remoteIp:(NSString*) ip remotePort:(NSInteger)port;


+(BOOL)SS5_Proxy_Enc:(unsigned char* )szSrc isSrcLen:(unsigned long )iSrcLen sZDst:(unsigned char*)szDst isDstLen:(unsigned long *)iDstLen izip:(int)iZip;
+(BOOL)SS5_Proxy_Dec:(unsigned char* )szSrc isSrcLen:(unsigned long )iSrcLen sZDst:(unsigned char*)szDst isDstLen:(unsigned long *)iDstLen izip:(int)iZip;

@end
