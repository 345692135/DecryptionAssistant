//
//  MailStrategyAnalysis.m
//  MISP
//
//  Created by iBlock on 14-6-5.
//
//

#import "MailStrategyAnalysis.h"
#import "MailStrategyProperty.h"
#import "MailPlainProperty.h"
#import "AccountManagement.h"

#define MAIL_IN_ECRYPT_IN_USER_STRATEGY @"268566577"
#define PLAIN_SEND_RECORD_IN_USER_STRATEGY @"269025290"

@implementation MailStrategyAnalysis

//单例类
+ (id)sharedInstance
{
    static MailStrategyAnalysis *singleton;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[MailStrategyAnalysis alloc] init];
    });
    
    return singleton;
}

- (NSArray *)getSendMailList:(NSMutableSet *)userList
{
    NSMutableArray *sendList = [NSMutableArray arrayWithCapacity:0];
    
    //获取当前SDK登录用户
    SystemAccount* account = [[AccountManagement getInstance]getActiveAccount];
    
    if (account == nil)
    {
        return NULL;
    }
    
    //获取当前用户策略
    UserStrategy* userStrategy = [account getStrategy];

    //获取当前用户的所有发送邮件加密策略
    NSArray* sendEncStrategyList = [userStrategy getItemByGroupId:MAIL_IN_ECRYPT_IN_USER_STRATEGY];
    
    if ([sendEncStrategyList count] == 0)
    {
          TRACK(@"没有找到邮件发送加密策略。");
          return NULL;
    }
  
    for (GDataXMLElement *element in sendEncStrategyList)
    {
        @autoreleasepool
        {
            //判断策略动作是否是允许
            if ([[[[element elementsForName:@"Action"]objectAtIndex:0]XMLString]
                 isEqual:@"<Action>1</Action>"] == YES)
            {
                GDataXMLDocument* doc = [[[GDataXMLDocument alloc]initWithRootElement:element]autorelease];
                //获取策略名称
                GDataXMLElement *nameElement = [[doc nodesForXPath:@"/ROW/Name" error:nil] objectAtIndex:0];
                NSString *straName = [nameElement stringValue];
                //获取策略密级
                GDataXMLElement *levelElement = [[doc nodesForXPath:@"/ROW/ActionContent/CONFIGITEM/DLP_OUTENC_SMTP_SECNAME_10" error:nil] objectAtIndex:0];
                NSString *level = [levelElement stringValue];
                //获取动作控制
                GDataXMLElement *actionControlElement = [[doc nodesForXPath:@"/ROW/ActionContent/CONFIGITEM/DLP_OUTENC_SMTP_ENCMETHOD_10" error:nil] objectAtIndex:0];
                NSString *actionControl = [actionControlElement stringValue];
                //获取目标用户列表
                NSArray *userArray = [doc nodesForXPath:@"/ROW/TargetCondition/CONFIGITEM/CLT_TARGETCONDITIONITEM/DLP_OUTENC_SMTP_TARGET_10" error:nil];
                
                NSMutableArray *tempSave = [NSMutableArray arrayWithCapacity:0];
                
                //将用户列表一一与策略中的目标用户进行对比，得到符合策略目标用户的用户列表
                for (NSString *user in userList)
                {
                    @autoreleasepool
                    {
                        char *pattenrn = (char *)[user UTF8String];
                        
                        for (GDataXMLElement *cmpUser in userArray)
                        {
                            char *content = (char *)[[cmpUser stringValue] UTF8String];
                            
                            if (match(content,pattenrn))
                            {
                                [tempSave addObject:user];
                                break;
                            }
                        }
                    }
                }
                
                if ([tempSave count] > 0)
                {
                    MailStrategyProperty *msp = [[MailStrategyProperty alloc] init];
                    msp.strategyName = straName;
                    msp.level = level;
                    msp.encAction = actionControl;
                    msp.userList = tempSave;
                    
                    [sendList addObject:msp];
                    [msp release]; msp = nil;
                    
                    //用户列表中的用户如已在策略中匹配到则不再去匹配其它策略，所以将其从用户列表中删除。
                    for (NSString *user in tempSave)
                    {
                        [userList removeObject:user];
                    }
                }
                
                if ([userList count] == 0)
                {
                    break;
                }
            }
            else
            {
                continue;
            }
        }
    }
    
    if ([userList count] > 0)
    {
        MailStrategyProperty *msp = [[MailStrategyProperty alloc] init];
        msp.strategyName = @"NOSTRATEGYNAME";
        msp.encAction = @"PASS";
        NSArray *plainUserList = [userList allObjects];
        msp.userList = plainUserList;
        [sendList addObject:msp];
        [msp release]; msp = nil;
    }
    //最后sendList内没有任何值时，返回nil
    if (!sendList.count) {
        return nil;
    }
    return sendList;
}
-(BOOL)haveEncStrategy{
    SystemAccount* account = [[AccountManagement getInstance]getActiveAccount];
    
    if (account == nil)
    {
        return NO;
    }
    
    //获取当前用户策略
    UserStrategy* userStrategy = [account getStrategy];
    
    //获取当前用户的所有发送邮件加密策略
    NSArray* sendEncStrategyList = [userStrategy getItemByGroupId:MAIL_IN_ECRYPT_IN_USER_STRATEGY];
    
    if ([sendEncStrategyList count] == 0)
    {
        TRACK(@"没有找到邮件发送加密策略。");
        return NO;
    }
    for (GDataXMLElement *element in sendEncStrategyList)
    {
        @autoreleasepool
        {
            //判断策略动作是否是允许
            if ([[[[element elementsForName:@"Action"]objectAtIndex:0]XMLString]
                 isEqual:@"<Action>1</Action>"] == YES)
            {
                GDataXMLDocument* doc = [[[GDataXMLDocument alloc]initWithRootElement:element]autorelease];
                //获取策略名称
                GDataXMLElement *nameElement = [[doc nodesForXPath:@"/ROW/Name" error:nil] objectAtIndex:0];
                NSString *straName = [nameElement stringValue];
                //获取策略密级
                GDataXMLElement *levelElement = [[doc nodesForXPath:@"/ROW/ActionContent/CONFIGITEM/DLP_OUTENC_SMTP_SECNAME_10" error:nil] objectAtIndex:0];
                NSString *level = [levelElement stringValue];
                //获取动作控制
                GDataXMLElement *actionControlElement = [[doc nodesForXPath:@"/ROW/ActionContent/CONFIGITEM/DLP_OUTENC_SMTP_ENCMETHOD_10" error:nil] objectAtIndex:0];
                NSString *actionControl = [actionControlElement stringValue];
                
                if ([actionControl isEqualToString:@"ENCATT"]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}
-(BOOL)havePlainStrategy{
    SystemAccount* account = [[AccountManagement getInstance]getActiveAccount];
    
    if (account == nil)
    {
        return NO;
    }
    
    //获取当前用户策略
    UserStrategy* userStrategy = [account getStrategy];
    
    //获取当前用户的所有发送邮件加密策略
    NSArray* sendEncStrategyList = [userStrategy getItemByGroupId:PLAIN_SEND_RECORD_IN_USER_STRATEGY];
    if ([sendEncStrategyList count] == 0)
    {
        TRACK(@"没有找到明文外发理由");
        return NO;
    }
    for (GDataXMLElement *element in sendEncStrategyList)
    {
        @autoreleasepool
        {
            //判断策略动作是否是允许
            if ([[[[element elementsForName:@"Action"]objectAtIndex:0]XMLString]
                 isEqual:@"<Action>1</Action>"] == YES)
            {
                MailPlainProperty *mpp = [[MailPlainProperty alloc]init];
                GDataXMLDocument* doc = [[[GDataXMLDocument alloc]initWithRootElement:element]autorelease];
                //获取策略名称
                GDataXMLElement *nameElement = [[doc nodesForXPath:@"/ROW/Name" error:nil] objectAtIndex:0];
                NSString *straName = [nameElement stringValue];
                if (straName) {
                    return YES;
                }
            }
        }
    }
    return NO;
}
-(NSArray *)getPlainStrategy{
    SystemAccount* account = [[AccountManagement getInstance]getActiveAccount];
    
    if (account == nil)
    {
        return NULL;
    }
    
    //获取当前用户策略
    UserStrategy* userStrategy = [account getStrategy];
    
    //获取当前用户的所有发送邮件加密策略
    NSArray* sendEncStrategyList = [userStrategy getItemByGroupId:PLAIN_SEND_RECORD_IN_USER_STRATEGY];
    if ([sendEncStrategyList count] == 0)
    {
        TRACK(@"没有找到明文外发理由");
        return nil;
    }
    NSMutableArray *plainList = [[NSMutableArray alloc]initWithCapacity:0];
    for (GDataXMLElement *element in sendEncStrategyList)
    {
        @autoreleasepool
        {
            //判断策略动作是否是允许
            if ([[[[element elementsForName:@"Action"]objectAtIndex:0]XMLString]
                 isEqual:@"<Action>1</Action>"] == YES)
            {
                MailPlainProperty *mpp = [[MailPlainProperty alloc]init];
                GDataXMLDocument* doc = [[[GDataXMLDocument alloc]initWithRootElement:element]autorelease];
                //获取策略名称
                GDataXMLElement *nameElement = [[doc nodesForXPath:@"/ROW/Name" error:nil] objectAtIndex:0];
                NSString *straName = [nameElement stringValue];
                mpp.strategyName = straName;
                //获取策略密级
                NSMutableArray *reasonList = [[NSMutableArray alloc]initWithCapacity:0];
                NSArray *reasonArray = [doc nodesForXPath:@"/ROW/TargetCondition/CONFIGITEM/CLT_TARGETCONDITIONITEM" error:nil];
                if(reasonArray.count>0){
                    for(GDataXMLElement *reasonElement in reasonArray){
                        NSString *reason = [[[reasonElement elementsForName:@"BRI_REG_REASON_MOBILE_10"]objectAtIndex:0] stringValue];
                        [reasonList addObject:reason];
                    }
                    
                }
                mpp.reasonList = reasonList;
                [plainList addObject:mpp];
//                [mpp release];mpp = nil;
            }
        }
    }
    if (!plainList.count) {
        return nil;
    }
    return plainList;
}


- (BOOL) haveCarryAttachedFile{
    SystemAccount* account = [[AccountManagement getInstance]getActiveAccount];
    
    if (account == nil)
    {
        return NO;
    }
    
    //获取当前用户策略
    UserStrategy* userStrategy = [account getStrategy];
    
    //获取当前用户的所有发送邮件加密策略
    NSArray* sendEncStrategyList = [userStrategy getItemByGroupId:PLAIN_SEND_RECORD_IN_USER_STRATEGY];
    if ([sendEncStrategyList count] == 0)
    {
        TRACK(@"没有找到明文外发理由");
        return NO;
    }
    //NSMutableArray *plainList = [[NSMutableArray alloc]initWithCapacity:0];
    BOOL flag = NO;
    for (GDataXMLElement *element in sendEncStrategyList)
    {
        @autoreleasepool
        {
            //判断策略动作是否是允许
            if ([[[[element elementsForName:@"Action"]objectAtIndex:0]XMLString]
                 isEqual:@"<Action>1</Action>"] == YES)
            {
                MailPlainProperty *mpp = [[MailPlainProperty alloc]init];
                GDataXMLDocument* doc = [[[GDataXMLDocument alloc]initWithRootElement:element]autorelease];
                //获取策略名称
                GDataXMLElement *nameElement = [[doc nodesForXPath:@"/ROW/Name" error:nil] objectAtIndex:0];
                NSString *straName = [nameElement stringValue];
                mpp.strategyName = straName;
                //获取是否允许携带附件
                //NSMutableArray *reasonList = [[NSMutableArray alloc]initWithCapacity:0];
                GDataXMLElement *actionContentElement = [[doc nodesForXPath:@"/ROW/ActionContent" error:nil] objectAtIndex:0];
                NSString *actionContentV = [actionContentElement stringValue];
                if ([actionContentV isEqualToString:@""]) {
                    flag = NO;
                }else{
                    GDataXMLElement *enableElement = [[doc nodesForXPath:@"/ROW/ActionContent/CONFIGITEM/BRI_MAN_ATT_MOBILE_10" error:nil] objectAtIndex:0];
                    if ([[enableElement name] isEqualToString:@"BRI_MAN_ATT_MOBILE_10"]) {
                        NSString *str = [enableElement stringValue];
                        if ([str isEqualToString: @"ATTACHMENT_ENABLE"]) {
                            flag = YES;
                        }else{
                            flag = NO;
                        }
                    }
               
                }
            }
        }
    }
    return flag;
}



bool match(char *pattern, char *content) {
    // if we reatch both end of two string, we are done
    if ('\0' == *pattern && '\0' == *content)
        return true;
    /* make sure that the characters after '*' are present in second string.
     this function assumes that the first string will not contain two
     consecutive '*'*/
    if ('*' == *pattern && '\0' != *(pattern + 1) && '\0' == *content)
        return false;
    // if the first string contains '?', or current characters of both
    // strings match
    if ('?' == *pattern || *pattern == *content)
        return match(pattern + 1, content + 1);
    /* if there is *, then there are two possibilities
     a) We consider current character of second string
     b) We ignore current character of second string.*/
    if ('*' == *pattern)
        return match(pattern + 1, content) || match(pattern, content + 1);
    return false;
}

@end
