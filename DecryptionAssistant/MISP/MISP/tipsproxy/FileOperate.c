#include "stdafx.h"
#include "FileOperate.h"


// 将所有的Tab替换成Space
void SF_TabToSpace(char *str)
{
	int n = 0;

	if (str == NULL) return ;
	for (n=0; n<(signed)strlen(str); n++) 
	{
		if (str[n] == '\t') str[n] = ' ';
	}
}

// 将多个Space精简成一个Space
void SF_ReduceSpace(char *str)
{
	int		len = 0;
	int		n = 0;
	int		bn = 0;
	char	*bStr = NULL;

	if (str == NULL) return ;
	SF_TabToSpace(str);
	len = strlen(str);
	bStr = (char*)calloc(1, len+1);
	if (bStr == NULL) return ;
	for (n=0, bn=0; n<len; n++) 
	{
		if ((bStr[bn] == ' ')&&(str[n] = ' ')) continue ;
		bStr[bn++] = str[n];
	}
	bStr[bn] = '\0';
	strcpy(str, bStr);
	free(bStr);
}

// 删除字符串中开始的Space和Tab
void SF_TrimLeft(char *str)
{
	int		st = 0;
	int		n = 0;

	if (str == NULL) return ;
	SF_TabToSpace(str);
	if (str[0] != ' ') return ;
	for (st=0; st<(signed)strlen(str); st++) 
	{
		if (str[st] != ' ') break;
	}
	for (n=0; n<(signed)strlen(str)-st+1; n++) 
	{
		str[n] = str[n+st];
	}
}

// 删除字符串中开始的Space和Tab
void SF_TrimRight(char *str)
{
	int st = 0;

	if (str == NULL) return ;
	SF_TabToSpace(str);
	if (str[strlen(str)-1] != ' ') return ;
	for (st=strlen(str)-1; st>=0; st--) 
	{
		if (str[st] != ' ') break;
	}
	str[st+1] = '\0';
}

// 去掉左右Spaces和精简Space
void SF_Trim(char *str)
{
	if (str == NULL) return ;
	SF_TrimLeft(str);
	SF_TrimRight(str);
	SF_ReduceSpace(str);
}

// 将str中的所有sc字符替换成dc字符
void SF_CharToChar(char *str, char sc, char dc)
{
	int n = 0;

	if (str == NULL) return ;
	for (n=0; n<(signed)strlen(str); n++) 
	{
		if (str[n] == sc) str[n] = dc;
	}
}

// 删除注释字符串，注释号为';'�?#'
static void SF_RemoveComment(char *str)
{
//	int n = 0;
/*
	if (str == NULL) return ;
	for (n=0; n<(signed)strlen(str); n++) 
	{
		if ((str[n] == ';')||(str[n] == '#')) 
		{
			str[n] = '\0';
			break;
		}
	}
*/
}

static int SF_GetValueByName(char *str, char *name, char *value, int valueSize)
{
	char	fieldName[256];
	char	valueStr[512];
	int		st = 0;
	int		n = 0;
	int		i = 0;

	memset(fieldName,0,sizeof(fieldName));
	memset(valueStr,0,sizeof(valueStr));
	
	if ((str == NULL)||(name == NULL)||(value == NULL)) return -1;
	for (st=0; st<(signed)strlen(str); st++) 
	{
		if (str[st] == '=') break ;
	}
	for (n=0; n<st; n++) 
	{
		fieldName[n] = str[n];
	}
	fieldName[n] = '\0';
	SF_Trim(fieldName);
	for (i=st+1; i<(signed)strlen(str); i++) 
	{
		valueStr[i-st-1] = str[i];
	}
	valueStr[i-st-1] = '\0';
	SF_Trim(valueStr);
	if (0 != strcmp(fieldName, name)) 
	{
		return -1;
	}
	if (valueSize > (signed)strlen(valueStr)) valueSize = strlen(valueStr);
	strncpy(value, valueStr, valueSize);
	value[valueSize] = '\0';
	return 0;
}

/********************************************************************
* 功能      : 从指定的FileName配置文件中的Section段中查找key(类型
			  为字符串)的�?
* 参数	    : 
*			  
* 返回�?   : 
* 备注      : �?
*********************************************************************/
int SF_GetProfileString(char *FileName, char *Section, char *Key, char *Default, 
						char *Value, int ValueSize)
{
	FILE		*fp = NULL;
	char		iniLine[1024];
	int			status = 0;
	char		a[512];

	memset(iniLine,0,sizeof(iniLine));
	memset(a,0,sizeof(a));

	if ((FileName == NULL)||(Section == NULL)||(Key == NULL)) return -1;
	if ((fp = fopen(FileName, "r")) == NULL) 
	{
		return -1;
	}
	while (!feof(fp)) 
	{
		if (status == 0) 
		{ // 查找Section
			fgets(iniLine, sizeof(iniLine)-1, fp);
			SF_CharToChar(iniLine, 0x0a, ' ');
			SF_CharToChar(iniLine, 0x0d, ' ');
			SF_RemoveComment(iniLine);
			SF_Trim(iniLine);
			if (iniLine[0] == '[') 
			{
				SF_CharToChar(iniLine, '[', ' ');
				SF_CharToChar(iniLine, ']', '\0');
				SF_Trim(iniLine);
				if (0 != strcmp(iniLine, Section)) continue ;
				status = 1;
			}
			continue;
		}
		if (status == 1) 
		{ // 查找Key
			fgets(iniLine, sizeof(iniLine)-1, fp);
			SF_CharToChar(iniLine, 0x0a, ' ');
			SF_CharToChar(iniLine, 0x0d, ' ');
			SF_RemoveComment(iniLine);
			SF_Trim(iniLine);
			if (iniLine[0] == '[') break ;
			if (0 == SF_GetValueByName(iniLine, Key, a, sizeof(a))) 
			{
				if (0 == strcmp(a, "")) break;
				fclose(fp);
				if (ValueSize > (signed)strlen(a)) ValueSize = strlen(a);
				strncpy(Value, a, ValueSize);
				Value[ValueSize] = '\0';
				return 0;
			}
			continue ;
		}
		break ;
	}
	// 没有查到Section或Key返回缺省�?
	fclose(fp);
	if (Default == NULL)
	{
		Value[0] = '\0';
	}else{
		if (ValueSize > (signed)strlen(Default)) ValueSize = strlen(Default);
		strncpy(Value, Default, ValueSize);
		Value[ValueSize] = '\0';
	}
	return 0;
}

// void readini(char *filePath)
// {
// 	char cKeyValue[255];
// 	char sectionValue[255];
// 	int remoteServiceNum = 0;
// 	int i=0;
// 	
// 	memset(&sConfigIniInfo,0,sizeof(sConfigIniInfo));	
// 
// 	memset(cKeyValue,0,sizeof(cKeyValue));
// 	SF_GetProfileString(filePath,"socks5","ss5server","192.168.2.251",cKeyValue,sizeof(cKeyValue));
// 	strcpy(sConfigIniInfo.serverip,cKeyValue);
// 
// 	memset(cKeyValue,0,sizeof(cKeyValue));
// 	SF_GetProfileString(filePath,"socks5","ss5port","50022",cKeyValue,sizeof(cKeyValue));
// 	strcpy(sConfigIniInfo.serverport,cKeyValue);
// 
// 	memset(cKeyValue,0,sizeof(cKeyValue));
// 	SF_GetProfileString(filePath,"socks5","ss5zip","0",cKeyValue,sizeof(cKeyValue));
// 	sConfigIniInfo.ss5ziptype = atoi(cKeyValue);
// 
// 	memset(cKeyValue,0,sizeof(cKeyValue));
// 	SF_GetProfileString(filePath,"socks5","remoteservicenum","1",cKeyValue,sizeof(cKeyValue));
// 	sConfigIniInfo.remoteservicenum = atoi(cKeyValue);
// 	remoteServiceNum  = atoi(cKeyValue);
// 	
// 	for(i=0; i<remoteServiceNum; i++)
// 	{
// 		memset(sectionValue,0,sizeof(sectionValue));
// 		sprintf(sectionValue,"remote%d",i+1);
// 
// 		memset(cKeyValue,0,sizeof(cKeyValue));
// 		SF_GetProfileString(filePath,sectionValue,"server","192.168.2.241",cKeyValue,sizeof(cKeyValue));
// 		strcpy(sConfigIniInfo.remoteService[i].server,cKeyValue);
// 		
// 		memset(cKeyValue,0,sizeof(cKeyValue));
// 		SF_GetProfileString(filePath,sectionValue,"port","110",cKeyValue,sizeof(cKeyValue));
// 		strcpy(sConfigIniInfo.remoteService[i].port,cKeyValue);
// 
// 		memset(cKeyValue,0,sizeof(cKeyValue));
// 		SF_GetProfileString(filePath,sectionValue,"bindport","110",cKeyValue,sizeof(cKeyValue));
// 		strcpy(sConfigIniInfo.remoteService[i].bindport,cKeyValue);
// 	}
// 
// }

int  Tools_Info_GetFileLineNum(char *cFileName)
{
	FILE *fp=NULL;
	int dwsize=0;
	int iLineNum = 0;
	char cBuffer[1024];
	char *ptr = NULL;
	int iNowPos = 0;

	//打开文件
	if((fp = fopen(cFileName, "rb")) == NULL)
	{
		return -1;
	}
	//定位文件
	fseek(fp,0,SEEK_END);
	dwsize=ftell(fp);

	//定位文件
	fseek(fp, 0, SEEK_SET);

	//读取
	memset(cBuffer, 0, sizeof(cBuffer));
	fread(cBuffer, dwsize, 1, fp);
	fclose(fp);

	ptr = cBuffer;
	while(iNowPos < dwsize)
	{
		if(*ptr == 0x0A)
		{
			iLineNum++;
		}
		iNowPos++; 
		if(iNowPos != dwsize)
			ptr++;
	}

	return iLineNum;
}

int  Tools_Info_GetFileSize(char *cFileName)
{
	FILE *fp=NULL;
	int dwsize=0;

	fp=fopen(cFileName,"rb");

	if (NULL!=fp)
	{
		fseek(fp,0,SEEK_END);

		dwsize=ftell(fp);
		fclose(fp);
	}
	else
	{
		//TRACK("Tools_Info_GetFileSize File(%s) fopen Error",cFileName);
	}

	//TRACK("Tools_Info_GetFileSize File(%s) Size=%d",cFileName,dwsize);
	return dwsize;
}

int Tools_File_Read(char* cFileName,int iPos,char* cBuffer,int iReadLen)
{
	int iReaded=-1;
	FILE *fp = NULL;

	//打开文件
	if((fp = fopen(cFileName, "rb")) == NULL)
	{
		return -1;
	}

	//定位文件
	if (0!=iPos) fseek(fp, iPos, SEEK_SET);

	//读取
	iReaded = (int)fread(cBuffer, sizeof(char), iReadLen, fp);

	fclose(fp);
	fp = NULL;
	return iReaded;
}

void GetTisvpnProxyConfig(VPN_PROXY_CONFIGINI *Config,char *configPath)
{
	VPN_PROXY_CONFIGINI *pTmp;
	char cVpnServerIP[1024];
	char cTisvpnConfigName[255];
	char cManagementIpAndPort[255];
	char *p = NULL;
    //char configuserPath[128] = {0};
    char configmapPath[128] = {0};
	int iNowPos = 0;
	int iDataSize = 0;
	int iLineNum = 0;
	char cLocalManagementIP[255];
	char cLocalManagementPort[255];
	char cCipherType[30];
	
	memset(cTisvpnConfigName, 0, sizeof(cTisvpnConfigName));
	memset(cManagementIpAndPort, 0, sizeof(cManagementIpAndPort));
	memset(cVpnServerIP, 0, sizeof(cVpnServerIP));
	memcpy(cVpnServerIP, Config->serverip, strlen(Config->serverip));
	printf("get server,cVpnServerIP=%s\n",cVpnServerIP);

	sprintf(cTisvpnConfigName, "%s/%s.conf", configPath,cVpnServerIP);
    printf("cTisvpnConfigName is <%s>\n",cTisvpnConfigName);
	GetValueBySectionFromFile(cTisvpnConfigName, "management", cManagementIpAndPort);
	iDataSize = strlen(cManagementIpAndPort);
	p = cManagementIpAndPort;
	while(iNowPos < iDataSize)
	{
		if(*p == ' ')
		{
			memset(cLocalManagementIP, 0, sizeof(cLocalManagementIP));
			memset(cLocalManagementPort, 0, sizeof(cLocalManagementPort));
			strncpy(cLocalManagementIP, cManagementIpAndPort, iNowPos);
			strcpy(cLocalManagementPort, p+1);
			break;
		}
		p++;
		iNowPos ++;
		continue;
	}
	memset(cCipherType, 0, sizeof(cCipherType));
	GetValueBySectionFromFile(cTisvpnConfigName, "cipher", cCipherType);

	//strcpy(Config->serverip,cVpnServerIP);
	//strcpy(Config->serverport,"50022");
	
	if(strcmp(cCipherType,"AES-128-CBC") == 0)
		Config->ss5ziptype = 0;
	else
		Config->ss5ziptype = 2;
	
	Config->managementport = atoi(cLocalManagementPort);

    sprintf(configmapPath, "%s/%s",configPath,VPN_CLIENTCORE_CONFIGMAP_INI_PATH);
    printf("[%s][%d] configmap path is <%s>",__FILE__,__LINE__,configmapPath);
	iLineNum = Tools_Info_GetFileLineNum(configmapPath);
	Config->remoteservicenum = iLineNum;
	pTmp = Config;
	GetLineValueFromFile(configmapPath,iLineNum, pTmp);

}

void GetLineValueFromFile(char *pFilePath, int  iServiceNum, VPN_PROXY_CONFIGINI *Config)
{
	int iFileSize = 0;
	char cFileData[1024];
	int iNowPos = 0;
	int iFileRead = 0;
	int iLineNum = 0;
	char *pFileData = NULL;
	char *p[100][CONFIGMAPLINEPARTNUMBER];
	int index = 0;

	//��ȡ�ļ���С
	iFileSize  = Tools_Info_GetFileSize(pFilePath);
	
	//��ȡ�ļ�����
	memset(cFileData, 0, sizeof(cFileData));
	Tools_File_Read(pFilePath, 0, cFileData, iFileSize);
	pFileData = cFileData;
	
	while(iNowPos < iFileSize)
	{
		if((*(pFileData + iNowPos) == 0x0A) || (*(pFileData + iNowPos) == 0x0D))
		{
			iNowPos++;
			continue;	
		}
		for (index = 0; index < CONFIGMAPLINEPARTNUMBER; index++)
		{
			if (!index)
			{
				p[iLineNum][index] = pFileData + iNowPos;
				////printf("**************************!\n%s\n", pFileData + iNowPos);
			}
			else
			{
				p[iLineNum][index]=NULL;
			}
		}

		iFileRead = iNowPos;
		index = 0;
		while(iFileRead < iFileSize)
		{		
			if (*(pFileData + iFileRead ) == 0x0a || *(pFileData + iFileRead ) == 0x0d)
			{
				*(pFileData + iFileRead )='\0';
				
				strcpy(Config->remoteService[iLineNum].fold, p[iLineNum][index]);
				iLineNum++;
				break;
			}
			if (*(pFileData + iFileRead ) == ' ')
			{	
				//�ҵ��˵�һ���ո�
				*(pFileData + iFileRead )='\0';
				switch(index)
				{
				case 0:
					{
						strcpy(Config->remoteService[iLineNum].bindport, p[iLineNum][index]);
					}
					break;
				case 1:
					{
						strcpy(Config->remoteService[iLineNum].server, p[iLineNum][index]);
					}
					break;
				case 2:
					{
						strcpy(Config->remoteService[iLineNum].port, p[iLineNum][index]);
					}
					break;
				case 3:
					{
						strcpy(Config->remoteService[iLineNum].Type, p[iLineNum][index]);
					}
					break;
				case 4:
					{

						strcpy(Config->remoteService[iLineNum].Name, p[iLineNum][index]);
					}
					break;
				case 5:
					{
						strcpy(Config->remoteService[iLineNum].fold, p[iLineNum][index]);
					}
					break;
				default:
					break;
				}

				if (*(pFileData + iFileRead + 1) == 0x0a)
				{
					memset(Config->remoteService[iLineNum].fold, 0, 200);
					iLineNum++;
					break;
				}
				index++;
				if (CONFIGMAPLINEPARTNUMBER == index)
				{
					iLineNum++;
					break;
				}
				p[iLineNum][index] = pFileData + iFileRead + 1;	
			}
			iFileRead ++;
		}

		iNowPos = ++iFileRead;
	}
}
void GetValueBySectionFromFile(char *pFilePath, char *pSectionName, char *pSectionValue)
{
	//printf("VPN_CLIENTCORE_CONFIGUSER_INI_PATH:%s\n", pFilePath);
	int iFileSize = 0;
	char cFileData[1024];
	int iNowPos = 0;
	int iFileRead = 0;
	char *pFileData = NULL;
	char *p[3] = {0, 0, 0};
	
	//获取文件大小
	iFileSize  = Tools_Info_GetFileSize(pFilePath);
	
	//获取文件内容
	memset(cFileData, 0, sizeof(cFileData));
	Tools_File_Read(pFilePath, 0, cFileData, iFileSize);
	printf("iFileSize  =%d, cFileData=%s\n",iFileSize , cFileData);
	pFileData = cFileData;
	while(iNowPos < iFileSize)
	{
		if((*(pFileData + iNowPos) == 0x0A) || (*(pFileData + iNowPos) == 0x0D))
		{
			iNowPos++;
			continue;	
		}
		p[0] =pFileData + iNowPos;
		p[1]=NULL;
		
		iFileRead = iNowPos;
		while(iFileRead < iFileSize)
		{
			if ((*(pFileData + iFileRead )==' ')&&(NULL==p[1]))
			{//找到了第一个空�?
				*(pFileData + iFileRead )=0;
				p[1]=pFileData + iFileRead +1;
			}
			if (
				(*(pFileData + iFileRead )==0x0A)
				||
				(*(pFileData + iFileRead )==0x0D)
				)
			{
				*(pFileData + iFileRead )=0;
				iFileRead ++;
				break;
			}
			iFileRead ++;
		}

		if(0==strcmp(pSectionName,p[0]))
		{
			strcpy(pSectionValue,p[1]);
		}
		iNowPos=iFileRead;
	}
	
}
