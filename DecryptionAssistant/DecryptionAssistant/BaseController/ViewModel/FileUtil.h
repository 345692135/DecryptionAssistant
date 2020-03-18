//
//  FileUtil.h
//  DecryptDemo
//
//  Created by 刘立业 on 2019/5/27.
//  Copyright © 2019 刘立业. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FileUtil : NSObject

+ (NSString *)saveFileToLocal:(NSData *)data fileName:(NSString *)fileName;

@end

NS_ASSUME_NONNULL_END
