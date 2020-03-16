//
//  UIView+VWAutoTest.m
//  SecretMail
//
//  Created by Granger on 2019/11/19.
//  Copyright © 2019 granger. All rights reserved.
//

#import "UIView+VWAutoTest.h"
#import "UIResponder+VWAutoTest.h"

@implementation UIView (VWAutoTest)

/**
 * 是否hook accessibilityIdentifier方法
 * 用于添加自动化测试标签
 */
BOOL isHookAccessibilityIdentifier = YES;

+ (void)load {
    
    if (NO == isHookAccessibilityIdentifier) return;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleSelector:@selector(accessibilityIdentifier) withAnotherSelector:@selector(vw_accessibilityIdentifier)];
        [self swizzleSelector:@selector(accessibilityLabel) withAnotherSelector:@selector(vw_accessibilityLabel)];
    });
}

+ (void)swizzleSelector:(SEL)originalSelector withAnotherSelector:(SEL)swizzledSelector {
    
    Class aClass = [self class];
    
    Method originalMethod = class_getInstanceMethod(aClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(aClass, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(aClass,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(aClass,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    }else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

#pragma mark - Method Swizzling

- (NSString *)vw_accessibilityIdentifier {
    
    NSString *accessibilityIdentifier = [self vw_accessibilityIdentifier];
    if (accessibilityIdentifier.length > 0 && [[accessibilityIdentifier substringToIndex:1] isEqualToString:@"("]) {
        return accessibilityIdentifier;
    }else if ([accessibilityIdentifier isEqualToString:@"null"]) {
        accessibilityIdentifier = @"";
    }
    
    NSString *labelStr = [self.superview findNameWithInstance:self];
    
    if (labelStr && ![labelStr isEqualToString:@""]) {
        labelStr = [NSString stringWithFormat:@"(%@)", labelStr];
    }else {
        // UILabel 使用 text
        if ([self isKindOfClass:[UILabel class]]) {
            labelStr = [NSString stringWithFormat:@"(%@)", ((UILabel *)self).text ?: @""];
        }
        // UIImageView 使用 image 的 imageName
        else if ([self isKindOfClass:[UIImageView class]]) {
            labelStr = [NSString stringWithFormat:@"(%@)", ((UIImageView *)self).image.accessibilityIdentifier ?: [NSString stringWithFormat:@"image%ld", (long)((UIImageView *)self).tag]];
        }
        // UIButton 使用 button 的 text 和 image
        else if ([self isKindOfClass:[UIButton class]]) {
            labelStr = [NSString stringWithFormat:@"(%@%@)", ((UIButton *)self).titleLabel.text ?: @"", ((UIButton *)self).imageView.image.accessibilityIdentifier ?: @""];
        }
        // 已有 label，则在此基础上再次添加更多信息
        else if (accessibilityIdentifier) {
            labelStr = [NSString stringWithFormat:@"(%@)", accessibilityIdentifier];
        }
        if ([self isKindOfClass:[UIButton class]]) {
            self.accessibilityValue = [NSString stringWithFormat:@"(%@)", ((UIButton *)self).currentBackgroundImage.accessibilityIdentifier ?: @""];
        }
    }
    if ([labelStr isEqualToString:@"()"] || [labelStr isEqualToString:@"(null)"] || [labelStr isEqualToString:@"null"]) {
        labelStr = @"";
    }
    [self setAccessibilityIdentifier:labelStr];
    
    return labelStr;
}

- (NSString *)vw_accessibilityLabel {
    
    // UIImageView 特殊处理
    if ([self isKindOfClass:[UIImageView class]]) {
        NSString *name = [self.superview findNameWithInstance:self];
        if (name) {
            self.accessibilityIdentifier = [NSString stringWithFormat:@"(%@)", name];
        }else {
            self.accessibilityIdentifier = [NSString stringWithFormat:@"(%@)", ((UIImageView *)self).image.accessibilityIdentifier ?: [NSString stringWithFormat:@"image%ld", (long)((UIImageView *)self).tag]];
        }
    }
    // UITableViewCell 特殊处理
    if ([self isKindOfClass:[UITableViewCell class]]) {
        self.accessibilityIdentifier = [NSString stringWithFormat:@"(%@)", ((UITableViewCell *)self).reuseIdentifier];
    }
    return [self vw_accessibilityLabel];
}

@end






