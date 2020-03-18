//
//  FileUtil.m
//  DecryptDemo
//
//  Created by 刘立业 on 2019/5/27.
//  Copyright © 2019 刘立业. All rights reserved.
//

#import "FileUtil.h"

@implementation FileUtil

+ (NSString *)saveFileToLocal:(NSData *)data fileName:(NSString *)fileName
{
    NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *fileDir = [documentDir stringByAppendingPathComponent:@"download"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileDir])
    {
        BOOL ret = [[NSFileManager defaultManager] createDirectoryAtPath:fileDir withIntermediateDirectories:YES attributes:nil error:nil];
        if (!ret)
        {
            NSLog(@"文件目录创建失败");
            return nil;
        }
    }
    
    NSString *filePath = [fileDir stringByAppendingPathComponent:fileName];
    
    //写入文件
    BOOL ret = [data writeToFile:filePath atomically:YES];
    
    if (!ret)
    {
        NSLog(@"文件写入失败");
        return nil;
    }
    
    return filePath;
}

@end
