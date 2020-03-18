//
//  MCApproveFileModel.m
//  MISP
//
//  Created by TanGuoLian on 17/6/13.
//  Copyright © 2017年 wondersoft. All rights reserved.
//

#import "MCApproveFileModel.h"

@implementation MCApproveFileModel

+ (MCApproveFileModel *)initWithObject:(NSString *)moudleId
                                opCode:(NSString *)opCode
                               xmlCode:(long)xmlCode
                         errorDescribe:(NSString *)errorDescribe
                                  sign:(NSString *)sign
                              filePath:(NSString *)filePath
{
    MCApproveFileModel *model = [[[MCApproveFileModel class] alloc] init];
    
    model.moudleId     = moudleId;
    model.opCode       = opCode;
    model.xmlCode      = xmlCode;
    model.errorDecribe = errorDescribe;
    model.sign         = sign;
    model.filePath     = filePath;
    
    return model;
}

@end
