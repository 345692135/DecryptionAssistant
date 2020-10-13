//
//  GSWaterMarkView.h
//  GSWatermarkView
//
//  Created by gensee on 2020/2/28.
//  Copyright © 2020年 sheng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSWatermarkParam : NSObject

/**
 富文本
 */
@property (nonatomic, strong) NSAttributedString *richtext;
/**
 垂直间距 default = 10
 */
@property (nonatomic, assign) int verticalSpacing;
/**
 水平间距 default = 10
 */
@property (nonatomic, assign) int horizonSpacing;
/**
 倾斜角度 - 逆时针旋转
 */
@property (nonatomic, assign) int angle;

@end

@interface GSWatermarkView : UIView
/**
 富文本
 */
@property (nonatomic, strong) NSAttributedString *richtext;
/**
 垂直间距 default = 10
 */
@property (nonatomic, assign) int verticalSpacing;
/**
 水平间距 default = 10
 */
@property (nonatomic, assign) int horizonSpacing;
/**
 倾斜角度 - 顺时针旋转 0 - 360
 */
@property (nonatomic, assign) int angle;

/// 停留时间
@property (nonatomic, assign) int duration;
/// 间隔时间
@property (nonatomic, assign) int interval;

@end

NS_ASSUME_NONNULL_END
