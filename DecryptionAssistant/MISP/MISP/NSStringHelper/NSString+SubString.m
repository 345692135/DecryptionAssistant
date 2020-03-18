//
//  NSString+SubString.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-8-24.
//
//

#import "NSString+SubString.h"

@implementation NSString (SubString)

- (NSString*)subStringFromString:(NSString*)from to:(NSString*)to
{
    if ([from length] == 0 || [to length] == 0) {
        return nil;
    }
    NSRange range0 = [self rangeOfString:from];
    NSRange range1 = [self rangeOfString:to];
    
    if (range0.length == 0 || range1.length ==0) {
        return nil;
    }
    
    NSRange range;
    range.length = range1.location+range1.length - range0.location;
    range.location = range0.location;
    return [self substringWithRange:range];
}


@end
