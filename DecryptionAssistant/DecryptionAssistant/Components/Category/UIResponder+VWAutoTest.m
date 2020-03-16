//
//  UIResponder+VWAutoTest.m
//  SecretMail
//
//  Created by Granger on 2019/11/19.
//  Copyright © 2019 granger. All rights reserved.
//

#import "UIResponder+VWAutoTest.h"

@implementation UIResponder (VWAutoTest)

- (NSString *)nameWithInstance:(id)instance {
    
    unsigned int numIvars = 0;
    NSString *key = nil;
    Ivar *ivars = class_copyIvarList([self class], &numIvars);
    for(int i = 0; i < numIvars; i++) {
        Ivar thisIvar = ivars[i];
        const char *type = ivar_getTypeEncoding(thisIvar);
        NSString *stringType =  [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
        if (![stringType hasPrefix:@"@"]) continue;
        if ((object_getIvar(self, thisIvar) == instance)) {
            key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
            break;
        }
    }
    free(ivars);
    return key;
}

- (NSString *)findNameWithInstance:(UIView *)instance {
    
    id nextResponder = [self nextResponder];
    NSString *name = [self nameWithInstance:instance];
    if (!name) {
        return [nextResponder findNameWithInstance:instance];
    }
    // 去掉变量名的下划线前缀
    if ([name hasPrefix:@"_"]) {
        name = [name substringFromIndex:1];
    }
    return name;
}

@end






