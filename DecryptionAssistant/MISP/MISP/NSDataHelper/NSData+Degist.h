//
//  NSData+Degist.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-8-13.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Degist)

- (NSString*)md5;

- (NSData*)MD5WithBytes;

- (NSString*)sha1;

@end
