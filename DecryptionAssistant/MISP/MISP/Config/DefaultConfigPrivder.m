//
//  DefaultConfigPrivder.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-8-6.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import "DefaultConfigPrivder.h"
#import "tbSysConfig.h"
#import "SystemStrategy.h"
#import "tbSysInfo.h"

@implementation DefaultConfigPrivder

- (id)getValueByKey:(WSConfigItem)key
{
    id value = nil;
    switch (key) {
        case WSConfigItemIP:
            value = [self getIp];
            break;
        case WSConfigItemPort:
            value = [self getPort];
            break;
        case WSConfigItemProductKey:
            value = [self getProductKey];
            break;
        case WSConfigItemSystemStrategy:
            value = [self getSystemStrategy];
            break;
        case WSConfigItemSystemPermission:
            value = [self getSystemPermission];
            break;
        case WSConfigItemMacAddress:
            value = [self getSystemMacAddress];
            break;
        case WSConfigItemGuid:
            value = [self getSystemGuid];
            break;
        case WSConfigInit:
            value = [self getSystemInit];
            break;
        default:
            break;
    }
    return value;
}

- (void)setValueByKey:(WSConfigItem)key value:(id)data
{
    if (data == nil) {
        return;
    }
    
    tbSysConfig* config = (tbSysConfig*)[tbSysConfig findByPK:1];
    if (config == nil) {
        return;
    }
    
    switch (key) {
        case WSConfigItemIP:
            [config setIp:data];
            break;
        case WSConfigItemPort:
            [config setProt:data];
            break;
        case WSConfigItemProductKey:
            [config setProductKey:data];
            break;
        case WSConfigItemSystemStrategy:
            [config setSystemStrategyData:data];
            break;
        case WSConfigItemSystemPermission:
            [config setSystemAuthority:data];
            break;
        case WSConfigInit:
            [config setSysInitialized:[(NSNumber*)data boolValue]];
            break;
        case WSConfigItemMacAddress:
            break;
        case WSConfigItemGuid:
            [config setGuid:data];
        default:
            break;
    }
    
    [config save];
    [tbSysConfig clearCache];
}

- (SystemStrategy*)getSystemStrategy
{
    tbSysConfig* config = (tbSysConfig*)[tbSysConfig findByPK:1];
    if (config == nil || [config systemStrategyData] == nil) {
        return nil;
    }
    
    NSError* err = nil;
    SystemStrategy* sysStrategy = [[SystemStrategy alloc]initWithStrategyData:[config systemStrategyData] error:&err];
    if (sysStrategy == nil) {
        TRACK(@"init sysStrategy error !%@",err);
    }
    
    [tbSysConfig clearCache];
    
    return [sysStrategy autorelease];
}

- (NSString*)getIp
{
    
    tbSysConfig* config = (tbSysConfig*)[tbSysConfig findByPK:1];
    if (config == nil) {
        return nil;
    }
   
    NSString* ip = [config ip];
    if ([ip length] == 0) {
        TRACK(@"ip address is null");
    }
    
    [tbSysConfig clearCache];
    
    return ip;
}

- (NSString*)getPort
{

    tbSysConfig* config = (tbSysConfig*)[tbSysConfig findByPK:1];
    if (config == nil) {
        return nil;
    }
    
    NSString* port = [config prot];
    if ([port length] == 0) {
        TRACK(@"port is null");
    }
    
    [tbSysConfig clearCache];
    
    return port;
}

- (NSString*)getProductKey
{
    
    tbSysConfig* config = (tbSysConfig*)[tbSysConfig findByPK:1];
    if (config == nil) {
        return nil;
    }
    
    NSString* productKey = [config productKey];
    if ([productKey length] == 0) {
        TRACK(@"product key is null");
    }
    
    [tbSysConfig clearCache];
    
    return productKey;
}

- (NSData*)getSystemPermission
{
    
    tbSysConfig* config = (tbSysConfig*)[tbSysConfig findByPK:1];
    if (config == nil) {
        return nil;
    }
    
    NSData* systemPermission = [config systemAuthority];
    if ([systemPermission length] == 0) {
        TRACK(@"system permission is null");
    }
    
    [tbSysConfig clearCache];
    
    return systemPermission;
}

- (NSString*)getSystemMacAddress
{
    tbSysInfo* info = (tbSysInfo*)[tbSysInfo findByPK:1];
    if (info == nil) {
        return nil;
    }
    
    NSString* mac = [info deviceMacAddress];
    if ([mac length] == 0) {
        TRACK(@"mac address is null");
    }
    
    [tbSysInfo clearCache];
    
    return mac;
}

- (NSString*)getSystemGuid
{
    tbSysConfig* config = (tbSysConfig*)[tbSysConfig findByPK:1];
    if (config == nil) {
        return nil;
    }
    
    NSString* guid = [config guid];
    if ([guid length] == 0) {
        TRACK(@"guid is null");
    }
    
    [tbSysConfig clearCache];

    return guid;
}

- (NSNumber*)getSystemInit
{
    
    tbSysConfig* config = (tbSysConfig*)[tbSysConfig findByPK:1];
    if (config == nil) {
        return nil;
    }
    
    NSNumber* systemInit = [NSNumber numberWithBool:[config sysInitialized]];
    
    [tbSysConfig clearCache];
    
    return systemInit;
}

@end
