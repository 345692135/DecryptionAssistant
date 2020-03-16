//
//  UIImage+VWAdd.h
//  SecretMail
//
//  Created by Granger on 2019/11/19.
//  Copyright © 2019 granger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (VWAdd)

//+ (NSData *)reSizeImageData:(UIImage *)sourceImage maxImageSize:(CGFloat)maxImageSize maxFileSizeWithKB:(CGFloat)maxFileSize;
+ (NSData *)reSizeImageData:(UIImage *)sourceImage maxImageSize:(CGFloat)maxImageSize maxSizeWithKB:(CGFloat) maxSize;

+ (UIImage *)imageWithCaptureView:(UIView *)view;
+ (UIImage *)compressImage:(UIImage *)image toByte:(long)maxLength;
- (UIImage *)imageWithColor:(UIColor *)color;
- (NSData *)compressWithMaxLength:(NSUInteger)maxLength;
+ (UIImage *)imageWithBase64String:(NSString *)base64String;
@end
