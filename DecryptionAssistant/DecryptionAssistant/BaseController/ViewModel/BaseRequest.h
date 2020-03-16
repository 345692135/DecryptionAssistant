//
//  BaseRequest.h
//  SecretMail
//
//  Created by Granger on 2019/11/19.
//  Copyright © 2019 granger. All rights reserved.
//

#import <Foundation/Foundation.h>

#define OAuthStoreVerifyCredentialsError @"OAuthStoreVerifyCredentialsError"

typedef NS_ENUM (NSInteger, HTTPMethod) {
    GET = 0,
    POST,
    PUT,
    DELETE,
    PATCH
};

typedef NS_ENUM (NSInteger, DataFormat) {
    PLAIN = 0,
    GZIP
};

// 网络请求返回值
#define kRequestStatusSuccess    @"success"

// 网络请求 返回数据 状态数据段key
#define kResponseDataKeyStatus   @"status"
// 网络请求 返回数据 数据数据段key
#define kResponseDataKeyData     @"data"
// 网络请求 返回数据 数据分页信息数据段key
#define kResponseDataKeyPageable @"pageable"


typedef void (^MyProgressBlock)(NSString *string);

NS_ASSUME_NONNULL_BEGIN

@interface BaseRequest : NSObject

@property (nonatomic, copy) MyProgressBlock myProgressBlock;
@property (nonatomic ,strong)NSMutableDictionary * urlDic;

+ (NSString *)MethodStringWithHttpMethod:(HTTPMethod)httpMethod;
// 请求  GET POST DELETE PUT .....
+ (RACSignal *)HTTPRequestWithHTTPMethod:(HTTPMethod)method UrlString:(NSString *)url params:(id)params;

// 上传文件
+ (RACSignal *)uploadFile:(NSURL *)fileUrl url:(NSString *)url;
//上传文件加参数
+ (RACSignal *)uploadFile:(NSURL *)fileUrl url:(NSString *)url params:(id)params;
+ (RACSignal *)uploadFile:(NSURL *)fileUrl url:(NSString *)url params:(id)params type:(NSString*)typeStr;

// 上传文件 + 进度
+ (RACSignal *)uploadFileWithProgress:(NSURL *)fileUrl url:(NSString *)url;

// 下载文件
+ (RACSignal *)downloadFileByUrl:(NSURL *)url toFilePath:(NSURL *)toFilePath;

+ (RACSignal *)getLocationFileName:(NSString *)fileName type:(NSString *)type;

+ (NSError *)getErrorOpertion:(NSURLSessionDataTask *)operation Error:(NSError *)error;

+ (NSError *)getErrorOpertion:(NSURLSessionDataTask *)operation :(id)response;

+ (void)dealTokenInvalid;
+ (RACSignal *)doRequestAndRefreshTokenIfNecessary:(RACSignal *)requestSignal;

+ (RACSignal *)refreshTokenVerifyCredentials;

@end

NS_ASSUME_NONNULL_END
