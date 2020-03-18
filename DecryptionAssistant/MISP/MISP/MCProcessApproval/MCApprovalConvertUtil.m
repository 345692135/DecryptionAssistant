//
//  MCApprovalConvertUtil.m
//  MISP
//
//  Created by TanGuoLian on 17/5/16.
//  Copyright © 2017年 wondersoft. All rights reserved.
//

#import "MCApprovalConvertUtil.h"

@implementation MCApprovalConvertUtil

+ (NSString *)dictionaryToJSON:(NSDictionary *)dict
{
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:nil error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (NSDictionary *)jsonToDictionary:(NSString *)jsonString
{
    if (!jsonString)
    {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *err;
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    
    return dict;
}

@end
