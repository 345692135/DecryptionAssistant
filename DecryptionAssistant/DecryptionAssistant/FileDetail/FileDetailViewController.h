//
//  FileDetailViewController.h
//  DecryptionAssistant
//
//  Created by Granger on 2020/4/15.
//  Copyright © 2020 sain. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FileDetailViewController : BaseViewController

-(instancetype)initWithMessage:(NSString*)message title:(NSString*)title isRecentOpenFile:(BOOL)isRecentOpenFile;
-(instancetype)initWithFilePath:(NSString*)filePath originalFilePath:(NSString*)originalFilePath title:(NSString*)title isRecentOpenFile:(BOOL)isRecentOpenFile;

@end

NS_ASSUME_NONNULL_END
