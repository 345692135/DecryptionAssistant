//
//  MCApprovalConvertUtil.h
//  MISP
//
//  Created by TanGuoLian on 17/5/16.
//  Copyright © 2017年 wondersoft. All rights reserved.
//

#import <Foundation/Foundation.h>

//转换器
@interface MCApprovalConvertUtil : NSObject

/**
 * 字典转json串
 * @param  dict 字典
 * @return json串
 */
+ (NSString *)dictionaryToJSON:(NSDictionary *)dict;

/**
 * json串转字典
 * @param  jsonString json串
 * @return 字典
 */
+ (NSDictionary *)jsonToDictionary:(NSString *)jsonString;

@end
