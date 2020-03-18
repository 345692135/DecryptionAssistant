//
//  BaseViewModel.m
//  DecryptionAssistant
//
//  Created by Granger on 2019/10/27.
//  Copyright © 2019 granger. All rights reserved.
//

#import "BaseViewModel.h"
#import <MISP/NSData+CryptoEmail.h>
#import <MISP/NSMutableData+Crypto.h>
#import <MISP/CryptoCoreData.h>
#import <MISP/SecLevelKeyHelper.h>
#import <MISP/EncryptSQLiteManager.h>
//#import <MISP/SystemStrategy.h>
#import "FileUtil.h"
#import "NSData+UTF8.h"


@interface BaseViewModel ()<NSURLSessionDelegate>

@end

@implementation BaseViewModel

/// 登录请求
/// @param model model description
/// @param success success description
/// @param failure failure description
//-(void)loginRequestByLoginModel:(LoginModel*)model success:(void (^)(BOOL isSuccess))success failure:(void (^)(NSError * error))failure {
//    [[DBManager shared] loginRequestByLoginModel:model success:success failure:failure];
//    //登录成功后请求RSA钥匙对
//    [[self requestUserLoginWithUserMail:model.username userPhone:@"" userDeviceId:AccountManager.shared.deviceToken deviceType:@"0"] subscribeNext:^(id x) {
////        NSLog(@"%@",x);
//    } error:^(NSError *error) {
////        NSLog(@"%@",error);
//    }];
//
//}


-(void)decryptionFileWithFilePath:(NSString*)filePath {
    
    NSDictionary *dictionary = [CryptoCoreData getLevelKeysDictionary];
//    NSDictionary *LevelNameDic = [SystemStrategy getLevelNameListWithRandID:dictionary.allKeys];
//    NSLog(@"LevelNameDic=%@",LevelNameDic);
    
    BOOL iRet = [NSMutableData isEncryptFile:filePath];
    if (iRet) {
//        NSData *data = [NSData dataWithContentsOfFile:filePath];
//        NSLog(@"%lu",data.length);
//
        
        
//        NSLog(@"%@",dictionary);
//        NSString *randId = nil;
//        for (NSString *key in dictionary.allKeys) {
//            if ([dictionary[key] isEqualToString:@"售后培训"]) {
//                randId = key;
//            }
//        }
//
//        if (randId) {
//            NSString *str = @"";
//            NSData *d = [NSData new];
//            SecLevelKeyHelper *secLevel = [[SecLevelKeyHelper alloc] initWithLevelKeyString:randId];
//            long re = [secLevel levelKeyDecrypt:data.bytes length:data.length plainText:[str UTF8String] outLength:str.length];
//            NSLog(@"%lu",re);
//
//        }
        
        
        
        
        NSData * decryptData = [NSData dataWithEncryptContentsOfFile: filePath];
        NSMutableData *muData = [NSMutableData dataWithData:decryptData];

        /*
        Abstract:解密结果判断
        @return isEncData YES:解密失败 NO：解密成功
        */
        BOOL isEncData = [muData isEncData];
        NSLog(@":::::%d",isEncData);
        if (!isEncData) {
            NSString *string = muData.utf8ToString;
//            NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
            NSLog(@"string=%@.",string);
            NSString *string2 = [FileUtil saveFileToLocal:muData.UTF8Data fileName:@"test.txt"];
            NSLog(@"string=%@.",string2);
        }
        
//        NSLog(@"%d", isEncData);
//        NSString * str  =[[NSString alloc] initWithData:decryptData encoding:-2147483623];
//        NSLog(@"%@",str);
////        [ToastManager showMsg:[NSString]];
//
//        CryptoCoreData *crypto = [[CryptoCoreData alloc] initWithLevel:@"售后培训" total:1];
//        NSData *electData = [crypto getElectronLabel];
//        NSString *elect = [[NSString alloc] initWithData:electData encoding:NSUTF8StringEncoding];
//        NSLog(@"elect:%@");
        
    }

}


@end
