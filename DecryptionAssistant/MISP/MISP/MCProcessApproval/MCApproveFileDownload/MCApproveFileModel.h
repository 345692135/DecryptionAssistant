//
//  MCApproveFileModel.h
//  MISP
//
//  Created by TanGuoLian on 17/6/13.
//  Copyright © 2017年 wondersoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCApprovalConvertUtil.h"

//审批附件下载 数据模型
@interface MCApproveFileModel : NSObject

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

//filestream本地保存路径
@property (nonatomic,strong) NSString *filePath;

+ (MCApproveFileModel *)initWithObject:(NSString *)moudleId
                                opCode:(NSString *)opCode
                               xmlCode:(long)xmlCode
                         errorDescribe:(NSString *)errorDescribe
                                  sign:(NSString *)sign
                              filePath:(NSString *)filePath;

@end
