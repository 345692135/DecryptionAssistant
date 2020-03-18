//
//  tbSysInfo.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-8-7.
//
//

#import "SQLitePersistentObject.h"

@interface tbSysInfo : SQLitePersistentObject
{
//    NSString* deviceName;
//    NSString* deviceSN;
//    NSString* deviceMACAddress;
//    NSString* deviceType;
//    NSString* deviceOSVersion;
//    NSString* deviceFlow3g;
//    NSString* deviceFlowWifi;
//    NSString* deviceFlowSafeTunnel;
}


@property(atomic,retain)NSString* deviceName;
@property(atomic,retain)NSString* deviceSn;
@property(atomic,retain)NSString* deviceMacAddress;
@property(atomic,retain)NSString* deviceType;
@property(atomic,retain)NSString* deviceOsVersion;
@property(atomic,retain)NSString* deviceFlow3g;
@property(atomic,retain)NSString* deviceFlowWifi;
@property(atomic,retain)NSString* deviceFlowSafeTunnel;


@end
