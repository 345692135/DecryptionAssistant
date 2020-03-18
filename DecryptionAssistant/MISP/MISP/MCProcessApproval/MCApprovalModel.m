//
//  MCApprovalModel.m
//  MISP
//
//  Created by TanGuoLian on 17/5/16.
//  Copyright © 2017年 wondersoft. All rights reserved.
//

#import "MCApprovalModel.h"

@implementation MCApprovalModel

+ (MCApprovalModel *)initWithObject:(NSString *)moudleId
                             opCode:(NSString *)opCode
                            xmlCode:(long)xmlCode
                      errorDescribe:(NSString *)errorDescribe
                               sign:(NSString *)sign
                           jsonDict:(NSDictionary *)dict
{
    MCApprovalModel *model = [[[self class] alloc] init];
    
    model.moudleId     = moudleId;
    model.opCode       = opCode;
    model.xmlCode      = xmlCode;
    model.errorDecribe = errorDescribe;
    model.sign         = sign;
    model.dict         = dict;
    
    return model;
}

@end
