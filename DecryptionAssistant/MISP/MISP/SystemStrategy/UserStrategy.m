//
//  UserStrategy.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-7-20.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import "UserStrategy.h"
#import "AuthentificationManager.h"
#import "ICertify.h"
#import "UserAccount.h"

@implementation UserStrategy

-(NSArray*)getItemByGroupId:(NSString*)grpId
{
    NSArray* arr = nil;
    NSError* err = nil;
    NSMutableArray* arryFinal = nil;
    
    if ([grpId length] == 0 || self.strategyXMLData == nil) {
        TRACK(@"null point");
        return nil;
    }
    NSString* xpath = [NSString stringWithFormat:@"/RESPONSE/TABLE/ROW[StrategyGroupId='%@' and IsActive='1']",grpId];
    arr = [self.strategyXMLData nodesForXPath:xpath error:&err];
    
    
    if ([arr count] == 0) {
        TRACK(@"get getItemByGroupId %@",err);
        return nil;
    }
    
    arryFinal = [[NSMutableArray alloc]init];
    
    for (NSObject* obj in arr){
        GDataXMLElement* element = (GDataXMLElement*)obj;
        
        //TRACK(@"xml string :%@",[element XMLString]);
        //isStrategyValid if == YES
        if ([self isStrategyValid:element] == YES) {
            [arryFinal addObject:obj];
        }
    }
    
    if ([arryFinal count] == 0) {
        [arryFinal release];
        return nil;
    }
    
    return [arryFinal autorelease];
    
}

-(NSArray*)getItemByName:(NSString*)name
{
    NSArray* arr = nil;
    NSError* err = nil;
    if ([name length] == 0 || self.strategyXMLData == nil) {
        TRACK(@"null point");
        return nil;
    }
    NSString* xpath = [NSString stringWithFormat:@"/RESPONSE/TABLE/ROW[Name='%@' and IsActive='1']",name];
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

#pragma mark Tools method

-(NSArray*)getSecLevelbyGroupId:(NSString*)grpId level:(NSString*)name
{
    NSArray* arr = nil;
    NSError* err = nil;
    if ([grpId length] == 0 || [name length] == 0 || self.strategyXMLData == nil) {
        TRACK(@"null point");
        return nil;
    }
    
    NSString* xpath = [NSString stringWithFormat:@"/RESPONSE/TABLE/ROW[StrategyGroupId='%@' and Name='%@'/TargetCondition/CONFIGITEM/CLT_TARGETCONDITIONITEM/FRM_SECLEVEL_SECNAME_10]",grpId,name];
    arr = [self.strategyXMLData nodesForXPath:xpath error:&err];
    if ([arr count] == 0) {
        TRACK(@"get getSecLevelbyGroupId %@",err);
        return nil;
    }
    
    return arr;
}

-(NSArray*) analysisStrategyForLevelKey:(NSArray*)rows
{
    NSMutableArray* whiteList = [[NSMutableArray alloc]init];
    NSMutableArray* blackList = [[NSMutableArray alloc]init];
    
    for (NSObject* obj in rows) {
        GDataXMLElement* element = (GDataXMLElement*)obj;
        if ([[[[element elementsForName:@"Action"]objectAtIndex:0]XMLString] isEqual:@"<Action>1</Action>"] == YES) {
            GDataXMLDocument* doc = [[[GDataXMLDocument alloc]initWithRootElement:element]autorelease];
            NSArray* levels = [doc nodesForXPath:@"/ROW/TargetCondition/CONFIGITEM/CLT_TARGETCONDITIONITEM/DSM_MANUAL_ENC_SECNAME_10" error:nil];
            
            if ([levels count] == 0){
                continue;
            }
            
            for (NSObject* levelobj in levels){
                GDataXMLElement* level = (GDataXMLElement*)levelobj;
                NSString* levelName = [level stringValue];
                if ([levelName length] == 0) {
                    continue;
                }
                
                if ([whiteList count] == 0 && [blackList count] == 0) {
                    [whiteList addObject:levelName];
                    continue;
                }
                BOOL isContinue = NO;
                //check in black list
                if ([blackList count] != 0) {
                    for (NSObject* blackobj in blackList){
                        NSString* blackLevel = (NSString*)blackobj;
                        if ([blackLevel length] == 0) continue;
                        if ([blackLevel isEqualToString:levelName] == YES) {
                            isContinue = YES;
                            break;
                        }
                    }
                    if (isContinue == YES) {
                        continue;
                    }
                }
                
                //check in white list
                isContinue = NO;
                if ([whiteList count] != 0) {
                    for (NSObject* whiteobj in whiteList){
                        NSString* whiteLevel = (NSString*)whiteobj;
                        if ([whiteLevel length] == 0) continue;
                        if ([whiteLevel isEqualToString:levelName] == YES) {
                            isContinue = YES;
                            break;
                        }
                    }
                    if (isContinue == YES) {
                        continue;
                    }else{
                        [whiteList addObject:levelName];
                    }
                }else{
                    [whiteList addObject:levelName];
                }
                
            }
        }else{
            GDataXMLDocument* doc = [[[GDataXMLDocument alloc]initWithRootElement:element]autorelease];
            NSArray* levels = [doc nodesForXPath:@"/ROW/TargetCondition/CONFIGITEM/CLT_TARGETCONDITIONITEM/DSM_MANUAL_ENC_SECNAME_10" error:nil];
            
            if ([levels count] == 0){
                continue;
            }
            
            for (NSObject* levelobj in levels){
                GDataXMLElement* level = (GDataXMLElement*)levelobj;
                NSString* levelName = [level stringValue];
                if ([levelName length] == 0) {
                    continue;
                }
                
                if ([whiteList count] == 0 && [blackList count] == 0) {
                    [blackList addObject:levelName];
                    continue;
                }
                BOOL isContinue = NO;
                //check in white list
                isContinue = NO;
                if ([whiteList count] != 0) {
                    for (NSObject* whiteobj in whiteList){
                        NSString* whiteLevel = (NSString*)whiteobj;
                        if ([whiteLevel length] == 0) continue;
                        if ([whiteLevel isEqualToString:levelName] == YES) {
                            isContinue = YES;
                            break;
                        }
                    }
                    if (isContinue == YES) {
                        continue;
                    }else{
                        [blackList addObject:levelName];
                    }
                }else{
                    [blackList addObject:levelName];
                }
                
            }
        }
    }
    
    for (NSObject* whiteobj in whiteList){
        NSLog(@"W:%@",whiteobj);
    }
    for (NSObject* blackobj in blackList){
        NSLog(@"B:%@",blackobj);
    }
    
    [blackList release];
    
    return [whiteList autorelease];
}


-(NSArray*) analysisStrategyForEmailKey:(NSArray*)rows
{
    NSMutableArray* whiteList = [[NSMutableArray alloc]init];
    NSMutableArray* blackList = [[NSMutableArray alloc]init];
    
    for (NSObject* obj in rows) {
        GDataXMLElement* element = (GDataXMLElement*)obj;
        
        //check att file dec
        NSRange range = [[element XMLString]rangeOfString:@"<DLP_INDEC_POP_DECMETHOD_10>DECALL</DLP_INDEC_POP_DECMETHOD_10>"];
        if (range.length == 0) {
            continue;
        }
        
        if ([[[[element elementsForName:@"Action"]objectAtIndex:0]XMLString] isEqual:@"<Action>1</Action>"] == YES) {
            GDataXMLDocument* doc = [[[GDataXMLDocument alloc]initWithRootElement:element]autorelease];
            NSArray* levels = [doc nodesForXPath:@"/ROW/TargetCondition/CONFIGITEM/CLT_TARGETCONDITIONITEM/DLP_INDEC_POP_SECNAME_10" error:nil];
            
            if ([levels count] == 0){
                continue;
            }
            
            for (NSObject* levelobj in levels){
                GDataXMLElement* level = (GDataXMLElement*)levelobj;
                NSString* levelName = [level stringValue];
                if ([levelName length] == 0) {
                    continue;
                }
                
                if ([whiteList count] == 0 && [blackList count] == 0) {
                    [whiteList addObject:levelName];
                    continue;
                }
                BOOL isContinue = NO;
                //check in black list
                if ([blackList count] != 0) {
                    for (NSObject* blackobj in blackList){
                        NSString* blackLevel = (NSString*)blackobj;
                        if ([blackLevel length] == 0) continue;
                        if ([blackLevel isEqualToString:levelName] == YES) {
                            isContinue = YES;
                            break;
                        }
                    }
                    if (isContinue == YES) {
                        continue;
                    }
                }
                
                //check in white list
                isContinue = NO;
                if ([whiteList count] != 0) {
                    for (NSObject* whiteobj in whiteList){
                        NSString* whiteLevel = (NSString*)whiteobj;
                        if ([whiteLevel length] == 0) continue;
                        if ([whiteLevel isEqualToString:levelName] == YES) {
                            isContinue = YES;
                            break;
                        }
                    }
                    if (isContinue == YES) {
                        continue;
                    }else{
                        [whiteList addObject:levelName];
                    }
                }else{
                    [whiteList addObject:levelName];
                }
                
            }
        }else{
            GDataXMLDocument* doc = [[[GDataXMLDocument alloc]initWithRootElement:element]autorelease];
            NSArray* levels = [doc nodesForXPath:@"/ROW/TargetCondition/CONFIGITEM/CLT_TARGETCONDITIONITEM/DLP_INDEC_POP_SECNAME_10" error:nil];
            
            if ([levels count] == 0){
                continue;
            }
            
            for (NSObject* levelobj in levels){
                GDataXMLElement* level = (GDataXMLElement*)levelobj;
                NSString* levelName = [level stringValue];
                if ([levelName length] == 0) {
                    continue;
                }
                
                if ([whiteList count] == 0 && [blackList count] == 0) {
                    [blackList addObject:levelName];
                    continue;
                }
                BOOL isContinue = NO;
                //check in white list
                isContinue = NO;
                if ([whiteList count] != 0) {
                    for (NSObject* whiteobj in whiteList){
                        NSString* whiteLevel = (NSString*)whiteobj;
                        if ([whiteLevel length] == 0) continue;
                        if ([whiteLevel isEqualToString:levelName] == YES) {
                            isContinue = YES;
                            break;
                        }
                    }
                    if (isContinue == YES) {
                        continue;
                    }else{
                        [blackList addObject:levelName];
                    }
                }else{
                    [blackList addObject:levelName];
                }
                
            }
        }
    }
    
    for (NSObject* whiteobj in whiteList){
        NSLog(@"W:%@",whiteobj);
    }
    for (NSObject* blackobj in blackList){
        NSLog(@"B:%@",blackobj);
    }
    
    [blackList release];
    
    return [whiteList autorelease];
}

-(NSArray*) analysisStrategyForEmailAttachedFileKey:(NSArray*)rows
{
    NSMutableArray* whiteList = [[NSMutableArray alloc]init];
    NSMutableArray* blackList = [[NSMutableArray alloc]init];
    
    for (NSObject* obj in rows) {
        GDataXMLElement* element = (GDataXMLElement*)obj;
        
        //check att file dec
        NSRange range = [[element XMLString]rangeOfString:@"<DLP_INDEC_POP_DECMETHOD_10>DECATT</DLP_INDEC_POP_DECMETHOD_10>"];
        if (range.length == 0) {
            continue;
        }
        
        if ([[[[element elementsForName:@"Action"]objectAtIndex:0]XMLString] isEqual:@"<Action>1</Action>"] == YES) {
            GDataXMLDocument* doc = [[[GDataXMLDocument alloc]initWithRootElement:element]autorelease];
            NSArray* levels = [doc nodesForXPath:@"/ROW/TargetCondition/CONFIGITEM/CLT_TARGETCONDITIONITEM/DLP_INDEC_POP_SECNAME_10" error:nil];
            
            if ([levels count] == 0){
                continue;
            }
            
            for (NSObject* levelobj in levels){
                GDataXMLElement* level = (GDataXMLElement*)levelobj;
                NSString* levelName = [level stringValue];
                if ([levelName length] == 0) {
                    continue;
                }
                
                if ([whiteList count] == 0 && [blackList count] == 0) {
                    [whiteList addObject:levelName];
                    continue;
                }
                BOOL isContinue = NO;
                //check in black list
                if ([blackList count] != 0) {
                    for (NSObject* blackobj in blackList){
                        NSString* blackLevel = (NSString*)blackobj;
                        if ([blackLevel length] == 0) continue;
                        if ([blackLevel isEqualToString:levelName] == YES) {
                            isContinue = YES;
                            break;
                        }
                    }
                    if (isContinue == YES) {
                        continue;
                    }
                }
                
                //check in white list
                isContinue = NO;
                if ([whiteList count] != 0) {
                    for (NSObject* whiteobj in whiteList){
                        NSString* whiteLevel = (NSString*)whiteobj;
                        if ([whiteLevel length] == 0) continue;
                        if ([whiteLevel isEqualToString:levelName] == YES) {
                            isContinue = YES;
                            break;
                        }
                    }
                    if (isContinue == YES) {
                        continue;
                    }else{
                        [whiteList addObject:levelName];
                    }
                }else{
                    [whiteList addObject:levelName];
                }
                
            }
        }else{
            GDataXMLDocument* doc = [[[GDataXMLDocument alloc]initWithRootElement:element]autorelease];
            NSArray* levels = [doc nodesForXPath:@"/ROW/TargetCondition/CONFIGITEM/CLT_TARGETCONDITIONITEM/DLP_INDEC_POP_SECNAME_10" error:nil];
            
            if ([levels count] == 0){
                continue;
            }
            
            for (NSObject* levelobj in levels){
                GDataXMLElement* level = (GDataXMLElement*)levelobj;
                NSString* levelName = [level stringValue];
                if ([levelName length] == 0) {
                    continue;
                }
                
                if ([whiteList count] == 0 && [blackList count] == 0) {
                    [blackList addObject:levelName];
                    continue;
                }
                BOOL isContinue = NO;
                //check in white list
                isContinue = NO;
                if ([whiteList count] != 0) {
                    for (NSObject* whiteobj in whiteList){
                        NSString* whiteLevel = (NSString*)whiteobj;
                        if ([whiteLevel length] == 0) continue;
                        if ([whiteLevel isEqualToString:levelName] == YES) {
                            isContinue = YES;
                            break;
                        }
                    }
                    if (isContinue == YES) {
                        continue;
                    }else{
                        [blackList addObject:levelName];
                    }
                }else{
                    [blackList addObject:levelName];
                }
                
            }
        }
    }
    
    for (NSObject* whiteobj in whiteList){
        NSLog(@"W:%@",whiteobj);
    }
    for (NSObject* blackobj in blackList){
        NSLog(@"B:%@",blackobj);
    }
    
    [blackList release];
    
    return [whiteList autorelease];
}


-(NSArray*) analysisStrategyForSS5Key:(NSArray*)rows
{
    NSMutableArray* whiteList = [[NSMutableArray alloc]init];
    NSMutableArray* blackList = [[NSMutableArray alloc]init];
    
    for (NSObject* obj in rows) {
        GDataXMLElement* element = (GDataXMLElement*)obj;
        // check enable
        NSRange range = [[element XMLString]rangeOfString:@"<MOBILE_APP_ACCESS_ENABLE_00>1</MOBILE_APP_ACCESS_ENABLE_00>"];
        if ([[[[element elementsForName:@"Action"]objectAtIndex:0]XMLString] isEqual:@"<Action>1</Action>"] == YES && range.length != 0) {
            GDataXMLDocument* doc = [[[GDataXMLDocument alloc]initWithRootElement:element]autorelease];
            NSArray* levels = [doc nodesForXPath:@"/ROW/TargetCondition/CONFIGITEM/CLT_TARGETCONDITIONITEM/MOBILE_APP_ID_10" error:nil];
            
            if ([levels count] == 0){
                continue;
            }
            
            for (NSObject* levelobj in levels){
                GDataXMLElement* level = (GDataXMLElement*)levelobj;
                NSString* levelName = [level stringValue];
                if ([levelName length] == 0) {
                    continue;
                }
                
                if ([whiteList count] == 0 && [blackList count] == 0) {
                    [whiteList addObject:levelName];
                    continue;
                }
                BOOL isContinue = NO;
                //check in black list
                if ([blackList count] != 0) {
                    for (NSObject* blackobj in blackList){
                        NSString* blackLevel = (NSString*)blackobj;
                        if ([blackLevel length] == 0) continue;
                        if ([blackLevel isEqualToString:levelName] == YES) {
                            isContinue = YES;
                            break;
                        }
                    }
                    if (isContinue == YES) {
                        continue;
                    }
                }
                
                //check in white list
                isContinue = NO;
                if ([whiteList count] != 0) {
                    for (NSObject* whiteobj in whiteList){
                        NSString* whiteLevel = (NSString*)whiteobj;
                        if ([whiteLevel length] == 0) continue;
                        if ([whiteLevel isEqualToString:levelName] == YES) {
                            isContinue = YES;
                            break;
                        }
                    }
                    if (isContinue == YES) {
                        continue;
                    }else{
                        [whiteList addObject:levelName];
                    }
                }else{
                    [whiteList addObject:levelName];
                }
                
            }
        }else{
            GDataXMLDocument* doc = [[[GDataXMLDocument alloc]initWithRootElement:element]autorelease];
            NSArray* levels = [doc nodesForXPath:@"/ROW/TargetCondition/CONFIGITEM/CLT_TARGETCONDITIONITEM/MOBILE_APP_ID_10" error:nil];
            
            if ([levels count] == 0){
                continue;
            }
            
            for (NSObject* levelobj in levels){
                GDataXMLElement* level = (GDataXMLElement*)levelobj;
                NSString* levelName = [level stringValue];
                if ([levelName length] == 0) {
                    continue;
                }
                
                if ([whiteList count] == 0 && [blackList count] == 0) {
                    [blackList addObject:levelName];
                    continue;
                }
                BOOL isContinue = NO;
                //check in white list
                isContinue = NO;
                if ([whiteList count] != 0) {
                    for (NSObject* whiteobj in whiteList){
                        NSString* whiteLevel = (NSString*)whiteobj;
                        if ([whiteLevel length] == 0) continue;
                        if ([whiteLevel isEqualToString:levelName] == YES) {
                            isContinue = YES;
                            break;
                        }
                    }
                    if (isContinue == YES) {
                        continue;
                    }else{
                        [blackList addObject:levelName];
                    }
                }else{
                    [blackList addObject:levelName];
                }
                
            }
        }
    }
    
    for (NSObject* whiteobj in whiteList){
        NSLog(@"W:%@",whiteobj);
    }
    for (NSObject* blackobj in blackList){
        NSLog(@"B:%@",blackobj);
    }
    
    [blackList release];
    
    return [whiteList autorelease];
}

/* 流程审批附件处理 */
- (NSArray *)analysisStrategyForApproveFileKey:(NSArray*)rows
{
    NSMutableArray* whiteList = [[NSMutableArray alloc]init];
    NSMutableArray* blackList = [[NSMutableArray alloc]init];
    
    for (NSObject* obj in rows)
    {
        GDataXMLElement* element = (GDataXMLElement*)obj;
        
        if ([[[[element elementsForName:@"Action"]objectAtIndex:0]XMLString] isEqual:@"<Action>1</Action>"] == YES) {
            GDataXMLDocument* doc = [[[GDataXMLDocument alloc]initWithRootElement:element]autorelease];
            NSArray* levels = [doc nodesForXPath:@"/ROW/TargetCondition/CONFIGITEM/CLT_TARGETCONDITIONITEM/FRM_SECLEVEL_SECNAME_10" error:nil];
            
            if ([levels count] == 0){
                continue;
            }
            
            for (NSObject* levelobj in levels){
                GDataXMLElement* level = (GDataXMLElement*)levelobj;
                NSString* levelName = [level stringValue];
                if ([levelName length] == 0) {
                    continue;
                }
                
                if ([whiteList count] == 0 && [blackList count] == 0) {
                    [whiteList addObject:levelName];
                    continue;
                }
                BOOL isContinue = NO;
                //check in black list
                if ([blackList count] != 0) {
                    for (NSObject* blackobj in blackList){
                        NSString* blackLevel = (NSString*)blackobj;
                        if ([blackLevel length] == 0) continue;
                        if ([blackLevel isEqualToString:levelName] == YES) {
                            isContinue = YES;
                            break;
                        }
                    }
                    if (isContinue == YES) {
                        continue;
                    }
                }
                
                //check in white list
                isContinue = NO;
                if ([whiteList count] != 0) {
                    for (NSObject* whiteobj in whiteList){
                        NSString* whiteLevel = (NSString*)whiteobj;
                        if ([whiteLevel length] == 0) continue;
                        if ([whiteLevel isEqualToString:levelName] == YES) {
                            isContinue = YES;
                            break;
                        }
                    }
                    if (isContinue == YES) {
                        continue;
                    }else{
                        [whiteList addObject:levelName];
                    }
                }else{
                    [whiteList addObject:levelName];
                }
                
            }
        }else{
            GDataXMLDocument* doc = [[[GDataXMLDocument alloc]initWithRootElement:element]autorelease];
            NSArray* levels = [doc nodesForXPath:@"/ROW/TargetCondition/CONFIGITEM/CLT_TARGETCONDITIONITEM/FRM_SECLEVEL_SECNAME_10" error:nil];
            
            if ([levels count] == 0){
                continue;
            }
            
            for (NSObject* levelobj in levels){
                GDataXMLElement* level = (GDataXMLElement*)levelobj;
                NSString* levelName = [level stringValue];
                if ([levelName length] == 0) {
                    continue;
                }
                
                if ([whiteList count] == 0 && [blackList count] == 0) {
                    [blackList addObject:levelName];
                    continue;
                }
                BOOL isContinue = NO;
                //check in white list
                isContinue = NO;
                if ([whiteList count] != 0) {
                    for (NSObject* whiteobj in whiteList){
                        NSString* whiteLevel = (NSString*)whiteobj;
                        if ([whiteLevel length] == 0) continue;
                        if ([whiteLevel isEqualToString:levelName] == YES) {
                            isContinue = YES;
                            break;
                        }
                    }
                    if (isContinue == YES) {
                        continue;
                    }else{
                        [blackList addObject:levelName];
                    }
                }else{
                    [blackList addObject:levelName];
                }
                
            }
        }
    }
    
    for (NSObject* whiteobj in whiteList){
        NSLog(@"W:%@",whiteobj);
    }
    for (NSObject* blackobj in blackList){
        NSLog(@"B:%@",blackobj);
    }
    
    [blackList release];
    
    return [whiteList autorelease];
}

///////////////////////// 控制策略
//////////////////////////
typedef enum
{
    Week_Choice,        //星期限制
    OnlineStatus,       //在线状态
    Start_Time,      //开始时间
    ValidTime,        //合法开始时间
    ExpireTime,      //合法消亡时间
    Finish_Time     //结束时间
}StrtegyType;

- (NSString*)getStrategy:(StrtegyType)strType Element:(GDataXMLElement*)element
{
    NSArray* arr = nil;
    NSError* err = nil;
    NSString* xpath = nil;
    // NSString* xpath = [NSString stringWithFormat:@"/ROW[StrategyGroupId = '268566593']"];//输出的结果是:2920130320邮件解密2685665930101SUNDAY;MONDAY;TUESDAY;ONLINE08:0019:002013-03-20 00:00:002023-03-20 00:00:00zkK8flXd-xFFSNR01DECATT86108274-39398501-00000000-200000012013-03-20 17:01:28
    
    switch (strType) {
        case ValidTime:
            xpath = [NSString stringWithFormat:@"/ROW/%@/text()",@"ValidTime"];
            break;
        case ExpireTime:
            xpath = [NSString stringWithFormat:@"/ROW/%@/text()",@"ExpireTime"];
            break;
        case Week_Choice:
            xpath = [NSString stringWithFormat:@"/ROW/StrategyCondition/CONFIGITEM/%@/text()",@"CLT_WEEK_CHOICE_12"];
            break;
        case OnlineStatus:
            xpath = [NSString stringWithFormat:@"/ROW/StrategyCondition/CONFIGITEM/%@/text()",@"CLT_ONLINESTATUS_10"];
            break;
        case Start_Time:
            xpath = [NSString stringWithFormat:@"/ROW/StrategyCondition/CONFIGITEM/CLT_OPERATETIME_09/%@/text()",@"STR_START_TIME"];
            break;
        case Finish_Time:
            xpath = [NSString stringWithFormat:@"/ROW/StrategyCondition/CONFIGITEM/CLT_OPERATETIME_09/%@/text()",@"STR_END_TIME"];
            break;
        default:
            break;
    }
    
    // arr = [self.strategyXMLData nodesForXPath:xpath error:&err];
    GDataXMLDocument* doc = [[[GDataXMLDocument alloc]initWithRootElement:element]autorelease];
    arr = [doc nodesForXPath:xpath error:&err];
    if ([arr count] == 0)
    {
        switch (strType) {
            case ValidTime:
                NSLog(@"Get ValidTime Strategy Failed!\n");
                break;
            case ExpireTime:
                NSLog(@"Get ExpireTime Strategy Failed!\n");
                break;
            case Week_Choice:
                NSLog(@"Get Week_Choice Strategy Failed!\n");
                break;
            case OnlineStatus:
                NSLog(@"Get OnlineStatus Strategy Failed!\n");
                break;
            case Start_Time:
                NSLog(@"Get Start_Time Strategy Failed!\n");
                break;
            case Finish_Time:
                NSLog(@"Get Finish_Time Strategy Failed!\n");
                break;
            default:
                break;
        }
        
        return nil;
    }
    // return arr;
    return  [[arr objectAtIndex:0] stringValue];
    
}


- (BOOL)isStrategyValid:(GDataXMLElement*)element
{
    NSString *onlineStatus = [self getStrategy:OnlineStatus Element:element];   //在线状态
    NSString *expireTime = [self getStrategy:ExpireTime Element:element];       //合法消亡时间
    NSString *validTime = [self getStrategy:ValidTime Element:element];         //合法开始时间
    NSString *weekChoice = [self getStrategy:Week_Choice Element:element];       //星期限制
    NSString *start_Time = [self getStrategy:Start_Time Element:element];        //每天开始时间
    NSString *finish_Time = [self getStrategy:Finish_Time Element:element];      //每天结束时间
    
    NSLog(@"onlineStatus:%@\n",onlineStatus);
    
    NSLog(@"expireTime:%@\n",expireTime);
    
    NSLog(@"validTime:%@\n",validTime);
    
    NSLog(@"weekChoice:%@\n",weekChoice);
    
    NSLog(@"start_Time:%@\n",start_Time);
    
    NSLog(@"finish_Time:%@\n",finish_Time);
    
    
    NSString *loginStatus = nil;;
    
    AuthentificationManager* actManager = [AuthentificationManager getInstance];
    id<ICertify> certify = [actManager getUserNameCertifyPrivder];
    int nRet = [certify getLoginAccoutStutus];
    
    if (![onlineStatus isEqualToString:@"ALLITEM"]) {
        
        if (nRet == 20) {
            loginStatus = @"ONLINE";
        }else if (nRet == 10)
        {
            loginStatus = @"OFFLINE";
        }
        
        if ([onlineStatus length] != 0)
        {
            if (![loginStatus isEqualToString:onlineStatus])
            {
                NSLog(@"当前用户在线状态与策略限制状态不相符！\n");
                return NO;
            }
            
        }
        
    }
    
    NSString *systemdate_Str = [self getSystemDate];
    
    
    if ([expireTime length] != 0) {
        if ([expireTime compare:systemdate_Str] == NSOrderedAscending) {//系统时间比消亡时间晚
            NSLog(@"系统时间晚于合法消亡时间！\n");
            return NO;
        }
    }
    if ([validTime length] != 0) {
        if ([validTime compare:systemdate_Str] == NSOrderedDescending) {//系统时间比开始时间早
            NSLog(@"系统时间早于合法开始时间！\n");
            
            return NO;
        }
    }
    
    //策略星期限制
    if ([weekChoice length] != 0) {
        NSString *systemWeek = nil;
        NSMutableArray *arrWeek = [self getStrategyWeek:weekChoice];
        NSInteger week = [self getWeek];
        systemWeek = [self getSystemWeek:week];
        
        if (systemWeek != nil)
        {
            int i = 0;
            for (; i < [arrWeek count] - 1; i ++)
            {
                if ([systemWeek isEqualToString:[arrWeek objectAtIndex:i]]) {
                    break;
                }
            }
            if (i == ([arrWeek count] - 1))
            {
                NSLog(@"系统当前星期与策略星期限制不相符！\n");
                return NO;
            }
        }else
            return NO;
    }
    
    //每天时间段限制
    NSString *systemTime = [self getSystemTime];
    
    if ([start_Time length] != 0) {
        if ([systemTime compare:start_Time] == NSOrderedAscending) {//系统时间早
            NSLog(@"系统当前时间早于每天开始时间！\n");
            return NO;
        }
    }
    
    if ([finish_Time length] != 0) {
        if ([systemTime compare:finish_Time] == NSOrderedDescending) {//系统时间晚
            NSLog(@"系统当前时间晚于每天结束时间！\n");
            return NO;
        }
    }
    
    return  YES;
}
- (NSInteger)getWeek
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *now;
    NSDateComponents *comps = nil;
    
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    now=[NSDate date];
    comps = [calendar components:unitFlags fromDate:now];
    NSInteger week = [comps weekday];
    
    [calendar release];
    
    return week;
    
}
- (NSString *)getSystemDate
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString* date = [formatter stringFromDate:[NSDate date]];
    NSString* datatime = [NSString  stringWithFormat:@"%@ 00:00:00",date];
    [formatter release];
    
    return datatime;
}
- (NSString *)getSystemTime
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSString* date = [formatter stringFromDate:[NSDate date]];
    
    [formatter release];
    return date;
}

- (NSMutableArray *)getStrategyWeek:(NSString *)weekChoice
{
    
    //for(id obj in dataArray)
    id obj;
    obj = weekChoice;
    
    NSString *Temp=obj;
    NSString *string2 = @";";
    
    NSMutableArray* maItem = [[[NSMutableArray alloc] init]autorelease];
    
    while (YES) {
        NSRange range =[Temp rangeOfString:string2];
        if (range.length == 0) {
            [maItem addObject:Temp];
            break;
        }
        else{
            NSString* strFileName=[Temp substringToIndex:range.location];
            [maItem addObject:strFileName];
            Temp = [Temp substringFromIndex:range.location+range.length];
        }
        
    }//while done
    
    return maItem;
}
- (NSString *)getSystemWeek:(NSInteger) week
{
    switch (week) {
        case 1:
            return @"SUNDAY";
            break;
        case 2:
            return @"MONDAY";
            break;
        case 3:
            return @"TUESDAY";
            break;
        case 4:
            return @"WENDESDAY";
            break;
        case 5:
            return @"THURSDAY";
            break;
        case 6:
            return @"FRIDAY";
            break;
        case 7:
            return @"SATURDAY";
            break;
        default:
            break;
    }
    return nil;
}


@end
