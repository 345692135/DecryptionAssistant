//
//  CGMacros.h
//  safemail
//
//  Created by Apple on 15/10/28.
//  Copyright © 2015年 Apple. All rights reserved.
//

#ifndef CGMacrosDefine
#define CGMacrosDefine

#import <Foundation/Foundation.h>
#import "UIColor+Hex.h"

#ifndef ORIGINAL_APP_VERSION
#define ORIGINAL_APP_VERSION @"0.0.1"
#endif

#ifndef FEEDBACK
#define FEEDBACK @"feedBack"
#endif

#ifdef CHINASEC_VERSION //♐
#define STORYBOAR_MODULES @"modules"
#define STORYBOAR_ID_CHINASEC_LOGIN @"chinasecLogin"
#define STORYBOAR_ID_BIND_MAILBOX_TO_CHINASEC @"bindMailboxToChinasec"
#endif

#define STORYBOAR_VPN @"VPN"
#define STORYBOAR_ID_VPN_LOGIN @"VPNLogin"
#define STORYBOAR_ID_VPN_MODIFY_PWD @"VPNModifyPwd"

#define IFSave NO

//#ifndef VALID_NO_COUNTDOWN
//#define VALID_NO_COUNTDOWN @"validNoCountDown"
//#endif

//声音类型
typedef enum : NSUInteger {
    kcgSoundType_shake,
    kcgSoundType_succeed,
    kcgSoundType_newMail,
    kcgSoundType_error
} cgSoundType;

//提示类型
typedef enum : NSUInteger {
    kcgPromptType_sign,//标记成功
    kcgPromptType_save,//保存成功
    kcgPromptType_add,//添加成功、添加失败
    kcgPromptType_AddPw,//加密成功、加密失败
    kcgPromptType_RemovePw, //取消成功、取消失败
    kcgPromptType_set, //设置成功、设置失败
    kcgPromptType_reset //重置成功、重置失败
} cgPromptType;

//检查邮件结果
typedef enum : NSUInteger {
    kcgCheckMailResult_OK,
    kcgCheckMailResult_MailContentIsTooBig,
    kcgCheckMailResult_MailContentIsTooBigForSaveTempMail,
    kcgCheckMailResult_MailContentIsTooBigForSaveDraft
} kcgCheckMailResult;

#pragma mark -
#pragma mark define color

//内存泄露
#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

#define COLOR_FRAME ([UIColor colorWithHex:0xc7c7c7])//边框颜色
//背景颜色
#define COLOR_BACKGROUND_FACE_0 ([UIColor colorWithRed:249.0 / 255 green:250.0 / 255 blue:251.0 / 255 alpha:1])
#define COLOR_BACKGROUND_FACE_trans ([UIColor colorWithRed:0 / 255 green:0 / 255 blue:0 / 255 alpha:0.1])

//自定义通知
#define CUSTOM_NOTIFICATION_NAME_REQUEST_REFRESH_MESSAGES @"requestRefreshMessages" //刷新首页
#define CUSTOM_NOTIFICATION_NAME_ON_SUCCEED_TO_SWITCH_ACCOUNT @"onSucceedToSwitchAccount"   //切换账号
#define CUSTOM_NOTIFICATION_NAME_ON_SUCCEED_TO_LOAD_RSAKEY @"onSucceedToLoadRSAKey" //成功下载RSA key
#define CUSTOM_NOTIFICATION_NAME_ON_FAIL_TO_LOAD_RSAKEY @"onFailToLoadRSAKey"   //失败下载RSA key
#define CUSTOM_NOTIFICATION_NAME_ON_FINISH_CANCEL_CHECKING @"onFinishCancelChecking"    //取消检查
#define CUSTOM_NOTIFICATION_NAME_IS_SERVER_CONNECTED @"isServerConnected"   //*鸡肋*
#define CUSTOM_NOTIFICATION_NAME_ON_NETWORK_DISCONNECTED @"onNetWorkDisconnected"   //网络点开
#define CUSTOM_NOTIFICATION_NAME_ON_NETWORK_CONNECTED @"onNetWorkConnected"   //网络连接
#define CUSTOM_NOTIFICATION_NAME_ON_SUCCEED_TO_UPDATE_CONTACTS @"onSucceedToUpdateContacts" //成功更新联系人
#define CUSTOM_NOTIFICATION_NAME_ON_INBOX_DID_APPEAR @"onInBoxDidAppear"    //收件箱一旦显示
#define CUSTOM_NOTIFICATION_NAME_ON_FINISH_UPDATE_MEMO @"onFinishUpdateMemo"    //完成更新待办
#define CUSTOM_NOTIFICATION_NAME_ON_FINISH_REFRESH_MESSAGES @"onFinishRefreshMenu"  //完成刷新menu
#define CUSTOM_NOTIFICATION_NAME_ON_NEW_MESSAGES_COME @"onNewMessages_com"  //*鸡肋*  有新消息
#define CUSTOM_NOTIFICATION_NAME_ON_SUCCEED_TO_SET_USER_SAFECODE @"onSucceedToSetUserSafeCode"
#define CUSTOM_NOTIFICATION_NAME_ON_FAIL_TO_SET_USER_SAFECODE @"onFailToSetUserSafeCode"
#define CUSTOM_NOTIFICATION_NAME_ON_FAIL_TO_VALID_SAFECODE @"onFailToValidSafeCode"
#define CUSTOM_NOTIFICATION_NAME_ON_SUCCEED_TO_VALID_SAFECODE @"onSucceedToValidSafeCode"
#define CUSTOM_NOTIFICATION_NAME_ON_FAIL_TO_SEND_MESSAGE @"onFailToSendMessage"
#define CUSTOM_NOTIFICATION_NAME_ON_FINISH_SAVE_DRAFT @"onFinishSaveDraft"
#define CUSTOM_NOTIFICATION_NAME_ON_FINISH_SAVE_TEMP @"onFinishSaveTemp" //♐
//发件
#define CUSTOM_NOTIFICATION_NAME_ON_FINISH_SEND_MAIL @"onFinishSendMail"
//#define CUSTOM_NOTIFICATION_NAME_ON_SUCCEED_TO_SEND_MAIL @"onSucceedToSendMail"
//#define CUSTOM_NOTIFICATION_NAME_ON_FAIL_TO_SEND_TALK_MESSAGE @"onFailToSendTalkMessage"

#define CUSTOM_NOTIFICATION_NAME_ON_FINISH_CREATE_FOLDER @"onFinishCreateFolder"
#define CUSTOM_NOTIFICATION_NAME_ON_SUCCEED_TO_MOVE_MESSAGES @"onSucceedToMoveMessages"
#define CUSTOM_NOTIFICATION_NAME_ON_SUCCEED_TO_UPDATE_BLACKLIST @"onSucceedToUpdateBlacklist" //🌲成功更新黑名单
#define CUSTOM_NOTIFICATION_NAME_ON_SUCCEED_TO_ADD_BLACKLIST @"onSucceedToAddBlacklist"//🌲添加黑名单
#define CUSTOM_NOTIFICATION_NAME_ON_SUCCEED_TO_REMOVE_BLACKLIST @"onSucceedToRemoveBlacklist"//🌲删除黑名单


//操作消息
//重命名文件夹
#define CUSTOM_NOTIFICATION_NAME_ON_FINISH_RENAME_FOLDER @"onFinishRenameFolder"
//只删除文件夹
#define CUSTOM_NOTIFICATION_NAME_ON_FINISH_DELETE_FOLDER @"onFinishDeleteFolder"
//删除文件夹和邮件
#define CUSTOM_NOTIFICATION_NAME_ON_FINISH_DELETE_FOLDER_MAILS @"onFinishDeleteFolderAndMails"
//更新完菜单
#define CUSTOM_NOTIFICATION_NAME_ON_FINISH_CONFIG_MENU @"onFinishConfigMenu"
//完成邮件操作 🌺
#define CUSTOM_NOTIFICATION_NAME_ON_FINISH_PROCESSING_TASK @"onFinishTaskProcessing"
//清除缓存🇺🇸
#define CUSTOM_NOTIFICATION_NAME_ON_FINISH_CLEANCACHE_TASK @"onFinishCleanCache"


#ifdef FREE_VERSION
#define COLOR_MAIN ([UIColor colorWithHex:0x0c9f63])//主色
#elif defined(SPRING_VERSION)
#define COLOR_MAIN ([UIColor colorWithHex:0xe84b4b])//主色
#else
#define COLOR_MAIN ([UIColor colorWithHex:0x2e5098])//主色
#endif

#ifdef FREE_VERSION
#define COLOR_MAIN_PATTERN ([UIColor colorWithHex:0x0c9f63])//花纹色
#elif defined(SPRING_VERSION)
#define COLOR_MAIN_PATTERN ([UIColor colorWithPatternImage:[UIImage imageNamed:@"safemail_top_navBar"]])//花纹色
#else
#define COLOR_MAIN_PATTERN ([UIColor colorWithHex:0x2e5098])//花纹色
#endif


#ifdef FREE_VERSION
#define COLOR_MAIN_DARK ([UIColor colorWithHex:0x086f45])//深主色
#elif defined(SPRING_VERSION)
#define COLOR_MAIN_DARK ([UIColor colorWithHex:0x982e2f])//深主色
#else
#define COLOR_MAIN_DARK ([UIColor colorWithHex:0x20386a])//深主色
#endif

#ifdef FREE_VERSION
#define FONTCOLOR_TITLE_GUIDE ([UIColor colorWithHex:0x10306b])//引导界面标题颜色
#elif defined(SPRING_VERSION)
#define FONTCOLOR_TITLE_GUIDE ([UIColor colorWithHex:0xe84b4b])//引导界面标题颜色
#else
#define FONTCOLOR_TITLE_GUIDE ([UIColor colorWithHex:0x10306b])//引导界面标题颜色
#endif

#ifdef FREE_VERSION
#define COLOR_LOGIN_BUTTON ([UIColor colorWithHex:0x13b873])//登录按钮颜色
#elif defined(SPRING_VERSION)
#define COLOR_LOGIN_BUTTON ([UIColor colorWithHex:0xe84b4c])//登录按钮颜色
#else
#define COLOR_LOGIN_BUTTON ([UIColor colorWithHex:0x1e6ad0])//登录按钮颜色
#endif

#ifdef FREE_VERSION
#define COLOR_MENU_CELL_SELECTED ([UIColor colorWithHex:0x60b7ff])//首页菜单选中色
#elif defined(SPRING_VERSION)
#define COLOR_MENU_CELL_SELECTED ([UIColor colorWithHex:0xE4B436])//首页菜单选中色
#else
#define COLOR_MENU_CELL_SELECTED ([UIColor colorWithHex:0x60b7ff])//首页菜单选中色
#endif

#ifdef FREE_VERSION
#define COLOR_SEARCH_BUTTON_TEXT ([UIColor colorWithHex:0x3391ec])//搜索栏按钮文字颜色
#elif defined(SPRING_VERSION)
#define COLOR_SEARCH_BUTTON_TEXT ([UIColor colorWithHex:0xe84b4b])//搜索栏按钮文字颜色
#else
#define COLOR_SEARCH_BUTTON_TEXT ([UIColor colorWithHex:0x3391ec])//搜索栏按钮文字颜色
#endif

#ifdef FREE_VERSION
#define COLOR_SEGMENT_TINT ([UIColor colorWithHex:0x0C9F63])//segment's tint
#elif defined(SPRING_VERSION)
#define COLOR_SEGMENT_TINT ([UIColor colorWithHex:0xe84d4c])//segment's tint
#else
#define COLOR_SEGMENT_TINT ([UIColor colorWithHex:0x648BD9])//segment's tint
#endif

#ifdef FREE_VERSION
#define COLOR_SWITCH_ON ([UIColor colorWithHex:0x13b873])//加密开关
#elif defined(SPRING_VERSION)
#define COLOR_SWITCH_ON ([UIColor colorWithHex:0xe4b436])//加密开关
#else
#define COLOR_SWITCH_ON ([UIColor colorWithHex:0x658ad9])//加密开关
#endif

#ifdef FREE_VERSION
#define COLOR_THIRD ([UIColor colorWithHex:0x13b873])//重要联系人按钮颜色
#elif defined(SPRING_VERSION)
#define COLOR_THIRD ([UIColor colorWithHex:0xe4b436])//重要联系人按钮颜色
#else
#define COLOR_THIRD ([UIColor colorWithHex:0x7fa1e7])//重要联系人按钮颜色
#endif

#ifdef FREE_VERSION
#define COLOR_CONTACT_BUTTON ([UIColor colorWithHex:0x658ad9])//联系人按钮颜色
#elif defined(SPRING_VERSION)
#define COLOR_CONTACT_BUTTON ([UIColor colorWithHex:0xe4b436])//联系人按钮颜色
#else
#define COLOR_CONTACT_BUTTON ([UIColor colorWithHex:0x658ad9])//联系人按钮颜色
#endif

#ifdef FREE_VERSION
#define COLOR_BACKGROUND_TALK ([UIColor colorWithHex:0x126D47])//讨论界面背景色
#elif defined(SPRING_VERSION)
#define COLOR_BACKGROUND_TALK ([UIColor colorWithHex:0xb03b3a])//讨论界面背景色
#else
#define COLOR_BACKGROUND_TALK ([UIColor colorWithHex:0x2c4985])//讨论界面背景色
#endif

#ifdef FREE_VERSION
#define COLOR_BUBBLE_TALK ([UIColor colorWithHex:0x67C19B])//讨论界面气泡背景色
#elif defined(SPRING_VERSION)
#define COLOR_BUBBLE_TALK ([UIColor colorWithHex:0xfd8a8a])//讨论界面气泡背景色
#else
#define COLOR_BUBBLE_TALK ([UIColor colorWithHex:0x7ea2e7])//讨论界面气泡背景色
#endif

#define COLOR_FOURTH ([UIColor colorWithHex:0xcdcdcd])//辅色三(cell细节说明)

#define COLOR_DONE ([UIColor colorWithHex:0xf2f2f2])//DONE

#define COLOR_SUB ([UIColor colorWithHex:0x658ad9])//辅色(可点击文字)

#define COLOR_SIX ([UIColor colorWithHex:0x238eee])//隐藏按钮
#define COLOR_DESTRUCTIVE ([UIColor colorWithHex:0xfe7e7f])   //警告色(收件箱工具条字体色)
#define COLOR_SWIPE_DELETE ([UIColor colorWithHex:0xfe3e2e])   //滑动删除色
#define COLOR_SWIPE_TODO ([UIColor colorWithHex:0x8f91a3])   //滑动待办色
#define COLOR_SWIPE_MORE ([UIColor colorWithHex:0xc0c2d6])   //滑动更多色
#define COLOR_CLEAR ([UIColor colorWithHex:0xff3b30])   //删除色(收件箱删除滑动条颜色、首页清空滑动条的颜色)
#define COLOR_SIGN ([UIColor colorWithHex:0xc1c1d6])   //标记色(收件箱标记滑动条颜色、首页标记滑动条的颜色)
#define COLOR_CELL_SELECTION ([UIColor colorWithHex:0xe6f0f9])    //选中色(首页菜单cell、收件箱邮件cell)
#define COLOR_CELL_SELECTION_GRAY ([UIColor colorWithHex:0xd9d9d9])    //选中色(设置菜单cell选中颜色)
#define COLOR_CELL_SELECTION_HOME ([UIColor colorWithHex:0xe7ea2e7])    //选中色(首页菜单cell、收件箱邮件cell)

#define COLOR_SEPARATOR ([UIColor colorWithHex:0xdbdbdb])    //tableView的separator颜色

/* 字体颜色 */
#define COLOR_TEXT_DARK ([UIColor colorWithHex:0x333333])    //深(标题、正文)
#define COLOR_TEXT_LIGHT ([UIColor colorWithHex:0x888888])    //浅(提示语、辅助信息)
#define COLOR_TEXT_CUSTOM ([UIColor colorWithHex:0xaeaeae])    //自定义(placeholder)
#define COLOR_TEXT_FROM_AND_SUBJECT ([UIColor colorWithHex:0x3a3a3a])    //🦑发件人和标题
#define COLOR_TEXT_CONTENT ([UIColor colorWithHex:0x8b8b8b])    //🦑内容

#define COLOR_FIGURE ([UIColor colorWithHex:0x8dafff])    //头像文字颜色

#define COLOR_LINE_LEAVEMENU ([UIColor colorWithHex:0xe0e0e0])//离开菜单边框
#define COLOR_LINE ([UIColor colorWithRed:220.0 / 255 green:220.0 / 255 blue:220.0 / 255 alpha:1])//附件边框
#define COLOR_EDIT_BUTTON ([UIColor colorWithHex:0x3391ec])


//section header
#define COLOR_BACKGROUND_FACE_1 ([UIColor colorWithHex:0xf0f0f0])


#pragma mark -
#pragma mark define font

//13到18号字
/*
 IOS字号：
 Top中间标题：36号 加粗
 TOP两边功能文字：34号
 搜索、搜索条件：28号    取消：34号
 首页文件夹名称、下拉菜单：34号  #333333        未读邮件提醒数字：30号  #999999
 
 邮件列表：
 发件人名称：34号加粗   #333333
 邮件主题：30号   #333333
 邮件内容简介：30号   #999999
 时间：26号
 编辑：34号
 
 邮件正文：
 邮件主题：36号 加粗  #333333
 发件人收件人：30号
 邮件正文：34号
 邮箱签名：32号  #999999
 附件名称：32号 加粗 #333333
 附件大小：26号  #999999
 
 设置：
 左标题：36号  #333333
 右说明：36号
 帮助文字列表：36号
 帮助详情：标题：34号加粗 #333333
 内容：28号  #333333
 
 写信：
 提示标题：34号  #999999
 输入主题：34号   #333333
 输入内容 ：36号   #333333
 */

#define FONT_NAVIGATIONITEM [UIFont systemFontOfSize:14]
#define FONT_LABEL_BOLD [UIFont boldSystemFontOfSize:20]
#define FONT_LABEL [UIFont systemFontOfSize:15]
#define FONT_TEXTFIELD [UIFont systemFontOfSize:13]
#define FONT_CELL_TITLE [UIFont systemFontOfSize:17]
#define FONT_SECTION_HEADER_TITLE [UIFont boldSystemFontOfSize:12]

#pragma mark -
#pragma mark process function

#define GET_LABEL_WIDTH(__content__, __labelHeight__, __font__)    [[CGMacros sharedInstance] getLabelWidthWithContent:__content__ withLabelHeight:__labelHeight__ withFont:__font__]
#define GET_LABEL_HEIGHT(__content__, __labelWidth__, __font__)    [[CGMacros sharedInstance] getLabelHeightWithContent:__content__ withLabelWidth:__labelWidth__ withFont:__font__]
#define GET_LABEL_HEIGHT_WITH_LINESPACE(__content__, __labelWidth__, __font__, __lineSpace__)    [[CGMacros sharedInstance] getLabelHeightWithContent:__content__ withLabelWidth:__labelWidth__ withFont:__font__ withLineSpace:__lineSpace__]

#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define ALERT_MESSAGE(__message__, __target__, __comletion__) [[CGMacros sharedInstance] alertWithMessage:__message__ target:__target__ completion:__comletion__]
#define HUD_SHOW_MESSAGE(__message__)  ([[CGMacros sharedInstance] showPrompt:__message__])
#define GENERATEDID()  ([[CGMacros sharedInstance] generatedId])
#define GENERATED_MESSAGEID()  ([[CGMacros sharedInstance] generatedMessageID])//♐
#define TIMESTAMP()  ([[CGMacros sharedInstance] timeStamp])
#define CHECKMAIL(__mail__)  ([[CGMacros sharedInstance] validateEmail:__mail__])
#define TIME_DESCRIPTION(__date__)  ([[CGMacros sharedInstance] timeDescriptionWithDate:__date__])
#define HUD_START_ACTIVITY_WITH_ENABLE(__enable__) ([[CGMacros sharedInstance] startActivityWithEnable:__enable__])
#define HUD_STOP_ACTIVITY  ([[CGMacros sharedInstance] stopActivity])
#define PLAY_SOUNT_EFFECT_WITH_SOUNDTYPE(__soundType__) [[CGMacros sharedInstance] playSoundEffectWithSoundType:__soundType__]
#define SEARCH(__key__, __dataArray__) ([[CGMacros sharedInstance] searchWithKey:__key__ inArray:__dataArray__])
#define SEARCH_CONTACTDATA(__key__, __dataArray__) ([[CGMacros sharedInstance] searchWithKey:__key__ inContactDataArray:__dataArray__])
#define THUMBNAIL_IMAGE(__image__, __fillSize__) ([[CGMacros sharedInstance] image:__image__ fillSize:__fillSize__])
#define ATTACHMENT_THUMBNAIL_IMAGE_WITH_RES(__res__, __fileName__, __fillSize__) ([[CGMacros sharedInstance] attachmentThumbnailWithRes:__res__ fileName:__fileName__ fillSize:__fillSize__])
#define ATTACHMENT_THUMBNAIL_IMAGE_WITH_ATTACHMENT(__attachment__, __fillSize__) ([[CGMacros sharedInstance] attachmentThumbnailWithAttachment:__attachment__ fillSize:__fillSize__])
//#define SHOW_SIGN_SUCCEED() ([[CGMacros sharedInstance] showSignSucceed])
//#define SHOW_SAVE_SUCCEED() ([[CGMacros sharedInstance] showSaveSucceed])
//#define SHOW_ADD_SUCCEED() ([[CGMacros sharedInstance] showAddSucceed])
//#define SHOW_ADD_FAIL() ([[CGMacros sharedInstance] showAddFail])
//
//#define SHOW_ADDPW_SUCCEED() ([[CGMacros sharedInstance] showAddPwSucceed])
//#define SHOW_ADDPW_FAIL() ([[CGMacros sharedInstance] showAddPwFail])
//#define SHOW_REMOVEPW_SUCCEED() ([[CGMacros sharedInstance] showRemovePwSucceed])
//#define SHOW_REMOVEPW_FAIL() ([[CGMacros sharedInstance] showRemovePwFail])

#define SHOW_PROMPT(__promptType__, __isSucceed__) ([[CGMacros sharedInstance] showPromptWithPromptType:__promptType__ isSucceed:__isSucceed__])


#define SHOW_DOWNLOADING_STATUS() ([[CGMacros sharedInstance] showDownloadingStatus])
#define REMOVE_DOWNLOADING_STATUS() ([[CGMacros sharedInstance] removeDownloadingStatus])

#define INDEX_OF_STRING(__string__) ([[CGMacros sharedInstance] indexWithString:__string__])
#define SHORTNAME_OF_FULLNAME(__string__) ([[CGMacros sharedInstance] fetchStringWithString:__string__])
#define CURRENT_LANGUAGE() ([[CGMacros sharedInstance] getPreferredLanguage])
#define IS_CURRENT_LANGUAGE_CHINESE() ([[CGMacros sharedInstance] isCurrentLanguageChinese])
#define DATESTRING_MAILCONTENT(__date__) ([[CGMacros sharedInstance] dateStringOfmailContent:__date__])
#define SHORT_OF_DATESTRING_MAILCONTENT(__date__) ([[CGMacros sharedInstance] shortOfDateStringOfmailContent:__date__])
#define SCALE_FACTOR ([[CGMacros sharedInstance] scaleFactor])
#define SCALE_FACTOR_2 ([[CGMacros sharedInstance] scaleFactor2])
#define SCALE_FACTOR_Y ([[CGMacros sharedInstance] scaleFactorY])

#define VALID_MOBILE(__mobile__) ([[CGMacros sharedInstance] valiMobile:__mobile__])

#define ATTACHMENT_EXTENSION(__mimeType__) ([[CGMacros sharedInstance] attachmentExtension:__mimeType__])

#define JUDGE_CHECKMAILRESULT(__kcgCheckMailResult__, __viewController__) ([[CGMacros sharedInstance] judgeCheckMailResult:__kcgCheckMailResult__ viewController:__viewController__])

#define IF_BREAK(ifBreak) if (ifBreak) break;

#define IF_MATCH_RETURN_NO(ifMatch) if (ifMatch) return NO; 

#define IF_NEED_USE_PROXY() ([[CGMacros sharedInstance] ifNeedUseProxy])

#define FETCH_VALID_STRING_OR_NIL(__string__) ([[CGMacros sharedInstance] fetchValidStringOrNil:__string__])

#define FETCH_VALID_STRING_OR_EMPTY_STRING(__string__) ([[CGMacros sharedInstance] fetchValidStringOrEmptyString:__string__])

#define CAN_CAMERA_WITH_VIEWCONTROLLER(__viewController__) ([[CGMacros sharedInstance] canCameraWithViewController:__viewController__])

#define CAN_OPEN_PHOTO_WITH_VIEWCONTROLLER(__viewController__) ([[CGMacros sharedInstance] canOpenPhotoWithViewController:__viewController__])

#define CAN_RECORD_WITH_VIEWCONTROLLER(__viewController__) ([[CGMacros sharedInstance] canRecordWithViewController:__viewController__])

#define CHECK_IP_FORMAT(__ipAddress__) ([[CGMacros sharedInstance] isValidatIP:__ipAddress__])

#define SHOW_WAIT_MESSAGE(__message__, __viewController__) ([[CGMacros sharedInstance] showWaitMessageWithMessage:__message__ viewController:__viewController__])
#define SHOW_WAIT_MESSAGE_AT_TOP(__message__) ([[CGMacros sharedInstance] showMessageAtTopWithMessage:__message__])
#define STOP_SHOW_WAIT_MESSAGE() ([[CGMacros sharedInstance] stopShowWaitMessage])
#define SIZE_STRING_WITH_BYTE_LENGTH(__length__) ([[CGMacros sharedInstance] sizeStringWithByteLength:__length__])
#define FETCH_LAUNCH_IMAGE() ([[CGMacros sharedInstance] fetchLaunchImage])
#define IS_STRING_EMPTY(__string__) ([[CGMacros sharedInstance] isStringEmptyWithString:__string__])

#pragma mark -
#pragma mark class

#import <UIKit/UIKit.h>

@class Attachment;
@interface CGMacros : NSObject

+ (nullable CGMacros*) sharedInstance;

- (CGFloat)getLabelWidthWithContent:(nullable NSString*)content withLabelHeight:(CGFloat)height withFont:(nullable UIFont*)font;

- (CGFloat)getLabelHeightWithContent:(nullable NSString*)content withLabelWidth:(CGFloat)width withFont:(nullable UIFont*)font;

- (CGFloat)getLabelHeightWithContent:(nullable NSString *)content withLabelWidth:(CGFloat)width withFont:(nullable UIFont *)font withLineSpace:(CGFloat)lineSpace;

- (void)alertWithMessage:(nullable NSString*)message target:(nullable id)target completion:(void (^ __nullable)(UIAlertAction * __nullable action))completion;

- (void)showMessageWithMessage:(nullable NSString*)message;

- (nullable NSString*)generatedId;

- (nullable NSString*)timeStamp;

- (BOOL)validateEmail: (nullable NSString*) candidate;

- (nullable NSString*)timeDescriptionWithDate:(nullable NSDate*)date;

- (void)playSoundEffectWithSoundType:(cgSoundType)soundType;

- (void)startActivityWithEnable:(BOOL)enable;

- (void)stopActivity;

- (nullable NSArray*)searchWithKey:(nullable NSString*)key inArray:(nullable NSArray*)dataArray;

- (nullable NSArray*)searchWithKey:(nullable NSString*)key inContactDataArray:(nullable NSArray*)dataArray;

- (nullable UIImage *)image:(nullable UIImage *)image fillSize:(CGSize)viewsize;


- (void)showPromptWithPromptType:(cgPromptType)promptType isSucceed:(BOOL)isSucceed;
//- (void)showSignSucceed;
//- (void)showSaveSucceed;
//- (void)showAddSucceed;
//- (void)showAddFail;
//
//- (void)showAddPwSucceed;
//- (void)showAddPwFail;
//- (void)showRemovePwSucceed;
//- (void)showRemovePwFail;

- (void)showDownloadingStatus;

- (void)removeDownloadingStatus;

- (void)showPrompt:(nullable NSString*)prompt;

- (NSInteger)indexWithString:(nullable NSString*)testString;

- (nullable NSString*)fetchStringWithString:(nullable NSString*)testString;

- (nullable NSString*)getPreferredLanguage;

- (BOOL)isCurrentLanguageChinese;

- (nullable NSString*)dateStringOfmailContent:(nullable NSDate*)date;

- (nullable NSString*)shortOfDateStringOfmailContent:(nullable NSDate*)date;

- (CGFloat)scaleFactor;

- (CGFloat)scaleFactor2;

- (CGFloat)scaleFactorY;

- (BOOL)valiMobile:(nullable NSString *)mobile;

- (nullable NSString*)attachmentExtension:(nullable NSString*)mimeType;

- (BOOL)judgeCheckMailResult:(kcgCheckMailResult)kcgCheckMailResult viewController:(nullable UIViewController*)viewController;

- (BOOL)ifNeedUseProxy;

- (nullable NSString*)fetchValidStringOrNil:(nullable NSString*)string;
- (nullable NSString*)fetchValidStringOrEmptyString:(nullable NSString*)string;

- (BOOL)canCameraWithViewController:(nullable UIViewController*)viewController;
- (BOOL)canOpenPhotoWithViewController:(nullable UIViewController*)viewController;
- (BOOL)canRecordWithViewController:(nullable UIViewController*)viewController;

- (BOOL)isValidatIP:(nullable NSString *)ipAddress;

- (void)showWaitMessageWithMessage:(nullable NSString*)message viewController:(nullable UIViewController*)viewController;
- (void)showMessageAtTopWithMessage:(nullable NSString*)message;
- (void)stopShowWaitMessage;
- (nullable NSString*)sizeStringWithByteLength:(NSInteger)length;
/** 获取launch图 */
- (nullable UIImage*)fetchLaunchImage;
/** 判断字符串是否空串 */
- (BOOL)isStringEmptyWithString:(nullable NSString*)string;

@end

#endif
