//
//  SystemStrategy.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-7-20.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import "SystemStrategy.h"

@implementation SystemStrategy


-(NSArray*)getItemByGroupId:(NSString*)grpId
{
    NSArray* arr = nil;
    NSError* err = nil;
    if ([grpId length] == 0 || self.strategyXMLData == nil) {
        TRACK(@"null point");
        return nil;
    }
    NSString* xpath = [NSString stringWithFormat:@"/RESPONSE/TABLE/ROW[StrategyGroupId='%@']",grpId];
    arr = [self.strategyXMLData nodesForXPath:xpath error:&err];
    if ([arr count] == 0) {
        TRACK(@"get getItemByGroupId %@",err);
        return nil;
    }
    
    return arr;
}


-(NSArray*)getItemByName:(NSString*)name
{
    NSArray* arr = nil;
    NSError* err = nil;
    if ([name length] == 0 || self.strategyXMLData == nil) {
        TRACK(@"null point");
        return nil;
    }
    NSString* xpath = [NSString stringWithFormat:@"/RESPONSE/TABLE/ROW[Name='%@']",name];
    arr = [self.strategyXMLData nodesForXPath:xpath error:&err];
    if ([arr count] == 0) {
        TRACK(@"get getItemByName %@",err);
        return nil;
    }
    
    return arr;
}

-(NSArray*)getItemByXpathString:(NSString*)str
{
    NSArray* arr = nil;
    NSError* err = nil;
    if ([str length] == 0 || self.strategyXMLData == nil) {
        TRACK(@"null point");
        return nil;
    }
    
    arr = [self.strategyXMLData nodesForXPath:str error:&err];
    if ([arr count] == 0) {
        TRACK(@"get getItemByXpathString %@",err);
        return nil;
    }
    
    return arr;
}

-(NSArray*)getSecPubKeybyGroupId:(NSString*)grpId secLevel:(NSString*)level
{
    //@"/RESPONSE/TABLE/ROW[StrategyGroupId='537001985']/ParamValue/CONFIGITEM/CLT_TARGETCONDITIONITEM[SECKEYS_LEVEL_RANDID_10='11111111-22222222-33333333-44444444']/SECKEYS_LEVEL_AS_KEY_10"
    NSArray* arr = nil;
    NSError* err = nil;
    if ([grpId length] == 0 || self.strategyXMLData == nil) {
        TRACK(@"null point");
        return nil;
    }
    NSString* xpath = [NSString stringWithFormat:@"/RESPONSE/TABLE/ROW[StrategyGroupId='%@']/ParamValue/CONFIGITEM/CLT_TARGETCONDITIONITEM[SECKEYS_LEVEL_RANDID_10='%@']/SECKEYS_LEVEL_AS_KEY_10",grpId,level];
    arr = [self.strategyXMLData nodesForXPath:xpath error:&err];
    if ([arr count] == 0) {
        TRACK(@"get getSecPubKeybyGroupId %@",err);
        return nil;
    }
    
    return arr;
}

-(NSArray*)getSecPrvKeybyGroupId:(NSString*)grpId secLevel:(NSString*)level
{
    NSArray* arr = nil;
    NSError* err = nil;
    if ([grpId length] == 0 || self.strategyXMLData == nil) {
        TRACK(@"null point");
        return nil;
    }
    NSString* xpath = [NSString stringWithFormat:@"/RESPONSE/TABLE/ROW[StrategyGroupId='%@']/ParamValue/CONFIGITEM/CLT_TARGETCONDITIONITEM[SECKEYS_LEVEL_RANDID_10='%@']/SECKEYS_LEVEL_S_KEY_10",grpId,level];
    arr = [self.strategyXMLData nodesForXPath:xpath error:&err];
    if ([arr count] == 0) {
        TRACK(@"get getSecPrvKeybyGroupId %@",err);
        return nil;
    }
    
    return arr;
}

-(NSDictionary*)getLevelNameListWithRandID:(NSArray*)list
{
    if ([list count] == 0) {
        return nil;
    }
    
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
    
    for (NSObject* obj in list)
    {
        NSString* xpath = [NSString stringWithFormat:@"/RESPONSE/TABLE/ROW[StrategyGroupId='%@']/ParamValue/CONFIGITEM/CLT_TARGETCONDITIONITEM[SECKEYS_LEVEL_RANDID_10='%@']/SECKEYS_LEVEL_NAME_10",@"537001985",obj];
        NSError* err = nil;
        NSArray* levelDefines = [self.strategyXMLData nodesForXPath:xpath error:&err];
        if ([levelDefines count] != 0) {
            GDataXMLElement* element = (GDataXMLElement*)[levelDefines objectAtIndex:0];
            [dic setValue:[element stringValue] forKey:(NSString*)obj];
        }
    }
    
    return [dic autorelease];
    
}


-(NSDictionary*)getSS5ConfigWithAppID:(NSString*)appId
{
    if ([appId length] == 0) {
        return nil;
    }
    
    NSMutableDictionary* dic = [[NSMutableDictionary alloc]init];
    
    //MOB_APP_NAME_10
    NSString* xpath = [NSString stringWithFormat:@"/RESPONSE/TABLE/ROW[StrategyGroupId='%@']/ParamValue/CONFIGITEM/CLT_TARGETCONDITIONITEM[MOB_APP_ID_10='%@']/MOB_APP_NAME_10",@"537460741",appId];
    NSError* err = nil;
    NSArray* levelDefines = [self.strategyXMLData nodesForXPath:xpath error:&err];
    if ([levelDefines count] != 0) {
        GDataXMLElement* element = (GDataXMLElement*)[levelDefines objectAtIndex:0];
        [dic setValue:[element stringValue] forKey:@"MOB_APP_NAME_10"];
    }
    
    //MOB_LOCAL_PORT_NUM_00
    xpath = [NSString stringWithFormat:@"/RESPONSE/TABLE/ROW[StrategyGroupId='%@']/ParamValue/CONFIGITEM/CLT_TARGETCONDITIONITEM[MOB_APP_ID_10='%@']/MOB_LOCAL_PORT_NUM_00",@"537460741",appId];
    
    levelDefines = [self.strategyXMLData nodesForXPath:xpath error:&err];
    if ([levelDefines count] != 0) {
        GDataXMLElement* element = (GDataXMLElement*)[levelDefines objectAtIndex:0];
        [dic setValue:[element stringValue] forKey:@"MOB_LOCAL_PORT_NUM_00"];
    }
    
    //MOB_REMOTE_IP_ADDR_04
    xpath = [NSString stringWithFormat:@"/RESPONSE/TABLE/ROW[StrategyGroupId='%@']/ParamValue/CONFIGITEM/CLT_TARGETCONDITIONITEM[MOB_APP_ID_10='%@']/MOB_REMOTE_IP_ADDR_04",@"537460741",appId];
    
    levelDefines = [self.strategyXMLData nodesForXPath:xpath error:&err];
    if ([levelDefines count] != 0) {
        GDataXMLElement* element = (GDataXMLElement*)[levelDefines objectAtIndex:0];
        [dic setValue:[element stringValue] forKey:@"MOB_REMOTE_IP_ADDR_04"];
    }
    
    //MOB_REMOTE_PORT_NUM_00
    xpath = [NSString stringWithFormat:@"/RESPONSE/TABLE/ROW[StrategyGroupId='%@']/ParamValue/CONFIGITEM/CLT_TARGETCONDITIONITEM[MOB_APP_ID_10='%@']/MOB_REMOTE_PORT_NUM_00",@"537460741",appId];
    
    levelDefines = [self.strategyXMLData nodesForXPath:xpath error:&err];
    if ([levelDefines count] != 0) {
        GDataXMLElement* element = (GDataXMLElement*)[levelDefines objectAtIndex:0];
        [dic setValue:[element stringValue] forKey:@"MOB_REMOTE_PORT_NUM_00"];
    }
    
    //MOB_APP_ATTACH_PATH_10
    xpath = [NSString stringWithFormat:@"/RESPONSE/TABLE/ROW[StrategyGroupId='%@']/ParamValue/CONFIGITEM/CLT_TARGETCONDITIONITEM[MOB_APP_ID_10='%@']/MOB_APP_ATTACH_PATH_10",@"537460741",appId];
    
    levelDefines = [self.strategyXMLData nodesForXPath:xpath error:&err];
    if ([levelDefines count] != 0) {
        GDataXMLElement* element = (GDataXMLElement*)[levelDefines objectAtIndex:0];
        [dic setValue:[element stringValue] forKey:@"MOB_APP_ATTACH_PATH_10"];
    }

    //MOB_PROTOCOL_TYPE_10
    xpath = [NSString stringWithFormat:@"/RESPONSE/TABLE/ROW[StrategyGroupId='%@']/ParamValue/CONFIGITEM/CLT_TARGETCONDITIONITEM[MOB_APP_ID_10='%@']/MOB_PROTOCOL_TYPE_10",@"537460741",appId];
    
    levelDefines = [self.strategyXMLData nodesForXPath:xpath error:&err];
    if ([levelDefines count] != 0) {
        GDataXMLElement* element = (GDataXMLElement*)[levelDefines objectAtIndex:0];
        [dic setValue:[element stringValue] forKey:@"MOB_PROTOCOL_TYPE_10"];
    }
    
    return [dic autorelease];
    
}

-(BOOL) check3gFlowUpLoad
{
    NSString* xpath = [NSString stringWithFormat:@"/RESPONSE/TABLE/ROW[StrategyGroupId='%@']/ParamValue/CONFIGITEM/CLT_TARGETCONDITIONITEM/MOB_3G_FLOWS_ENABLE_00",@"537460739"];
    
    NSError* err = nil;
    NSArray* levelDefines = [self.strategyXMLData nodesForXPath:xpath error:&err];
    if ([levelDefines count] != 0) {
        GDataXMLElement* element = (GDataXMLElement*)[levelDefines objectAtIndex:0];
        return [[element stringValue]intValue];
    }
    
    return 0;
}

/*  
 0729 ADD 检测是否具有代理流量上传策略
 **/
-(BOOL) checkSafeTunelFlowLoad
{
    /* Need to be modified! */
    NSString* xpath = [NSString stringWithFormat:@"/RESPONSE/TABLE/ROW[StrategyGroupId='%@']/ParamValue/CONFIGITEM/CLT_TARGETCONDITIONITEM/MOB_TUNNEL_FLOWS_ENABLE_00",@"537460740"];
    
    NSError* err = nil;
    NSArray* levelDefines = [self.strategyXMLData nodesForXPath:xpath error:&err];
    if ([levelDefines count] != 0) {
        GDataXMLElement* element = (GDataXMLElement*)[levelDefines objectAtIndex:0];
        return [[element stringValue]intValue];
    }
    
    return 0;
}

@end
