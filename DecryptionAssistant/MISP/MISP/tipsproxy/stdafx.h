#ifndef WIN32
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <sys/types.h>    
#include <sys/socket.h>

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>    
#include <sys/select.h>
#include <errno.h>
#include <stdarg.h>
//  #include <linux/time.h>
#include <pthread.h>
#include <fcntl.h>
#include <stdlib.h>
#include "md5.h"

typedef int SOCKET;
#define INVALID_SOCKET (-1)
#define SOCKET_ERROR (-1)
#define closesocket(s) close(s)
#define ENCRYPT  0     //������ܱ�־   
#define DECRYPT  1     //������ܱ�־   

typedef unsigned char muint8;   
typedef unsigned int muint32;
typedef unsigned long u32;         /* ditto */
typedef unsigned short u16;         /* ditto */
typedef unsigned char u8;           /* ditto */

#ifndef SS5

#define bool unsigned int
#define BOOL bool

#endif

#define true 1
#define false 0
#define TRUE 1
#define FALSE 0
typedef unsigned long DWORD;
typedef unsigned long ULONG;
typedef unsigned int UINT;
typedef unsigned short WORD;
typedef unsigned char UCHAR;
typedef unsigned char  BYTE;
typedef long LONG;
typedef char* LPSTR;
typedef void* LPVOID;
#define VOID void            
#define Sleep usleep
#define MAX_PATH 260
#define SD_SEND 0x01
#define ZeroMemory(x,y) memset(x, 0, y)
#endif
#ifdef WIN32
#include <winsock2.h>
#include <stdio.h>
#include <time.h>
#include  <stdarg.h>
#endif  
#define FILE_PATH			"error.log"
#define TISPROXYDEBUG	printf
//#define TISPROXYDEBUG	printf
//¶Ë¿Ú
#define PORT_IN_PROXY		5890
#define PORT_IN_SERVER		80

#define LOCAL_IP_ADDRESS	"127.0.0.1"
#define SERVER_IP_ADDRESS	"192.168.1.124"

#define SOCKET_STARTUP_ERROR     1
#define SOCKET_VERSION_ERROR     2
#define PROXY_SOCKET_BUFFER_SIZE 3008
#define PROXY_SOCKET_ENC_SIZE	 16
#define	CCR_SUCCESS		         0

//select ³¬Ê±Ê±¼ä
#define TV_SEC	1000			//Ãë
#define TV_USEC	500				//ºÁÃë

//´íÎóÐÅÏ¢´òÓ¡
#define ERROR_TRACE(SOCK,szInfo)\
closesocket(int);\
printf(szInfo);\
printf("\n");\
system("pause")

#define MTU					1500
#define MAX_PATH			260

#define WINAPI				__stdcall
#define INVAILD_LENGTH		-11

#ifndef NULL
#ifdef __cplusplus
#define NULL				0
#else
#define NULL				((void *)0)
#endif
#endif

#ifndef FALSE
#define FALSE               0
#endif

#ifndef TRUE
#define TRUE                1
#endif



typedef unsigned long THREADID;
typedef unsigned long PROCESSID;
typedef THREADID * PTHREADID;
typedef PROCESSID * PPROCESSID;
	#ifdef WIN32	
typedef CRITICAL_SECTION pthread_mutex_t;
#define pthread_mutex_init(Mutex,Param) InitializeCriticalSection(Mutex)
#define pthread_mutex_lock(Mutex) EnterCriticalSection(Mutex)
#define pthread_mutex_unlock(Mutex) LeaveCriticalSection(Mutex)
#define pthread_mutex_destroy(Mutex) DeleteCriticalSection(Mutex)
	#endif
extern char g_cTFPin[30];
extern char g_PrivateKey[255];
extern char g_cSessionID[255];
extern char g_cCertDeviceType[10];
int Socket_Listen(const char* pszLocalAddr,
				  int usPort		
				  );

int Socket_Connect(const char* Target,			//
				   int wPort				//
				   );

//socket¶Ô£¬ÓÃÒÔ¹ÜÀíÍ¨µÀÁ¬½Ó
typedef struct _SOCKET_PAIR
{
	int				 sSocketClient;
	int				 sSocketServer;
	BOOL                    blServerUsing;
	BOOL                    blClientUsing;
	int                 iSendWeb;
	int                 iSendServer;
	int                 iRecvWeb;
	int                 iRecvServer;
	char               *szRecv;
	int                 iTotel;       
	int                  iCurrentPos; 
	int                     iZip;          // ÊÇ·ñ¼ÓÃÜ´«µÝ²ÎÊýÓÃ,ÓöÕâ¸ö½á¹¹ÌåÎÞ¹Ø.
	struct _SOCKET_PAIR*	next,			// Used to link socket objects together
					         *	prev;	
}SOCKET_PAIR,*PSOCKET_PAIR;

typedef struct _tag_Frame_Header_
{
	unsigned char    bVer;			//Ð­Òé°æ±¾ºÅ:  8 bits
	unsigned char    bTos;		    //²úÆ·±àºÅ:    8 bits
	unsigned char    bZip;			//ÊÇ·ñ¼ÓÃÜ
	unsigned char    bReserved;		//±£ÁôÊý¾Ý1
	unsigned long   dwTotalLen;     //Ö¡×Ü³¤¶È:   32 bits £¨×Ö½ÚÎªµ¥Î»£©
	unsigned short    wKeyLen;		//¼ÓÃÜÍ¨Ñ¶ÃÜÔ¿Êµ¼Ê³¤¶È: 16 bits £¨×Ö½ÚÎªµ¥Î»£©
	unsigned short    wFrameChksum;   //°üÐ£ÑéÖµ:   16 bits 
	unsigned long   dwOrgLen;		//Ô­Ê¼Êý¾Ý³¤¶È
}FRAMEHEAD,*LPFRAMEHEAD;
typedef struct _VPN_REMOTE_SERVICE_INFO_
{
	char server[255];
	char port[10];
	char bindport[10];
	char Type[10];
	char Name[50];
	char fold[200];
}VPN_REMOTE_SERVICE_INFO, *PVPN_REMOTE_SERVICE_INFO;
typedef struct  _VPN_PROXY_CONFIGINI_
{
	char serverip[255];
	char serverport[10];
	int ss5ziptype;
	int remoteservicenum;
	int managementport;

	VPN_REMOTE_SERVICE_INFO remoteService[255];
}VPN_PROXY_CONFIGINI,*PVPN_PROXY_CONFIGINI;
typedef struct _VPN_PROXY_SOCKET5_PARAM_
{
	int  iLisen;
	int	clientSock;
	char dwSocks5Svr[255];
	char wSocks5Port[10];
	char dwRemoteIP[255];	
	char wRemotePort[10];
	int ss5zip;
	int  bindPort;

}VPN_PROXY_SOCK5_PARAMS,*PVPN_PROXY_SOCK5_PARAMS;
typedef unsigned long THREAD_ID;

#define VPN_PROXY_CONFIG_INI_PATH	"vpnproxy.cfg"
//#define VPN_PROXY_CONFIG_INI_PATH	"/sdcard/vpnproxy.cfg"
#define VPN_PROXY_PID_FILE_PATH		"tisvpnORproxypid.txt"
#define 	VPN_PROXY_LOG_FILE_PATH		"vpnproxy.log"
#define VPN_CLIENTCORE_CONFIGUSER_INI_PATH	"configuser.ini"
#define VPN_CLIENTCORE_CONFIGMAP_INI_PATH	"configmap.ini"

#define CONFIGMAPLINEPARTNUMBER 6
 int Socket_Init(int nLowByte,int nHighByte);


//¼ÓÈë¶ÔÓ¦µÄsocket¶Ôµ½Á´±íÖÐ
 void InsertSocketPair(PSOCKET_PAIR pSockPair, PSOCKET_PAIR Tail);
/*void InsertSocketPair(PSOCKET_PAIR pSockPair,			//Socket pair
					  PSOCKET_PAIR pSockListHead,		//Socket list head
					  PSOCKET_PAIR pSockListTail);		//Socket list tail*/

 PSOCKET_PAIR RemoveSocketPair(PSOCKET_PAIR pSockPair);			//Socket pair
//ÒÆ³ý¶ÔÓ¦µÄsocket¶Ô´ÓÁ´±íÖÐ
/*void RemoveSocketPair(PSOCKET_PAIR pSockPair,			//Socket pair
					  PSOCKET_PAIR pSockListHead,		//Socket list head
					  PSOCKET_PAIR pSockListTail);		//Socket list tail*/

//ºÏ²¢µÚ¶þ¸öÁ´±í
//½«²ÎÊý3Ëù¶ÔÓ¦µÄÁ´±íºÏ²¢µ½²ÎÊý1Ëù¶ÔÓ¦µÄÁ´±íÎ²²¿
 void ListMerge(PSOCKET_PAIR pListMainHead,
			   PSOCKET_PAIR pListMainTail,				
			   PSOCKET_PAIR pListTempHead,
			   PSOCKET_PAIR pListTempTail);

//ÖÆ×÷²¢³õÊ¼»¯socket¶Ô
 PSOCKET_PAIR Make_Sock_Pair(int scClient, int scServer);
//½ÓÊÜ²¢×ª·¢Êý¾Ý
unsigned long SCB2_Enc(char* szSrc,unsigned long iSrcLen,char * szDst,unsigned long iDstLen, FRAMEHEAD *header);
unsigned long SCB2_Dec(const char* szSrc,unsigned long  iSrcLen,char * szDst,unsigned long iDstLen, FRAMEHEAD *header);
 
int SS5_Proxy_Dec(unsigned char* szSrc, unsigned long  iSrcLen,unsigned char* szDst,unsigned long * iDstLen, int iZip);
int SS5_Proxy_Enc(unsigned char* szSrc,unsigned long iSrcLen,unsigned char* szDst,unsigned long * iDstLen, int iZip);
int WriteLog(const char* szFilePath, const char *format, ... );
// pthread_mutex_t cs;
 int Socket_Send(int sock, char * buf, size_t size, int flag, int timeout);
 int Socket_Recv(int sock, char * buf, size_t size, int flag, int timeout);

unsigned long KI_KEY_Open(void** ppHandle,unsigned long ulSlot);
void WriteLog2(char *format,...);

void Write2Log(char *format,int ilen);
void Write22Log(char *format,int ilen);

void LogAndroidInfo(char *szFormat, ...);
 void ListMerge(PSOCKET_PAIR pListMainHead,
			   PSOCKET_PAIR pListMainTail,				
			   PSOCKET_PAIR pListTempHead,
			   PSOCKET_PAIR pListTempTail);
//char AutoRemoteIP[255] ;

#define CONTEN_LENGTH 0
#define CHUNKED       1

//md5
void getPrivateKey(LPFRAMEHEAD pHeader, char *Key);
void GetMD5(char *Input, char *Output);
int GetRand();
