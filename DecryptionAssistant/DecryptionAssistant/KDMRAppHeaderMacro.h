//
//  KDMRAppHeaderMacro.h
//  MASTERREPAYMENT
//
//  Created by Jeff.Wang on 2019/4/1.
//  Copyright © 2019 Jeff.Wang. All rights reserved.
//

#ifndef KDMRAppHeaderMacro_h
#define KDMRAppHeaderMacro_h


#ifdef DEBUG
#define LRString [NSString stringWithFormat:@"%s", __FILE__].lastPathComponent
#define NSLog(...) printf("%s: %s 第%d行: %s\n\n",[[NSString jk_UUIDTimestamp] UTF8String], [LRString UTF8String] ,__LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String]);
#else
#define NSLog(...){}
#endif


/*
 * 请求服务器标识，0位测试服务器 1位正式服务器
 */
#define kServerType 0

//#pragma mark -----或者宽高属性------
#define kAppScreenWidth  [[UIScreen mainScreen] bounds].size.width
#define kAppScreenHeight [[UIScreen mainScreen] bounds].size.height
#define kFrameWidth  self.view.frame.size.width
#define kFrameHeight self.view.frame.size.height

// KeyWindow
#define JWKeyWindow [UIApplication sharedApplication].keyWindow

#undef    RGB
#define RGB(R,G,B)        [UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:1.0f]
#undef    RGBA
#define RGBA(R,G,B,A)    [UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:A]

//16进制转色值带透明度
#define UIColorFromRGBA(rgbValue, alphaValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 blue:((float)(rgbValue & 0x0000FF))/255.0 alpha:alphaValue]

//随机颜色
#define JWRandomColor [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0]

/**
 *
 *
 *  @param X
 *
 *  @return
 */
#define kFont(X)            [UIFont systemFontOfSize:X]
#define kFontBold(X)        [UIFont fontWithName:@"HelveticaNeue-Bold" size:X]
#define kFontThin(X)        [UIFont fontWithName:@"HelveticaNeue-Thin" size:X]
#define kFontLight(X)       [UIFont fontWithName:@"HelveticaNeue-Light" size:X]


/**
 *
 *
 *  @param weakSelf
 *
 *  @return
 */
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;


///判断是否是ipad
#define isPad ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

//判断iPhone4系列
#define kiPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
//判断iPhone5系列
#define kiPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
//判断iPhone6系列
#define kiPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
//判断iphone6+系列
#define kiPhone6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
//判断iPhoneX
#define IS_IPHONE_X ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
//判断iPHoneXr
#define IS_IPHONE_Xr ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
//判断iPhoneXs
#define IS_IPHONE_Xs ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)
//判断iPhoneXs Max
#define IS_IPHONE_Xs_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) && !isPad : NO)

//iPhoneX系列

#define KNavgationHight ((IS_IPHONE_X==YES || IS_IPHONE_Xr ==YES || IS_IPHONE_Xs== YES || IS_IPHONE_Xs_Max== YES) ? 88.0 : 64.0)

#define kTabBarHeight ((IS_IPHONE_X==YES || IS_IPHONE_Xr ==YES || IS_IPHONE_Xs== YES || IS_IPHONE_Xs_Max== YES) ? 83.0 : 49.0)


#define kBottomToolHeight ((IS_IPHONE_X==YES || IS_IPHONE_Xr ==YES || IS_IPHONE_Xs== YES || IS_IPHONE_Xs_Max== YES) ? 34 : 0)


/*
 定义UIImage对象
 */
#define kImageName(X)  [YYImage imageNamed:X]


#define kPS @property(nonatomic,copy)NSString*
#define kPN @property(nonatomic,copy)NSNumber*
#define kPA @property(nonatomic,copy)NSArray*
#define kPD @property(nonatomic,copy)NSDictionary*
#define kPINT  @property (nonatomic,assign) NSInteger
#define kPFLOAT @property (nonatomic,assign) CGFloat


//三目运算符
#define StrNotNullValue(x) [x isNotBlank] ? x : @""


#define IMAGE_URL_BY(X,W,H) [NSString stringWithFormat:@"%@?x-oss-process=image/resize,m_fixed,h_%@,w_%@",X,[NSString stringWithFormat:@"%d",W*2],[NSString stringWithFormat:@"%d",H*2]]


/**
 *
 *
 *  @param
 *
 *  @return
 */

#if __has_feature(objc_instancetype)

#undef    AS_SINGLETON
#define AS_SINGLETON

#undef    AS_SINGLETON
#define AS_SINGLETON( ... ) \
- (instancetype)sharedInstance; \
+ (instancetype)sharedInstance;

#undef    DEF_SINGLETON
#define DEF_SINGLETON \
- (instancetype)sharedInstance \
{ \
return [[self class] sharedInstance]; \
} \
+ (instancetype)sharedInstance \
{ \
static dispatch_once_t once; \
static id __singleton__; \
dispatch_once( &once, ^{ __singleton__ = [[self alloc] init]; } ); \
return __singleton__; \
}

#undef    DEF_SINGLETON
#define DEF_SINGLETON( ... ) \
- (instancetype)sharedInstance \
{ \
return [[self class] sharedInstance]; \
} \
+ (instancetype)sharedInstance \
{ \
static dispatch_once_t once; \
static id __singleton__; \
dispatch_once( &once, ^{ __singleton__ = [[self alloc] init]; } ); \
return __singleton__; \
}

#else    // #if __has_feature(objc_instancetype)

#undef    AS_SINGLETON
#define AS_SINGLETON( __class ) \
- (__class *)sharedInstance; \
+ (__class *)sharedInstance;

#undef    DEF_SINGLETON
#define DEF_SINGLETON( __class ) \
- (__class *)sharedInstance \
{ \
return [__class sharedInstance]; \
} \
+ (__class *)sharedInstance \
{ \
static dispatch_once_t once; \
static __class * __singleton__; \
dispatch_once( &once, ^{ __singleton__ = [[[self class] alloc] init]; } ); \
return __singleton__; \
}

#endif    // #if __has_feature(objc_instancetype)

#undef    DEF_SINGLETON_AUTOLOAD
#define DEF_SINGLETON_AUTOLOAD( __class ) \
DEF_SINGLETON( __class ) \
+ (void)load \
{ \
[self sharedInstance]; \
}



//我的银行卡-银行卡详情-点击更新账单
#define kMineCeridtCardDetailsUpdateBillNotification @"MineCeridtCardDetailsUpdateBillNotification"

//我的卡包-银行卡详情-点击更新账单
#define kCardPackageDetailsUpdateBillNotification @"CardPackageDetailsUpdateBillNotification"



#endif /* KDMRAppHeaderMacro_h */
