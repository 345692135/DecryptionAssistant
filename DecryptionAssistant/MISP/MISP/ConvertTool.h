//
//  ConvertTool.h
//  MISP
//
//  Created by wondersoft on 16/6/14.
//  Copyright © 2016年 wondersoft. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface ConvertTool : NSObject

+ (unichar *)NstringtoUnistr:(NSString *)nsString;
+ (unichar *)contentStringToUnistr:(NSString *)nsString;
+ (NSString *)convertHexStringToString:(NSString *)strHexString;
+ (NSString *)convertStringToHexString:(NSString *)strString;
+ (NSString *)changeISO88591StringToUnicodeString:(NSString *)iso88591String;
+ (NSString *) utf8ToUnicode:(NSString *)string;
+ (NSString*) replaceUnicode:(NSString*)aUnicodeString;

@end


