//
//  NSString+Validation.m
//  SecretMail
//
//  Created by Granger on 2019/11/19.
//  Copyright © 2019 granger. All rights reserved.
//

#import "NSString+Validation.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Validation)

// 判断邮箱是否合法

- (BOOL)validateEmail {
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailRegex];
    return [emailTest evaluateWithObject:self];
    
//
//    NSString *emailTypeRegex   = @".*(163.com|126.com|yeah.net)$";
//    NSPredicate *emailTypeTest = [NSPredicate predicateWithFormat :@"SELF MATCHES %@", emailTypeRegex];
//    // 针对特殊的邮箱做特殊的判断
//    /*
//     * 163.com、126.com、yeah.net
//     * 开头为字母，不算后缀，长度为6-18
//     */
//    NSString *emailTypeRegexQQ   = @".*(qq.com)$";
//    NSPredicate *emailTypeTestQQ = [NSPredicate predicateWithFormat :@"SELF MATCHES %@", emailTypeRegexQQ];
//
//    if ([emailTypeTest evaluateWithObject :self]) {
//        // 163.com、126.com、yeah.net
//        NSString *emailRegex1   = @"[A-Za-z][A-Z0-9a-z._%+-]{5,17}+@(163.com|126.com|yeah.net)";
//        NSPredicate *emailTest1 = [NSPredicate predicateWithFormat :@"SELF MATCHES %@", emailRegex1];
//        return ![emailTest1 evaluateWithObject :self];
//
//    } else if([emailTypeTestQQ evaluateWithObject :self]) {
//        // QQ
//        NSString *emailRegexQQ   = @"[1-9]d{7,10}@qq.com";
//        NSPredicate *emailTestQQ = [NSPredicate predicateWithFormat :@"SELF MATCHES %@", emailRegexQQ];
//        NSPredicate *emailTest2 = [NSPredicate predicateWithFormat :@"SELF MATCHES '.*(_|-|\\\\.){2,}.*'"];
//        if ([emailTest2 evaluateWithObject:self]) {
//            return true;
//        }
//        return ![emailTestQQ evaluateWithObject :self];
//    }else{
//
//        NSString *emailRegex   = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
//        NSPredicate *emailTest = [NSPredicate predicateWithFormat :@"SELF MATCHES %@", emailRegex];
//        return ![emailTest evaluateWithObject :self];
//
//    }
}

- (BOOL)validateNumberAndCharacter{
    // 大写字母小写字母 特殊符号至少包含两种
    // NSString *numcharRegex = @"^(?![\\d]+$)(?![a-zA-Z]+$)(?![^\\da-zA-Z]+$).{6,20}$";
    NSString *numcharRegex = @"^(?![A-Z]*$)(?![a-z]*$)(?![0-9]*$)(?![^a-zA-Z0-9]*$)\\S{6,20}$";
    // 上面的正则里所说的特殊字符是除了数字，字母之外的所有字符如果要限定特殊字符
    // 例如，特殊字符的范围为 !#$%^&*
    // 那么可以这么改^(?![\d]+$)(?![a-zA-Z]+$)(?![!#$%^&*]+$)[\da-zA-Z!#$%^&*]{6,20}$
    NSPredicate *numcharTest = [NSPredicate predicateWithFormat :@"SELF MATCHES %@", numcharRegex];
    return [numcharTest evaluateWithObject :self];
}


- (BOOL)validatePassword{
    if ([self validateNumberAndCharacter] && self.length < 21 && self.length > 1) {
        return YES;
    }
    return NO;
}

- (BOOL)validateNicknameRule{
    NSString *regex = @"^[a-zA-Z0-9\u4e00-\u9fa5]+$";
//    NSString *regex = @"^(?![\\u4e00-\\u9fa5]*$)(?![A-Z]*$)(?![a-z]*$)(?![0-9]*$)(?![^a-zA-Z0-9\\u4e00-\\u9fa5]*$)\\S{1,19}$";
    NSPredicate *nicknameTest = [NSPredicate predicateWithFormat :@"SELF MATCHES %@", regex];
    return [nicknameTest evaluateWithObject :self];
}
- (BOOL)validateName{
    NSString *regex = @"^[a-zA-Z\u4e00-\u9fa5]{1,20}+$";
    NSPredicate *nicknameTest = [NSPredicate predicateWithFormat :@"SELF MATCHES %@", regex];
    return [nicknameTest evaluateWithObject :self];
}

- (BOOL)validateNickname{
    if ([self validateNicknameRule] && self.length < 21 && self.length > 1) {
        return YES;
    }
    return NO;
}


- (NSUInteger)realLenghtIncludeCN{
    NSUInteger len = self.length;
    NSString * pattern  = @"[\u4e00-\u9fa5\u3000-\u301e\ufe10-\ufe19\ufe30-\ufe44\ufe50-\ufe6b\uff01-\uffee]";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSInteger numMatch = [regex numberOfMatchesInString:self options:NSMatchingReportProgress range:NSMakeRange(0, len)];
    return len + numMatch;
}


/*
 手机号码 13[0-9],14[5|7|9],15[0-3],15[5-9],17[0|1|3|5|6|8],18[0-9]
 移动：134[0-8],13[5-9],147,15[0-2],15[7-9],178,18[2-4],18[7-8]
 联通：13[0-2],145,15[5-6],17[5-6],18[5-6]
 电信：133,1349,149,153,173,177,180,181,189
 虚拟运营商: 170[0-2]电信  170[3|5|6]移动 170[4|7|8|9],171 联通
 上网卡又称数据卡，14号段为上网卡专属号段，中国联通上网卡号段为145，中国移动上网卡号段为147，中国电信上网卡号段为149
 */

- (BOOL)validatePhone {
    
    // 1开头  11位
    NSString * MOBIL = @"^[1][0-9]{10}$";
    //NSString * MOBIL = @"^1(3[0-9]|4[579]|5[0-35-9]|7[0135678]|8[0-9])\\d{8}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBIL];
    if ([regextestmobile evaluateWithObject :self] == YES) {
        return YES;
    }else{
        return NO;
    }
}


/**
 * 中国移动：China Mobile
 * 134[0-8],13[5-9],147,15[0-2],15[7-9],170[3|5|6],178,18[2-4],18[7-8]
 */
-(BOOL)isCMMobilePhone{
    NSString * CM = @"^1(34[0-8]|70[356]|(3[5-9]|4[7]|5[0-27-9]|7[8]|8[2-47-8])\\d)\\d{7}$";
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    if ([regextestcm evaluateWithObject:self]) {
        return YES;
    }
    return NO;
}

/**
 * 中国联通：China Unicom
 * 13[0-2],145,15[5-6],17[5-6],18[5-6],170[4|7|8|9],171
 */
-(BOOL)isCUMobilePhone
{
    NSString * CU = @"^1(70[07-9]|(3[0-2]|4[5]|5[5-6]|7[15-6]|8[5-6])\\d)\\d{7}$";
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    if ([regextestcu evaluateWithObject:self]) {
        return YES;
    }
    return NO;
}



/**
 * 中国电信：China Telecom
 * 133,1349,149,153,173,177,180,181,189,170[0-2]
 */
- (BOOL)isCTMobilePhone{
    NSString * CT = @"^1(34[9]|70[0-2]|(3[3]|4[9]|5[3]|7[37]|8[019])\\d)\\d{7}$";
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    if ([regextestct evaluateWithObject:self]) {
        return YES;
    }
    return NO;
}

// 判断是否是网站
- (BOOL)validateWebsite {
    NSString * websiteRegex   = @"(http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?";
    NSPredicate *numcharTest = [NSPredicate predicateWithFormat :@"SELF MATCHES %@", websiteRegex];
    
    return [numcharTest evaluateWithObject :self];
}

- (BOOL)isChinese
{
    NSString *match = @"(^[\u4e00-\u9fa5]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:self];
}

// 验证是否有中文
- (BOOL)validateIsContainChinese {
    NSString * websiteRegex   = @".*[\\u4e00-\\u9faf].*";
    NSPredicate *numcharTest = [NSPredicate predicateWithFormat :@"SELF MATCHES %@", websiteRegex];
    
    return [numcharTest evaluateWithObject :self];
}

// 验证是否是车牌
- (BOOL)validateCarNum {
    NSString * regex   = @"^[京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼使领]{1}[A-Z]{1}[A-Z0-9]{4}[A-Z0-9挂学警港澳]{1}$";
    NSPredicate *numcharTest = [NSPredicate predicateWithFormat :@"SELF MATCHES %@", regex];
    return [numcharTest evaluateWithObject :self];
}


+ (NSString *)md5:(NSString *)source {
    const char *str = [source UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(str, (CC_LONG)strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%2s", result];
    }
    
    return ret;
}

+ (NSString *)sha1:(NSString *)source {
    const char *cstr = [source cStringUsingEncoding:NSUTF8StringEncoding];
    
    NSData *data = [NSData dataWithBytes:cstr length:source.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}
+ (NSString *)getHexByDecimal:(NSInteger)decimal {
    
    NSString *hex =@"";
    NSString *letter;
    NSInteger number;
    for (int i = 0; i<9; i++) {
        
        number = decimal % 16;
        decimal = decimal / 16;
        switch (number) {
                
            case 10:
                letter =@"A"; break;
            case 11:
                letter =@"B"; break;
            case 12:
                letter =@"C"; break;
            case 13:
                letter =@"D"; break;
            case 14:
                letter =@"E"; break;
            case 15:
                letter =@"F"; break;
            default:
                letter = [NSString stringWithFormat:@"%ld", number];
        }
        hex = [letter stringByAppendingString:hex];
        if (decimal == 0) {
            
            break;
        }
    }
    return hex;
}

- (NSAttributedString*)attributeStringByHtmlString:(NSString*)htmlString {
    NSAttributedString*attributeString;
    NSData *htmlData = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *importParams = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                   NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]
                                   };
    NSError*error =nil;
    attributeString = [[NSAttributedString alloc]initWithData:htmlData options:importParams documentAttributes:NULL error:&error];

    return attributeString;

}


@end
