//
//  FileManager.h
//  SecretMail
//
//  Created by Granger on 2019/11/10.
//  Copyright © 2019 granger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DirectoryModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FileManager : NSObject

+ (FileManager *)shared;

/// 拷贝文件到目录
/// @param filePath filePath description
/// @param Dir Dir description
-(void)copyFile:(NSString*)filePath toDir:(NSString*)Dir;

//递归读取解压路径下的所有.png文件
- (id)showAllFileWithPath:(NSString *) path;

/// 获取最近打开目录所有文件
-(NSArray*)fileList;
-(NSString*)accountPath;
-(NSString*)getUploadDirPathWithUidDir:(NSString*)uid;
-(NSFileManager*)createDir:(NSString*)dirPath;
-(NSString*)getLoadPathWithPath:(NSString*)path;
-(void)openFileWithPath:(NSString*)path password:(NSString*)password complete:(void (^)(NSArray *models))complete;
-(NSString*)getFileSizeStringWithFileLength:(CGFloat)fLength;
- (long long) folderSizeAtPath:(NSString*) folderPath;

@end

NS_ASSUME_NONNULL_END
