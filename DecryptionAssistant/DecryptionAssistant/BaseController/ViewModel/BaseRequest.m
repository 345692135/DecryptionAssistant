//
//  BaseRequest.m
//  SecretMail
//
//  Created by Granger on 2019/11/19.
//  Copyright © 2019 granger. All rights reserved.
//

#import "BaseRequest.h"
#import "MMDeviceInformation.h"
#import "NavUtil.h"
#import "TokenModel.h"
#import "AFHTTPSessionManager+DecryptionAssistant.h"

@implementation BaseRequest

#pragma mark - Public Method
+ (NSString *)MethodStringWithHttpMethod:(HTTPMethod)httpMethod {
    switch(httpMethod){
        case GET:   return @"GET";
        case POST:  return @"POST";
        case PUT:   return @"PUT";
        case DELETE: return @"DELETE";
        case PATCH: return @"PATCH";
        default:NSCAssert(NO, @"无效的HTTPMethod");
    }
}

+ (RACSignal *)HTTPRequestWithHTTPMethod:(HTTPMethod)method UrlString:(NSString *)url params:(id)params {
    NSLog(@"\n请求方式：httpmethod = %ld,\n 请求： url = %@, \n请求参数：params = %@,\n",(long)method,url,params);
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id < RACSubscriber > subscriber) {
        
        if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
            [subscriber sendError:[NSError errorWithDomain:@"" code:-1
                                                  userInfo:@{@"errorMessage":@"请打开移动网络"}]];
        }
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager sharedManager];
        // 设置请求格式
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        
        manager.responseSerializer.acceptableContentTypes =
        [NSSet setWithObjects:@"application/json", @"text/json", @"text/plain",@"text/html",@"charset=UTF-8",nil];
        // 设置请求超时的时间
        manager.requestSerializer.timeoutInterval = 30.f;
        manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", nil];
//        // 添加请求头
//        NSRange isRefreshRange = [url rangeOfString:@"users/refreshToken" options:NSRegularExpressionSearch];
//
//        if(isRefreshRange.location != NSNotFound ) {
//            [manager.requestSerializer setValue:AccountManager.shared.tokenModel.refreshToken forHTTPHeaderField:@"Authorization"];
//        }else{
//            [manager.requestSerializer setValue:AccountManager.shared.tokenModel.accessToken forHTTPHeaderField:@"Authorization"];
//        }
//
//        [manager.requestSerializer setValue:kUUID?:@"" forHTTPHeaderField:@"deviceId"];
//        NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//        [manager.requestSerializer setValue:[NSString stringWithFormat:@"platform=iOS;systemVersion=%@;appVersion=%@", [MMDeviceInformation os_version],appVersion] forHTTPHeaderField:@"PhoneModel"];
        
        NSURLSessionDataTask *op = [manager dataTaskWithHTTPMethod:[self MethodStringWithHttpMethod:method ] URLString:url parameters:params uploadProgress:^(NSProgress *uploadProgress) {
            
        } downloadProgress:^(NSProgress *downloadProgress) {
            
        } success:^(NSURLSessionDataTask *operation, id response) {
            response = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:nil];
            NSLog(@"response ===== [url=%@] response = %@",url, response);
            [subscriber sendNext:response];
            [subscriber sendCompleted];
            /*
            id statusStr = response[@"success"];
            if (![statusStr isKindOfClass:[NSString class]]) {
                statusStr = [statusStr stringValue];
            }
            if([statusStr boolValue]){
                [subscriber sendNext:response[@"data"]];
                [subscriber sendCompleted];
            }else {
                [subscriber sendError:[BaseRequest getErrorOpertion:operation :response]];
            }
             */
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            NSLog(@"response ===== [url=%@] error = %@",url, error);
            [subscriber sendError:[BaseRequest getErrorOpertion:operation Error:error]];
        }];
        
        [op resume];
        return [RACDisposable disposableWithBlock:^{
            [op cancel];
        }];
    }];
    
    return [self doRequestAndRefreshTokenIfNecessary:signal];
}

+ (RACSignal *)HTTPRequestWithHTTPMethod:(HTTPMethod)method UrlString:(NSString *)url params:(id)params type:(NSInteger)type{
    NSLog(@"\n请求方式：httpmethod = %ld,\n 请求： url = %@, \n请求参数：params = %@,\n",(long)method,url,@"...");
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id < RACSubscriber > subscriber) {
        
        if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
            [subscriber sendError:[NSError errorWithDomain:@"" code:-1
                                                  userInfo:@{@"errorMessage":@"请打开移动网络"}]];
        }
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager sharedManager];
        // 设置请求格式
        if (type == GZIP) {
            manager.requestSerializer = [AFHTTPRequestSerializer serializer];
            [manager.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Content-Type"];
        } else {
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        }
        
        manager.responseSerializer.acceptableContentTypes =
        [NSSet setWithObjects:@"application/json", @"text/json", @"text/plain",@"text/html",@"charset=UTF-8",nil];
        // 设置请求超时的时间
        manager.requestSerializer.timeoutInterval = 30.f;
        manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", nil];
        // 添加请求头
        NSRange isRefreshRange = [url rangeOfString:@"users/refreshToken" options:NSRegularExpressionSearch];
        
//        if(isRefreshRange.location != NSNotFound ) {
//            [manager.requestSerializer setValue:AccountManager.shared.tokenModel.refreshToken forHTTPHeaderField:@"Authorization"];
//        }else{
//            [manager.requestSerializer setValue:AccountManager.shared.tokenModel.accessToken forHTTPHeaderField:@"Authorization"];
//        }
        
        [manager.requestSerializer setValue:kUUID?:@"" forHTTPHeaderField:@"deviceId"];
        NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"platform=iOS;systemVersion=%@;appVersion=%@", [MMDeviceInformation os_version],appVersion] forHTTPHeaderField:@"PhoneModel"];
        
        NSURLSessionDataTask *op = [manager dataTaskWithHTTPMethod:[self MethodStringWithHttpMethod:method ] URLString:url parameters:params uploadProgress:^(NSProgress *uploadProgress) {
            
        } downloadProgress:^(NSProgress *downloadProgress) {
            
        } success:^(NSURLSessionDataTask *operation, id response) {
            response = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:nil];
            NSLog(@"response ===== [url=%@] response = %@",url, @"...");
            [subscriber sendNext:response];
            [subscriber sendCompleted];
            /*
            id statusStr = response[@"success"];
            if (![statusStr isKindOfClass:[NSString class]]) {
                statusStr = [statusStr stringValue];
            }
            if([statusStr boolValue]){
                [subscriber sendNext:response[@"data"]];
                [subscriber sendCompleted];
            }else {
                [subscriber sendError:[BaseRequest getErrorOpertion:operation :response]];
            }
             */
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            NSLog(@"response ===== [url=%@] error = %@",url, error);
            [subscriber sendError:[BaseRequest getErrorOpertion:operation Error:error]];
        }];
        
        [op resume];
        return [RACDisposable disposableWithBlock:^{
            [op cancel];
        }];
    }];
    
    return [self doRequestAndRefreshTokenIfNecessary:signal];
}

+ (NSError *)getErrorOpertion:(NSURLSessionDataTask *)operation :(id)response{
    NSDictionary * userInfoDict;
    // 接口异常，直接显示返回结果，方便调试
    
    NSString *errorMessage;
    NSString *code = response[@"errorCode"];
    if (code && [code isKindOfClass:[NSString class]]) {
        
        if ([code isEqualToString:@"10001"]) errorMessage = @"请求超时";//@"系统服务错误";
        else if ([code isEqualToString:@"10002"]) errorMessage = @"请求参数不能为空";
        else if ([code isEqualToString:@"10003"]) errorMessage = @"请求参数错误";
        else if ([code isEqualToString:@"10004"]) errorMessage = @"验证码输入错误";
        else if ([code isEqualToString:@"10005"]) errorMessage = @"验证码超时";
        else if ([code isEqualToString:@"10006"]) errorMessage = @"您的手机号码已注册";
        else if ([code isEqualToString:@"10007"]) errorMessage = @"用户昵称已存在";
        else if ([code isEqualToString:@"10008"]) errorMessage = @"验证码还在有效期内";
        else if ([code isEqualToString:@"10009"]) errorMessage = @"您的手机号码未注册";
        else if ([code isEqualToString:@"10010"]) errorMessage = @"帐号密码不匹配";
        else if ([code isEqualToString:@"10012"]) errorMessage = @"该设备已被其他账号绑定，请先行解绑";
        else if ([code isEqualToString:@"10013"]) errorMessage = @"操作频繁，稍后再试";
        else if ([code isEqualToString:@"10101"]) errorMessage = @"验证码错误";
        else if ([code isEqualToString:@"10102"]) errorMessage = @"更新手机号码失败";
        else if ([code isEqualToString:@"10103"]) errorMessage = @"当前手机号码不存在";
        else if ([code isEqualToString:@"10104"]) errorMessage = @"当前手机号码已被占用";
        else if ([code isEqualToString:@"10105"]) errorMessage = @"userId为空";
        else if ([code isEqualToString:@"10106"]) errorMessage = @"更新用户头像图片失败";
        else if ([code isEqualToString:@"10107"]) errorMessage = @"昵称已被使用";
        else if ([code isEqualToString:@"10108"]) errorMessage = @"上传图片为空";
        else if ([code isEqualToString:@"10109"]) errorMessage = @"更新昵称失败";
        else if ([code isEqualToString:@"10110"]) errorMessage = @"昵称涉及敏感词汇";
        else if ([code isEqualToString:@"10111"]) errorMessage = @"用户不存在";
        else if ([code isEqualToString:@"10112"]) errorMessage = @"图形验证码校验失败";
        else if ([code isEqualToString:@"10117"]) errorMessage = @"请输入图形验证码";
        else if ([code isEqualToString:@"10118"]) errorMessage = @"此手机号已被obd绑定";
        else if ([code isEqualToString:@"10200"]) errorMessage = @"没有空闲资源";
        else if ([code isEqualToString:@"10201"]) errorMessage = @"预约已过期不能取消";
        else if ([code isEqualToString:@"10202"]) errorMessage = @"不能重复取消";
        else if ([code isEqualToString:@"10203"]) errorMessage = @"已履约不能取消";
        else if ([code isEqualToString:@"10204"]) errorMessage = @"请选择正确的时间";
        else if ([code isEqualToString:@"10206"]) errorMessage = @"未获取到ModelCode";
        else if ([code isEqualToString:@"10300"]) errorMessage = @"请重新登录";
        else if ([code isEqualToString:@"10303"]) errorMessage = @"请重新登录";
        else if ([code isEqualToString:@"10304"]) errorMessage = @"您的账号已在其他设备登录，请重新登录！";
        else if ([code isEqualToString:@"10305"]) errorMessage = @"获取短信验证码错误";
        else if ([code isEqualToString:@"10306"]) errorMessage = @"短信验证码校验错误";
        else if ([code isEqualToString:@"10307"]) errorMessage = @"忘记密码错误";
        else if ([code isEqualToString:@"10308"]) errorMessage = @"修改密码错误";
        else if ([code isEqualToString:@"10309"]) errorMessage = @"请重新登录";
        else if ([code isEqualToString:@"10310"]) errorMessage = @"昵称已存在";
        else if ([code isEqualToString:@"10311"]) errorMessage = @"验证失败";
        else if ([code isEqualToString:@"10312"]) errorMessage = @"网络异常";
        else if ([code isEqualToString:@"10500"]) errorMessage = @"获取用户信息失败";
        else if ([code isEqualToString:@"10501"]) errorMessage = @"修改用户信息失败";
        else if ([code isEqualToString:@"10502"]) errorMessage = @"验证失败";
        else if ([code isEqualToString:@"10503"]) errorMessage = @"验证失败";
        else if ([code isEqualToString:@"10505"]) errorMessage = @"验证失败";
        else if ([code isEqualToString:@"10506"]) errorMessage = @"验证失败";
        else if ([code isEqualToString:@"10507"]) errorMessage = @"验证失败";
        else if ([code isEqualToString:@"10508"]) errorMessage = @"系统异常";
        else if ([code isEqualToString:@"10509"]) errorMessage = @"获取短信验证码频率过快，请60秒后重试";
        else if ([code isEqualToString:@"10510"]) errorMessage = @"验证失败";
        else if ([code isEqualToString:@"10511"]) errorMessage = @"短信服务超时";
        else if ([code isEqualToString:@"10512"]) errorMessage = @"失败次数过多，请30分钟后重试";
        else if ([code isEqualToString:@"10513"]) errorMessage = @"验证失败";
        else if ([code isEqualToString:@"10514"]) errorMessage = @"获取用户信息失败";
        else if ([code isEqualToString:@"10515"]) errorMessage = @"获取用户信息失败";
        else if ([code isEqualToString:@"10516"]) errorMessage = @"获取用户信息失败";
        else if ([code isEqualToString:@"10517"]) errorMessage = @"更新用户信息失败";
        else if ([code isEqualToString:@"10518"]) errorMessage = @"请输入短信验证码或授权验证码";
        else if ([code isEqualToString:@"10519"]) errorMessage = @"更新手机号失败";
        else if ([code isEqualToString:@"10520"]) errorMessage = @"更新密码失败";
        else if ([code isEqualToString:@"10521"]) errorMessage = @"密码不正确";
        else if ([code isEqualToString:@"10522"]) errorMessage = @"系统异常";
        else if ([code isEqualToString:@"10523"]) errorMessage = @"系统异常";
        else if ([code isEqualToString:@"10524"]) errorMessage = @"系统异常";
        else if ([code isEqualToString:@"10525"]) errorMessage = @"系统异常";
        else if ([code isEqualToString:@"10526"]) errorMessage = @"系统异常";
        else if ([code isEqualToString:@"10527"]) errorMessage = @"系统异常";
        else if ([code isEqualToString:@"10529"]) errorMessage = @"获取验证码次数超限";
        else if ([code isEqualToString:@"10530"]) errorMessage = @"授权验证码校验失败次数过多，请重新获取短信验证码";
        else if ([code isEqualToString:@"10531"]) errorMessage = @"短信验证码校验失败次数过多，请重新获取短信验证码";
        else if ([code isEqualToString:@"10534"]) errorMessage = @"大众一家账号或密码错误";
        else if ([code isEqualToString:@"10535"]) errorMessage = @"未绑定大众一家账号";
        else if ([code isEqualToString:@"10536"]) errorMessage = @"查询大众一家会员信息失败";//此信息不做提示
        else if ([code isEqualToString:@"20113"]) errorMessage = @"用户已签到";

        else errorMessage = @"请求超时";//@"系统服务异常"; //IDP_SERVICE_TIMEOUT("10532","调用IDP服务超时") 处理为请求超时
        
        userInfoDict = @{@"errorMessage":errorMessage,
                         @"errorCode":code};
    } else {
        userInfoDict = response;
    }
    
    NSError *error = [NSError errorWithDomain :operation.originalRequest.URL.pathComponents[1] code :[response[@"errorCode"] integerValue] userInfo :userInfoDict];
    return error;
    
    /*
    else if ([response[@"errorCode"] isEqualToString:@"10011"]){
        errorMessage = @"请重新登录";
        [ToastManager showMsg:errorMessage duration:1.0];
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            [BaseRequest dealTokenInvalid];
        });
    }
     */
}

+ (NSError *)getErrorOpertion:(NSURLSessionDataTask *)operation Error:(NSError *)error{
    NSData *errorData = error.userInfo[@"com.alamofire.serialization.response.error.data"];
    if(errorData){
    }
    else {
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:error.userInfo];
    
    // 请求超时
    if (error.code == -1001) {
        [dict setObject:@"请求超时" forKey:@"errorMessage"];
        
    }else{
        // [dict setObject:error.userInfo[@"NSLocalizedDescription"]?:@"" forKey:@"errorMessage"];
         [dict setObject:@"请求超时" forKey:@"errorMessage"];
    }
    NSHTTPURLResponse * responses = (NSHTTPURLResponse *)operation.response;
    if (responses!=nil) {
        NSLog(@"服务器网络故障, code=%ld",responses.statusCode);
        [dict setObject:[NSNumber numberWithInteger:responses.statusCode] forKey:@"httpErrorCode"];
    }
    NSError *myError = [NSError errorWithDomain :dict[@"errorMessage"] code :error.code userInfo :dict];
    return myError;
}

+ (RACSignal *)uploadFileWithProgress:(NSURL *)fileUrl url:(NSString *)url {
    
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id < RACSubscriber > subscriber) {
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager sharedManager];
        //设置请求超时的时间
        manager.requestSerializer.timeoutInterval = 30.f;
        manager.responseSerializer.acceptableContentTypes =
        [NSSet setWithObjects:@"application/json", @"text/json", @"text/plain", nil];
        
        manager.responseSerializer.acceptableContentTypes =
        [NSSet setWithObjects:@"application/json", @"text/json", @"text/plain",@"text/html",@"charset=UTF-8",nil];
        // 设置请求超时的时间
        manager.requestSerializer.timeoutInterval = 30.f;
        manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", nil];
        // 添加请求头
//        [manager.requestSerializer setValue:AccountManager.shared.tokenModel.accessToken forHTTPHeaderField:@"Authorization"];
        [manager.requestSerializer setValue:kUUID?:@"" forHTTPHeaderField:@"deviceId"];
        NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"platform=iOS;systemVersion=%@;appVersion=%@", [MMDeviceInformation os_version],appVersion] forHTTPHeaderField:@"PhoneModel"];
        
        NSURLSessionDataTask *op = [manager POST:url parameters:nil constructingBodyWithBlock:^(id < AFMultipartFormData > formData) {
            NSError *error = nil;
            [formData appendPartWithFileURL:fileUrl name:@"file" error:&error];
            if (error) {
            }
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            
            [subscriber sendNext:@([uploadProgress fractionCompleted])];
            
        } success:^(NSURLSessionDataTask *operation, id response) {
            response = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:nil];
            id statusStr = response[@"success"];
            if (![statusStr isKindOfClass:[NSString class]]) {
                statusStr = [statusStr stringValue];
            }
            if([statusStr isEqualToString :@"true"]||[statusStr boolValue]){
                [subscriber sendNext:response[@"data"]];
                [subscriber sendCompleted];
            }else {
                [subscriber sendError:[BaseRequest getErrorOpertion:operation :response]];
            }
            
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            [subscriber sendError:[BaseRequest getErrorOpertion:operation Error:error]];
        }];
        [op resume];
        return [RACDisposable disposableWithBlock:^{
            [op cancel];
        }];
    }];
    
    return [self doRequestAndRefreshTokenIfNecessary:signal];
}

+ (RACSignal *)uploadFile:(NSURL *)fileUrl url:(NSString *)url {
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id < RACSubscriber > subscriber) {
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager sharedManager];
        // 设置请求格式
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        // 添加请求头
        
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        [securityPolicy setValidatesDomainName:NO];
        securityPolicy.allowInvalidCertificates = YES; //还是必须设成YES
        manager.securityPolicy = securityPolicy;
        
        // manager.responseSerializer的默认值是AFJSONRequestSerializer
        // manager.responseSerializer = [AFCompoundResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes =
        [NSSet setWithObjects:@"application/json", @"text/json", @"text/plain",@"text/html",@"charset=UTF-8",nil];
        // 设置请求超时的时间
        manager.requestSerializer.timeoutInterval = 30.f;
        manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", nil];
        // 添加请求头
//        [manager.requestSerializer setValue:AccountManager.shared.tokenModel.accessToken forHTTPHeaderField:@"Authorization"];
        
        [manager.requestSerializer setValue:kUUID?:@"" forHTTPHeaderField:@"deviceId"];
        NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"platform=iOS;systemVersion=%@;appVersion=%@", [MMDeviceInformation os_version],appVersion] forHTTPHeaderField:@"PhoneModel"];
        
        NSURLSessionTask *op = [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            NSError *error = nil;
            [formData appendPartWithFileURL:fileUrl name:@"image" error:&error];
            if (error) {
            }
            
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            responseObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];

            id statusStr = responseObject[@"success"];
            if (![statusStr isKindOfClass:[NSString class]]) {
                statusStr = [statusStr stringValue];
            }
            if([statusStr isEqualToString :@"true"]||[statusStr boolValue]){
                [subscriber sendNext:responseObject[@"data"]];
                [subscriber sendCompleted];
            }else {
                [subscriber sendError:[BaseRequest getErrorOpertion:task :responseObject]];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [subscriber sendError:[BaseRequest getErrorOpertion:task Error:error]];
        }];
        
        [op resume];
        return [RACDisposable disposableWithBlock:^{
            [op cancel];
        }];
    }];
    
    return [self doRequestAndRefreshTokenIfNecessary:signal];
}
+ (RACSignal *)uploadFile:(NSURL *)fileUrl url:(NSString *)url params:(id)params{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id < RACSubscriber > subscriber) {
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager sharedManager];
        // 设置请求格式
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        // 添加请求头
        
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        [securityPolicy setValidatesDomainName:NO];
        securityPolicy.allowInvalidCertificates = YES; //还是必须设成YES
        manager.securityPolicy = securityPolicy;
        
        // manager.responseSerializer的默认值是AFJSONRequestSerializer
        // manager.responseSerializer = [AFCompoundResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes =
        [NSSet setWithObjects:@"application/json", @"text/json", @"text/plain",@"text/html",@"charset=UTF-8",nil];
        // 设置请求超时的时间
        manager.requestSerializer.timeoutInterval = 30.f;
        manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", nil];
        // 添加请求头
//        [manager.requestSerializer setValue:AccountManager.shared.tokenModel.accessToken forHTTPHeaderField:@"Authorization"];
        
        [manager.requestSerializer setValue:kUUID?:@"" forHTTPHeaderField:@"deviceId"];
        NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"platform=iOS;systemVersion=%@;appVersion=%@", [MMDeviceInformation os_version],appVersion] forHTTPHeaderField:@"PhoneModel"];
        NSURLSessionTask *op = [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            NSError *error = nil;
            if (fileUrl) {
                [formData appendPartWithFileURL:fileUrl name:@"image" error:&error];
            }
            if (error) {
            }
            
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            responseObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            id statusStr = responseObject[@"success"];
            if (![statusStr isKindOfClass:[NSString class]]) {
                statusStr = [statusStr stringValue];
            }
            if([statusStr isEqualToString :@"true"]||[statusStr boolValue]){
                [subscriber sendNext:responseObject[@"data"]];
                [subscriber sendCompleted];
            }else {
                [subscriber sendError:[BaseRequest getErrorOpertion:task :responseObject]];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [subscriber sendError:[BaseRequest getErrorOpertion:task Error:error]];
        }];
        
        [op resume];
        return [RACDisposable disposableWithBlock:^{
            [op cancel];
        }];
    }];
    
    return [self doRequestAndRefreshTokenIfNecessary:signal];
}

+ (RACSignal *)uploadFile:(NSURL *)fileUrl url:(NSString *)url params:(id)params type:(NSString*)typeStr{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id < RACSubscriber > subscriber) {
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager sharedManager];
        // 设置请求格式
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        // 添加请求头
        
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        [securityPolicy setValidatesDomainName:NO];
        securityPolicy.allowInvalidCertificates = YES; //还是必须设成YES
        manager.securityPolicy = securityPolicy;
        
        // manager.responseSerializer的默认值是AFJSONRequestSerializer
        // manager.responseSerializer = [AFCompoundResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes =
        [NSSet setWithObjects:@"application/json", @"text/json", @"text/plain",@"text/html",@"charset=UTF-8",nil];
        // 设置请求超时的时间
        manager.requestSerializer.timeoutInterval = 30.f;
        manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", nil];
        // 添加请求头
//        [manager.requestSerializer setValue:AccountManager.shared.tokenModel.accessToken forHTTPHeaderField:@"Authorization"];
        
        [manager.requestSerializer setValue:kUUID?:@"" forHTTPHeaderField:@"deviceId"];
        NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"platform=iOS;systemVersion=%@;appVersion=%@", [MMDeviceInformation os_version],appVersion] forHTTPHeaderField:@"PhoneModel"];
        NSURLSessionTask *op = [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            NSError *error = nil;
            if (fileUrl) {
                [formData appendPartWithFileURL:fileUrl name:typeStr error:&error];
            }
            if (error) {
            }
            
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            responseObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            id statusStr = responseObject[@"success"];
            if (![statusStr isKindOfClass:[NSString class]]) {
                statusStr = [statusStr stringValue];
            }
            if([statusStr isEqualToString :@"true"]||[statusStr boolValue]){
                [subscriber sendNext:responseObject[@"data"]];
                [subscriber sendCompleted];
            }else {
                [subscriber sendError:[BaseRequest getErrorOpertion:task :responseObject]];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [subscriber sendError:[BaseRequest getErrorOpertion:task Error:error]];
        }];
        
        [op resume];
        return [RACDisposable disposableWithBlock:^{
            [op cancel];
        }];
    }];
    
    return [self doRequestAndRefreshTokenIfNecessary:signal];
}


+ (RACSignal *)downloadFileByUrl :(NSURL *)url toFilePath :(NSURL *)toFilePath {
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id < RACSubscriber > subscriber) {
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            
            return toFilePath?:targetPath;
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            
            
            if(!error){
                // [subscriber sendNext:filePath];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:error];
            }
        }];
        
        // 保证下载特别快的时候，没有执行进度回调也能拿到下载文件路径
        [manager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
            float progressValue = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
            [subscriber sendNext:@(progressValue)];
        }];
        
        [downloadTask resume];
        
        return [RACDisposable disposableWithBlock:^{
            [downloadTask cancel];
        }];
    }];
    return [self doRequestAndRefreshTokenIfNecessary:signal];
}

/**
 获取本地数据
 
 @param fileName 本地文件名称
 @param type 本地文件类型
 
 */
+ (RACSignal *)getLocationFileName :(NSString *)fileName type :(NSString *)type {
    return [RACSignal createSignal :^RACDisposable *(id < RACSubscriber > subscriber) {
        NSError *error;
        // 获取文件路径
        NSString *filePath = [[NSBundle mainBundle] pathForResource :fileName ofType :type];
        
        // 根据文件路径读取数据
        NSData *jdata = [[NSData alloc] initWithContentsOfFile :filePath];
        // id jsonObject = [NSJSONSerialization JSONObjectWithData:jdata options:kNilOptions error:&error];
        if (jdata) {
            id jsonObject = [NSJSONSerialization JSONObjectWithData :jdata
                                                            options :kNilOptions
                                                              error :&error];
            [subscriber sendNext :jsonObject[@"data"]];
        }else{
            [subscriber sendError:error];
        }
        return [RACDisposable disposableWithBlock :^{
        }];
    }];
}


+ (RACSignal *)doRequestAndRefreshTokenIfNecessary:(RACSignal *)requestSignal {
    return [requestSignal catch:^RACSignal *(NSError *error) {
        /*
         当请求返回10301(token  过期)、10304(token 废弃了)时候，
         RefreshToken 返回成功后继续请求之前请求失败的接口，
         如果RefreshToken 返回错误,退出到登录页面。
         */
        
        /*
         NSInteger status = 0;
         NSData *errorData = error.userInfo[@"com.alamofire.serialization.response.error.data"];
         if(errorData){
         NSDictionary *errDict = [NSJSONSerialization JSONObjectWithData :errorData options :NSJSONReadingMutableContainers error :nil];
         status = [errDict[@"status"] intValue];
         }
         if (status == 401 || status == 403) {
         return [[[[[OAuthRequest refreshTokenVerifyCredentials] retry:1] catch:^RACSignal *(NSError *error) {
         [self dealTokenInvalid];
         return [RACSignal empty];
         }] ignoreValues] concat:requestSignal];
         
         }else{
         return [RACSignal error:error];
         }
         */
        
        NSInteger errorCode = 0;
        // eg [error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] statusCode] == 401
        errorCode = [error.userInfo[@"errorCode"] integerValue];
        if (errorCode == 10301) {
            //10303 10309 错误注销登录
            if ([UserDefaults boolForKey:@"isRefreshToken"] == YES) {
                NSError *myError =[NSError errorWithDomain:@"" code:-1
                                                  userInfo:@{@"errorMessage":@""}];

                return [RACSignal error:myError];
            }
            else{
                [UserDefaults setBool:YES forKey:@"isRefreshToken"];
                [UserDefaults synchronize];
                return [[[[self refreshTokenVerifyCredentials] catch:^RACSignal *(NSError *error) {
                      [ToastManager showMsg:@"请重新登录" duration:1.0];
                    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
                    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                         [BaseRequest dealTokenInvalid];
                        [UserDefaults setBool:NO forKey:@"isRefreshToken"];
                        [UserDefaults synchronize];
                    });
                    return [RACSignal error:error];
                }] ignoreValues] concat:requestSignal];
            }
            
            

        }else if(errorCode == 10304||errorCode == 10300||errorCode == 10303){
            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                [BaseRequest dealTokenInvalid];
            });
            return [RACSignal error:error];
        }else{
            return [RACSignal error:error];
        }
        
    }];
}

+ (void)dealTokenInvalid{
    dispatch_async(dispatch_get_main_queue(), ^{
//        if (AccountManager.shared.flag!=nil&&AccountManager.shared.flag.length>0) {
////            UIViewController *vc = [UtilsNav topViewController];
////            if ([vc isKindOfClass:[VWActivityWebViewController class]]) {
////                [vc dismissViewControllerAnimated:NO completion:nil];
////            } else {
////                [vc.navigationController popToRootViewControllerAnimated:NO];
////            }
//
//            [[NavUtil topViewController].navigationController popToRootViewControllerAnimated:NO];
////            [kAppDelegate pushLogin];
//        }
    });
}

// 刷新token
+ (RACSignal *)refreshTokenVerifyCredentials{
    
    return [[self HTTPRequestWithHTTPMethod:POST UrlString:HTTP_REFRESH_TOKEN params :nil] map :^id (id value) {
        [UserDefaults setBool:NO forKey:@"isRefreshToken"];
        [UserDefaults synchronize];
        TokenModel *token = [TokenModel yy_modelWithDictionary:value];
//        [AccountManager.shared updateDataWithTokenModel:token];
        return token;
    }];
}

@end
