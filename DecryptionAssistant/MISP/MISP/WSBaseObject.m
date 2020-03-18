//
//  WSBaseObject.m
//  MISP
//
//  Created by li yang on 12-7-19.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import "WSBaseObject.h"

@implementation WSBaseObject

- (long)makeError:(NSError**)err domain:(NSString*)describe errCode:(NSInteger)code
{
    if (err != nil) {
        *err = [NSError errorWithDomain:describe code:code userInfo:nil];
    }
    return 0;
}

@end
