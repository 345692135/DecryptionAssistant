//
//  MCApprovalManager.h
//  MISP
//
//  Created by TanGuoLian on 17/5/16.
//  Copyright © 2017年 wondersoft. All rights reserved.
//

#import "MISP.h"
#import "WSBaseObject.h"
#import "MCApprovalModel.h"           //获取返回数据模型
#import "MCApproveTCPParamProvider.h" //获取请求类型枚举值

@class MCApprovalModel;

@interface MCApprovalManager : WSBaseObject

/**
 * 获取当前用户的sid
 */
- (NSString *)getActiveAccountSid;

/**
 * 流程审批数据请求整体入口
 * @param dictionary json转dictionary时的请求串
 * @return block回调
 */
- (void)requestProcessApprovalDataFromServer:(NSDictionary *)dictionary
                                 requestType:(RequestType)RequestType
                             completionBlock:(void(^)(long xmlCode,MCApprovalModel *approvalModel))completionBlock;

@end
