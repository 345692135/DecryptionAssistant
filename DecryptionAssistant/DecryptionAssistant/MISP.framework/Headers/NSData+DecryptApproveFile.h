//
//  NSData+DecryptApproveFile.h
//  MISP
//
//  Created by TanGuoLian on 17/6/8.
//  Copyright © 2017年 wondersoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSMutableData+Crypto.h"

//解密流程审批附件
@interface NSData (DecryptApproveFile)

//文件是否已经解密成功 NO:成功 YES:失败
- (BOOL)isEncryptNewApproveFileData;

//解密对应路径的密文
+ (id)dataWithEncryptContentsOfNewApproveFile:(NSString *)filePath;

@end
