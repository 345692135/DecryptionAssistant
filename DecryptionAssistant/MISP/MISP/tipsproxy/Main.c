#include <stdio.h>
#include "stdafx.h"
#include "FileOperate.h"
#include "Main.h"
//#include "filter.h"
#include <unistd.h>
#include <fcntl.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/stat.h>

//#include "httpFilter.h"

//Globle variable


pthread_mutex_t csmainc;
char g_cTFPin[30];
int gd_childpid = 0;

char g_PrivateKey[255]={0};
char g_cSessionID[255]={0};
char g_cCertDeviceType[10]={0};
int *m_status = 0;
#define PERMISSION_APPLY_MAP_LOCAL_BINDPORT			"8080"
#define PERMISSION_APPLY_MAP_REMOTE_IP				"127.0.0.1"
#define PERMISSION_APPLY_MAP_REMOTE_PORT				"80"




#include <dlfcn.h>

/* main method         */
/* proxy main entry    */
/* 2011-07             */
int tisProxyStart(PVPN_PROXY_CONFIGINI pConfigIniInfo,char *configPath,char *sessonID,char *privateKey,int *status)
{
	//variable definition
	
	THREAD_ID	id;			
	int iNum  = 0;
	int bindPort = 0;
	SOCKET  hSocket			= INVALID_SOCKET;
    //save Sesson ID for proxy enc&dec data
    memset(g_cSessionID, 0, sizeof(g_cSessionID));
    memset(g_PrivateKey, 0, sizeof(g_PrivateKey));
    memcpy(g_cSessionID, sessonID, strlen(sessonID));
    memcpy(g_PrivateKey, privateKey, 16);
    m_status = status;
    
	//read configuration
	GetTisvpnProxyConfig(pConfigIniInfo,configPath);


	//thread lock initialize
	pthread_mutex_init(&csmainc, NULL);
	//build socket listen according to map,
	//start 20000 port directly
	for(iNum = 0; iNum < (pConfigIniInfo->remoteservicenum+1); iNum++)
	{
		//build param configuration
		VPN_PROXY_SOCK5_PARAMS *proxyParam = malloc(sizeof(VPN_PROXY_SOCK5_PARAMS));
		memset(proxyParam, 0,sizeof(VPN_PROXY_SOCK5_PARAMS));
		//application socket listen
		/* modify by wangbinayang 2012-10-31 Zotn
		if(iNum == pConfigIniInfo->remoteservicenum) {
            printf("\n##################################################\n");
			bindPort = 20000;
		} else {
			bindPort =atoi(pConfigIniInfo->remoteService[iNum].bindport);
		}
         */
        //add by wangbingyang 2012-10-31
        bindPort =atoi(pConfigIniInfo->remoteService[iNum].bindport);
        
		hSocket = Socket_Listen(NULL,bindPort);
		//create accept thread
		if(hSocket !=0 && hSocket != INVALID_SOCKET) {
            //监听端口开启
            unsigned long tmp = PROXY_CONNECT_STATUS_CONNECTED_SUCCESS;
            memcpy(m_status, &tmp, sizeof(tmp));
			//start application process thread for processing incoming request
			proxyParam->iLisen		= hSocket;
			proxyParam->clientSock	= iNum;	
			proxyParam->bindPort	= bindPort;
			strcpy(proxyParam->dwSocks5Svr, pConfigIniInfo->serverip);
			strcpy(proxyParam->wSocks5Port, pConfigIniInfo->serverport);
			proxyParam->ss5zip = pConfigIniInfo->ss5ziptype;
            /* modify by wangbingyang 2012-10-31 zotn
			if(iNum == pConfigIniInfo->remoteservicenum) {//for port 20000,without remoute application ip and port
				strcpy(proxyParam->dwRemoteIP, "127.0.0.1");
				strcpy(proxyParam->wRemotePort, "20000");		
			} else {
				strcpy(proxyParam->dwRemoteIP, pConfigIniInfo->remoteService[iNum].server);
				strcpy(proxyParam->wRemotePort, pConfigIniInfo->remoteService[iNum].port);		
			}
             */
            //add by wangbingyang 2012-10-31 Zotn
            strcpy(proxyParam->dwRemoteIP, pConfigIniInfo->remoteService[iNum].server);
            strcpy(proxyParam->wRemotePort, pConfigIniInfo->remoteService[iNum].port);
            //end
            
            TISPROXYDEBUG("--ss5 client-- start:ss5 serverip=<%s>\n serverport=<%s>\n ss5Zip=<%d>",proxyParam->dwSocks5Svr,proxyParam->wSocks5Port,proxyParam->ss5zip);
			pthread_create((pthread_t *)&id, NULL, (void*)Thread_Sock5, (void*)proxyParam);
			TISPROXYDEBUG("--ss5 client- start listen port(%d) socket(%d) created thread(%lu) successfully \n", bindPort, hSocket,id);
		} else {
			free(proxyParam);
			proxyParam = NULL;
		}

	}
    
	while (1)
	{
		//Sleep(5000); 
	}
	
	//printf("--ss5 client-fir process is exit\n");
    //add by cooriyou 2013-05-09
    pthread_detach(pthread_self());
	pthread_mutex_destroy(&csmainc);
	return 1;
}


/* Thread_Sock5                              */
/* socks client socket accept process thread */
/* 2011-07                                   */
void* Thread_Sock5(void* pParam)
{
	
	//variable definition
	SOCKET sClientRecv = 0;
	
	THREAD_ID id = 0;
	struct   sockaddr_in clientAddr;
	VPN_PROXY_SOCK5_PARAMS *proxyParam = 0;
	int clientAddrLen = sizeof(clientAddr);
	PVPN_PROXY_SOCK5_PARAMS remotesrvparam = (VPN_PROXY_SOCK5_PARAMS*)pParam;

	TISPROXYDEBUG("--ss5 client-  enter accept threadid(%d),socket(%d)\n",pthread_self(),remotesrvparam->iLisen);

	//block for waiting incoming accept
	while(1)
	{
		//blocking acception for incoming request
		sClientRecv = accept(remotesrvparam->iLisen, (struct sockaddr *)&clientAddr, (unsigned int *)&clientAddrLen);
		if(sClientRecv == INVALID_SOCKET) {
			TISPROXYDEBUG("--ss5 client-  client accept error,thread(%d) port(%d) will exit!\n",pthread_self(),remotesrvparam->bindPort);
			break;
		}

		//new and init proxy param
		proxyParam = malloc(sizeof(VPN_PROXY_SOCK5_PARAMS));
		memset(proxyParam, 0,sizeof(VPN_PROXY_SOCK5_PARAMS));

		//set proxy param
		proxyParam->clientSock = sClientRecv;
		memcpy(proxyParam->dwSocks5Svr, remotesrvparam->dwSocks5Svr, strlen(remotesrvparam->dwSocks5Svr));
		memcpy(proxyParam->wSocks5Port, remotesrvparam->wSocks5Port, strlen(remotesrvparam->wSocks5Port));
		memcpy(proxyParam->dwRemoteIP, remotesrvparam->dwRemoteIP, strlen(remotesrvparam->dwRemoteIP));
		memcpy(proxyParam->wRemotePort, remotesrvparam->wRemotePort, strlen(remotesrvparam->wRemotePort));
		proxyParam->ss5zip = 	remotesrvparam->ss5zip;
		if (strcmp(remotesrvparam->dwRemoteIP, "127.0.0.1"))
		{						
			TISPROXYDEBUG("--ss5 client- start Thread_Sock5_Process\n");
			pthread_create((pthread_t *)&id, NULL, (void*)Thread_Sock5_Process, (void*)proxyParam);
		}
		else
		{
            printf("\nXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n"); //modify by wangbingyang 2012-10-31
			//pthread_create((pthread_t *)&id, NULL, (void*)Thread_Sock5_Process20000, (void*)proxyParam);
			TISPROXYDEBUG("--ss5 client- start Thread_Sock5_Process20000 threadid(%lu) client socket(%d)\n",id,sClientRecv);
			////printf("!!!%s\n", proxyParam->dwSocks5Svr);
		}		
	}

	//thread exit
	close(remotesrvparam->iLisen);
	free(remotesrvparam);
	remotesrvparam = NULL;
    //add by cooriyou 2013-05-09
    pthread_detach(pthread_self());
    return 0;
}


int Validate(void* pParam, int *socket)
{
	//printf("Thread_Validate\n");
	
	char szBuffer[1024] = {0};
	int  iSend		  = 0;
	int  iRet	 = 0;
	int nerro = 0;
	char *pchTmp;
	int iPort = 0;

	DWORD	dwRemoteIP  = 0;
	WORD	wRemotePort = 0;
	int	    sVPNServer = 0;	
	VPN_PROXY_SOCK5_PARAMS remotesrvparam = *(VPN_PROXY_SOCK5_PARAMS*)pParam;
	int sClientRecv = remotesrvparam.clientSock;
	//fcntl(sClientRecv, F_SETFL, fcntl(sClientRecv, F_GETFD, 0)|O_NONBLOCK);
	iPort = strtol(remotesrvparam.wSocks5Port, &pchTmp, 10);

	*socket = Socket_Connect(remotesrvparam.dwSocks5Svr, iPort);
	if(-1 == *socket)
	{
		TISPROXYDEBUG("connect vpn server error:%s\n", strerror(nerro));
		if (*socket!=0)
		{
			close(sClientRecv);
		}
		if (*socket!=0)
		{
			close(*socket);
		}
		return 0;
	}
	TISPROXYDEBUG("connect vpn server success\n");

	if(strlen(g_PrivateKey)>0){
		szBuffer[0] = 0x5;
		szBuffer[1] = 0x1;
		szBuffer[3] = 's';
		szBuffer[4] = ':';
		memcpy(szBuffer+5, g_cSessionID, strlen(g_cSessionID));
		iSend  = 5+strlen(g_cSessionID);    
	}
	else{
		szBuffer[0] = 0x5;
		szBuffer[1] = 0x1;
		iSend  = 3;    
	}
	nerro = 0;
    //printf("socket ==> %d\n",*socket);
	iRet = Socket_Send(*socket, szBuffer, iSend, 0, 5);
	//TISPROXYDEBUG("send vpn server 51, iRet=%d\n", iRet);
	if(iRet < 0)
	{
		TISPROXYDEBUG("send vpn server error:%d---%s\n", nerro, strerror(nerro));
		if (sClientRecv!=0)
		{
			close(sClientRecv);
		}
		if (*socket!=0)
		{
			close(*socket);
		}
		TISPROXYDEBUG("thread exit\n");
		return 0;
	}
	//TISPROXYDEBUG("send vpn server 51 ok, iRet=%d\n", iRet);

	memset(szBuffer, 0, sizeof(szBuffer));
    //modify by wangbingyang
/*    
	if((iRet = Socket_Recv(*socket, szBuffer, 2, 0, 1) == 0)) //modify by wangbingyang 2012-10-31 Zotn timeout 5
		//	if(iRet = rcv(sVPNServer, szBuffer, sizeof(szBuffer), 20) == 0)
		//	if(iRet = recv(sVPNServer, szBuffer, sizeof(szBuffer),0) == -1)
	{
		TISPROXYDEBUG("recv vpn server 51, iRet=%d\n", iRet);
		if (*socket != 0)
		{
//            TISPROXYDEBUG("1 － close socket , iRet=%d\n", iRet);
			close(*socket);
			return 0;
		}
	}
*/    
    //add by wangbingyang 2012/11/10
    iRet = recv(*socket, szBuffer, 2, 0);
    if (iRet <= 0) {
        close(*socket);
        TISPROXYDEBUG("!!!!! Socket is closed!\n");
        return 0;
    }
    TISPROXYDEBUG("----------------1---------------------\n");
    //end
	TISPROXYDEBUG("recv vpn server 51 OK, iRet=%d\n", iRet);

	if (szBuffer[0] != 0x5 && szBuffer[1] != 0x0)
	{
		//	√®¬ø¬û√¶¬é¬•√•‚Ç¨¬±√®≈Ω¬?
		if (sClientRecv!=0)
		{
			close(sClientRecv);
		}
		if (*socket!=0)
		{
			close(*socket);
		}
		TISPROXYDEBUG("Thread_Sock5_Process port: exit, because recv VPN Server Data error\n");
		return 0;
	}
	memset(szBuffer, 0, sizeof(szBuffer));
	szBuffer[0] = 0x5;
	szBuffer[1] = 0x1;
	szBuffer[3] = 0x1;
	dwRemoteIP  = inet_addr(remotesrvparam.dwRemoteIP);
	szBuffer[7] = (dwRemoteIP&0xFF000000)>>24;
	szBuffer[6] = (dwRemoteIP&0xFF0000)>>16;
	szBuffer[5] = (dwRemoteIP&0xFF00)>>8;
	szBuffer[4] = (dwRemoteIP&0xFF);
	wRemotePort = atoi(remotesrvparam.wRemotePort);
	szBuffer[8] = (wRemotePort&0xFF00)>>8;
	szBuffer[9] = (wRemotePort&0xFF);
	iSend  = 10;
	iRet = Socket_Send(*socket, szBuffer, iSend, 0, 5);
	//TISPROXYDEBUG("send vpn server ip and port, iRet=%d\n", iRet);
	if(iRet == -1)
	{
		TISPROXYDEBUG("send romteserver info:%d\n", iRet);
		if (sClientRecv!=0)
		{
			close(sClientRecv);
		}
		if (sVPNServer!=0)
		{
			close(sVPNServer);
		}
		return 0;
	}
	//TISPROXYDEBUG("send vpn server ip and port ok, iRet=%d\n", iRet);
	//////////////////////////////////////////////////////////////////////////
	memset(szBuffer, 0, sizeof(szBuffer));
    //modify by wangbingyang
/*
	if((iRet = Socket_Recv(*socket, szBuffer, 10, 0, 1) == 0)) //modify by wangbingyang Zotn TimeOut
		//	if(iRet = rcv(sVPNServer, szBuffer, sizeof(szBuffer), 20) == 0)	
		//	if(iRet = recv(sVPNServer, szBuffer, sizeof(szBuffer),0) == 0)
	{
		TISPROXYDEBUG("recv vpn server ip and port1, iRet=%d\n", iRet);
		if (*socket != 0)
		{
            TISPROXYDEBUG("2 － close socket , iRet=%d\n", iRet);
			close(*socket);
		}
	}
*/
    
  
    //add by wangbingyang 2012/11/10
    iRet = recv(*socket, szBuffer, 10, 0);
    if (iRet <= 0) {
        close(*socket);
        TISPROXYDEBUG("!!!!! Socket is closed!");
        return 0;
    }
    TISPROXYDEBUG("----------------2---------------------\n");
    //end
    
	TISPROXYDEBUG("recv vpn server ip and port2, iRet=%d\n", iRet);

	if (szBuffer[0] != 0x5 && szBuffer[1] != 0x0)
	{	
		TISPROXYDEBUG("5.1 error\n");
		if (sClientRecv!=0)
		{
			close(sClientRecv);
		}
		if (*socket!=0)
		{
			close(*socket);
		}
		return 0;
	}		 
//	return *socket;
    
    
    TISPROXYDEBUG("----------------50 51 Over---------------------\n");
    return 1;
}



void* Thread_Sock5_Process(void* pParam)
{ 
	int sVPNServer  = 0;              // server's socket;
	int iRecvLenght = 0;
	unsigned long iDecLenght  = 0;
	int iZip = -1;
	//////////////////////////////////////////////////////////////////////////

	char RecvBuffer[PROXY_SOCKET_BUFFER_SIZE + PROXY_SOCKET_ENC_SIZE * 2]  = {0}; 	
	char DecBuffer[PROXY_SOCKET_BUFFER_SIZE + PROXY_SOCKET_ENC_SIZE * 2]   = {0}; 
	char TotalBuffer[PROXY_SOCKET_BUFFER_SIZE * 2 + PROXY_SOCKET_ENC_SIZE * 4] = {0}; 
	char szRecvCilentBuffer[PROXY_SOCKET_BUFFER_SIZE * 2] = {0};
	int  iTotalBufferPos = 0;
	
	
	struct timeval tvLeft = {5, 0};
	FRAMEHEAD head;
	
	//recieve outer proxy param
	VPN_PROXY_SOCK5_PARAMS remotesrvparam = *(VPN_PROXY_SOCK5_PARAMS*)pParam;
	SOCKET sClientRecv = remotesrvparam.clientSock;
	int	iRet	    	= 0; 
	int iSocket		= 0;   //
	fd_set	fdSvrRead;
	
	iZip = 	remotesrvparam.ss5zip;
	if(!Validate(pParam, &sVPNServer))
	{
		close(sClientRecv);
        TISPROXYDEBUG("!!!!! Validate is fail!");
		return 0; //MDF ZTW
	}
    
    //add by wangbingyang
//    sleep(10);
    
	if(sClientRecv >= sVPNServer)
	{
		iSocket = sClientRecv;
	}
	else
	{
		iSocket = sVPNServer;
	}
	//the following data process data
//    TISPROXYDEBUG("----------------3---------------------\n");
	while(TRUE)
	{
		//initialize fd set for client and server socket pair
		FD_ZERO(&fdSvrRead);			
		FD_SET(sClientRecv, &fdSvrRead);
		FD_SET(sVPNServer, &fdSvrRead);	
		tvLeft.tv_sec = 15;  //Modify by wangbingyang 2012-10-31 zotn
//		TISPROXYDEBUG("----------------4---------------------\n");
		//select method
		iRet = select(iSocket + 1, &fdSvrRead, NULL, NULL, &tvLeft);    
		if(iRet < 0 )//socket error
		{
			TISPROXYDEBUG("--ss5 client- socket select error(%d)\n",errno);
			break;
		}			
		if (iRet == 0)//timeout
		{
			continue;
		}
        
		//data from vpn server	
		if(FD_ISSET(sVPNServer, &fdSvrRead))
		{
//            TISPROXYDEBUG("----------------5---------------------\n");
			iRecvLenght = recv(sVPNServer, TotalBuffer + iTotalBufferPos, PROXY_SOCKET_BUFFER_SIZE, 0);
//			TISPROXYDEBUG("--ss5 client - recv from ss5 data len (%d) totallen (%d)\n", iRecvLenght,iTotalBufferPos);
			if (iRecvLenght <= 0)
			{
				break;
			}
			iTotalBufferPos += iRecvLenght;
			while (iTotalBufferPos >= 16)
			{
				//get head
				memset(&head,0,16);
				memcpy(&head, TotalBuffer, 16);
				if(iTotalBufferPos < head.dwTotalLen)
				{
					break;
				}
				//TISPROXYDEBUG("--ss5 client - find a whole package\n");
				memset(RecvBuffer, 0, sizeof(RecvBuffer));
				memset(DecBuffer, 0, sizeof(DecBuffer));
				memcpy(RecvBuffer, TotalBuffer, head.dwTotalLen);
				memcpy(TotalBuffer, TotalBuffer + head.dwTotalLen, iTotalBufferPos - head.dwTotalLen);
				memset(TotalBuffer + iTotalBufferPos - head.dwTotalLen, 0, head.dwTotalLen);
				iTotalBufferPos -= head.dwTotalLen;
				//printf("--ss5 recv from server eny data info\n%s\n", RecvBuffer);
				iRet = SS5_Proxy_Dec((unsigned char *)RecvBuffer, head.dwTotalLen, (unsigned char *)DecBuffer, &iDecLenght, iZip);
//				printf("--ss5 recv from server dec data info\n%s\n", DecBuffer);
				//send data directly
				iDecLenght = send(sClientRecv,DecBuffer,iDecLenght,0);
			}
		}
		// data from client				
		if(FD_ISSET(sClientRecv, &fdSvrRead))
			{
//                TISPROXYDEBUG("----------------6---------------------\n");
				ZeroMemory(szRecvCilentBuffer, sizeof(szRecvCilentBuffer));
				iRet = recv(sClientRecv, szRecvCilentBuffer, sizeof(szRecvCilentBuffer), 0);
//				printf("recv form web:\n%s\n", szRecvCilentBuffer);
				if (iRet == SOCKET_ERROR || iRet == 0)
				{
					if (sClientRecv!=INVALID_SOCKET)
					{
						closesocket(sClientRecv);
					}
					if (sVPNServer!=INVALID_SOCKET)
					{
						closesocket(sVPNServer);
					}
					break;
				}
				ZeroMemory(DecBuffer, sizeof(DecBuffer));
//				printf("send data to VPN:\n%s\n", szRecvCilentBuffer);
				if(CCR_SUCCESS == SS5_Proxy_Enc((unsigned char *)szRecvCilentBuffer, iRet, (unsigned char *)DecBuffer, &iDecLenght, iZip))
				{
//					printf("--ss5 send to server eny data info\n%s\n", DecBuffer);
					iRet = send(sVPNServer, DecBuffer, iDecLenght, 0);
				}
				if(iRet == SOCKET_ERROR)
				{
					if (sClientRecv!=INVALID_SOCKET)
					{
						closesocket(sClientRecv);
					}
					if (sVPNServer!=INVALID_SOCKET)
					{
						closesocket(sVPNServer);
					}
					break;
				}						
			}
	}
	
	//while thread exit,clear
	TISPROXYDEBUG("--ss5 client- thread (%d) exit\n",pthread_self());
	if(sClientRecv >0) {	
		close(sClientRecv);
        TISPROXYDEBUG("----------------close(sClientRecv);---------------------\n");
	}	
	if(sVPNServer >0) {
		close(sVPNServer);
        TISPROXYDEBUG("-----------------close(sVPNServer);---------------------\n");
	}
	FD_CLR(sClientRecv, &fdSvrRead);
	FD_CLR(sVPNServer, &fdSvrRead);	
	free(pParam);
	pParam = 0;
    //add by cooriyou 2013-05-09
    pthread_detach(pthread_self());
	return 0;
}

/* Thread_Sock5_Process20000				*/
/* ss5 20000 process method				*/
/* 2011-07						*/

void* Thread_Sock5_Process20000(void* pParam)
{
    return 0;
}

//void* Thread_Sock5_Process20000(void* pParam)
//{ 
//	int sVPNServer  = 0;              // server's socket;
//	int iResult     = 0;    
//	int iRecvLenght = 0;
//	unsigned long iDecLenght  = 0;
//	int iSendLenght = 0;
//	unsigned long iEncLenght  = 0;
//	char TmpRemoteIP[255]			 = {0};
//	//////////////////////////////////////////////////////////////////////////
//
//	char RecvBuffer[PROXY_SOCKET_BUFFER_SIZE + PROXY_SOCKET_ENC_SIZE * 2]  = {0}; 	
//	char DecBuffer[PROXY_SOCKET_BUFFER_SIZE + PROXY_SOCKET_ENC_SIZE * 2]   = {0}; 
//	char TotalBuffer[PROXY_SOCKET_BUFFER_SIZE * 2 + PROXY_SOCKET_ENC_SIZE * 4] = {0}; 
//	int  iTotalBufferPos = 0;
//	int iZip = -1;
//	
//	struct timeval tvLeft = {5, 0};
//	FRAMEHEAD head;
//
//	//add begin sunfei 2011-08-05
//	char restBuffer[1024*6];
//	char handleWholePackageBuffer[1024*6];
//	VPN_HTTP_BUILD_PACKAGE_INFO httpBuildPkg;
//	memset(&httpBuildPkg, 0, sizeof(VPN_HTTP_BUILD_PACKAGE_INFO));
//	memset(restBuffer, 0, sizeof(restBuffer));
//	memset(handleWholePackageBuffer, 0, sizeof(handleWholePackageBuffer));
//	httpBuildPkg.pRecvSS5Data = DecBuffer;
//	httpBuildPkg.pRestSS5Data = restBuffer;
//	httpBuildPkg.pHandledWholeData = handleWholePackageBuffer;
//	httpBuildPkg.iDataType = 1;
//	//add end sunfei 2011-08-05
//
//    printf("****************");
//    
//	//recieve outer proxy param
//	VPN_PROXY_SOCK5_PARAMS remotesrvparam = *(VPN_PROXY_SOCK5_PARAMS*)pParam;
//	SOCKET sClientRecv = remotesrvparam.clientSock;
//	int	iRet	    	= 0; 
//	int iSocket		= 0;   //
//	fd_set	fdSvrRead;
//	iZip = 	remotesrvparam.ss5zip;
//
//	//recieve first http package
//	memset(RecvBuffer, 0, sizeof(RecvBuffer));
//	iRecvLenght = recv(sClientRecv, RecvBuffer, sizeof(RecvBuffer), 0);
//	TISPROXYDEBUG("--tisproxy - start thread id = (%d) recieve web socket = (%d) length = (%d) data info\n%s\n",pthread_self(), sClientRecv,iRecvLenght,RecvBuffer);
//	if(!iRecvLenght)
//	{
//		iRecvLenght = Socket_Recv(sClientRecv, RecvBuffer, sizeof(RecvBuffer), 0, 1);
//	}
//	if(!iRecvLenght)
//	{
//		if(sClientRecv >0)
//		{	
//			close(sClientRecv);
//		}	
//		if(sVPNServer >0)
//		{
//			close(sVPNServer);	
//		}
//		FD_CLR(sClientRecv, &fdSvrRead);
//		FD_CLR(sVPNServer, &fdSvrRead);	
//		free(pParam);
//		pParam = 0;
//		return 0;
//	}
//
//	DeleteEncondeGZIP(RecvBuffer);
//	
//	FindPart(RecvBuffer, "/requestpage=", &iResult, 1);
//	if (iResult > 20)
//	{
//		for (iSendLenght = iResult; iSendLenght < strlen(RecvBuffer); iSendLenght++)
//		{
//			if (RecvBuffer[iSendLenght] == '/')
//			{
//				break;
//			}
//		}
//		memcpy(TmpRemoteIP, RecvBuffer + iResult, iSendLenght - iResult);
//	}
//	else
//	{
//		removeHead(RecvBuffer, TmpRemoteIP, 1);		
//	}
//	memset(httpBuildPkg.RemoteIP, 0, 255);
//	memcpy(httpBuildPkg.RemoteIP, TmpRemoteIP, strlen(TmpRemoteIP));
//	TISPROXYDEBUG("--tisproxy get ipport = (%s)\n",TmpRemoteIP );
//
//	if (0 == Validate20000((int)remotesrvparam.dwSocks5Svr, httpBuildPkg.RemoteIP, &sVPNServer))
//	{
//		if(sClientRecv >0) {	
//			close(sClientRecv);
//		}	
//		if(sVPNServer >0) {
//			close(sVPNServer);	
//		}
//		free(pParam);
//		pParam = 0;
//		TISPROXYDEBUG("Validate20000 Fail\n");
//		return  0; //MDF ZTW
//	}
//	TISPROXYDEBUG("Validate20000 Success\n");
//
//	//encryption first http package 
//	//then send the first http package to ss5 server
//	TISPROXYDEBUG("data enc\n");
//	if(CCR_SUCCESS == SS5_Proxy_Enc((unsigned char *)RecvBuffer, strlen(RecvBuffer),(unsigned char *) DecBuffer, &iEncLenght, iZip))
//	{
//		iSendLenght = send(sVPNServer, DecBuffer, iEncLenght, 0);
//		TISPROXYDEBUG("send enc data, iLen=%d\n", iSendLenght);
//		if(iSendLenght <0)
//		{			
//			//close socket
//			if(sClientRecv >0) {	
//				close(sClientRecv);
//			}	
//			if(sVPNServer >0) {
//				close(sVPNServer);	
//			}
//			free(pParam);
//			pParam = 0;
//			return  0; //MDF ZTW
//		}
//	}	
//
//	//calculate max socket
//	if(sClientRecv >= sVPNServer)
//	{
//		iSocket = sClientRecv;
//	}
//	else
//	{
//		iSocket = sVPNServer;
//	}
//	//the following data process data
//
//
//	while(TRUE)
//	{
//		//initialize fd set for client and server socket pair
//		FD_ZERO(&fdSvrRead);			
//		FD_SET(sClientRecv, &fdSvrRead);
//		FD_SET(sVPNServer, &fdSvrRead);	
//		tvLeft.tv_sec = 25; //modify by wangbingyang 2012-10-31 Zotn
//		
//		//select method
//		iRet = select(iSocket + 1, &fdSvrRead, NULL, NULL, &tvLeft);    
//		if(iRet < 0 )//socket error
//		{
//			TISPROXYDEBUG("--ss5 select error(%d) \n",errno);
//			break;
//		}			
//		if (iRet == 0)//timeout
//		{
//			TISPROXYDEBUG("--ss5 select timeout(%d) \n",errno);
//			continue;
//		}
//			
//		//data from vpn server	
//		if(FD_ISSET(sVPNServer, &fdSvrRead))
//		{
//			iRecvLenght = recv(sVPNServer, TotalBuffer + iTotalBufferPos, PROXY_SOCKET_BUFFER_SIZE, 0);
//			//TISPROXYDEBUG("--tisproxy recv from ss5server data len (%d) totallen (%d)\n", iRecvLenght,iTotalBufferPos);
//			if (iRecvLenght <= 0)
//			{
//				break;
//			}
//			iTotalBufferPos += iRecvLenght;
//			while (iTotalBufferPos >= 16)
//			{
//				//get head
//				memset(&head,0,16);
//				memcpy(&head, TotalBuffer, 16);
//				if(iTotalBufferPos < head.dwTotalLen)
//				{
//					break;
//				}
//				TISPROXYDEBUG("--tisproxy find a whole package from server\n");
//				memset(RecvBuffer, 0, sizeof(RecvBuffer));
//				memset(DecBuffer, 0, sizeof(DecBuffer));
//				memcpy(RecvBuffer, TotalBuffer, head.dwTotalLen);
//				memcpy(TotalBuffer, TotalBuffer + head.dwTotalLen, iTotalBufferPos - head.dwTotalLen);
//				memset(TotalBuffer + iTotalBufferPos - head.dwTotalLen, 0, head.dwTotalLen);
//				iTotalBufferPos -= head.dwTotalLen;
//				iRet = SS5_Proxy_Dec((unsigned char *)RecvBuffer, head.dwTotalLen, (unsigned char *)DecBuffer, &iDecLenght, iZip);
//				TISPROXYDEBUG("**************************************recv ss5 begin**************************************\n");
//				TISPROXYDEBUG("\n%s\n",RecvBuffer);
//				TISPROXYDEBUG("**************************************recv ss5 end  **************************************\n");		
//				TISPROXYDEBUG("**************************************recv ss5 dec begin**************************************\n");
//				TISPROXYDEBUG("\nhead.dwTotalLen=%lu iDecLenght=%lu\n%s\n",head.dwTotalLen,iDecLenght,DecBuffer);
//				TISPROXYDEBUG("**************************************recv ss5 dec end  **************************************\n");
//
//				//build html package
//				httpBuildPkg.iRecvSS5DataSize= iDecLenght;
//				iRet = BuildHttpPackage(&httpBuildPkg);
//				if (iRet == HTTP_BUILD_PACKAGE_RESULT_DIRECT_SEND)
//				{
//					iDecLenght = send(sClientRecv,httpBuildPkg.pHandledWholeData,httpBuildPkg.iHandledWholeDataSize,0);			
//					
//					TISPROXYDEBUG("**************************************direct send begin**************************************\n");
//					TISPROXYDEBUG("--tisproxy  send to web length =(%lu), httpBuildPkg.iHandledWholeDataSize=%d\n", iDecLenght, httpBuildPkg.iHandledWholeDataSize);
//					TISPROXYDEBUG("--tisproxy  send to web data info\n%s\n",httpBuildPkg.pHandledWholeData);
//					TISPROXYDEBUG("**************************************direct send end  **************************************\n");
//					httpBuildPkg.iHandledWholeDataSize = httpBuildPkg.iHandledWholeDataSize-iDecLenght;
//					memset(handleWholePackageBuffer, 0, sizeof(handleWholePackageBuffer));
//				}
//				if(iRet == HTTP_BUILD_PACKAGE_RESULT_CONTINUE)
//				{
//					TISPROXYDEBUG("continue\n");
//					continue;
//				}
//				if (iRet == HTTP_BUILD_PACKAGE_RESULT_SUCCESS)
//				{
//					iRet = send(sClientRecv, httpBuildPkg.pHandledWholeData, httpBuildPkg.iHandledWholeDataSize, 0);
//					TISPROXYDEBUG("************************************** send begin**************************************\n");
//					TISPROXYDEBUG("--tisproxy  send to web length =(%d), httpBuildPkg.iHandledWholeDataSize=%d\n", iRet, httpBuildPkg.iHandledWholeDataSize);
//					TISPROXYDEBUG("--tisproxy send to web info\n%s\n",httpBuildPkg.pHandledWholeData);
//					TISPROXYDEBUG("************************************** send end  **************************************\n");
//					memset(handleWholePackageBuffer, 0, sizeof(handleWholePackageBuffer));
//					httpBuildPkg.iHandledWholeDataSize = 0;
//				}
//			}
//		}
//		// data from client				
//		if(FD_ISSET(sClientRecv, &fdSvrRead))
//		{
//			if (DoClient(sVPNServer, sClientRecv, 2, TmpRemoteIP) == -1)
//			{				
//				break;
//			}		
//		}	
//	}
//	
//	//while thread exit,clear
//	TISPROXYDEBUG("--tisproxy  thread (%d) exit\n",pthread_self());
//	if(sClientRecv >0) {	
//		close(sClientRecv);
//	}	
//	if(sVPNServer >0) {
//		close(sVPNServer);	
//	}
//	FD_CLR(sClientRecv, &fdSvrRead);
//	FD_CLR(sVPNServer, &fdSvrRead);	
//	free(pParam);
//	pParam = 0;
//	return 0;
//}

/*Validate20000						*/
/*build tisproxy conn ection according to dynamical remote ip*/
/*2011-07		
*/

//int Validate20000(int sSrv, char * RemoteIP, int *socket)
//{
//	struct   timeval   tpstart,tpend; 
//	gettimeofday(&tpstart,NULL); 
//	float timeuse; 	
//	char szBuffer[255] = {0};
//	int  iSend		  = 0;
//	int  iRet	 = 0;
//	int nerro = 0;
//
//	char IP[255] = {0};
//	int iResult = 0;
//	//char tmpip[255] = {0};
//
//	unsigned long	dwRemoteIP  	= 0;
//	unsigned short	wRemotePort 	= 0;
//	int	    	sVPNServer 	= 0;	
//	char    	port[10]    	= {0};
//
//	TISPROXYDEBUG("Enter Validate20000\n");
//	*socket = Socket_Connect(sSrv, SERVER_PORT);
//	if(-1 == *socket)
//	{
//		TISPROXYDEBUG("connect vpn server error:%s, ip=%s\n", strerror(nerro), sSrv);	
//		if (*socket!=0)
//		{
//			close(*socket);
//		}
//		return 0;
//	}
//	TISPROXYDEBUG("connect vpn server success, ip=%s\n", sSrv);
//	
//	//fist verify, send 0x51 to tisproxy server
//	if(strlen(g_PrivateKey)>0){
//		szBuffer[0] = 0x5;
//		szBuffer[1] = 0x1;
//		szBuffer[3] = 's';
//		szBuffer[4] = ':';
//		memcpy(szBuffer+5, g_cSessionID, strlen(g_cSessionID));
//		iSend  = 5+strlen(g_cSessionID);    
//	}
//	else{
//		szBuffer[0] = 0x5;
//		szBuffer[1] = 0x1;
//		iSend  = 3;    
//	} 
//	nerro = 0;
//	iRet = send(*socket, szBuffer, iSend, 0);
//	if(iRet < 0)
//	{
//		TISPROXYDEBUG("send vpn server error:%d---%s\n", nerro, strerror(nerro));
//
//		if (*socket!=0)
//		{
//			close(*socket);
//		}
//		TISPROXYDEBUG("thread exit\n");
//		return 0;
//	}
//	TISPROXYDEBUG("Validate20000 send51 ok, iRe=%d\n", iRet);
//
//	memset(szBuffer, 0, sizeof(szBuffer));
//	if((iRet = recv(*socket, szBuffer, 2, 0) == 0))
//	{
//		TISPROXYDEBUG("Validate20000 recv51, iRet=%d\n", iRet);
//		if (*socket != 0)
//		{
//			close(*socket);
//			return 0;
//		}
//	}
//	TISPROXYDEBUG("Validate20000 recv51 ok, iRe=%d\n", iRet);
//	
//	//wheather get 0x50 from tisproxy server
//	if (szBuffer[0] != 0x5 && szBuffer[1] != 0x0)
//	{
//		if (*socket!=0)
//		{
//			close(*socket);
//		}
//		TISPROXYDEBUG("Thread_Sock5_Process port:%d exit, because recv VPN Server Data error\n");
//		return 0;
//	}
//	
//	//send remote ip and prot to tisproxy server ,build tisproxy connection
//	memset(szBuffer, 0, sizeof(szBuffer));
//	szBuffer[0] = 0x5;
//	szBuffer[1] = 0x1;
//
//	iResult = FindPort(RemoteIP, port, IP);	
//	TISPROXYDEBUG("find port RemoteIP=%s, port=%s, IP=%s, iResult=%d", RemoteIP, port, IP, iResult);
//
//
//	if (IP[0] > 0x39)
//	{
//		szBuffer[3] = 0x03;
//		memcpy(szBuffer + 5, IP, strlen(IP));
//		szBuffer[4] = (unsigned char)strlen(IP);
//		if(strlen(port))
//		{			
//			wRemotePort = atoi(port);
//			szBuffer[strlen(IP) + 5] = (wRemotePort&0xFF00)>>8;
//			szBuffer[strlen(IP) + 6] = (wRemotePort&0xFF);
//			iSend = strlen(IP) + 7;
//		}
//	}
//	else
//	{
//		szBuffer[3] = 0x1;
//		dwRemoteIP  = inet_addr(IP);
//		szBuffer[7] = (dwRemoteIP&0xFF000000)>>24;
//		szBuffer[6] = (dwRemoteIP&0xFF0000)>>16;
//		szBuffer[5] = (dwRemoteIP&0xFF00)>>8;
//		szBuffer[4] = (dwRemoteIP&0xFF);
//		if(strlen(port))
//		{			
//			wRemotePort = atoi(port);
//			szBuffer[8] = (wRemotePort&0xFF00)>>8;
//			szBuffer[9] = (wRemotePort&0xFF);
//			iSend = 10;
//		}
//
//	}
//	iRet = send(*socket, szBuffer, iSend, 0);
//	if(iRet == -1)
//	{
//		TISPROXYDEBUG("send romteserver info:%d\n", iRet);
//		if (sVPNServer!=0)
//		{
//			close(sVPNServer);
//		}
//		return 0;
//	}
//	TISPROXYDEBUG("send romteserver info ok :%d\n", iRet);
//	//////////////////////////////////////////////////////////////////////////
//	memset(szBuffer, 0, sizeof(szBuffer));
//	iRet = recv(*socket, szBuffer, sizeof(szBuffer), 0);
//	TISPROXYDEBUG("recv romteserver info ok :%d\n", iRet);	
//	if(iRet == 0)
//	{
//		if (*socket != 0)
//		{
//			close(*socket);
//		}
//		return 0;
//	}
//	//two phase verify successfully!
//	if (szBuffer[0] != 0x5 && szBuffer[1] != 0x0)
//	{	
//		TISPROXYDEBUG("5.1 error\n");
//		if (*socket!=0)
//		{
//			close(*socket);
//		}
//		return 0;
//	}
//	
//	
//	//calculate time okay!
//	gettimeofday(&tpend,NULL);  
//	timeuse=1000000*(tpend.tv_sec-tpstart.tv_sec)+tpend.tv_usec-tpstart.tv_usec;
//	timeuse/=1000000;
//	TISPROXYDEBUG( "--tisproxy - connect time ellasped(%f)\n ",timeuse); 
//	return *socket;
//}

/*DoClient			*/
/*recieve  client  data 	*/
/*2011-07			*/
//int DoClient(int sServer, int sClient, int Zip, char * chIP)
//{
//	int iRecvLenght = 0;
//	unsigned long iEncLenght  = 0;
//	int iSendLenght = 0;
//	
//	char szRecvCilentBuffer[1024 * 6] = {0};
//	char szEncBuffer[1024 * 6]        = {0};
//	char TmpRemoteIP[255];
//
//	char chFavicon[] = "/favicon.ico HTTP/1.1";
//	char ch404[]     = "HTTP/1.1 404 Not Found\r\n\r\n";
//	memset(szRecvCilentBuffer, 0, sizeof(szRecvCilentBuffer));
//	memset(szEncBuffer, 0, sizeof(szEncBuffer));
//	
//	//recieve data from client according to mtu
//	iRecvLenght = recv(sClient, szRecvCilentBuffer, 4096, 0);
//	if(iRecvLenght <=0)
//	{	
//		TISPROXYDEBUG( "--tisproxy doClient - recieve data from web error!client socket(%d) erro no(%d) thread id(%d)\n",sClient,errno,pthread_self());		
//		return -1;
//	}
//	
//	DeleteEncondeGZIP(szRecvCilentBuffer);
//	
//	FindPart(szRecvCilentBuffer, chFavicon, &iSendLenght, 1);
//	if (iSendLenght)
//	{
//		send(sClient, ch404, strlen(ch404), 0);
//		return  0; //MDF ZTW
//	}		
//	TISPROXYDEBUG( "--tisproxy doClient socket(%d) data len(%d) thread id(%d) recieve data info\n%s\n",sClient,strlen(szRecvCilentBuffer),pthread_self(),szRecvCilentBuffer);
//	memset(TmpRemoteIP, 0, sizeof(TmpRemoteIP));
//	ReplaceMoreHttpRequestHeader(szRecvCilentBuffer, &iRecvLenght, TmpRemoteIP);		
//	TISPROXYDEBUG( "--tisproxy doClient ReplaceMoreHttpRequestHeader data info\n%s\n",szRecvCilentBuffer);
//	if(CCR_SUCCESS == SS5_Proxy_Enc((unsigned char *)szRecvCilentBuffer, strlen(szRecvCilentBuffer), (unsigned char *)szEncBuffer, &iEncLenght, TRUE))
//	{						
//		TISPROXYDEBUG("--tisproxy  send to ss5server sSocket:%d sClient:%d\n", sServer, sClient);	
//		iSendLenght = send(sServer, szEncBuffer, iEncLenght, 0);	
//		if(iSendLenght <0)
//		{	
//			TISPROXYDEBUG( "--tisproxy doClient - send to server error!server socket(%d) erro no(%d) thread id(%d)\n",sServer,errno,pthread_self()); 					
//			return -1;
//		}
//	}		
//}

//void DeleteEncondeGZIP(char *SourceData)
//{	
//	int iPost = 0;	
//	FindPart(SourceData, "Accept-Encoding: gzip,", &iPost, 1);
//	
//	if (iPost)
//	{
//		memcpy(SourceData + iPost - 6, "      ", 6);
//		//printf("--ss5 deleted gzip info\n%s\n", SourceData);
//	}
//}
