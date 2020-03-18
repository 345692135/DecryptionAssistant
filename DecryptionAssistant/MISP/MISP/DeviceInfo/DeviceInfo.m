//
//  DeviceInfo.m
//  GetDeviceInfo
//
//  Created by nie on 12-8-7.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import "DeviceInfo.h"
#import "ifaddrs.h"
#import "arpa/inet.h"
#import <SystemConfiguration/SCSchemaDefinitions.h>  
#import <sys/sysctl.h>  
#include <sys/socket.h> // Per msqr
#include <net/if.h>
#include <net/if_dl.h>



@implementation DeviceInfo

static DeviceInfo  *deviceInfo = nil;

//  realize singleton class method
+ (DeviceInfo *)getInstance
{
    @synchronized(self){
        if (!deviceInfo) {
            deviceInfo = [NSAllocateObject([self class], 0, NULL) init];
        }
    }
    return deviceInfo;
}

+ (id)allocWithZone:(NSZone *)zone{
    @synchronized(self){
        if (deviceInfo == nil) {
            deviceInfo = [super allocWithZone:zone];
        }
    }
    return deviceInfo;   //assingment and return first allocation
}

- (id) retain{
    return  self;
}

- (NSUInteger)retainCount{
    return NSIntegerMax;
}

- (id)autorelease{
    return  self;
}

-(oneway void)release{
    //  DO Nothing
}

-(id)copyWithZone:(NSZone *)zone{
    return self;
}


//  get system version
- (NSString *)getSystemVersion
{
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    NSMutableString *temp = [[NSMutableString alloc] init];
    NSMutableString *ultimateSystemVersion = [NSMutableString string];
    
    if ([systemVersion  isEqualToString:@"5.1.1"]) {
        [temp appendString:iPhone5_1_1_FIRMWARE_ID];}
    if ([systemVersion isEqualToString:@"5.0.1"]) {
         [temp appendString:iPhone5_0_1_FIRMWARE_ID];}
    if ([systemVersion isEqualToString:@"5.0"]) {
        [temp appendString:iPhone5_0_FIRMWARE_ID];}
    
    
    if ([systemVersion isEqualToString:@"4.3.3"]) {
        [temp appendString:iPhone4_3_FIRMWARE_ID];}
    if ([systemVersion isEqualToString:@"4.3.2"]) {
        [temp appendString:iPhone4_3_2_FIRMWARE_ID];}
    if ([systemVersion isEqualToString:@"4.3.1"]) {
        [temp appendString: iPhone4_3_1_FIRMWARE_ID];}
    if ([systemVersion isEqualToString:@"4.3"]) {
        [temp appendString:iPhone4_3_FIRMWARE_ID];}
    
    if ([systemVersion isEqualToString:@"4.2.1"]) {
        [temp appendString:iPhone4_2_1_FIRMWARE_ID];}
    if ([systemVersion isEqualToString:@"4.1"]) {
        [temp appendString:iPhone4_1_FIRMWARE_ID];}
    if ([systemVersion isEqualToString:@"4.0.2"]) {
        [temp appendString:iPhone4_0_2_FIRMWARE_ID];}
    if ([systemVersion isEqualToString:@"4.0.1"]) {
        [temp appendString:iPhone4_0_1_FIRMWARE_ID];}
    if ([systemVersion isEqualToString:@"4.0"]) {
        [temp appendString:iPhone4_0_FIRMWARE_ID];}
    
    
    if ([systemVersion isEqualToString:@"3.1.3"]) {
        [temp appendString:iPhone3_1_3_FIRMWARE_ID];}
    if ([systemVersion isEqualToString:@"3.1.2"]) {
        [temp appendString:iPhone3_1_2_FIRMWARE_ID];}
    if ([systemVersion isEqualToString:@"3.1"]) {
        [temp appendString:iPhone3_1_FIRMWARE_ID];}
    if ([systemVersion isEqualToString:@"3.0.1"]) {
        [temp appendString:iPhone3_0_1_FIRMWARE_ID];}
    if ([systemVersion isEqualToString:@"3.0"]) {
        [temp appendString:iPhone3_0_FIRMWARE_ID];}
    
    if ([systemVersion isEqualToString:@"2.2.1"]) {
        [temp appendString:iPhone2_2_1_FIRMWARE_ID];}
    if ([systemVersion isEqualToString:@"2.2"]) {
        [temp appendString:iPhone2_2_FIRMWARE_ID];}
    if ([systemVersion isEqualToString:@"2.1"]) {
        [temp appendString:iPhone2_1_FIRMWARE_ID];}
    if ([systemVersion isEqualToString:@"2.0.2"]) {
        [temp appendString:iPhone2_0_2_FIRMWARE_ID];}
    if ([systemVersion isEqualToString:@"2.0.1"]) {
        [temp appendString:iPhone2_0_1_FIRMWARE_ID];}
    if ([systemVersion isEqualToString:@"2.0"]) {
        [temp appendString:iPhone2_0_FIRMWARE_ID];}
    
    if ([systemVersion isEqualToString:@"1.1.4"]) {
        [temp appendString:iPhone1_1_4_FIRMWARE_ID];}
    if ([systemVersion isEqualToString:@"1.1.3"]) {
        [temp appendString:iPhone1_1_3_FIRMWARE_ID];}
    if ([systemVersion isEqualToString:@"1.1.2"]) {
        [temp appendString:iPhone1_1_2_FIRMWARE_ID];}
    if ([systemVersion isEqualToString:@"1.1.1"]) {
        [temp appendString:iPhone1_1_1_FIRMWARE_ID];}
    if ([systemVersion isEqualToString:@"1.0.2"]) {
        [temp appendString:iPhone1_0_2_FIRMWARE_ID];}
    if ([systemVersion isEqualToString:@"1.0.1"]) {
        [temp appendString:iPhone1_0_1_FIRMWARE_ID];}
    if ([systemVersion isEqualToString:@"1.0"]) {
        [temp appendString:iPhone1_0_FIRMWARE_ID];}
    
    [ultimateSystemVersion appendFormat:@"%@(%@)",systemVersion,temp];
    [temp release];
    return ultimateSystemVersion;
    return nil;
}

//获取设备基本信息
- (NSDictionary *)getDeviceBaseInfo
{
    UIDevice *uidevice = [UIDevice currentDevice];
    
//    NSDictionary *deviceBaseInfo=[NSDictionary dictionaryWithObjectsAndKeys:[uidevice uniqueIdentifier],@"UNIQUE_ID",[uidevice localizedModel],@"LOCALIZED_MODEL",[uidevice systemVersion],@"SYSTEM_VERSION",[uidevice systemName],@"SYSTEM_NAME",[uidevice model],@"MODEL", nil];
    
    NSDictionary *deviceBaseInfo=[NSDictionary dictionaryWithObjectsAndKeys:[[uidevice identifierForVendor] UUIDString],@"UNIQUE_ID",[uidevice localizedModel],@"LOCALIZED_MODEL",[uidevice systemVersion],@"SYSTEM_VERSION",[uidevice systemName],@"SYSTEM_NAME",[uidevice model],@"MODEL", nil];
    return deviceBaseInfo;
}

//  获取 host 名称
- (NSString *)getHostname
{
    char baseHostName[256];
    int success = gethostname(baseHostName, 255);  //   成功返回success = 0
    if (success != 0) {
        return nil;
    }
    baseHostName[255] = '\0';
    
#if  TARGET_IPHONE_SIMULATOR
    return [NSString stringWithFormat:@"%s",baseHostName];
#else
    return [NSString stringWithFormat:@"%s.local", baseHostName];
#endif
}



- (NSString *)getIPAddressWithtype:(IPAddressType)IPType
{
    BOOL sucuess;
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    
    sucuess = getifaddrs(&addrs) == 0;//获取本机的IP地址
    if (sucuess)
    {
        cursor = addrs;
        while (cursor != NULL)
        {
            //  the second test keeps from picking up the looPback address
            if (cursor->ifa_addr->sa_family == AF_INET /*&& (cursor->ifa_flags & IFF_LOOPBACK) == 0*/)
            {
                NSString *name = [NSString stringWithUTF8String:cursor->ifa_name]; //name of interface
                if ([name isEqualToString:@"pdp_ip0"] && IPType == Gprs3GIPAddress){   //3G or GPRS adapter
                    
                    NSString* str_pdp = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];//ifa_addr, address of interface
                    freeifaddrs(addrs);
                    return str_pdp;
                }else if([name isEqualToString:@"en0"] && IPType == WifiIPAddress){  // Wi-Fi adaPter
                    
                    NSString *str_en = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];//address of wifi interface
                    freeifaddrs(addrs);
                    return str_en;
                    
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }//if (success)
    
    return nil;
}

//获取 wifi 流量
-(long) getWifiFlowIOBytes
{
    struct ifaddrs *ifa_list = 0, *ifa;
    if (getifaddrs(&ifa_list) == -1)
    {
        return 0;
    }
    
    long iBytes = 0;
    long oBytes = 0;
    
    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next)
    {
        if (AF_LINK != ifa->ifa_addr->sa_family)
        {
            continue;
        }
        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING))
        {
            continue;
        }
        if (ifa->ifa_data == 0)
        {
            continue;
        }
        if (!strcmp(ifa->ifa_name, "en0"))
        {
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            
            iBytes += if_data->ifi_ibytes;
            oBytes += if_data->ifi_obytes;
        }
    }
    freeifaddrs(ifa_list);
    
    return iBytes + oBytes;
}

//获取3G 或 GPRS 流量
- (long) getGprs3GFlowIOBytes
{
    struct ifaddrs *ifa_list = 0, *ifa;
    if (getifaddrs(&ifa_list) == -1)
    {
        return 0;
    }
    long iBytes = 0;
    long oBytes = 0;
    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next)
    {
        if (AF_LINK != ifa->ifa_addr->sa_family)
            continue;
        
        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING))
            continue;
        
        if (ifa->ifa_data == 0)
            continue;
        
        if (!strcmp(ifa->ifa_name, "pdp_ip0"))
        {
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            
            iBytes += if_data->ifi_ibytes;
            oBytes += if_data->ifi_obytes;
        }
    }
    freeifaddrs(ifa_list);
    return iBytes + oBytes;
}

//字节转换为KB MB GB
- (NSString *)bytesToAvaiUnit:(long) bytes
{
    if (bytes < 1024)               //B
    {
        return [NSString stringWithFormat:@"%ldB",bytes];
    }
    else if (bytes >= 1024 && bytes < 1024*1024)        //KB
    {
        return [NSString stringWithFormat:@"%.1fKB",(double)bytes/ 1024];
    }
    else if(bytes >= 1024 * 1024 && bytes < 1024 * 1024 * 1024)     // MB
    {
        return [NSString stringWithFormat:@"%.2fMB", (double)bytes / (1024 * 1024)];
    }
    else    // GB
    {
        return [NSString stringWithFormat:@"%.3fGB", (double)bytes / (1024 * 1024 * 1024)];
    }
}

- (NSString *) getMacAddress
{
    int                    mib[6];
    size_t                len;
    char                *buf;
    unsigned char        *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl    *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1/n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    // NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    NSString *outstring = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    return [outstring uppercaseString];
    
}

@end

