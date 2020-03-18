#ifndef __MAIN_H__
#define __MAIN_H__

pthread_mutex_t cs;
#define PERMISSION_APPLY_MAP_LOCAL_BINDPORT			"8080"
#define PERMISSION_APPLY_MAP_REMOTE_IP				"127.0.0.1"
#define PERMISSION_APPLY_MAP_REMOTE_PORT				"80"


#define PROXY_CONNECT_STATUS_CONNECTED_SUCCESS  0x00000001
#define PROXY_CONNECT_STATUS_CONNECTED_FAULED   0x00000002
#define PROXY_CONNECT_STATUS_BIND_FAULED        0x00000003
#define PROXY_CONNECT_STATUS_NETWORK_ERROR      0x00000004
#define PROXY_CONNECT_STATUS_EXIT               0x00000000
//处理线程，完成数据转�?
int Validate(void* pParam, int *socket);
int Validate20000(int sSrv, char * RemoteIP, int *socket);
int DoClient(int sServer, int sClient, int Zip, char * chIP);
void* Thread_Sock5_Process(void* pParam);
void* Thread_Sock5_Process20000(void* pParam);
void* Thread_Sock5(void* pParam);
//void DeleteEncondeGZIP(char *SourceData);
void* Management_Moniter_Listen(void* pParam);
int tisProxyStart(PVPN_PROXY_CONFIGINI pConfigIniInfo,char *configPath,char *sessonID,char *privateKey,int *status);

#endif//main