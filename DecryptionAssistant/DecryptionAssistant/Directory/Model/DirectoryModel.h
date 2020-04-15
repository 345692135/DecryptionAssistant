//
//  DirectoryModel.h
//  SecretMail
//
//  Created by Granger on 2020/3/23.
//  Copyright © 2020 granger. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DirectoryModel : BaseModel

@property (nonatomic, copy) NSString * icon;
@property (nonatomic, copy) NSString * fileName;
@property (nonatomic, copy) NSString * filePath;
@property (nonatomic, assign) BOOL isDir;
@property (nonatomic, copy) NSString * fileSize;//如果是文件夹，就是文件数。如果是文件，就是文件大小
@property (nonatomic, copy) NSArray * innerFilePaths;

@end

NS_ASSUME_NONNULL_END
