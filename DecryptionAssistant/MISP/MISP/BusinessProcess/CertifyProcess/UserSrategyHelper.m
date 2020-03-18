//
//  UserSrategyHelper.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-12-7.
//
//

#import "UserSrategyHelper.h"
#import "AccountManagement.h"

#define LOCK_SCREEN_GROUPID_IN_USER_STRATEGY    @"269025284"
#define OFFLINE_LOGIN_GROUPID_IN_USER_STRATEGY  @"269025285"

@implementation UserSrategyHelper

+ (BOOL)lockScreen
{
    SystemAccount* account = [[AccountManagement getInstance]getActiveAccount];
    if (account == nil) {
        return NO;
    }
    
    if ([account userSid] == nil) {
        return NO;
    }
    
    if ([[account userSid] isEqualToString:SYSTEM_DEFAULT_USER_SID]) {
        return NO;
    }
    
    UserStrategy* userStrategy = [account getStrategy];
    
    NSArray* array = [userStrategy getItemByGroupId:LOCK_SCREEN_GROUPID_IN_USER_STRATEGY];
    if ([array count] == 0) {
        
        return NO;
    }
    
    GDataXMLElement* element = (GDataXMLElement*)[array objectAtIndex:0];
    if ([[[[element elementsForName:@"Action"]objectAtIndex:0]XMLString] isEqual:@"<Action>1</Action>"] == YES)
    {
        NSRange range = [[element XMLString]rangeOfString:@"<MOBILE_LOCK_SCREEN_ENABLE_00>1</MOBILE_LOCK_SCREEN_ENABLE_00>"];
        if (range.length == 0) {
            return NO;
        }
        return YES;
    }
    return NO;
    
}

+ (BOOL)permissionOffline
{
    SystemAccount* account = [[AccountManagement getInstance]getActiveAccount];
    if (account == nil) {
        return NO;
    }
    
    if ([account userSid] == nil) {
        return NO;
    }
    
    if ([[account userSid] isEqualToString:SYSTEM_DEFAULT_USER_SID]) {
        return NO;
    }
    
    UserStrategy* userStrategy = [account getStrategy];
    
    NSArray* array = [userStrategy getItemByGroupId:OFFLINE_LOGIN_GROUPID_IN_USER_STRATEGY];
    if ([array count] == 0) {
        
        return NO;
    }
    
    GDataXMLElement* element = (GDataXMLElement*)[array objectAtIndex:0];
    if ([[[[element elementsForName:@"Action"]objectAtIndex:0]XMLString] isEqual:@"<Action>1</Action>"] == YES)
    {
        NSRange range = [[element XMLString]rangeOfString:@"<MOBILE_OFFLINE_LOGIN_ENABLE_00>1</MOBILE_OFFLINE_LOGIN_ENABLE_00>"];
        if (range.length == 0) {
            return NO;
        }
        return YES;
    }
    return NO;
    
}

/**
 *  删除某文件夹下所有文件和目录
 *
 *  path：文件夹全路径
 */
+ (void)clearAllContentsOfPath:(NSString *)path{
    @autoreleasepool {
        NSFileManager * fileMgr = [NSFileManager defaultManager];
        NSError * error = nil;
        NSArray *directroyContents = [fileMgr contentsOfDirectoryAtPath:path error:&error];
        if(error == nil){
            for(NSString * pathItem in directroyContents){
                NSString * fullPath = [path stringByAppendingPathComponent:pathItem];
                BOOL removeSuccess = [fileMgr removeItemAtPath:fullPath error:&error];
                if(!removeSuccess){
                    NSLog(@"%@ remove failed.",fullPath);
                }else{
                    NSLog(@"%@ remove success.",fullPath);
                }
            }
        }else{
            NSLog(@"Get contents error: %@",error);
        }
    }
}

@end
