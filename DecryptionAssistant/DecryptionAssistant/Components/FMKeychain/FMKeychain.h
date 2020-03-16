//
//  Keychain.h
//  SecretMail
//
//  Created by Granger on 2019/11/19.
//  Copyright © 2019 granger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMKeychain : NSObject

/**
 * 获取设备唯一标识符
 */
+ (NSString *)deviceID;

@end

