#ifndef __FILEOPERATE_H__
#define __FILEOPERATE_H__

//#include "stdafx.h"
#define PERMISSION_APPLY_MAP_LOCAL_BINDPORT			"8080"
#define PERMISSION_APPLY_MAP_REMOTE_IP				"127.0.0.1"
#define PERMISSION_APPLY_MAP_REMOTE_PORT				"80"
void SF_TabToSpace(char *str);
void SF_ReduceSpace(char *str);
void SF_TrimLeft(char *str);
void SF_TrimRight(char *str);
void SF_Trim(char *str);

void SF_CharToChar(char *str, char sc, char dc);
static void SF_RemoveComment(char *str);
static int SF_GetValueByName(char *str, char *name, char *value, int valueSize);
int SF_GetProfileString(char *FileName, char *Section, char *Key, char *Default, 
						char *Value, int ValueSize);

int  Tools_Info_GetFileLineNum(char *cFileName);
int  Tools_Info_GetFileSize(char *cFileName);

int Tools_File_Read(char* cFileName,int iPos,char* cBuffer,int iReadLen);

void GetTisvpnProxyConfig(VPN_PROXY_CONFIGINI *Config,char *configPath);
void GetLineValueFromFile(char *pFilePath, int  iServiceNum, VPN_PROXY_CONFIGINI *Config);
void GetValueBySectionFromFile(char *pFilePath, char *pSectionName, char *pSectionValue);

#endif