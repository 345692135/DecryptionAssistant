//
//  FileDetailViewController.m
//  DecryptionAssistant
//
//  Created by Granger on 2020/4/15.
//  Copyright © 2020 sain. All rights reserved.
//

#import "FileDetailViewController.h"
#import <WebKit/WebKit.h>
#import "FileManager.h"
#import "LAWExcelTool.h"
#include <xlsxwriter/xlsxwriter.h>
#import "ZContent.h"
#import "WebViewJavascriptBridge.h"

@interface FileDetailViewController ()<WKNavigationDelegate, WKUIDelegate,LAWExcelParserDelegate>

@property(nonatomic, strong) WKWebView *webView;
@property(nonatomic, strong) UITextView *myTextView;
@property (nonatomic,strong) NSString *content;
@property (nonatomic,strong) NSString *filePath;
@property (nonatomic,strong) NSString *originalFilePath;
@property (nonatomic,strong) NSString *titleString;
@property (nonatomic,assign) BOOL isEdit;
@property (nonatomic,strong) UIDocumentInteractionController *documentInteractionController;
@property (nonatomic,strong) NSMutableArray *datas;
@property WebViewJavascriptBridge* bridge;
@property (nonatomic,assign) BOOL isRecentOpenFile;

@end

static lxw_workbook  *workbook;
static lxw_format *contentformat;// 内容的样式

@implementation FileDetailViewController

static NSDictionary* mimeTypes = nil;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initWithViewFrame];
    [self initEvent];
    
    [self initData];
    
}

-(instancetype)initWithMessage:(NSString*)message title:(NSString*)title isRecentOpenFile:(BOOL)isRecentOpenFile {
    self = [super init];
    if (self) {
        self.content = message;
        self.titleString = title;
        self.isRecentOpenFile = isRecentOpenFile;
        [self loadDataWithMessage:message];
    }
    return self;
}

-(instancetype)initWithFilePath:(NSString*)filePath originalFilePath:(NSString*)originalFilePath title:(NSString*)title isRecentOpenFile:(BOOL)isRecentOpenFile {
    self = [super init];
    if (self) {
        self.filePath = filePath;
        self.originalFilePath = originalFilePath;
        self.titleString = title;
        self.isRecentOpenFile = isRecentOpenFile;
        [self loadDataWithFilePath:filePath];
    }
    return self;
}

-(void)initView {
    [self.leftButton setTitle:@"" forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageNamed:@"safemail_top_back"] forState:UIControlStateNormal];
    [self.navigationView addSubview:self.leftButton];
    
    if (self.isRecentOpenFile) {
        [self.rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [self.navigationView addSubview:self.rightBtn];
    }
    
    self.navigationView.backgroundColor = RGB(0, 164, 102);
    
    self.titleLabel.text = kIsNULLString(self.titleString)?@"文件详情":self.titleString;
    self.titleLabel.textColor = [UIColor whiteColor];
    [self.navigationView addSubview:self.titleLabel];
    
}

-(void)initWithViewFrame {
    
}

-(void)initEvent {
    
}

-(void)initData {
    mimeTypes = @{
    @"3gp": @"video/3gpp",
    @"apk": @"application/vnd.android.package-archive",
    @"asf": @"video/x-ms-asf",
    @"avi": @"video/x-msvideo",
    @"bin": @"application/octet-stream",
    @"bmp": @"image/bmp",
    @"c": @"text/plain",
    @"class": @"application/octet-stream",
    @"conf": @"text/plain",
    @"cpp": @"text/plain",
    @"css": @"text/css",
    @"doc": @"application/msword",
    //                      @"doc": @"application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    @"docx": @"application/msword",//@"application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    @"exe": @"application/octet-stream",
    @"gif": @"image/gif",
    @"gtar": @"application/x-gtar",
    @"gz": @"application/x-gzip",
    @"h": @"text/plain",
    @"htm": @"text/html",
    @"html": @"text/html",
    @"jar": @"application/java-archive",
    @"java": @"text/plain",
    @"jpeg": @"image/jpeg",
    @"jpg": @"image/jpeg",
    @"js": @"application/x-javascript",
    @"log": @"text/plain",
    @"m3u": @"audio/x-mpegurl",
    @"m4a": @"audio/mp4a-latm",
    @"m4b": @"audio/mp4a-latm",
    @"m4p": @"audio/mp4a-latm",
    @"m4u": @"video/vnd.mpegurl",
    @"m4v": @"video/x-m4v",
    @"mov": @"video/quicktime",
    @"mp2": @"audio/x-mpeg",
    @"mp3": @"audio/x-mpeg",
    @"mp4": @"video/mp4",
    @"mpc": @"application/vnd.mpohun.certificate",
    @"mpe": @"video/mpeg",
    @"mpeg": @"video/mpeg",
    @"mpg": @"video/mpeg",
    @"mpg4": @"video/mp4",
    @"mpga": @"audio/mpeg",
    @"msg": @"application/vnd.ms-outlook",
    @"ogg": @"audio/ogg",
    @"pdf": @"application/pdf",
    @"png": @"image/png",
    @"pps": @"application/vnd.ms-powerpoint",
    @"ppt": @"application/vnd.ms-powerpoint",
    @"pptx": @"application/vnd.openxmlformats-officedocument.presentationml.presentation",
    @"prop": @"text/plain",
    @"rc": @"text/plain",
    @"rmvb": @"audio/x-pn-realaudio",
    @"rtf": @"application/rtf",
    @"sh": @"text/plain",
    @"tar": @"application/x-tar",
    @"tgz": @"application/x-compressed",
    @"txt": @"text/plain",
    @"wav": @"audio/x-wav",
    @"wma": @"audio/x-ms-wma",
    @"wmv": @"audio/x-ms-wmv",
    @"wps": @"application/vnd.ms-works",
    @"xml": @"text/plain",
    @"xls": @"application/vnd.ms-excel",
    @"xlsx": @"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    @"z": @"application/x-compress",
    @"zip": @"application/x-zip-compressed"
    };
    
    _bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    [_bridge setWebViewDelegate:self];
    
//    [_bridge registerHandler:@"getExcel" handler:^(id data, WVJBResponseCallback responseCallback) {
//        NSLog(@"getExcel called: %@", data);
//        responseCallback(@"Response from getExcel");
//    }];
    
//    [_bridge callHandler:@"saveExcel" data:self.datas];
    
}

-(WKWebView*)webView {
    if (!_webView) {
        //js脚本 （脚本注入设置网页样式）
//        NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
        
        
        NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta); var imgs = document.getElementsByTagName('img');for (var i in imgs){imgs[i].style.maxWidth='100%';imgs[i].style.height='auto';}";
        
        //注入
        WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        WKUserContentController *wkUController = [[WKUserContentController alloc] init];
        [wkUController addUserScript:wkUScript];
        //配置对象
        WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
        wkWebConfig.userContentController = wkUController;
        //改变初始化方法 （这里一定要给个初始宽度，要不算的高度不对）
        WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight, kScreenWidth, kScreenHeight-kNavigationBarHeight-kTBarBottomHeight) configuration:wkWebConfig];
        webView.scrollView.bounces = NO;
        webView.UIDelegate = self;
        webView.navigationDelegate = self;
        _webView = webView;
        [self.view addSubview:_webView];
//    // js配置
//        WKUserContentController *userContentController = [[WKUserContentController alloc] init];
//    //    [userContentController addScriptMessageHandler:weakself name:@"jsCallOC"];
//
//        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc]init];
//        configuration.allowsInlineMediaPlayback = true;
//        configuration.userContentController = userContentController;
//        [configuration.preferences setValue:@YES forKey:@"allowFileAccessFromFileURLs"];
//        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight, kScreenWidth, kScreenHeight-kNavigationBarHeight-kTBarBottomHeight-kYSBL(45)) configuration:configuration];
//        _webView.UIDelegate = self;
//        _webView.navigationDelegate = self;
    }
    return _webView;
}

-(UITextView*)myTextView {
    if (!_myTextView) {
        _myTextView = [UITextView new];
        _myTextView.frame = CGRectMake(0, kNavigationBarHeight, kScreenWidth, kScreenHeight-kNavigationBarHeight-kTBarBottomHeight);
        _myTextView.scrollEnabled = YES;
    }
    return _myTextView;
}

-(void)loadDataWithFilePath:(NSString*)filePath {
        // 2.创建url（注意替换为实际路径)
    @try {
        if ([[filePath pathExtension].lowercaseString isEqualToString:@"txt"] || [[filePath pathExtension].lowercaseString isEqualToString:@"text"]) {
            NSString *message = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];;
            [self.view addSubview:self.myTextView];
            self.myTextView.text = message;
            self.myTextView.editable = NO;
        }else {
            NSURL *url = [NSURL fileURLWithPath:filePath];
            // 3.加载文件
            [self.webView loadFileURL:url allowingReadAccessToURL:url];
        }
        
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
}

-(void)loadDataWithMessage:(NSString*)message {
    NSString* content = message;//[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSString *htmlString = [NSString stringWithFormat:@"<html> \n"
    "<head> \n"
    "<style type=\"text/css\"> \n"
    "body {font-size:15px;}\n"
    "</style> \n"
    "</head> \n"
    "<body>"
    "<script type='text/javascript'>"
    "window.onload = function(){\n"
    "var $img = document.getElementsByTagName('img');\n"
    "for(var p in  $img){\n"
    " $img[p].style.width = '100%%';\n"
    "$img[p].style.height ='auto'\n"
    " let height = document.body.offsetHeight;\n"   "window.webkit.messageHandlers.imagLoaded.postMessage(height);\n"
    "}\n"
    "}"
    "</script>%@"
    "</body>"
    "</html>", content];
    if (!kIsNULLString(content)) {
        self.content = content;
    }
    [self.webView loadHTMLString:htmlString baseURL:nil];
    
}

-(void)back {
    if (self.filePath && [self.filePath containsString:@"Inbox/"]) {
        [FileManager.shared deleteFileWithFilePath:self.filePath];
    }
    NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileDir = [documentDir stringByAppendingPathComponent:@"download"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:fileDir])
    {
        NSArray *tempFileList = [[NSArray alloc] initWithArray:[fileManager contentsOfDirectoryAtPath:fileDir error:nil]];
        if (tempFileList.count) {
            NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:fileDir];
            for (NSString *fileName in enumerator) {
                [[NSFileManager defaultManager] removeItemAtPath:[fileDir stringByAppendingPathComponent:fileName] error:nil];
            }
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -编辑按钮

-(void)rightButtonClick {
    
    //txt文本编辑 其他文本类型也可以加进来
    if ([self.filePath.pathExtension.lowercaseString isEqualToString:@"txt"] || [self.filePath.pathExtension.lowercaseString isEqualToString:@"text"]) {
        self.isEdit = !self.isEdit;
        NSString *rightTitleString = @"编辑";
        if (self.isEdit) {
            rightTitleString = @"保存";

        }else {
            //保存内容
            [self.myTextView.text writeToFile:self.filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
//            if (self.originalFilePath) {
//                //未加密的文件保存
//                [self.myTextView.text writeToFile:self.originalFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
//            }

        }

        self.myTextView.editable = self.isEdit;
        [self.rightBtn setTitle:rightTitleString forState:UIControlStateNormal];

    }else if ([self.filePath.pathExtension.lowercaseString isEqualToString:@"xlsx"] || [self.filePath.pathExtension.lowercaseString isEqualToString:@"xls"]) {
        self.isEdit = !self.isEdit;
        NSString *rightTitleString = @"编辑";
        if (self.isEdit) {
            rightTitleString = @"保存";
            //进入编辑状态
            [LAWExcelTool shareInstance].delegate = self;
            [[LAWExcelTool shareInstance] parserExcelWithPath:self.filePath];

        }else {
            WS(weakSelf);
            [_bridge callHandler:@"saveExcel" data:nil responseCallback:^(id response) {
                NSLog(@"saveExcel responded: %@", response);
                if ([response isKindOfClass:[NSArray class]]) {
                    NSArray *array = [NSArray arrayWithArray:response];
                    dispatch_async_on_main_queue(^{
                        //结束编辑状态，保存内容
                        [weakSelf createXlsxFileWithDatas:array];
                        //刷新界面
                        [weakSelf loadDataWithFilePath:weakSelf.filePath];

                    });
                }
            }];

        }

        [self.rightBtn setTitle:rightTitleString forState:UIControlStateNormal];

    }
    
//    NSLog(@"path=%@",self.filePath);
//    self.isEdit = !self.isEdit;
//    NSString *rightTitleString = @"编辑";
//    if (self.isEdit) {
//        rightTitleString = @"保存";
//    }else {
//        //编辑
//    }

//    [self.rightBtn setTitle:rightTitleString forState:UIControlStateNormal];
    
//    [self exportFileToOtherApp:self.filePath];
     
    
    //excel编辑
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"testDemo" ofType:@"html"];
//    [self loadDataWithFilePath:filePath];
     
    
    
}


/// 保存xls数据
/// @param datas datas description
-(void)createXlsxFileWithDatas:(NSArray*)datas {
//    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
//    NSString *filename = [documentPath stringByAppendingPathComponent:@"c_demo.xlsx"];
    workbook  = workbook_new([self.filePath UTF8String]);// 创建新xlsx文件，路径需要转成c字符串
    [self setupFormat];
    
    NSMutableArray *sheetNames = [NSMutableArray new];
    for (NSDictionary *dic in datas) {
        if (![sheetNames containsObject:dic[@"sheetName"]]) {
            [sheetNames addObject:dic[@"sheetName"]];
        }
    }
    NSMutableArray *sheetDataArray = [NSMutableArray new];
    for (NSString *string in sheetNames) {
        NSMutableArray *sheetArray = [NSMutableArray new];
        for (NSDictionary *dic in datas) {
            if ([string isEqualToString:dic[@"sheetName"]]) {
                [sheetArray addObject:dic];
            }
        }
        if (sheetArray.count) {
            [sheetDataArray addObject:sheetArray];
        }
    }
    
    for (NSArray *array in sheetDataArray) {
        NSDictionary *content = array[0];
        NSString *sheetName = content[@"sheetName"];
        lxw_worksheet *worksheet = workbook_add_worksheet(workbook, [sheetName UTF8String]);// 创建sheet
        worksheet_set_column(worksheet, 0, 3, 20, NULL);
        
        for (int i = 0; i < array.count; i++) {
            NSDictionary *content = array[i];
            NSString *keyName = content[@"keyName"];
            if (kIsNULLString(keyName)) {
                continue;
            }
            
            NSMutableArray *names = [NSMutableArray new];
            for (int i = 0; i < keyName.length; i++) {
                NSRange range = NSMakeRange(i,1);
                NSString *word = [keyName substringWithRange:range];
                [names addObject:word];
            }
            
    //        NSString *colString = @"";
            NSString *rowString = @"";
            NSMutableArray *cols = [NSMutableArray new];
            NSMutableArray *rows = [NSMutableArray new];
            
            for (NSString *string in names) {
                if ([self isLetter:string]) {
                    [cols addObject:string];
                }else {
                    [rows addObject:string];
                }
            }
            
    //        colString = [cols componentsJoinedByString:@""];
            rowString = [rows componentsJoinedByString:@""];
            
            int col = [self getColumnNumberWithCols:cols];
            int row = rowString.intValue-1;
            
            NSString *contentString = [NSString stringWithFormat:@"%@",content[@"value"]];
            worksheet_write_string(worksheet, row, col, [contentString UTF8String], contentformat);
            
        }
    }
    
    workbook_close(workbook);
    
}

-(int)getColumnNumberWithCols:(NSArray*)cols {
    int col = 0;
    //AB
    for (NSInteger i = 0; i < cols.count; i++) {
        if (i == 0) {
            col += [self getIndexWithChar:cols[cols.count-1]];
        }else {
            int value = powl(26, i);
            col += value*([self getIndexWithChar:cols[cols.count-1-i]]);
        }
    }
    
    
    return col;
}

-(int)getIndexWithChar:(NSString*)charString {
    int index = 0;
    if ([charString.uppercaseString isEqualToString:@"A"]) {
        index = 0;
    }else if ([charString.uppercaseString isEqualToString:@"B"]) {
        index = 1;
    }else if ([charString.uppercaseString isEqualToString:@"C"]) {
        index = 2;
    }else if ([charString.uppercaseString isEqualToString:@"D"]) {
        index = 3;
    }else if ([charString.uppercaseString isEqualToString:@"E"]) {
        index = 4;
    }else if ([charString.uppercaseString isEqualToString:@"F"]) {
        index = 5;
    }else if ([charString.uppercaseString isEqualToString:@"G"]) {
        index = 6;
    }else if ([charString.uppercaseString isEqualToString:@"H"]) {
        index = 7;
    }else if ([charString.uppercaseString isEqualToString:@"I"]) {
        index = 8;
    }else if ([charString.uppercaseString isEqualToString:@"J"]) {
        index = 9;
    }else if ([charString.uppercaseString isEqualToString:@"K"]) {
        index = 10;
    }else if ([charString.uppercaseString isEqualToString:@"L"]) {
        index = 11;
    }else if ([charString.uppercaseString isEqualToString:@"M"]) {
        index = 12;
    }else if ([charString.uppercaseString isEqualToString:@"N"]) {
        index = 13;
    }else if ([charString.uppercaseString isEqualToString:@"O"]) {
        index = 14;
    }else if ([charString.uppercaseString isEqualToString:@"P"]) {
        index = 15;
    }else if ([charString.uppercaseString isEqualToString:@"Q"]) {
        index = 16;
    }else if ([charString.uppercaseString isEqualToString:@"R"]) {
        index = 17;
    }else if ([charString.uppercaseString isEqualToString:@"S"]) {
        index = 18;
    }else if ([charString.uppercaseString isEqualToString:@"T"]) {
        index = 19;
    }else if ([charString.uppercaseString isEqualToString:@"U"]) {
        index = 20;
    }else if ([charString.uppercaseString isEqualToString:@"V"]) {
        index = 21;
    }else if ([charString.uppercaseString isEqualToString:@"W"]) {
        index = 22;
    }else if ([charString.uppercaseString isEqualToString:@"X"]) {
        index = 23;
    }else if ([charString.uppercaseString isEqualToString:@"Y"]) {
        index = 24;
    }else if ([charString.uppercaseString isEqualToString:@"Z"]) {
        index = 25;
    }
    return index;
}

#pragma mark -单元格样式
-(void)setupFormat{
    contentformat = workbook_add_format(workbook);
    format_set_font_size(contentformat, 10);
    format_set_left(contentformat, LXW_BORDER_THIN);// 左边框：双线边框
    format_set_bottom(contentformat, LXW_BORDER_THIN);// 下边框：双线边框
    format_set_right(contentformat, LXW_BORDER_THIN);// 右边框：双线边框
    
}

- (void)exportFileToOtherApp:(NSString*)filePath

{
    NSURL *url = [NSURL fileURLWithPath:filePath];

    self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];

//    [self.documentInteractionController setDelegate:self];

    CGRect rect = CGRectMake(self.view.bounds.size.width, 40.0, 0.0, 0.0);

    [self.documentInteractionController presentOpenInMenuFromRect:rect inView:self.view animated:YES];

}

// 页面加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
//    [webView evaluateJavaScript:jScript completionHandler:nil];
    
}

// 页面加载失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(nonnull NSError *)error {
    NSLog(@"加载失败%@", error.userInfo);
}


//- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
//{
////    NSString *_webUrlStr = navigationAction.request.URL.absoluteString;
////    NSString *lastName =[[_webUrlStr lastPathComponent] lowercaseString];
////
////    NSString* mimeType = [self mimeTypeForXlsOrDocOrPptWithPath:navigationAction.request.URL.absoluteString];
////    if (mimeType) {
////        NSData *data = [NSData dataWithContentsOfURL:navigationAction.request.URL];
////        [self.webView loadData:data MIMEType:mimeType characterEncodingName:@"UTF-8" baseURL:nil];
////    }
////
////    decisionHandler(WKNavigationActionPolicyAllow);
//}

- (NSString*)mimeTypeForXlsOrDocOrPptWithPath:(NSString*)path
{
    if (!path || [path isEqual:[NSNull null]] || [path isEqualToString:@""]) {
        return nil;
    }
    
    /** 获取后缀 */
    NSString* extension = path.pathExtension;
    if (!extension
        || [extension isEqual:[NSNull null]]
        || [extension isEqualToString:@""]) {
        return nil;
    }
    extension = extension.lowercaseString;
    
    
    /** 获取文件类型 */
    int fileType = - 1; //-1：不可用 0：表格类型 1：文档类型 2：演示文稿
    
    if ([extension isEqualToString:@"xls"]
        || [extension isEqualToString:@"xlsx"]
        || [extension isEqualToString:@"xlt"]
        || [extension isEqualToString:@"xltx"]
        || [extension isEqualToString:@"xlsm"]
        || [extension isEqualToString:@"xltm"]
        || [extension isEqualToString:@"et"]
        || [extension isEqualToString:@"ett"]) {
        fileType = 0;
    }
    else if ([extension isEqualToString:@"doc"]
             || [extension isEqualToString:@"docx"]
             || [extension isEqualToString:@"dot"]
             || [extension isEqualToString:@"dotx"]
             || [extension isEqualToString:@"wps"]
             || [extension isEqualToString:@"wpt"]) {
        fileType = 1;
    }
    else if ([extension isEqualToString:@"ppt"]
             || [extension isEqualToString:@"pptx"]
             || [extension isEqualToString:@"pot"]
             || [extension isEqualToString:@"potx"]
             || [extension isEqualToString:@"dps"]
             || [extension isEqualToString:@"dpt"]) {
        fileType = 2;
    }
    if (fileType == -1) {
        return nil;
    }
    
    /** 获取扩展类型 */
    NSData* data = [[NSData alloc] initWithContentsOfFile:path];
    if (!data
        || data.length < 4) {
        return nil;
    }
    
    int extensionType = -1; //-1：不可用 0:非扩展格式 1:扩展格式
    Byte *bytesArray = (Byte*)[data bytes];
    if (bytesArray[0] == 0xD0
        && bytesArray[1] == 0xCF
        && bytesArray[2] == 0x11
        && bytesArray[3] == 0xE0) {
        extensionType = 0;
    }
    else if (bytesArray[0] == 0x50
             && bytesArray[1] == 0x4B
             && bytesArray[2] == 0x03
             && bytesArray[3] == 0x04) {
        extensionType = 1;
    }
    if (extensionType == -1) {
        return nil;
    }
    
    
    /** 拼接后缀字符串 */
    NSString* prefix;
    if (fileType == 0) {
        prefix = @"xls";
    }
    else if (fileType == 1) {
        prefix = @"doc";
    }
    else if (fileType == 2) {
        prefix = @"ppt";
    }
    if (!prefix) {
        return nil;
    }
    NSString* suffix = extensionType == 0 ? @"" : @"x";
    NSString* extension_real = [[NSString alloc] initWithFormat:@"%@%@", prefix, suffix];
    
    
    /** 获取文件格式字符串 */
    NSString* mimeType = mimeTypes[extension_real];
    if (!mimeType) {
        return nil;
    }
    
    return mimeType;
}


#pragma mark -懒加载

-(NSMutableArray*)datas {
    if (!_datas) {
        _datas = [NSMutableArray new];
    }
    return _datas;
}

#pragma mark -Excel解析 LAWExcelParserDelegate

- (void)parser:(LAWExcelTool *)parser success:(id)responseObj
{
//    NSLog(@"%@",responseObj);
    if ([responseObj isKindOfClass:[NSArray class]]) {
        [self.datas removeAllObjects];
        [self.datas addObjectsFromArray:responseObj];
        [self dataFormat];
        
        
//        NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"keyName" ascending:YES];
//        NSArray* sortPackageResListArr = [self.datas sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
//        NSLog(@"%@",sortPackageResListArr);
    }
}

-(void)dataFormat {
    WS(weakSelf);
    NSMutableArray *myData = [NSMutableArray new];
    for (ZContent *content in self.datas) {
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:kIsNULLString(content.sheetName)?@"":content.sheetName forKey:@"sheetName"];
        [dic setObject:kIsNULLString(content.keyName)?@"":content.keyName forKey:@"keyName"];
        [dic setObject:kIsNULLString(content.value)?@"":content.value forKey:@"value"];
        [myData addObject:dic];
    }
    [self clearCache];
    dispatch_async_on_main_queue(^{
        BOOL isLocal = YES;
        if (isLocal) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"js_excel/vue_excel.html" ofType:@""];
            NSURL *url = [NSURL fileURLWithPath:path];
            [weakSelf.webView loadFileURL:url allowingReadAccessToURL:url];
        }else {
            NSURL *url = [NSURL URLWithString:@"http://192.168.0.27:8088/test/js_excel/vue_excel.html"];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            [weakSelf.webView loadRequest:request];
        }
        
        [weakSelf.bridge callHandler:@"getExcel" data:myData responseCallback:^(id response) {
            NSLog(@"getExcel responded: %@", response);
        }];
        
    });
    
    
}

-(void)clearCache {
    dispatch_sync_on_main_queue(^{
        NSSet*websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];

        NSDate*dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            
        }];
    });

}

//判断是不是字母

- (BOOL)isLetter:(NSString *)str

{
    if ([str characterAtIndex:0] >= 'a' && [str characterAtIndex:0] <= 'z') {
        return YES;

    }else if ([str characterAtIndex:0] >= 'A' && [str characterAtIndex:0] <= 'Z') {
        return YES;

    }

    return NO;

}

//-(NSArray*)getChars {
//    return [NSArray arrayWithObjects:(nonnull id), ..., nil];
//}

@end
