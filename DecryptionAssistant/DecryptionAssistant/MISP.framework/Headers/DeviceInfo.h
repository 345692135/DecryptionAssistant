//
//  DeviceInfo.h
//  GetDeviceInfo
//
//  Created by nie on 12-8-7.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import  <mach/mach.h>
#include <ifaddrs.h>
#include <sys/socket.h>
#include <net/if.h>

#define iPhone5_1_1_FIRMWARE_ID @"9B206"
#define iPhone5_0_1_FIRMWARE_ID @"9A405"
#define iPhone5_0_FIRMWARE_ID @"9A334"

#define iPhone4_3_3_FIRMWARE_ID @"8J2"
#define iPhone4_3_2_FIRMWARE_ID @"8H7"
#define iPhone4_3_1_FIRMWARE_ID @"8G4"
#define iPhone4_3_FIRMWARE_ID @"8F190"
#define iPhone4_2_1_FIRMWARE_ID @"8C148"
#define iPhone4_1_FIRMWARE_ID @"8B117"
#define iPhone4_0_2_FIRMWARE_ID @"8A400"
#define iPhone4_0_1_FIRMWARE_ID @"8A306"
#define iPhone4_0_FIRMWARE_ID @"8A293"


#define iPhone3_1_3_FIRMWARE_ID @"7E18"
#define iPhone3_1_2_FIRMWARE_ID @"7D11"
#define iPhone3_1_FIRMWARE_ID @"7C144"
#define iPhone3_0_1_FIRMWARE_ID @"7A400"
#define iPhone3_0_FIRMWARE_ID @"7A341"

#define iPhone2_2_1_FIRMWARE_ID @"5H11"
#define iPhone2_2_FIRMWARE_ID @"5G77"
#define iPhone2_1_FIRMWARE_ID @"5F136"
#define iPhone2_0_2_FIRMWARE_ID @"5C1"
#define iPhone2_0_1_FIRMWARE_ID @"5B108"
#define iPhone2_0_FIRMWARE_ID @"5A347"
#define iPhone1_1_4_FIRMWARE_ID @"4A102"
#define iPhone1_1_3_FIRMWARE_ID @"4A93"
#define iPhone1_1_2_FIRMWARE_ID @"3B48b"
#define iPhone1_1_1_FIRMWARE_ID @"3A109a"
#define iPhone1_0_2_FIRMWARE_ID @"1C28"
#define iPhone1_0_1_FIRMWARE_ID @"1C25"
#define iPhone1_0_FIRMWARE_ID @"1A543a"


typedef enum {              //  system version of IOS
    iPhone5_1_1,
    iPhone5_0_1,
    iPhone5_0,
    
    
    iPhone4_3_3,
    iPhone4_3_2,
    iPhone4_3_1,
    iPhone4_3 ,
    iPhone4_2_1 ,
    iPhone4_1,
    iPhone4_0_2,
    iPhone4_0_1,
    iPhone4_0,
    
    
    iPhone3_1_3,
    iPhone3_1_2,
    iPhone3_1,
    iPhone3_0_1,
    iPhone3_0,
    
    iPhone2_2_1,
    iPhone2_2,
    iPhone2_1,
    iPhone2_0_2,
    iPhone2_0_1,
    iPhone2_0,
    iPhone1_1_4,
    iPhone1_1_3,
    iPhone1_1_2,
    iPhone1_1_1,
    iPhone1_0_2,
    iPhone1_0_1,
    iPhone1_0
}IPHONE_FIRMWARE_VERSION;

typedef enum            //  type of IP Address
{
    WifiIPAddress,
    Gprs3GIPAddress
}IPAddressType;



@interface DeviceInfo : NSObject

// define singleton class method

/*!
 @method   getInstance
 @abstract get a singleton of class
 @param    Null
 @result   get a singleton
 */
+ (DeviceInfo *)getInstance;


//获取设备基本信息

/*!
 @method   getDeviceBaseInfo
 @abstract get Device base information
 @param    Null
 @result   when call success, some based information like system version, id, system name and
 so no will be returned
 */
- (NSDictionary *)getDeviceBaseInfo;


//获取主机名以及IP地址

/*!
 @method   getSystemVersion
 @abstract get system version of device
 @param    Null
 @result   system version of device will be returned
 */
- (NSString *)getSystemVersion;

/*!
 @method   getHostname
 @abstract get name of device
 @param    Null
 @result   name of device will be returned
 */
- (NSString *)getHostname;

/*!
 @method   getIPAddressWithtype:IPtype
 @abstract get IP Address of Device
 @param    IPtype including wifiIPAddress and Gprs3GIPAddress
 @result   IP Address will be returned
 */
- (NSString *)getIPAddressWithtype:(IPAddressType)IPType;

//获取流量信息

/*!
 @method   getWifiFlowIOBytes
 @abstract when Wifi connected, get flow wifi IO bytes
 @param    Null
 @result   return flow IO bytes
 */
- (long) getWifiFlowIOBytes;

/*!
 @method   getGprs3GFlowIOBytes
 @abstract when Wifi connected unsuccessful, get flow 3G or Gprs IO bytes
 @param    Null
 @result   return flow 3G or Gprs IO bytes
 */
- (long) getGprs3GFlowIOBytes;


//流量转换为KB MB GB

/*!
 @method   bytesToAvaiUint:bytes
 @abstract change flow B to KB or MB or GB
 @param    int:bytes
 @result   return flow KB or MB or GB
 */
- (NSString *)bytesToAvaiUnit:(long) bytes;

- (NSString *) getMacAddress;


@end





























