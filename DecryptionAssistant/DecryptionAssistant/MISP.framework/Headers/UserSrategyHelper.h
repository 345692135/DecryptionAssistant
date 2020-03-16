//
//  UserSrategyHelper.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-12-7.
//
//

#import "WSBaseObject.h"

@interface UserSrategyHelper : WSBaseObject

+ (BOOL)lockScreen;
+ (BOOL)permissionOffline;
+ (void)clearAllContentsOfPath:(NSString *)path;//清除某文件夹下所有文件和目录数据

@end
