//
//  BaseViewModel.m
//  DecryptionAssistant
//
//  Created by Granger on 2019/10/27.
//  Copyright © 2019 granger. All rights reserved.
//

#import "BaseViewModel.h"
#import "MISPMailHelper.h"

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
    [MISPMailHelper.sharedInstance decryptionFileWithFilePath:filePath completion:^(NSString *text) {
        
    }];

}


@end
