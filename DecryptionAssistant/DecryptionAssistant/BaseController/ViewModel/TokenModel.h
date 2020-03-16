//
//  TokenModel.h
//  SecretMail
//
//  Created by Granger on 2019/11/19.
//  Copyright © 2019 granger. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TokenModel : NSObject

@property(nonatomic, copy) NSString *accessToken;
@property(nonatomic, copy) NSString *refreshToken;
@property(nonatomic, copy) NSString *accessTokenExprTime;
@property(nonatomic, copy) NSString *refreshTokenExprTime;
@property(nonatomic, copy) NSString *accessTokenForWeb;
@property(nonatomic, copy) NSString *accessTokenForWebExprTime;

@end

NS_ASSUME_NONNULL_END
