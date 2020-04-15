//
//  FileManager.h
//  SecretMail
//
//  Created by Granger on 2019/11/10.
//  Copyright © 2019 granger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DirectoryModel.h"

typedef enum : NSUInteger {
    kcgAttachmentType_other,//其他类型0
    kcgAttachmentType_pdf,//pdf类型1
    kcgAttachmentType_ics,//日历类型2
    kcgAttachmentType_photoshop,//ps类型3
    kcgAttachmentType_ae,//AE类型4
//    kcgAttachmentType_email,//邮件类型4
    kcgAttachmentType_pages,//苹果特有类型5
    kcgAttachmentType_numbers,//苹果表格类型6
    kcgAttachmentType_keynote,//苹果特有类型7
    kcgAttachmentType_html,//html类型8
    kcgAttachmentType_zip,//压缩包类型9
    kcgAttachmentType_doc,//文档类型10
    kcgAttachmentType_ppt,//ppt类型11
    kcgAttachmentType_xsl,//表格类型12
    kcgAttachmentType_txt,//文本类型13
    kcgAttachmentType_flash,//flash类型14
    kcgAttachmentType_picture,//图片类型15
    kcgAttachmentType_music,//音乐类型16
    kcgAttachmentType_video,//视频类型17
    kcgAttachmentType_ai,//ai类型18
    kcgAttachmentType_cdr//coreldraw类型19
} kAttachmentType;

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
- (kAttachmentType)getAttachmentTypeWithPath:(NSString*)path;

@end

NS_ASSUME_NONNULL_END
