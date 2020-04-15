//
//  FileDetailViewController.m
//  DecryptionAssistant
//
//  Created by Granger on 2020/4/15.
//  Copyright © 2020 sain. All rights reserved.
//

#import "FileDetailViewController.h"
#import <WebKit/WebKit.h>

@interface FileDetailViewController ()<WKNavigationDelegate, WKUIDelegate>

@property(nonatomic, strong) WKWebView *webView;
@property (nonatomic,strong) NSString *content;
@property (nonatomic,strong) NSString *titleString;

@end

@implementation FileDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initWithViewFrame];
    [self initEvent];
    
    [self initData];
    
}

-(instancetype)initWithMessage:(NSString*)message title:(NSString*)title {
    self = [super init];
    if (self) {
        self.content = message;
        self.titleString = title;
        [self loadDataWithMessage:message];
    }
    return self;
}

-(void)initView {
    [self.leftButton setTitle:@"" forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageNamed:@"safemail_top_back"] forState:UIControlStateNormal];
    [self.navigationView addSubview:self.leftButton];
    
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
    
}

-(WKWebView*)webView {
    if (!_webView) {
        //js脚本 （脚本注入设置网页样式）
        NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
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
        _webView = webView;
        _webView.navigationDelegate = self;
        
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
        [self.view addSubview:_webView];
    }
    return _webView;
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
    [self.navigationController popViewControllerAnimated:YES];
}

// 页面加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    
}

// 页面加载失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(nonnull NSError *)error {
    NSLog(@"加载失败%@", error.userInfo);
}

@end
