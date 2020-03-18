//
//  NSData+HMACMD5.h
//  MISP
//
//  Created by iBlock on 13-12-2.
//
//

#import <Foundation/Foundation.h>

@interface NSData (HMACMD5)

-(NSData *)MD5HMACWithKey:(NSString*)key;

@end
