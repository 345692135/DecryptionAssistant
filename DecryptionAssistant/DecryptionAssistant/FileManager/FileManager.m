//
//  FileManager.m
//  SecretMail
//
//  Created by Granger on 2019/11/10.
//  Copyright © 2019 granger. All rights reserved.
//

#import "FileManager.h"
#import "DDYCompress.h"

static FileManager *fileManager;

@implementation FileManager

static NSArray* attachmentTypeArray = nil;

+ (FileManager *)shared {
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        fileManager = [[FileManager alloc]init];
        attachmentTypeArray = @[
            @"pdf",//pdf类型
            @"ics",//日历类型
            @"psd",//ps类型
            @"aep",//AE类型
//                                @"eml",//邮件类型
            @"pages",//苹果特有类型
            @"numbers",//苹果表格类型
            @"key",//苹果特有类型
            @[@"htm", @"html", @"shtml", @"stm", @"shtm", @"asp"],//html类型
            @[@"zip", @"rar", @"7z"],//压缩包类型
            @[@"doc", @"docx"],//文档类型
            @[@"ppt", @"pptx"],//ppt类型
            @[[@"XLS" lowercaseString], [@"XLSX" lowercaseString]],//表格类型
            @[@"txt", @"log", @"ini", @"lrc", @"rtf"],//文本类型
            @[@"swf", @"gif", @"avi", @"mov"],//flash类型
            @[@"jpg", @"jpeg", @"png", @"bmp", @"heic"],//图片类型
            @[@"mp3", @"wma", @"wav", @"ogg", @"ape", @"acc", @"amr"],//音乐类型
            @[@"mp4", @"wmv", @"mpeg", @"m4v", @"3gp", @"3gpp", @"3g2", @"3gpp2", @"asf"],//视频类型
            @"ai",//ai类型
            @"cdr"//coreldraw类型
            ];
    });
    return fileManager;
}

/// 删除文件
/// @param filePath filePath description
-(BOOL)deleteFileWithFilePath:(NSString*)filePath {
    BOOL isDelete = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath])
    {
        isDelete = [fileManager removeItemAtPath:filePath error:nil];
    }
    return isDelete;
}

/// 拷贝文件到目录
/// @param filePath filePath description
/// @param Dir Dir description
-(void)copyFile:(NSString*)filePath toDir:(NSString*)Dir {
    [self copyMissingFile:filePath toPath:Dir];
}

/**
 *    @brief    把Resource文件夹下的save1.dat拷贝到沙盒
 *
 *    @param     sourcePath     Resource文件路径
 *    @param     toPath     把文件拷贝到XXX文件夹
 *
 *    @return    BOOL
 */
- (BOOL)copyMissingFile:(NSString *)sourcePath toPath:(NSString *)toPath
{
    BOOL retVal = YES; // If the file already exists, we'll return success…
    NSString * finalLocation = [toPath stringByAppendingPathComponent:[sourcePath lastPathComponent]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:finalLocation])
    {
        retVal = [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:finalLocation error:NULL];
    }
    return retVal;
}

//递归读取解压路径下的所有.png文件 0329，0306，0404，0305
- (id)showAllFileWithPath:(NSString *) path {
    NSFileManager * fileManger = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExist = [fileManger fileExistsAtPath:path isDirectory:&isDir];
    if (isExist) {
        if (isDir) {
            NSArray * dirArray = [fileManger contentsOfDirectoryAtPath:path error:nil];
            return dirArray;
//            NSString * subPath = nil;
//            for (NSString * str in dirArray) {
//                subPath  = [path stringByAppendingPathComponent:str];
//                BOOL issubDir = NO;
//                [fileManger fileExistsAtPath:subPath isDirectory:&issubDir];
//                [self showAllFileWithPath:subPath];
//            }
        }else{
//            NSString *fileName = [[path componentsSeparatedByString:@"/"] lastObject];
//            if ([fileName hasSuffix:@".png"]) {
//                NSLog(@"%@", path);
//            }
            return path;
            
        }
    }else{
        NSLog(@"this path is not exist!");
        return nil;
    }
}

/// 获取最近打开目录所有文件
-(NSArray*)fileList {
    NSString *RecentOpenFile = [self recentOpenFilePath];
    NSFileManager *fileManager = [self createDir:RecentOpenFile];
    NSError *error = nil;
    NSArray *files = [fileManager contentsOfDirectoryAtPath:RecentOpenFile error:&error];
    if (files == nil) {
        files = [NSArray new];
    }
    return files;
    
}

-(NSString*)recentOpenFilePath {
    // 获得Documents目录路径
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    //账号路径
    NSString *accountPath = [documentsPath stringByAppendingPathComponent:@"RecentOpenFile"];
    return accountPath;
}

-(NSFileManager*)createDir:(NSString*)dirPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
    BOOL existed = [fileManager fileExistsAtPath:dirPath isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) ) {//如果文件夹不存在
        [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return fileManager;
    
}

-(NSString*)getLoadPathWithPath:(NSString*)path {
    NSString *loadPath = path;
    if ([path hasSuffix:@".rar"] || [path hasSuffix:@".zip"] || [path hasSuffix:@".7z"]) {
        if ([path hasSuffix:@".7z"]) {
            loadPath = [loadPath substringWithRange:NSMakeRange(0, loadPath.length-3)];
        }else {
            loadPath = [loadPath substringWithRange:NSMakeRange(0, loadPath.length-4)];
        }
    }
    return loadPath;
}

-(void)openFileWithPath:(NSString*)path password:(NSString*)password complete:(void (^)(NSArray *models))complete {
    WS(weakSelf);
    if ([path hasSuffix:@".rar"] || [path hasSuffix:@".zip"] || [path hasSuffix:@".7z"]) {
        NSString *loadPath = path;
        if ([path hasSuffix:@".7z"]) {
            loadPath = [loadPath substringWithRange:NSMakeRange(0, loadPath.length-3)];
        }else {
            loadPath = [loadPath substringWithRange:NSMakeRange(0, loadPath.length-4)];
        }
        
        [DDYCompress ddy_DecopressFile:path destinationPath:loadPath password:password complete:^(NSError *error, NSString *destPath) {
            if (error == nil) {
                [weakSelf openFileWithPath:destPath password:password complete:complete];
            }else {
                dispatch_async_on_main_queue(^{
                    [ToastManager showMsg:@"解压失败"];
                    complete(nil);
                });
            }
        }];

    }
    else {
        id value = [weakSelf showAllFileWithPath:path];
        DirectoryModel *model = [DirectoryModel new];
        model.filePath = path;
        model.fileName = [[path componentsSeparatedByString:@"/"] lastObject];
        if (value) {
            if ([value isKindOfClass:[NSString class]]) {
                //icon/filename/size
                model.fileSize = [self getFileSizeStringWithFileLength:[self fileSizeAtPath:model.filePath]];
                model.icon = @"safemail_Details_fujian0696";
                model.isDir = NO;
            }else if ([value isKindOfClass:[NSArray class]]) {
                NSArray *array = [NSArray arrayWithArray:value];
                //icon/foldername/filecount
                model.fileSize = array.count?[NSString stringWithFormat:@"%lu个文件", array.count]:@"";
                model.innerFilePaths = [NSArray arrayWithArray:array];
                model.icon = @"safemail_Details_fujian0596";
                model.isDir = YES;
            }
        }
        complete(@[model]);
    }

}

-(NSString*)getFileSizeStringWithFileLength:(CGFloat)fLength {
    //B
    if (fLength / 1024 < 1) {
         return [NSString stringWithFormat:@"%.0fB", fLength];
    }
    
    //KB
    fLength /= 1024;
    if (fLength / 1024 < 1) {
        return [NSString stringWithFormat:@"%.2fKB", fLength];
    }
    
    //MB
    fLength /= 1024;
    if (fLength / 1024 < 1) {
        return [NSString stringWithFormat:@"%.2fMB", fLength];
    }
    
    //GB
    fLength /= 1024;
    if (fLength / 1024 < 1) {
        return [NSString stringWithFormat:@"%.2fGB", fLength];
    }
    
    return nil;
}

- (long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        long long size = [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
        return size;
    }
    return 0;
}

- (long long) folderSizeAtPath:(NSString*) folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];//从前向后枚举器／／／／//
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
//        NSLog(@"fileName ==== %@",fileName);
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
//        NSLog(@"fileAbsolutePath ==== %@",fileAbsolutePath);
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
//    NSLog(@"folderSize ==== %lld",folderSize);
    return folderSize;
}

- (kAttachmentType)getAttachmentTypeWithPath:(NSString*)path
{
    NSString* extension = [path pathExtension];
    if (!extension || [extension isEqualToString:@""]) {
        return kcgAttachmentType_other;
    }
    extension = [extension lowercaseString];
    NSInteger count = attachmentTypeArray.count;
    
    kAttachmentType attachmentType = kcgAttachmentType_other;
    for (int i = 0; i < count; i++) {
        id object = attachmentTypeArray[i];
        if ([object isKindOfClass:[NSString class]]) {
            if ([extension isEqualToString:object]) {
                attachmentType = i + 1;
                break;
            }
        }
        else {
            for (NSString* str in object) {
                if ([extension isEqualToString:str]) {
                    attachmentType = i + 1;
                    break;
                }
            }
        }
    }
    return attachmentType;
}

@end
