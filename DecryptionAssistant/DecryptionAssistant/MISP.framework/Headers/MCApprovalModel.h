//
//  MCApprovalModel.h
//  MISP
//
//  Created by TanGuoLian on 17/5/16.
//  Copyright © 2017年 wondersoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCApprovalConvertUtil.h"

//TCP返回结果 数据模型
@interface MCApprovalModel : NSObject

//模块ID
@property (nonatomic,strong) NSString *moudleId;

//操作码
@property (nonatomic,strong) NSString *opCode;

//结果码
@property (nonatomic,assign) long xmlCode;

//错误描述
@property (nonatomic,strong) NSString *errorDecribe;

//签名值
@property (nonatomic,strong) NSString *sign;

//json串(JAVA)
@property (nonatomic,strong) NSDictionary *dict;

+ (MCApprovalModel *)initWithObject:(NSString *)moudleId
                             opCode:(NSString *)opCode
                               xmlCode:(long)xmlCode
                      errorDescribe:(NSString *)errorDescribe
                               sign:(NSString *)sign
                           jsonDict:(NSDictionary *)dict;

@end
