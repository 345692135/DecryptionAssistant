//
//  MISPMailHelper.h
//  cellDemo
//
//  Created by 刘秀红 on 2017/6/16.
//  Copyright © 2017年 刘秀红. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    kcgChinasecAccountStatus_noLogin,
    kcgChinasecAccountStatus_offline,
    kcgChinasecAccountStatus_online
} kcgChinasecAccountStatus;

@class CGAccountData;

@interface MISPMailHelper : NSObject

+ (MISPMailHelper *)sharedInstance;

@property (nonatomic) kcgChinasecAccountStatus chinasecAccountStatus;

/** 初始化 */
- (void)handleInitOperationWithIp:(NSString*)ip
                             port:(NSString*)port
                              key:(NSString*)key
                       completion:(void (^)(BOOL ifSuccess))completion;

/** 登录 */
- (void)loginWithAccountName:(NSString*)accountName
                   password:(NSString*)password
                 completion:(void (^)(BOOL ifSuccess))completion;

/** 检测安元帐号是否激活 */
- (BOOL)isChinasecActiveWithAccountData:(CGAccountData*)accountData;

///** 初始化安元 */
//- (void)initializeChinasecWithAccountData:(CGAccountData*)accountData;

/** 获取策略 */
- (void)fetchStrategyWithCompletion:(void (^)(BOOL ifSuccess))completion;

/** 加密 */
- (void)encryptWithFilePath:(NSString*)filePath completion:(void (^)(BOOL ifSuccess, NSData* data))completion;

/** 解密 */
- (NSData*)decryptWithFilePath:(NSString*)filePath;
- (void)decryptWithFilePath:(NSString*)filePath completion:(void (^)(BOOL ifSuccess, NSData* data))completion;

/** 登出 */
- (void)logOut;

/** 发邮件 */
- (void)sendMail;

- (void)decryptionFileWithFilePath:(NSString*)filePath completion:(void (^)(NSString* text))completion;

@end
