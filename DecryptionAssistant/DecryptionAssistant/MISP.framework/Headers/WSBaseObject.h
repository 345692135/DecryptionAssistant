//
//  WSBaseObject.h
//  MISP
//
//  Created by li yang on 12-7-19.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSBaseObject : NSObject

- (long)makeError:(NSError**)err domain:(NSString*)describe errCode:(NSInteger)code;

@end
