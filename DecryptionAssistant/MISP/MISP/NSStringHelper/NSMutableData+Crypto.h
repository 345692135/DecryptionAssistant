//
//  NSMutableData+Crypto.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-12-7.
//
//

#import <Foundation/Foundation.h>

@interface NSMutableData (Crypto)

- (BOOL)encryptWriteToFile:(NSString *)path level:(NSString*)levelId;

+ (id)dataWithEncryptContentsOfFile:(NSString *)path;

+ (BOOL)isEncryptFile:(NSString*)path;

@end
