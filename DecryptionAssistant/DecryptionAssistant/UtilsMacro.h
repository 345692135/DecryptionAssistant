//
//  UtilsMacro.h
//  ProfitCalculator
//
//  Created by Granger on 2019/8/29.
//  Copyright © 2019 granger. All rights reserved.
//

#ifndef UtilsMacro_h
#define UtilsMacro_h

// 开放平台 key
//#define kWeiChatAppId @"wx38f5a9140117b3bc"

//#define kScreenHeight       ([UIScreen mainScreen].bounds.size.height)
//#define kScreenWidth        ([UIScreen mainScreen].bounds.size.width)
#define kIphone4            (480==kScreenHeight)
#define kIphone5            (568==kScreenHeight)
#define kIphone6            (667==kScreenHeight)
#define kIphone6plus        (736==kScreenHeight)
#define kIphoneX            (812==kScreenHeight)

#define KEYWINDOW [UIApplication sharedApplication].keyWindow
#define kStatusBarHeight    ([UIScreen mainScreen].bounds.size.height == 812 ? 44:20)
#define kSafeHeight         ([UIScreen mainScreen].bounds.size.height == 812 ? [UIScreen mainScreen].bounds.size.height - 88 - 34:[UIScreen mainScreen].bounds.size.height - 64 )
#define kNavigationBarHeight ([UIScreen mainScreen].bounds.size.height == 812 ? 88:64)
#define kTBarBottomHeight ([UIScreen mainScreen].bounds.size.height == 812 ? 34:0)

#define LINE_WIDTH           (1 / [UIScreen mainScreen].scale)
#define LINE_ADJUST_OFFSET   ((1 / [UIScreen mainScreen].scale) / 2)
#define kYSBL(number)  ([UIScreen mainScreen].bounds.size.width/375 *(number))
#define kP6HEIGHTYSBL(number)  (kSafeHeight/(667 - kStatusBarHeight - 40) *(number))
#define kAdaptationFont(number)   (MIN([UIScreen mainScreen].bounds.size.width, 375) / 375 *(number))
#define kColor(r, g, b, a)      [UIColor colorWithRed:  r / 255.f green:  g / 255.f blue:  b / 255.f alpha: a]

#define UIImageName(imageName)          [UIImage imageNamed:imageName]
#define kIsNSString(string)             [string isKindOfClass:[NSString class]]
#define kIsNSNull(string)               [string isKindOfClass:[NSNull class]]
//判断字符串是否为空
#define kIsNULLString(string) ((![string isKindOfClass:[NSString class]])||[string isEqualToString:@""] || (string == nil) ||[string isEqualToString:@""] || [string isKindOfClass:[NSNull class]] || [string isEqualToString:@"(null)"] ||[[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0)

#define kAppDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define kAvatar       (Person.sharedPerson.avatarUrl)
#define kMobile       (Person.sharedPerson.mobile)
#define kDefaultAvatar       [UIImage imageNamed:@"defaultAvatar"]


#define k1PX (1/[[UIScreen mainScreen] scale])
#define UserDefaults [NSUserDefaults standardUserDefaults]
#define UserDefaultsSynchronize [UserDefaults synchronize]

#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#endif

#define  kCommonBackgroundColor  kColor(25, 31, 50, 1)
#define  kCommonButtonColor  [UIColor colorWithHexString:@"#0070e7"]
#define  kUUID ([FMKeychain deviceID])
#define kAFNetworkReachabilityManager [AFNetworkReachabilityManager sharedManager]
#define APP_STATUSBAR_HEIGHT                (CGRectGetHeight([UIApplication sharedApplication].statusBarFrame))
// 热点栏高度
#define HOTSPOT_STATUSBAR_HEIGHT            20
// 标准系统状态栏高度
#define SYS_STATUSBAR_HEIGHT                 ([UIScreen mainScreen].bounds.size.height == 812 ? 44:20)

//是否开启个人热点
#define IS_HOTSPOT_CONNECTED                (APP_STATUSBAR_HEIGHT==(SYS_STATUSBAR_HEIGHT+HOTSPOT_STATUSBAR_HEIGHT)?YES:NO)

// 是否关闭用户数据分析  YES 关闭  NO 开启
#define kCloseUserStatistics YES
// 运营功能是否开启  YES 开启  NO 关闭
#define kBusinessOpen YES

// HUD
#define Loading          [[HudView sharedHud] show]
#define LoadingError     [[HudView sharedHud] showError]
#define Dismiss          [[HudView sharedHud] hide]

// 国际化字符串
#define LString(string) (NSLocalizedString(string, @""))

/* Color*/
#define HSColor(r, g, b) [NSColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
/*  weakSelf */
#define HS_WeakSelf(weakSelf) __weak __typeof(self) weakSelf = self

/*  **** 判断字典、数组是否为空 ****  */
#define IsDictionaryNull(dict) (nil == dict || ![dict isKindOfClass:[NSDictionary class]]\
|| [dict isKindOfClass:[NSNull class]] || [dict allKeys].count <= 0)
#define IsArrayNull(array) ((nil == array || ![array isKindOfClass:[NSArray class]]\
|| [array isKindOfClass:[NSNull class]] || array.count <= 0))
#define IsStringNull(string) (nil == string || [string isKindOfClass:[NSNull class]] \
|| string.length <= 0)
#define IsObjectNull(object) (nil == object || [object isKindOfClass:[NSNull class]])

/// 刷新Token
#define HTTP_REFRESH_TOKEN   @""//HTTP_8081(@"users/refreshToken")

#define SERVER_HOST @"103.25.23.58:8443" //新外网

#define SERVER_URL_AND_ARGUMENTS [NSString stringWithFormat:@"https://%@/MailServer/userLogin.action",SERVER_HOST]
#define SERVER_URL_AND_ARGUMENTS_CONTACT [NSString stringWithFormat:@"https://%@/MailServer/friendManager.action",SERVER_HOST]
#define SERVER_URL_AND_ARGUMENTS_LOGINOUT [NSString stringWithFormat:@"https://%@/MailServer/loginOut.action",SERVER_HOST]
#define SERVER_URL_AND_ARGUMENTS_MAILSEND [NSString stringWithFormat:@"https://%@/MailServer/mailSend.action",SERVER_HOST]

///获取已加锁邮件编号列表接口 op=list&userMail=85452254@qq.com
#define SERVER_URL_AND_ARGUMENTS_FETCH_LOCK_EMAIL_NUMBERS [NSString stringWithFormat:@"https://%@/MailServer/lockMailManager.action",SERVER_HOST]

///验证是否已经设过安全密码 op=isHaveSafeCode&userMail=85452254@qq.com
#define SERVER_URL_AND_ARGUMENTS_VALIDATE_IFHAVE_SAFEPASSWORD [NSString stringWithFormat:@"https://%@/MailServer/lockMailManager.action",SERVER_HOST]

///设置安全码 op=setUserSafeCode&userMail=85452254@qq.com&safeCode=1234
#define SERVER_URL_AND_ARGUMENTS_SET_SAFECODE [NSString stringWithFormat:@"https://%@/MailServer/lockMailManager.action",SERVER_HOST]

///验证安全码 op=validSafeCode&userMail=85452254@qq.com&safeCode=1234
#define SERVER_URL_AND_ARGUMENTS_VALIDATE_SAFECODE [NSString stringWithFormat:@"https://%@/MailServer/lockMailManager.action",SERVER_HOST]

///锁邮件 op=lockMail&userMail=85452254@qq.com&mailId=12345
#define SERVER_URL_AND_ARGUMENTS_LOCK_EMAIL [NSString stringWithFormat:@"https://%@/MailServer/lockMailManager.action",SERVER_HOST]

///邮件解锁 op=unlockMail&userMail=85452254@qq.com&mailId=12345
#define SERVER_URL_AND_ARGUMENTS_UNLOCK_EMAIL [NSString stringWithFormat:@"https://%@/MailServer/lockMailManager.action",SERVER_HOST]

///获取验证码接口 phoneNumberOrMail=电话号码或邮箱&language=en/cn
#define SERVER_URL_AND_ARGUMENTS_FETCH_VALIDATECODE [NSString stringWithFormat:@"https://%@/MailServer/getValidate.action",SERVER_HOST]

///将验证接口改为 isSetMailOrPhone=0或1phoneNumberOrMail=电话号码或邮箱&validateCode=验证码&userMail=账号; isSetMailOrPhone = 0 代表验证通过后绑定手机或邮箱,isSetMailOrPhone = 1 代表只验证不绑定
#define SERVER_URL_AND_ARGUMENTS_VALIDATECODE [NSString stringWithFormat:@"https://%@/MailServer/validateUser.action",SERVER_HOST]

#endif /* UtilsMacro_h */
