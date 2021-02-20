//
//  WebViewTestViewController.m
//  CESHI
//
//  Created by gfy on 2017/9/22.
//  Copyright © 2017年 gfy. All rights reserved.
//

#import "WebViewTestViewController.h"
#import "WebViewJavascriptBridge.h"
#import "FileManager.h"

@interface WebViewTestViewController ()<UIWebViewDelegate>
{

    UIScrollView *scrollView;
    
    
}

@property WebViewJavascriptBridge* bridge;
@property (nonatomic,strong) UIWebView *webView;
@property (nonatomic,assign) BOOL isEdit;

@end

@implementation WebViewTestViewController
- (void)dealloc {
    NSLog(@"%s",__func__);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self createWebView];
}

-(void)initView {
    [self.leftButton setTitle:@"" forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageNamed:@"safemail_top_back"] forState:UIControlStateNormal];
    [self.navigationView addSubview:self.leftButton];
    
    [self.rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [self.navigationView addSubview:self.rightBtn];
    
    self.navigationView.backgroundColor = RGB(0, 164, 102);
    
    self.titleLabel.textColor = [UIColor whiteColor];
    [self.navigationView addSubview:self.titleLabel];
    
}

- (void)createWebView {

    self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, kNavigationBarHeight, kScreenWidth, kScreenHeight-kNavigationBarHeight-kTBarBottomHeight)];
    self.webView.delegate = self;
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *path = [paths objectAtIndex:0];
//    NSString *basePath = [NSString stringWithFormat:@"%@/%@",path,@"QueHTML/"];
//    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"123" ofType:@"html"];
//    NSString *htmlString2 = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
//    [webView loadHTMLString:htmlString2 baseURL:[NSURL URLWithString:basePath]];
    
    _bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    [_bridge setWebViewDelegate:self];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"222.doc" ofType:@""];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];

}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"%s",__func__);
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"%s",__func__);
    
//    NSString *dir = [FileManager.shared recentOpenFilePath];
//    NSString *file = [dir stringByAppendingPathComponent:@"aaa.doc"];
//    [currentURL writeToFile:file atomically:YES encoding:NSUTF8StringEncoding error:nil];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"%s",__func__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)rightButtonClick {
    NSString *rightTitleString = @"编辑";
    if (_isEdit) {
        //保存
//        WS(weakSelf);
        [_bridge callHandler:@"saveExcel" data:nil responseCallback:^(id response) {
            NSLog(@"saveDoc responded: %@", response);
            if ([response isKindOfClass:[NSString class]]) {
                NSString *dir = [FileManager.shared recentOpenFilePath];
                NSString *file = [dir stringByAppendingPathComponent:@"abc.doc"];
                NSString *string = [NSString stringWithFormat:@"<!DOCTYPE html><html><head></head><body>%@</body></html>",response];
                NSData *data =[string dataUsingEncoding:NSUTF8StringEncoding];
//                NSString *jsonString = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
                [data writeToFile:file atomically:YES];
//                [jsonString jk_writeToFile:file atomically:YES];
                
            }
        }];
    }else {
        //编辑
        WS(weakSelf);
        rightTitleString = @"保存";
        dispatch_async_on_main_queue(^{
            NSURL *url = [NSURL URLWithString:@"http://192.168.0.27:8088/test/js_excel/vue_doc.html"];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            
    //                NSString *path = [[NSBundle mainBundle] pathForResource:@"js_excel/vue_excel.html" ofType:@""];
    //
    //                NSURL *url = [NSURL fileURLWithPath:path];
            
    //        NSURLRequest *request = [NSURLRequest requestWithURL:url];
            [weakSelf.webView loadRequest:request];
    //                [weakSelf.webView loadFileURL:url allowingReadAccessToURL:url];
    //                NSString * str  =[[NSString alloc] initWithData:[data bytes] encoding:NSUTF8StringEncoding];
            NSString *currentURL = [weakSelf.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML"];
            NSLog(@"%@",currentURL);
            [weakSelf.bridge callHandler:@"getExcel" data:currentURL responseCallback:^(id response) {
                NSLog(@"getExcel responded: %@", response);
            }];
            
            
        });
    }
    _isEdit = !_isEdit;
    [self.rightBtn setTitle:rightTitleString forState:UIControlStateNormal];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
