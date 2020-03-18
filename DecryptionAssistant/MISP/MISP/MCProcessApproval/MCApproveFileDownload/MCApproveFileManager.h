//
//  MCApproveFileManager.h
//  MISP
//
//  Created by TanGuoLian on 17/6/10.
//  Copyright © 2017年 wondersoft. All rights reserved.
//

#import "MISP.h"
#import "WSBaseObject.h"
#import "MCApproveFileModel.h"        //获取返回数据模型
#import "MCApproveTCPParamProvider.h" //获取请求类型枚举值

@class MCApprovalModel;

//审批流程文件下载管理类
@interface MCApproveFileManager : WSBaseObject

/**
 * 获取当前用户的sid
 */
- (NSString *)getActiveAccountSid;

/**
 * 流程审批文件下载接口
 * @param dictionary  json转dictionary时的请求串
 * @param fileLength  文件长度
 * @param filePath    文件本地保存路径
 * @param requestType 请求类型
 * @return block回调
 */
- (void)requestProcessApprovalFileFromServer:(NSDictionary *)dictionary
                                  fileLength:(long long)fileLength
                                    filePath:(NSString *)filePath
                                 requestType:(RequestType)RequestType
                             completionBlock:(void(^)(long xmlCode,MCApproveFileModel *approvalFileModel))completionBlock;

@end
