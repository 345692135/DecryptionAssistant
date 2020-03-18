#include "stdafx.h"
#include "SM4_Crypto.h"

#include <sys/time.h>

//#include "BDI_Android.h"
//DEV_HANDLE hDev = NULL;
pthread_mutex_t g_TrackMutex;				//记录日志的互斥量
pthread_mutex_t g_EncMutex;
pthread_mutex_t g_DecMutex;
/*
函数名称：socket_Init
函数描述：初始化socket库,
参数描述：nLowByte，socket库的主版本号
		  nHighByte，socket库的副版本号
返回值：成功返回0，
*/
//Globle variable
int g_iMutexInited = 0;

/*extern PSOCKET_PAIR gSocketListTemp;		
extern PSOCKET_PAIR gSocketListTailTemp;*/	


int Socket_Init(int nLowByte,int nHighByte)
{
#ifdef WIN32
	WORD wVersionRequested = MAKEWORD(nLowByte,nHighByte);
	WSADATA wsaData;
	int err;

	err = WSAStartup(wVersionRequested,&wsaData);
	if (err != 0)
	{
		if (err == SOCKET_ERROR)
		{
			WriteLog(FILE_PATH,"WSAStartup error %d\n",WSAGetLastError());
		}
		return SOCKET_STARTUP_ERROR;
	}

	if (LOBYTE(wsaData.wVersion) != nLowByte ||
		HIBYTE(wsaData.wVersion) != nHighByte)
	{
		WSACleanup();
		WriteLog(FILE_PATH,"WSAStartup failed with error version 0x%04X\n",wsaData.wVersion);
		return SOCKET_VERSION_ERROR;
	}

	printf("WSAStart up Success\n");
#endif		
	return 0;
}

int SS5_Proxy_Dec(unsigned char* szSrc, unsigned long  iSrcLen,unsigned char* szDst,unsigned long * iDstLen, int iZip)
{
	int uRet = CCR_SUCCESS;
	int iPos = 0;
	FRAMEHEAD head;
	int iHeadSize = sizeof(FRAMEHEAD);
	int iCount = iSrcLen;
	unsigned char szDstTmp[3200] = {0};
	int iDstLenTmp = sizeof(szDstTmp);
	int encryptLength = 0;

	char cSm1Key[255];

	char privateKey[17] = {0}; 

	unsigned char Decrk[128];


	memset(&head,0, iHeadSize);
	memcpy(&head,(BYTE*)szSrc,iHeadSize);
	iPos = iHeadSize;

	*iDstLen = iSrcLen - iPos;
	iCount -= iPos;
	//sms4 算法
	//#ifdef _IPHONE_
	//#ifndef _GA_SDVPNAPI_

	if(iZip == 0)
	{
		uRet = SCB2_Dec(szSrc+iPos,iCount,szDstTmp,iDstLenTmp, &head);
		if(uRet != CCR_SUCCESS)
		{
			*iDstLen = 0;
			return -1;
		}
		memcpy(szDst, szDstTmp, iCount-(16 - head.dwOrgLen%16));
		*iDstLen = iCount-(16 - head.dwOrgLen%16);
	}
	else
	{
		//sm4
		//解密密钥！
		if(strlen(g_PrivateKey)>0)
			strcpy(cSm1Key, g_PrivateKey);
		else{
			getPrivateKey(&head, privateKey);
			strcpy(cSm1Key, privateKey);
		}

		memset(Decrk, 0, sizeof(Decrk));
		SMS4KeyExt((unsigned char *)cSm1Key, Decrk, DECRYPT);
		while (encryptLength < iCount)
		{
			SMS4Crypt(szSrc + iPos +encryptLength, szDstTmp + encryptLength, Decrk);
			encryptLength += 16;
		}
		memcpy(szDst, szDstTmp, iCount-(16 - head.dwOrgLen%16));

		*iDstLen = iCount-(16 - head.dwOrgLen%16);
	}
	//	*iDstLen = iDstLenTmp;
	//szDst[iDstLen] = '\0';
	return uRet;
}


int SS5_Proxy_Enc(unsigned char* szSrc,unsigned long iSrcLen,unsigned char* szDst,unsigned long * iDstLen, int iZip)
{
	int uRet = CCR_SUCCESS;
	int iPos = 0;
	FRAMEHEAD head;
	int iHeadSize = sizeof(FRAMEHEAD);
	int iCount = iSrcLen;
	BYTE bFillUp = 0x10;
	
	char cSm1Key[255];
	char privateKey[17] = {0}; 
	unsigned char Encrk[128];

	int iFillUp = 0;
	int encryptLength = 0;

	memset(&head, 0, iHeadSize);
	head.bVer = 0x1;
	head.bTos = 0x2;


	switch(iZip)
	{
	case 0:
		{
			head.bZip = 0x00;
		}
		break;
	case 1:
		{
			head.bZip = 0x01;
		}
		break;
	default:
		{
			head.bZip = 0x02;
		}
		break;
	}

	iFillUp = (iSrcLen % 16);
	if(0 == iFillUp)
	{
		iFillUp = 16;
	}
	iCount = iSrcLen + 16 -  iFillUp;
	head.dwTotalLen = iCount + iHeadSize;
	head.dwOrgLen   = iSrcLen;



	memcpy(szDst, &head, iHeadSize);
	iPos = iHeadSize;



	if(iFillUp > 0)
	{
		bFillUp = 16 - iFillUp;
		memset(szSrc + iSrcLen, bFillUp, 16 - iFillUp);
	}

	//解密密钥！

	if(iZip == 0)
	{
		uRet =  SCB2_Enc(szSrc,iCount,szDst+iPos,*iDstLen, &head);
		if(uRet != CCR_SUCCESS)
		{
			*iDstLen = 0;
			return uRet;
		}
		memcpy(szDst, &head, 16);
	}
	else
	{
		//sm4
		head.wKeyLen = 0;
		head.wFrameChksum = 0;
		if(strlen(g_PrivateKey)>0)
			strcpy(cSm1Key, g_PrivateKey);
		else{
			getPrivateKey(&head, privateKey);
			strcpy(cSm1Key, privateKey);
		}
        printf("KEY IS = %s",cSm1Key);
		memset(Encrk, 0, sizeof(Encrk));
		SMS4KeyExt((unsigned char *)cSm1Key, Encrk, ENCRYPT);
		while(encryptLength < iCount)
		{
			SMS4Crypt(szSrc + encryptLength, szDst + iPos + encryptLength, Encrk);
			encryptLength += 16;
		}
		memcpy(szDst, &head, iHeadSize);
	}

	*iDstLen = head.dwTotalLen;
	

	//	pthread_mutex_unlock(&g_EncMutex);
	return uRet;
}

int Socket_Listen(const char* pszLocalAddr, int usPort)
{
	int iRet     = 0;
	int iBackLog = 2000;
	int	iSockRet = 0;
	struct sockaddr_in sinLocal;
	int loop    = 1;
	int iStatus = 0;

	iSockRet = socket(AF_INET, SOCK_STREAM, 0);
	if(0 == iSockRet)
	{
		iRet = -1;		
		close(iSockRet);		
		iSockRet = 0;
		return iSockRet;
	}
	bzero(&sinLocal, sizeof(sinLocal));
	sinLocal.sin_family = AF_INET;
	sinLocal.sin_port   = htons(usPort);
//	inet_aton();
	if(pszLocalAddr)
	{
		long lAddr = inet_addr(pszLocalAddr);
		memcpy(&(sinLocal.sin_addr), &lAddr, sizeof(lAddr));
	}
	else
	{
		long lAddr = INADDR_ANY;
		memcpy(&(sinLocal.sin_addr), &lAddr, sizeof(lAddr));
	}

	//设置可以重复绑定
	if(setsockopt(iSockRet, SOL_SOCKET, SO_REUSEADDR, (char*)&loop, sizeof(loop)) < 0)
	{
		printf("[%s]  [%d] create socket success\n", __FILE__, __LINE__);
	}
	errno   = 0;
	iStatus = bind(iSockRet,(struct sockaddr*)&sinLocal,sizeof(sinLocal));
	if(-1 == iStatus)
	{		
		printf("%d, [%s] \n ",errno, strerror(errno));
		iRet=-1;
		if (iSockRet!=0)
		{
			close(iSockRet);
		}
		iSockRet=0;
		return iSockRet;
	}
	//listen.
	iStatus = -1;
	iStatus = listen(iSockRet, iBackLog);
	if(-1 == iStatus)
	{
		iRet=-1;
		if (iSockRet!=0)
		{
			close(iSockRet);
		}
		iSockRet = 0;
		printf("[%s]  [%d] create socket success\n", __FILE__, __LINE__);
		return iSockRet;
	}
	return iSockRet;
}

int Socket_Send(int sock, char * buf, size_t size, int flag, int timeout)
{
	int i = 0, ret = 0, intretry = 0;	
	struct timeval tival;
	fd_set writefds;
	tival.tv_sec = timeout;
	tival.tv_usec = 0;
//	fcntl(sock, F_SETFL, fcntl(sock, F_GETFD, 0)&~O_NONBLOCK);
	while(i < size)
	{
		FD_ZERO(&writefds);
		FD_SET(sock, &writefds);
		errno = 0;
		ret = select(sock + 1, NULL, &writefds, NULL, &tival);
		if(ret <= 0)
		{
			if(ret < 0) 
			{
				printf("Send socket:%d select() error! return:%d, errno=%d, errortext:'%s'\n", sock, ret, errno, strerror(errno));	
			}
			else
			{
				printf( "Send socket:%d select timeout(%d) errorcode:%d  errorinfo:%s  ret:%d!\n", sock, timeout, errno, strerror(errno), ret);				
			}			
			break;
		}
		ret = send(sock, buf + i, size - i, flag);
		if(ret <= 0)
		{			
			if (errno == EINTR || errno == EWOULDBLOCK || errno == EAGAIN)
			{
				if(intretry < 10) 
				{
					intretry++;
					continue;
				}
				else
				{
					printf("Send socket:%d send() error!EINTR 10 times!\n", sock);					
					break;
				}
						
			}
			else if(errno != EINTR && errno != EWOULDBLOCK && errno != EAGAIN)
			{
				printf("Send socket:%d send() error! return:%d, errno=%d, errortext:'%s'\n", sock, ret, errno, strerror(errno));				
				return -1;
			}	
		}
		else
		{
			i += ret;
		}
	}
	//printf("Send socket:%d send() OK! %d/%d bytes sent!\n", sock, i, size);
	return i;

}
int Socket_Recv(int sock, char * buf, size_t size, int flag, int timeout)
{
	int i = 0, ret = 0, intretry = 0;

	struct timeval tival;
	fd_set readfds;
	fd_set readTmp;
    
	FD_ZERO(&readfds);	
	FD_ZERO(&readTmp);	
	FD_SET(sock, &readTmp);
	tival.tv_sec = timeout;
	tival.tv_usec = 0;	
     
//	fcntl(sock, F_SETFL, fcntl(sock, F_GETFD, 0)&~O_NONBLOCK);
	while(i < size)
	{
        //add by wangbingyang
        FD_ZERO(&readfds);
        FD_ZERO(&readTmp);
        FD_SET(sock, &readTmp);
        tival.tv_sec = timeout;
        tival.tv_usec = 0;
        //end
		tival.tv_sec = timeout;
		readfds = readTmp;
        
		ret = select(sock + 1, &readfds, NULL, NULL, &tival);
		if(ret <= 0) 
		{
			if(ret < 0)
			{
				printf("Recv socket:%d select() error! return:%d, errno=%d, errortext:'%s'\n", sock, ret, errno, strerror(errno));
				return -1;
			}
			else 
			{
				printf("Recv socket:%d select timeout(%d)! ============= i= [%d]\n", sock, timeout,i);
				break;
			}
		}
		ret = recv(sock, buf + i, size - i, flag);
		if(ret <= 0)
		{
			if(errno == EINTR || errno == EWOULDBLOCK || errno == EAGAIN)
			{	
				if(intretry < 10) 
				{
					intretry++;
					continue;
				}
				else 
				{
					printf("Recv socket:%d recv() error! EINTR 10 times!\n", sock);
					break;
				}
			}
			else if(errno != EINTR && errno != EWOULDBLOCK && errno != EAGAIN)
			{
				printf( "Recv socket:%d recv() error! return:%d, errno=%d, errortext:'%s'\n", sock, ret, errno, strerror(errno));
				return -1;
			}
		}
		else
		{
            printf("$$$$$$$$$$$$$$$$$$$ i = [%d] ret = [%d]\n",i,ret);
			i += ret;
		}
	}
	printf("Recv socket:%d recv() OK! recv:%d/ will recv:%ld bytes received!\n", sock, i, size);
	return i;
}

int Socket_Connect(const char* Target, int wPort)
{

	int    iSockRet = 0;	
	struct sockaddr_in sinRemote;
	iSockRet = socket(AF_INET, SOCK_STREAM, 0);
	if(0 == iSockRet)
	{
		return 0;
	}
	sinRemote.sin_family = AF_INET;
	sinRemote.sin_port   = htons(wPort);
	sinRemote.sin_addr.s_addr = inet_addr(Target);
    /*
	while(iTime < 3)
	{		
        tm.tv_sec = 5;
		FD_ZERO(&set);
		FD_SET(iSockRet, &set);
		iSelect = select(iSockRet + 1, NULL, &set, NULL, &tm);
		if(iSelect <= 0) 
		{
			if(iSelect < 0)
			{
				printf("connect socket:%d select() error! return:%d, errno=%d, errortext:'%s'\n", iSockRet, iSelect, errno, strerror(errno));
				return -1;
			}
			else 
			{
				printf("coonect socket:%d select timeout(%d)! times = %d\n", iSockRet, 5, iTime++);
				continue;
			}
		}
		else
		{
			connect(iSockRet, (struct sockaddr *)&sinRemote, sizeof(sinRemote));
			return iSockRet;
		}
	}
     */
    connect(iSockRet, (struct sockaddr *)&sinRemote, sizeof(sinRemote));
    return iSockRet;
	//return 0;
}

unsigned long KI_KEY_Open(void** ppHandle,unsigned long ulSlot)
{
    /*
	unsigned long uRet=0;
	unsigned char ucInBuf[255];

	if(hDev == NULL)
	{
		pthread_mutex_init(&g_EncMutex,NULL);
		pthread_mutex_init(&g_DecMutex,NULL);
		TISPROXYDEBUG("SD_OpenDev");
		//uRet = SD_OpenDev((PDEV_HANDLE)ppHandle, 0);
#ifdef	_ANDROID_
#ifndef	_GA_SDVPNAPI_
		uRet = SD_OpenDev(&hDev, 0);
#else
		uRet=SD_OpenDev(0,&hDev);
#endif
#endif
		if (CCR_SUCCESS!=uRet)
		{
			TISPROXYDEBUG("SD_OpenDev uRet=0x%X",uRet);
		}

		memset(ucInBuf, 0, sizeof(ucInBuf));
		strcpy(ucInBuf, g_cTFPin);
		//uRet = SD_Login((DEV_HANDLE)*ppHandle, ucInBuf, strlen(ucInBuf), 0);
		TISPROXYDEBUG("SD_Login, g_cTFPin=%s\n", g_cTFPin);
		uRet = SD_Login(hDev, ucInBuf, strlen(ucInBuf), 0);
		if( uRet != 0 )
		{
			TISPROXYDEBUG("SD_Login failure!\n");
		}
		return uRet;

	}
*/
	return CCR_SUCCESS;
}

void WriteLog2(char *format,...)
{
	va_list		args;
	char timeLog[32];

	va_start(args,format);
	time_t now = time(NULL);
	strftime(timeLog,sizeof(timeLog),"%d/%b/%Y:%H:%M:%S %Z",localtime(&now));

#ifdef	_DEBUG_FILE_
	if(access(VPN_PROXY_LOG_FILE_PATH, F_OK) == -1)
	{
		return;
	}

	if (0==g_iMutexInited)
	{
		g_iMutexInited=1;
		pthread_mutex_init(&g_TrackMutex,NULL);	
	}
	pthread_mutex_lock(&g_TrackMutex);

	memset(cString,0,sizeof(cString));
	sprintf(cString,VPN_PROXY_LOG_FILE_PATH);
	pFILE = fopen( cString, "ab+" );
	if( pFILE == NULL ) {
		pthread_mutex_unlock (&g_TrackMutex);
		return;
	}

	fprintf(pFILE,"[%s] ",timeLog);
	vfprintf(pFILE ,format, args ) ;
	fputs( "\n", pFILE );
	fclose( pFILE );
#endif

#ifdef	_DEBUG_CONSOLE_
	printf(format, args);
#endif
	va_end(args);

#ifdef	_DEBUG_FILE_
	pthread_mutex_unlock (&g_TrackMutex);
#endif
}

int     g_iMutexInitedB2=0;					//是否读取过设置
pthread_mutex_t g_TrackMutexB2;				//记录日志的互斥量

void Write2Log(char *format,int ilen)
{
	FILE      *pFILE;
	char	cString[2048];
	va_list		args;
	char timeLog[32];

	if(access("/sdcard/vpnproxyB2.txt", F_OK) == -1)
	{
		return;
	}

	if (0==g_iMutexInitedB2)
	{
		g_iMutexInitedB2=1;
		pthread_mutex_init(&g_TrackMutexB2,NULL);	
	}
	pthread_mutex_lock(&g_TrackMutexB2);

	memset(cString,0,sizeof(cString));
	pFILE = fopen( "/sdcard/vpnproxyB2.txt", "ab+" );
	if( pFILE == NULL ) {
		pthread_mutex_unlock (&g_TrackMutexB2);
		return;
	}
	fwrite(format, ilen,1,pFILE);
	fclose( pFILE );
	pthread_mutex_unlock (&g_TrackMutexB2);
}

int     g_iMutexInitedB22=0;					//是否读取过设置
pthread_mutex_t g_TrackMutexB22;				//记录日志的互斥量

void Write22Log(char *format,int ilen)
{
	FILE      *pFILE;
	char	cString[2048];
	va_list		args;
	char timeLog[32];

	if(access("/sdcard/vpnproxyB22.txt", F_OK) == -1)
	{
		return;
	}

	if (0==g_iMutexInitedB22)
	{
		g_iMutexInitedB22=1;
		pthread_mutex_init(&g_TrackMutexB22,NULL);	
	}
	pthread_mutex_lock(&g_TrackMutexB22);

	memset(cString,0,sizeof(cString));
	pFILE = fopen( "/sdcard/vpnproxyB22.txt", "ab+" );
	if( pFILE == NULL ) {
		pthread_mutex_unlock (&g_TrackMutexB22);
		return;
	}
	fwrite(format, ilen,1,pFILE);
	fclose( pFILE );
	pthread_mutex_unlock (&g_TrackMutexB22);
}

void LogAndroidInfo(char *szFormat, ...)
{
    /*
	char Buffer[8*1024];
	va_list		args;

	memset(Buffer, 0, sizeof(Buffer));

	va_start(args,szFormat);
	vsnprintf (Buffer, sizeof (Buffer), szFormat, args);
	va_end(args);
#ifdef	__VPNPROXY__
	LOGW(Buffer);
#else
	printf(Buffer);
	printf("\n");
#endif
     */
}

//打印日志到指定的文件
int WriteLog(const char* szFilePath, const char* format, ...)
{
	FILE* file;
	int nLength;

	va_list v;

	char timeLog[32];
	time_t now = time(NULL);

	va_start(v,format);

	file = fopen(szFilePath,"a");

	strftime(timeLog,sizeof(timeLog),"%d/%b/%Y:%H:%M:%S %Z",localtime(&now));
	fprintf(file,"---------------------[%s]---------------------\n",timeLog);

	nLength = fprintf(file, format, v);
	if (nLength <= 0)
	{
		fprintf(file,"Log write error\n");
	}
	fprintf(file,"---------------------------------------------------\n");

	return nLength;	
}


unsigned long SCB2_Enc(char* szSrc,unsigned long iSrcLen,char * szDst,unsigned long iDstLen, FRAMEHEAD *header)
{
    /*
#ifdef WIN32
	return 0;
#else
#ifdef	_ANDROID_
#ifndef	_GA_SDVPNAPI_
	SD_SYMKEY	SecKey;
	SD_SYMIV		sm1IV;
	char privateKeySeed[4] = {0};
	char privateKey[17] = {0}; 
	ZeroMemory(&SecKey,sizeof(SD_SYMKEY));
	SecKey.length = 16;

	int i;

	//解密密钥！
	header->wKeyLen = 0;
	header->wFrameChksum = 0;

	if(strlen(g_PrivateKey)>0)
		strcpy(SecKey.data, g_PrivateKey);
	else{
		getPrivateKey(header, privateKey);
		strcpy(SecKey.data,privateKey);
	}

	sm1IV.length = 16;
	memset(sm1IV.data, '2', 16);
#else
	KEY_HANDLE hKey;
	char cSm1Key[255];
	char privateKeySeed[4] = {0};
	char privateKey[17] = {0}; 

	int i;
	//解密密钥！
	header->wKeyLen = 0;
	header->wFrameChksum = 0;

	if(strlen(g_PrivateKey)>0)
		strcpy(cSm1Key, g_PrivateKey);
	else{
		getPrivateKey(header, privateKey);
		strcpy(cSm1Key,privateKey);
	}
#endif
#endif
	unsigned long	uRet = 0;
	DEV_HANDLE hHandle = NULL;
	//PBDT_CIPHER_CTX	CipherCtx;
	ULONG	ulSlot = 0;

	//uRet=BDI_Initialize(NULL);
	//uRet=BDI_Connect(ulSlot,(PBDT_DEV_HANDLE)&hHandle);

	uRet = KI_KEY_Open(&hHandle,ulSlot);
	if(CCR_SUCCESS!=uRet)
	{
		TISPROXYDEBUG("KI_KEY_Open：%X\n",uRet);
		return uRet;
	}

	TISPROXYDEBUG("Encrypt begin ......\n");
	TISPROXYDEBUG("src data;%s\n src data length:%d\n",szSrc,iSrcLen);

	int iDstLenx = 8092;

	//uRet = SD_Encrypt(hHandle, 
#ifdef	_ANDROID_
#ifndef	_GA_SDVPNAPI_
	uRet = SD_Encrypt(hDev,
		SDKEY_ALG_SM1_ECB, 
		&SecKey, &sm1IV, 
		szSrc, iSrcLen, 
		szDst, (unsigned long *)&iDstLenx, 
		SDKEY_PKCS7_PADDING);
#else
	//KEY_HANDLE hKey;
	uRet = SD_ImportKey(hDev, SDF_SM1, (unsigned char*)cSm1Key, 16, 0, &hKey);
	if (uRet != CCR_SUCCESS)
	{
		TISPROXYDEBUG("SD_ImportKey uRet=0x%X",uRet);
		return uRet;
	}
	uRet=SD_Encrypt(hDev, hKey, SDF_ECB, NULL, szSrc, iSrcLen, szDst, &iDstLenx, 0);
	
#endif
#endif
	if(uRet != CCR_SUCCESS)
	{
		TISPROXYDEBUG("SD_Encrypt ECB failure,error:%X\n",uRet);
		return uRet;
	}
	iDstLen = iDstLenx;

	TISPROXYDEBUG("dst data;%s\n dst data length:%d\n",szDst,iDstLen);
	TISPROXYDEBUG("Encrypt end......\n");

#ifdef	_ANDROID_
#ifndef	_GA_SDVPNAPI_
	//
#else
	uRet = SD_DelKey(hDev, hKey, SDF_SM1, 0);
	if (CCR_SUCCESS!=uRet)
	{
		TISPROXYDEBUG("SD_DelKey uRet=0x%X",uRet);
	}
	TISPROXYDEBUG("SD_DelKey uRet=0x%X",uRet);
	return uRet;

#endif
#endif	
	
#endif	
     */
    
    return 0;
    
}
unsigned long SCB2_Dec(const char* szSrc,unsigned long  iSrcLen,char * szDst,unsigned long iDstLen, FRAMEHEAD *header)
{
    /*
#ifdef WIN32
	return CCR_SUCCESS;
#else
#ifdef	_ANDROID_
#ifndef	_GA_SDVPNAPI_
	SD_SYMKEY	SecKey;
	SD_SYMIV		sm1IV;
	char privateKeySeed[4] = {0};
	char privateKey[17] = {0}; 

	ZeroMemory(&SecKey,sizeof(SD_SYMKEY));
	SecKey.length = 16;

	int i;
	//解密密钥！
	if(strlen(g_PrivateKey)>0)
		strcpy(SecKey.data, g_PrivateKey);
	else{
		getPrivateKey(header, privateKey);
		strcpy(SecKey.data,privateKey);
	}
	sm1IV.length = 16;
	memset(sm1IV.data, '2', 16);
#else
	KEY_HANDLE hKey;
	char cSm1Key[255];
	char privateKeySeed[4] = {0};
	char privateKey[17] = {0}; 

	memset(cSm1Key, 0x00, 16);
	int i;
	//解密密钥！
	if(strlen(g_PrivateKey)>0)
		strcpy(cSm1Key, g_PrivateKey);
	else{
		getPrivateKey(header, privateKey);
		strcpy(cSm1Key,privateKey);
	}
#endif
#endif
	unsigned long	uRet = 0;
	DEV_HANDLE hHandle = NULL;
	//PBDT_CIPHER_CTX	CipherCtx;
	ULONG	ulSlot = 0;

	//uRet=BDI_Initialize(NULL);
	//uRet=BDI_Connect(ulSlot,(PBDT_DEV_HANDLE)&hHandle);

	uRet = KI_KEY_Open(&hHandle,ulSlot);
	if(CCR_SUCCESS!=uRet)
	{
		TISPROXYDEBUG("KI_KEY_Open：%X\n",uRet);
		return uRet;
	}
	TISPROXYDEBUG("Decrypt  begin ......\n");
	TISPROXYDEBUG("Decrypt  src data;%s\n src data length:%d\n",szSrc,iSrcLen);

#ifdef	_ANDROID_
#ifndef	_GA_SDVPNAPI_
	//uRet = SD_Decrypt(hHandle, 
	uRet = SD_Decrypt(hDev,
		SDKEY_ALG_SM1_ECB, 
		&SecKey, &sm1IV, 
		(unsigned char *)szSrc, iSrcLen, 
		szDst, (unsigned long *)&iDstLen, 
		SDKEY_NO_PADDING);
#else
	//KEY_HANDLE hKey;
	uRet = SD_ImportKey(hDev, SDF_SM1, (unsigned char*)cSm1Key, 16, 0, &hKey);
	if (uRet != CCR_SUCCESS)
	{
		TISPROXYDEBUG("SD_ImportKey uRet=0x%X",uRet);
		return uRet;
	}
	uRet=SD_Decrypt(hDev, hKey, SDF_ECB, NULL, szSrc, iSrcLen, szDst, &iDstLen, 0);


#endif
#endif
	TISPROXYDEBUG("Decrypt  dst data;%s\n dst data length:%d\n",szDst,iDstLen);
	TISPROXYDEBUG("Decrypt  end......\n");
	if(uRet != CCR_SUCCESS)
	{
		TISPROXYDEBUG("SD_Decrypt ECB failure,error:%X\n",uRet);
		return uRet;
	}

#ifdef	_ANDROID_
#ifndef	_GA_SDVPNAPI_
	//
#else
	uRet = SD_DelKey(hDev, hKey, SDF_SM1, 0);
	if (CCR_SUCCESS!=uRet)
	{
		TISPROXYDEBUG("SD_DelKey uRet=0x%X",uRet);
	}
	TISPROXYDEBUG("SD_DelKey uRet=0x%X",uRet);

#endif
#endif	

	return CCR_SUCCESS;
#endif	
     */
    return CCR_SUCCESS;

}

void getPrivateKey(LPFRAMEHEAD pHeader, char *Key)
{
	char *cRand[16] = {"Haman rosa haman", 
		"Haman rosa haman", 
		"Haman rosa haman",
		 "Haman rosa haman",
		 "Haman rosa haman", 
		 "Haman rosa haman", 
		"Haman rosa haman",
		 "Haman rosa haman",
		 "Haman rosa haman", 
		"Haman rosa haman", 
		"Haman rosa haman",
		 "Haman rosa haman",
		 "Haman rosa haman", 
		 "Haman rosa haman",
		 "Haman rosa haman",
		 "Haman rosa haman"};
	unsigned int iKey    = 0;
	int iSelect = 0;
	int index   = 0;
	char privateKeySeed[5] = {0};
	char MD5OutPut[33]	   = {0};
	char RandS[16]		   = {0};
	char MD5Input[32]	   = {0};
	struct timeval tpstart;
	// send to client
	if(pHeader->wKeyLen == 0 && pHeader->wFrameChksum == 0)
	{
		// get random
		while ( iKey == 0)
		{
			iKey = GetRand() % 10000;		
		}
		sprintf(privateKeySeed, "%d", iKey);
		//memcpy(privateKeySeed, &iKey, 4);
		iSelect = GetRand() % 16;
		memcpy(RandS, *(cRand + iSelect), 16);
		pHeader->bReserved = iSelect;
		memcpy(&pHeader->wKeyLen, privateKeySeed, 4);
		printf("--ss5--getPrivateKey server RandS = (%s) pHeader->wKeyLen = (%d) pHeader->wFrameChksum = (%d) iSelect = (%d)", RandS, pHeader->wKeyLen, pHeader->wFrameChksum,iSelect);
	}
	else
	{
		memcpy(&privateKeySeed, &pHeader->wKeyLen, 4);
		//iKey = atoi(privateKeySeed);
		memcpy(RandS, *(cRand + pHeader->bReserved), 16);
		printf("--ss5--getPrivateKey server RandS = (%s) pHeader->wKeyLen = (%d) pHeader->wFrameChksum = (%d) iSelect = (%d)", RandS, pHeader->wKeyLen, pHeader->wFrameChksum,iSelect);
	}

	//memcpy(privateKeySeed, &iKey, 4);	

	for(index = 0; index < 16; index++)
	{
		if(index < pHeader->bReserved)
		{
			MD5Input[index] = privateKeySeed[index % 4] & RandS[index];
		}
		else
		{
			MD5Input[index] = privateKeySeed[index % 4] ^ RandS[index];
		}
	}
	GetMD5(MD5Input, MD5OutPut);
	memcpy(Key, MD5OutPut + pHeader->bReserved, 16);	
	for(index = 0; index < 16; index++)
	{
		if(Key[index] == 0)
		{
			Key[index] = pHeader->bReserved;
		}
	}
	printf("%s", Key);
}

void GetMD5(char *Input, char *Output)
{
	int index = 0;
	struct MD5Context md5c;
	unsigned char ss[16];
	char tmp[3]  = {0};	
	MD5Init( &md5c );
	MD5Update(&md5c, Input, strlen(Input));
	MD5Final(ss, &md5c);
	for(index = 0; index < 16; index++ )
	{
		sprintf(tmp,"%02X", ss[index]);
		strcat(Output, tmp);
	}
}

int GetRand()
{
	struct timeval tpstart;
	//gettimeofday(&tpstart,NULL);
   int ret = gettimeofday(&tpstart,0);
   
//    int	gettimeofday(struct timeval * __restrict, void * __restrict);

	srand(tpstart.tv_sec);
	return rand();
}



