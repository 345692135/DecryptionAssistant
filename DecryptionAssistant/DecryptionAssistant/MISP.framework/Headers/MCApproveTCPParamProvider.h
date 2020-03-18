//
//  MCApproveTCPParamProvider.h
//  MISP
//
//  Created by TanGuoLian on 17/5/16.
//  Copyright © 2017年 wondersoft. All rights reserved.
//

typedef NS_ENUM(NSInteger,RequestType)
{
    Type_IsHaveNew = 0,              //我的申请/待办列表信息是否存在未读
    Type_ApplyList,                  //我的申请列表
    Type_UnFinishedList,             //我的待办列表
    Type_FinishedList,               //我的已办列表
    Type_ApplyUpdateUnRead,          //我的申请查看状态变更
    Type_UnFinishedUpdateUnRead,     //我的待办查看状态变更
    Type_HandleUnFinished,           //审批我的待办信息
    Type_Revork,                     //撤销审批请求
    Type_Delete,                     //删除审批请求
    Type_ProcessApplyHistory,        //我的申请审批流程查询
    Type_ProcessUnFinishedHistory,   //我的待办审批流程查询
    Type_ProcessFinishedHistory,     //我的已办审批流程查询
    Type_DownloadAtt,                //审批附件下载
    Type_CustomProcessGroupMember,   //获取自定义审批组包含的用户信息
};

#import <Foundation/Foundation.h>
#import "MCApprovalCodeMarco.h"
#import "SystemCommand.h"

//TCP请求参数生成器
@interface MCApproveTCPParamProvider : NSObject

/**
 * 构建TCP请求参数
 * @param  paramType 请求类型
 * @param  jsonString 携带的json字符串
 * @return 请求参数
 */
+ (SystemCommand *)buildParamForTCPRequest:(RequestType)RequestType jsonString:(NSString *)jsonString;

/**
 * 构建审批附件下载时的TCP请求参数
 * @param  paramType  请求类型
 * @param  fileSize   文件大小
 * @param  jsonString 携带的json字符串
 * @return 请求参数
 */
+ (SystemCommand *)buildFileDownloadParamForTCPRequest:(RequestType)RequestType
                                              fileSize:(NSString *)fileSize
                                            jsonString:(NSString *)jsonString;

@end
