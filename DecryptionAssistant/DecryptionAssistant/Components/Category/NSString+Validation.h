//
//  NSString+Validation.h
//  SecretMail
//
//  Created by Granger on 2019/11/19.
//  Copyright © 2019 granger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Validation)

- (BOOL)validateEmail;

- (BOOL)validatePhone;

- (BOOL)validateNumberAndCharacter;

- (BOOL)validatePassword;

- (BOOL)validateWebsite;

- (BOOL)validateIsContainChinese;
- (BOOL)validateNickname;

+ (NSString *)md5 :(NSString *)source; // md5

+ (NSString *)sha1 :(NSString *)source; // sha1
// 验证是否是车牌
- (BOOL)validateCarNum;
- (BOOL)isChinese;//判断是否是纯汉字
- (BOOL)validateName;//判定是否是姓名

- (NSAttributedString*)attributeStringByHtmlString:(NSString*)htmlString;

@end
