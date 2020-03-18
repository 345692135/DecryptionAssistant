//
//  BaseViewModel.h
//  DecryptionAssistant
//
//  Created by Granger on 2019/10/27.
//  Copyright © 2019 granger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewModel : BaseRequest

@property (nonatomic, strong) UIImage* adImage;

/// 登录请求
/// @param model model description
/// @param success success description
/// @param failure failure description
//-(void)loginRequestByLoginModel:(LoginModel*)model success:(void (^)(BOOL isSuccess))success failure:(void (^)(NSError * error))failure;

-(void)decryptionFileWithFilePath:(NSString*)filePath;

@end

NS_ASSUME_NONNULL_END
