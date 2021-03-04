//
//  AnyuanLoginViewController.m
//  SecretMail
//
//  Created by Granger on 2020/2/11.
//  Copyright © 2020 granger. All rights reserved.
//

#import "AnyuanLoginViewController.h"
#import "BaseNaviViewController.h"
#import "GPLoadingView.h"
#import "MISPMailHelper.h"
#import "CGMacros.h"
#import "FileListViewController.h"
#import "GestureViewController.h"
#import "GestureVerifyViewController.h"
#import "PCCircleViewConst.h"
#import "AppDelegate.h"
#import "GSWatermarkView.h"

@interface AnyuanLoginViewController ()<UITextFieldDelegate>
{
    UIImageView *_logoIV;
    UIView *_emailView;
    UIView *_passView;

    UIImageView *_emailIV;
    UIImageView *_passIV;
    UIView *_lineView;

    UITextField *_emailField;
    UITextField *_passField;
    UIButton *_loginButton;
    UIButton *_button_eye;
    
    UIView *_line2View;
    UIView *_line3View;
    UIView *_serverView;
    UIImageView *_serverIV;
    UITextField *_serverField;
    
    UIView *_portView;
    UIImageView *_portIV;
    UITextField *_portField;
    UIView *_linePortView;
    
    GPLoadingView* _loadingIndicator;
    UILabel* _instrLable;
    BOOL _isEmailEnable;
    BOOL _isPassEnable;
    BOOL _isServerEnable;
    BOOL _isPortEnable;
    UITableView* _promptTableView;
    NSMutableArray* _mails;
    NSMutableArray* _filterMails;
    NSMutableArray* _providerDatas;
    UILabel* _promptLabel;
    kLoginStatus _loginStatus;
    
    UIButton *_checkYuButton;
    UIButton *_checkKouLingButton;
    BOOL _isYuLogin;
}
@property (nonatomic,strong) UIImageView *logoIV;
@property (nonatomic,strong) UIView *emailView;
@property (nonatomic,strong) UIView *passView;
@property (nonatomic,strong) UIView *serverView;
@property (nonatomic,strong) UIView *portView;

@property (nonatomic,strong) UIImageView *emailIV;
@property (nonatomic,strong) UIImageView *passIV;
@property (nonatomic,strong) UIImageView *serverIV;
@property (nonatomic,strong) UIImageView *portIV;
@property (nonatomic,strong) UIView *lineView;
@property (nonatomic,strong) UIView *linePortView;
@property (nonatomic,strong) UIView *line2View;
@property (nonatomic,strong) UIView *line3View;

@property (nonatomic,strong) UITextField *emailField;
@property (nonatomic,strong) UITextField *passField;
@property (nonatomic,strong) UITextField *serverField;
@property (nonatomic,strong) UITextField *portField;
@property (nonatomic,strong) UIButton *loginButton;
@property (nonatomic,strong) UIButton *button_eye;

@property (nonatomic, strong) GPLoadingView* loadingIndicator;
@property (nonatomic, strong) UILabel* instrLable;

@property (nonatomic,assign) BOOL isEmailEnable;
@property (nonatomic,assign) BOOL isPassEnable;
@property (nonatomic,assign) BOOL isServerEnable;
@property (nonatomic,assign) BOOL isPortEnable;

@property (nonatomic, strong) UITableView* promptTableView;
@property (nonatomic) NSMutableArray* mails;
@property (nonatomic) NSMutableArray* filterMails;
@property (nonatomic) NSMutableArray* providerDatas;
@property (nonatomic, strong) UILabel* promptLabel;
@property (nonatomic, assign) kLoginStatus loginStatus;

@property (nonatomic,strong) UIButton *checkYuButton;
@property (nonatomic,strong) UIButton *checkKouLingButton;
@property (nonatomic, assign) BOOL isYuLogin;

@end

@implementation AnyuanLoginViewController
@synthesize titleLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initEvent];
    [self initWithViewFrame];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initOtherView];
    self.isYuLogin = NO;
    
    [self previewLoginValidate];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    delegate.waterView.hidden = YES;
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.emailField.text.jk_trimmingWhitespace.length > 0) {
        [self showWater];
    }
    
}

-(void)showWater {
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    delegate.waterView.hidden = NO;
    [delegate.waterView removeAllSubviews];
    GSWatermarkView *markview = [[GSWatermarkView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    markview.richtext = [[NSAttributedString alloc] initWithString:self.emailField.text.jk_trimmingWhitespace attributes:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[UIFont systemFontOfSize:11],RGBA(100, 100, 100, 0.1),@(-2),RGBA(140, 140, 140, 0.1), nil] forKeys:[NSArray arrayWithObjects:NSFontAttributeName,NSForegroundColorAttributeName,NSStrokeWidthAttributeName,NSStrokeColorAttributeName, nil]]];
    markview.angle = 330;
    markview.verticalSpacing = 80;
    markview.horizonSpacing = 100;
    markview.interval = 0;
    markview.duration = 1;
    [delegate.waterView addSubview:markview];
}

-(void)previewLoginValidate {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *accountDic = [ud objectForKey:@"accountDic"];
    if (accountDic && accountDic.allKeys.count) {
        /*
        NSString* ip = self.serverField.text;
        NSString* account = self.emailField.text;
        NSString* password = self.passField.text;
        NSString* port = self.portField.text;
        BOOL isYuLogic = self.isYuLogin;
        */
        self.serverField.text = accountDic[@"ip"];
        self.emailField.text = accountDic[@"account"];
        self.passField.text = accountDic[@"password"];
        self.portField.text = accountDic[@"port"];
        NSString *isYuLogicString = accountDic[@"isYuLogic"];
        self.isYuLogin = isYuLogicString.boolValue;
        
        [self connectWayAction:self.isYuLogin?self.checkYuButton:self.checkKouLingButton];
        
        WS(weakSelf);
        if ([[PCCircleViewConst getGestureWithKey:gestureFinalSaveKey] length]) {
            GestureViewController *gestureVc = [[GestureViewController alloc] init];
            [gestureVc setType:GestureViewControllerTypeLogin];
            gestureVc.popBlock = ^{
                dispatch_sync_on_main_queue(^{
                    [weakSelf loginClick];
                });
            };
            [self.navigationController pushViewController:gestureVc animated:NO];
        }else {
            [self loginClick];
        }
        
    }else {
        [self connectWayAction:self.isYuLogin?self.checkYuButton:self.checkKouLingButton];
    }
    
}

-(void)initView {
//    [self.view bringSubviewToFront:self.navigationView];
//    [self.leftButton setTitle:@"取消" forState:UIControlStateNormal];
//    [self.leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [self.navigationView addSubview:self.leftButton];
    
    [self.view addSubview:self.logoIV];
    [self.view addSubview:self.serverView];
    [self.serverView addSubview:self.serverIV];
    [self.serverView addSubview:self.serverField];
    [self.view addSubview:self.lineView];
    
    [self.view addSubview:self.portView];
    [self.portView addSubview:self.portIV];
    [self.portView addSubview:self.portField];
    [self.view addSubview:self.linePortView];
    
    [self.view addSubview:self.emailView];
    [self.emailView addSubview:self.emailIV];
    [self.emailView addSubview:self.emailField];
    [self.view addSubview:self.line2View];
    
    [self.view addSubview:self.passView];
    [self.passView addSubview:self.passIV];
    [self.passView addSubview:self.passField];
    [self.passView addSubview:self.button_eye];
    [self.view addSubview:self.line3View];
    
    [self.view addSubview:self.loginButton];
    
    [self.view addSubview:self.checkYuButton];
    [self.view addSubview:self.checkKouLingButton];
    
    [self.view addSubview:self.instrLable];
    [self.view addSubview:self.loadingIndicator];
    
    [self.view addSubview:self.promptTableView];
    [self.view addSubview:self.promptLabel];
    
}

//-(void)back {
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

-(void)initEvent {
    WS(weakSelf);
    [self.loginButton jk_addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        
        if ([weakSelf.emailField.text isEqualToString:@""] || [weakSelf.passField.text isEqualToString:@""] || [weakSelf.serverField.text isEqualToString:@""]) {
            [ToastManager showMsg:@"数据不能为空"];
            return;
        }
//        if (![weakSelf.emailField.text validateEmail]) {
//            [ToastManager showMsg:@"邮箱格式不正确"];
//            return;
//        }
        [weakSelf loginClick];
         
//        AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//        delegate.isActiving = YES;
//        FileListViewController *vc = [[FileListViewController alloc] initWithIsRecentOpenFile:NO];
//        vc.modalPresentationStyle = 0;
//        [weakSelf.navigationController pushViewController:vc animated:YES];
    }];
    
    [self.button_eye jk_addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        [weakSelf.button_eye setSelected:!weakSelf.button_eye.selected];
        weakSelf.passField.secureTextEntry = !weakSelf.button_eye.isSelected;
    }];
    
    [[RACSignal merge:@[self.emailField.rac_textSignal, RACObserve(self.emailField, text)]] subscribeNext:^(NSString* text){
        NSString * ss = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
        weakSelf.isEmailEnable = ss.length>0;
        [weakSelf loginButtonStatusChanged];
    }];
    
    [[RACSignal merge:@[self.passField.rac_textSignal, RACObserve(self.passField, text)]] subscribeNext:^(NSString* text){
        NSString * ss = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
        weakSelf.isPassEnable = ss.length>0;
        [weakSelf loginButtonStatusChanged];
    }];
    
    [[RACSignal merge:@[self.serverField.rac_textSignal, RACObserve(self.serverField, text)]] subscribeNext:^(NSString* text){
        NSString * ss = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
        weakSelf.isServerEnable = ss.length>0;
        [weakSelf loginButtonStatusChanged];
    }];
    
    [[RACSignal merge:@[self.portField.rac_textSignal, RACObserve(self.portField, text)]] subscribeNext:^(NSString* text){
        NSString * ss = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
        weakSelf.isPortEnable = ss.length>0;
        [weakSelf loginButtonStatusChanged];
    }];
    
}

-(void)initWithViewFrame {
    WS(weakSelf);
    [self.logoIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.view).offset(kYSBL(75));
        make.width.mas_equalTo(kYSBL(75));
        make.height.mas_equalTo(kYSBL(85));
    }];
    
    [self.serverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view);
        make.right.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.logoIV.mas_bottom).offset(kYSBL(15));
        make.height.mas_equalTo(kYSBL(58));
    }];
    
    [self.serverIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.serverView).offset(kYSBL(30));
        make.centerY.equalTo(weakSelf.serverView);
        make.width.mas_equalTo(kYSBL(15));
        make.height.mas_equalTo(kYSBL(15));
    }];
    
    [self.serverField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.serverView).offset(kYSBL(62));
        make.right.equalTo(weakSelf.serverView).offset(kYSBL(-15));
        make.top.equalTo(weakSelf.serverView);
        make.height.mas_equalTo(kYSBL(58));
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view);
        make.right.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.serverView.mas_bottom);
        make.height.mas_equalTo(1);
    }];
    
    [self.portView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view);
        make.right.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.lineView.mas_bottom);
        make.height.mas_equalTo(kYSBL(58));
    }];
    
    [self.portIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.serverView).offset(kYSBL(30));
        make.centerY.equalTo(weakSelf.portView);
        make.width.mas_equalTo(kYSBL(15));
        make.height.mas_equalTo(kYSBL(15));
    }];
    
    [self.portField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.portView).offset(kYSBL(62));
        make.right.equalTo(weakSelf.portView).offset(kYSBL(-15));
        make.top.equalTo(weakSelf.portView);
        make.height.mas_equalTo(kYSBL(58));
    }];
    
    [self.linePortView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view);
        make.right.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.portView.mas_bottom);
        make.height.mas_equalTo(1);
    }];
    
    [self.emailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view);
        make.right.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.linePortView.mas_bottom);
        make.height.mas_equalTo(kYSBL(58));
    }];
    
    [self.emailIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.emailView).offset(kYSBL(30));
        make.centerY.equalTo(weakSelf.emailView);
        make.width.mas_equalTo(kYSBL(15));
        make.height.mas_equalTo(kYSBL(15));
    }];
    
    [self.emailField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.emailView).offset(kYSBL(62));
        make.right.equalTo(weakSelf.emailView).offset(kYSBL(-15));
        make.top.equalTo(weakSelf.emailView);
        make.height.mas_equalTo(kYSBL(58));
    }];
    
    [self.line2View mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view);
        make.right.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.emailField.mas_bottom);
        make.height.mas_equalTo(1);
    }];
    
    [self.passView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view);
        make.right.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.line2View.mas_bottom);
        make.height.mas_equalTo(kYSBL(58));
    }];
    
    [self.passIV mas_makeConstraints:^(MASConstraintMaker *make) {
           make.left.equalTo(weakSelf.passView).offset(kYSBL(30));
           make.centerY.equalTo(weakSelf.passView);
           make.width.mas_equalTo(kYSBL(15));
           make.height.mas_equalTo(kYSBL(15));
    }];
    
    [self.line3View mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view);
        make.right.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.passView.mas_bottom);
        make.height.mas_equalTo(1);
    }];
    
   [self.passField mas_makeConstraints:^(MASConstraintMaker *make) {
       make.left.equalTo(weakSelf.passView).offset(kYSBL(62));
       make.right.equalTo(weakSelf.button_eye).offset(kYSBL(-30));
       make.top.equalTo(weakSelf.passView);
       make.height.mas_equalTo(kYSBL(58));
   }];
    
    [self.button_eye mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.view).offset(kYSBL(-15));
        make.centerY.equalTo(weakSelf.passIV);
        make.width.mas_equalTo(kYSBL(21));
        make.height.mas_equalTo(kYSBL(15));
    }];
    
    [self.checkYuButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.passView.mas_bottom).offset(kYSBL(10));
        make.left.equalTo(weakSelf.view).offset(kYSBL(30));
        make.width.mas_equalTo(kYSBL(100));
        make.height.mas_equalTo(kYSBL(30));
    }];
    
    [self.checkKouLingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.passView.mas_bottom).offset(kYSBL(10));
        make.right.equalTo(weakSelf.view).offset(kYSBL(-30));
        make.width.mas_equalTo(kYSBL(100));
        make.height.mas_equalTo(kYSBL(30));
    }];
    
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.checkKouLingButton.mas_bottom).offset(kYSBL(50));
        make.centerX.equalTo(weakSelf.view);
        make.left.mas_equalTo(kYSBL(43));
        make.right.mas_equalTo(kYSBL(-43));
        make.height.mas_equalTo(kYSBL(45));
    }];
    
    [self.promptTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.lineView);
        make.top.equalTo(weakSelf.lineView.mas_bottom);
        make.bottom.equalTo(weakSelf.view);
        
    }];
}

/// 懒加载
-(UIImageView *)logoIV
{
    if (!_logoIV) {
        _logoIV=[UIImageView new];
        _logoIV.image = [UIImage imageNamed:@"login"];
    }
    return _logoIV;
}
-(UIView*)emailView
{
    if (!_emailView) {
        _emailView = [UIView new];
        _emailView.backgroundColor = [UIColor whiteColor];
    }
    return _emailView;
}

-(UIView*)passView
{
    if (!_passView) {
        _passView = [UIView new];
        _passView.backgroundColor = [UIColor whiteColor];
    }
    return _passView;
}

-(UIView*)serverView
{
    if (!_serverView) {
        _serverView = [UIView new];
        _serverView.backgroundColor = [UIColor whiteColor];
    }
    return _serverView;
}

-(UIView*)portView
{
    if (!_portView) {
        _portView = [UIView new];
        _portView.backgroundColor = [UIColor whiteColor];
    }
    return _portView;
}

-(UIView*)lineView
{
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = UIColorHex(0xebebeb);
    }
    return _lineView;
}

-(UIView*)line2View
{
    if (!_line2View) {
        _line2View = [UIView new];
        _line2View.backgroundColor = UIColorHex(0xebebeb);
    }
    return _line2View;
}

-(UIView*)line3View
{
    if (!_line3View) {
        _line3View = [UIView new];
        _line3View.backgroundColor = UIColorHex(0xebebeb);
    }
    return _line3View;
}

-(UIView*)linePortView
{
    if (!_linePortView) {
        _linePortView = [UIView new];
        _linePortView.backgroundColor = UIColorHex(0xebebeb);
    }
    return _linePortView;
}

-(UIImageView *)emailIV
{
    if (!_emailIV) {
        _emailIV=[UIImageView new];
        _emailIV.image = [UIImage imageNamed:@"account"];
    }
    return _emailIV;
}

-(UIImageView *)passIV
{
    if (!_passIV) {
        _passIV=[UIImageView new];
        _passIV.image = [UIImage imageNamed:@"password"];
    }
    return _passIV;
}

-(UIImageView *)serverIV
{
    if (!_serverIV) {
        _serverIV=[UIImageView new];
        _serverIV.image = [UIImage imageNamed:@"IP"];
    }
    return _serverIV;
}

-(UIImageView *)portIV
{
    if (!_portIV) {
        _portIV=[UIImageView new];
        _portIV.image = [UIImage imageNamed:@"port"];
    }
    return _portIV;
}

-(UITextField *)emailField
{
    if (!_emailField) {
        _emailField= [[UITextField alloc] init];
        _emailField.placeholder=@"帐号";
        _emailField.font=kFont(kYSBL(13));
        _emailField.textColor=UIColorHex(0x333333);
        _emailField.keyboardType = UIKeyboardTypeEmailAddress;
        [_emailField setAutocorrectionType:UITextAutocorrectionTypeNo];
//        _emailField.delegate = self;
        _emailField.clearsOnBeginEditing = NO;
        _emailField.clearButtonMode = UITextFieldViewModeWhileEditing;
//        [_emailField addTarget:self action:@selector(onTextFieldContentChanged:) forControlEvents:UIControlEventEditingChanged];
        _emailField.text = @"saien";//@"lingsian@wondersoft.cn";//@"phone01";//
    }
    return _emailField;
}

-(UITextField *)passField
{
    if (!_passField) {
        _passField= [[UITextField alloc] init];
        _passField.placeholder=@"密码";
        _passField.font=kFont(kYSBL(13));
        _passField.textColor=UIColorHex(0x333333);
        _passField.keyboardType = UIKeyboardTypeASCIICapable;
        _passField.secureTextEntry = YES;
        [_passField setAutocorrectionType:UITextAutocorrectionTypeNo];
//        _passField.delegate = self;
        _passField.clearsOnBeginEditing = NO;
        _passField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _passField.text = @"123456789";//@"abcd@1234";//
    }
    return _passField;
}

-(UITextField *)serverField
{
    if (!_serverField) {
        _serverField= [[UITextField alloc] init];
        _serverField.placeholder=@"IP";
        _serverField.font=kFont(kYSBL(13));
        _serverField.textColor=UIColorHex(0x333333);
        _serverField.keyboardType = UIKeyboardTypeEmailAddress;
        [_serverField setAutocorrectionType:UITextAutocorrectionTypeNo];
//        __serverField.delegate = self;
        _serverField.clearsOnBeginEditing = NO;
        _serverField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _serverField.text = @"210.12.140.220";//@"39.105.206.232";//
    }
    return _serverField;
}

-(UITextField *)portField
{
    if (!_portField) {
        _portField= [[UITextField alloc] init];
        _portField.placeholder=@"端口";
        _portField.font=kFont(kYSBL(13));
        _portField.textColor=UIColorHex(0x333333);
        _portField.keyboardType = UIKeyboardTypeEmailAddress;
        [_portField setAutocorrectionType:UITextAutocorrectionTypeNo];
//        __serverField.delegate = self;
        _portField.clearsOnBeginEditing = NO;
        _portField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _portField.text = @"50068";
    }
    return _portField;
}

-(UIButton*)button_eye
{
    if (!_button_eye) {
        //密码按钮
        _button_eye = [UIButton buttonWithType:UIButtonTypeCustom];
        //背景图片
        [_button_eye setImage:[UIImage imageNamed:@"safemail_dengku_look"] forState:UIControlStateNormal];
        [_button_eye setImage:[UIImage imageNamed:@"safemail_dengku_look_selected"] forState:UIControlStateSelected];
        [_button_eye setSelected:NO];
        
    }
    return _button_eye;
}

-(UIButton*)loginButton
{
    if (!_loginButton) {
        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginButton setTitle:@"登  录" forState:UIControlStateNormal];
        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _loginButton.backgroundColor = RGB(0, 164, 102);
        [_loginButton.layer setMasksToBounds:YES];
        [_loginButton.layer setCornerRadius:5.0];
        _loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:kYSBL(15)];
        _loginButton.enabled = NO;
        _loginButton.alpha = 0.6;
        
    }
    return _loginButton;
}

-(UILabel*)instrLable {
    if (!_instrLable) {
        //正在登录....
        UILabel* label_instr = [[UILabel alloc] initWithFrame:CGRectMake(0, 42 + 78 - 20 - 20, CGRectGetWidth(self.view.bounds), 20)];
//        label_instr.textColor = COLOR_TEXT_DARK;
        label_instr.font = [UIFont systemFontOfSize:18];
        label_instr.textAlignment = NSTextAlignmentCenter;
        label_instr.hidden = YES;
        _instrLable = label_instr;
    }
    return _instrLable;
}

-(GPLoadingView*)loadingIndicator {
    if (!_loadingIndicator) {
        //指示器
        GPLoadingView *loading = [[GPLoadingView alloc] initWithFrame:CGRectMake(0, CGRectGetMidY(_instrLable.frame) - 17.0f / 2, 17, 17)];
        [self.view addSubview:loading];
        self.loadingIndicator = loading;
        loading.hidden = YES;
    }
    return _loadingIndicator;
}

-(UIButton*)checkYuButton
{
    if (!_checkYuButton) {
        _checkYuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_checkYuButton setTitle:@"域登录" forState:UIControlStateNormal];
        [_checkYuButton setImage:[UIImage imageNamed:@"check_button"] forState:UIControlStateNormal];
        [_checkYuButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _checkYuButton.titleLabel.font = [UIFont systemFontOfSize:kYSBL(15)];
        _checkYuButton.tag = 50;
        [_checkYuButton setImageEdgeInsets:UIEdgeInsetsMake(2, 0, 0, 0)];
        [_checkYuButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [_checkYuButton addTarget:self action:@selector(connectWayAction:)
        forControlEvents:UIControlEventTouchUpInside];
    }
    return _checkYuButton;
}

-(UIButton*)checkKouLingButton
{
    if (!_checkKouLingButton) {
        _checkKouLingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_checkKouLingButton setTitle:@"口令登录" forState:UIControlStateNormal];
        [_checkKouLingButton setImage:[UIImage imageNamed:@"uncheck_button"] forState:UIControlStateNormal];
        [_checkKouLingButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _checkKouLingButton.titleLabel.font = [UIFont systemFontOfSize:kYSBL(15)];
        _checkKouLingButton.tag = 51;
        [_checkKouLingButton setImageEdgeInsets:UIEdgeInsetsMake(2, 0, 0, 0)];
        [_checkKouLingButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [_checkKouLingButton addTarget:self action:@selector(connectWayAction:)
        forControlEvents:UIControlEventTouchUpInside];
    }
    return _checkKouLingButton;
}

- (void)connectWayAction:(UIButton *)sender
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

    if (sender.tag ==50) {
        //移除View，添加View
        NSLog(@"域");
        //获取另一个button
        button = (UIButton *)[self.view viewWithTag:51];
        [self.checkYuButton setImage:[UIImage imageNamed:@"check_button"] forState:UIControlStateNormal];
        [self.checkKouLingButton setImage:[UIImage imageNamed:@"uncheck_button"] forState:UIControlStateNormal];
        self.isYuLogin = YES;
    }else{
        NSLog(@"口令");
        button = (UIButton *)[self.view viewWithTag:50];
        [self.checkYuButton setImage:[UIImage imageNamed:@"uncheck_button"] forState:UIControlStateNormal];
        [self.checkKouLingButton setImage:[UIImage imageNamed:@"check_button"] forState:UIControlStateNormal];
        self.isYuLogin = NO;
    }

    //设置当前选中Button为不可交互，防止其重复添加View
    sender.selected = !sender.selected;
    button.selected = !button.selected;
    sender.userInteractionEnabled = NO;
    button.userInteractionEnabled = YES;

}

- (void)updateUI
{
    if (self.loginStatus == kLoginStatus_normal) {
        //登录按钮
        NSString* content = self.emailField.text;

        if ([content containsString:@"@gmail.com"]) {
            //提示框文字
            self.promptLabel.text = @"根据Google要求，需要在谷歌授权页中输入密码";
            //登录按钮是否禁用
            self.loginButton.enabled = YES;
            //输入框是否隐藏
            self.passField.hidden = YES;
            
            //输入框位置
//            CGRect frame_account = self.accountCell.frame;
//            frame_account.origin.y = 42 + 78 + 46 + 44 - CGRectGetMidY(self.accountCell.bounds);
//            self.accountCell.frame = frame_account;
            
        }
        else {
            //提示框文字
            if ([content containsString:@"@qq.com"]) {
                self.promptLabel.text = @"使用QQ授权码或独立密码登录";
            }
            else if ([content containsString:@"@163.com"]
                     || [content containsString:@"126.com"]) {
                self.promptLabel.text = @"";
            }
            else {
                self.promptLabel.text = @"";
            }
            
            //输入框是否隐藏
            self.passField.hidden = NO;
            
            //输入框位置
//            CGRect frame_account = self.accountCell.frame;
//            frame_account.origin.y = 42 + 78 + 46;
//            self.accountCell.frame = frame_account;

        }
        
        [UIView setAnimationsEnabled:NO];
        [self.loginButton setTitle:@"登录" forState:UIControlStateNormal];
        [UIView setAnimationsEnabled:YES];
        
        //其他按钮
//        [self setSelfTouchable:YES];
        
        //logo
//        self.logoImageView.hidden = NO;
//        [self updateInstrLabelAndLoadingIndicatorFrame:@"添加邮箱帐号" showIndicator:NO];
        
        //调整位置
        CGRect frame_promptTableView = self.promptTableView.frame;
        CGFloat originY = CGRectGetHeight(self.emailField.bounds);
        CGFloat y = [self.emailField convertPoint:CGPointMake(0, originY) toView:self.view].y;
        frame_promptTableView.origin.y = y;
        frame_promptTableView.size.height = CGRectGetHeight(self.view.bounds) - y;
        self.promptTableView.frame = frame_promptTableView;
    }
    else if (self.loginStatus == kLoginStatus_logining) {
        //键盘
        [self.view endEditing:YES];
        
        //登录按钮
        self.loginButton.enabled = YES;
        [UIView setAnimationsEnabled:NO];
        [self.loginButton setTitle:NSLocalizedString(@"Cancel login", nil) forState:UIControlStateNormal];
        [UIView setAnimationsEnabled:YES];
        
        //其他按钮
//        [self setSelfTouchable:NO];
        
//        //logo
//        self.logoImageView.hidden = YES;
        
        //说明
//        [self updateInstrLabelAndLoadingIndicatorFrame:@"登录中..." showIndicator:YES];
    }
    else if (self.loginStatus == kLoginStatus_canceling) {
//        //键盘
//        [self.view endEditing:YES];
        
        //登录按钮
        self.loginButton.enabled = NO;
        [UIView setAnimationsEnabled:NO];
//        [self.loginButton setTitle:NSLocalizedString(@"Cancel login", nil) forState:UIControlStateNormal];
        [UIView setAnimationsEnabled:YES];
        
        //其他按钮
//        [self setSelfTouchable:NO];
    }
}

- (void)onTextFieldContentChanged:(id)sender
{
    if ([sender isEqual:self.emailField])
    {
        if (![[self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
            
            NSString* string = self.emailField.text;
            //求@以后的文字
            NSRange range = [string rangeOfString:@"@"];
            NSString* prefix = nil;
            NSString* suffix = nil;
            if (range.location != NSNotFound) {
                prefix = [string substringToIndex:range.location];
                suffix = [string substringFromIndex:range.location + 1];
            }
            else {
                prefix = [string copy];
                suffix = @"";
            }
            
            //拦截gmail输入
            [self updateUI];
            
            
            //1127212292@qq.com
            [self.filterMails removeAllObjects];
            NSInteger count = self.mails.count;
            for (int i = 0; i < count; i++) {
                //@以后的还没有输入
                if ([suffix isEqualToString:@""]) {
                    [self.filterMails addObject:[[NSString alloc] initWithFormat:@"%@@%@", prefix, self.mails[i]]];
                }
                //@以后的有输入
                else {
                    if ([self.mails[i] containsString:suffix]) {
                        if ([self.mails[i] isEqualToString:suffix]) {
                            
                        }
                        else {
                            [self.filterMails addObject:[[NSString alloc] initWithFormat:@"%@@%@", prefix, self.mails[i]]];
                        }
                    }
                }
            }
            
            //如果没有符合的，就隐藏
            if (self.filterMails.count == 0) {
                self.promptTableView.hidden = YES;
            }
            else {
            //更新显示
                [self.promptTableView reloadData];
                self.promptTableView.hidden = NO;
            }
        }
        else {
            //隐藏提示
            self.promptTableView.hidden = YES;
        }
    }
    
}

-(void)initOtherView {
    //说明
    UILabel* label_prompt = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.instrLable.frame) + 20, CGRectGetWidth(self.view.bounds), 20)];
//    label_prompt.textColor = COLOR_TEXT_DARK;
    label_prompt.font = [UIFont systemFontOfSize:12];
    label_prompt.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label_prompt];
    self.promptLabel = label_prompt;
}

-(void)loginClick {
    SHOW_WAIT_MESSAGE(@"正在登录", self);
    [self performSelector:@selector(run) withObject:nil afterDelay:1];
}

-(void)loginButtonStatusChanged {
    if (self.isEmailEnable && self.isPassEnable && self.isServerEnable && self.isPortEnable) {
        self.loginButton.enabled = YES;
        self.loginButton.alpha = 1.0;
    }else {
        self.loginButton.enabled = NO;
        self.loginButton.alpha = 0.6;
    }
}

-(void)gestureLogin {
    WS(weakSelf);
    if ([[PCCircleViewConst getGestureWithKey:gestureFinalSaveKey] length]) {
        GestureViewController *gestureVc = [[GestureViewController alloc] init];
        [gestureVc setType:GestureViewControllerTypeLogin];
        gestureVc.popBlock = ^{
            dispatch_sync_on_main_queue(^{
                [weakSelf loginClick];
            });
        };
        [self.navigationController pushViewController:gestureVc animated:NO];
    } else {
        NSUserDefaults *ud = NSUserDefaults.standardUserDefaults;
        if ([ud objectForKey:@"isHaveOperateSet"]) {
            AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            delegate.isActiving = YES;
            FileListViewController *vc = [[FileListViewController alloc] initWithIsRecentOpenFile:NO];
            vc.modalPresentationStyle = 0;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }else {
            UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"暂未设置手势密码，是否前往设置？" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [ud setObject:@"1" forKey:@"isHaveOperateSet"];
                AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                delegate.isActiving = YES;
                FileListViewController *vc = [[FileListViewController alloc] initWithIsRecentOpenFile:NO];
                vc.modalPresentationStyle = 0;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }];
            UIAlertAction *set = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [ud setObject:@"1" forKey:@"isHaveOperateSet"];
                GestureViewController *gestureVc = [[GestureViewController alloc] init];
                gestureVc.type = GestureViewControllerTypeSetting;
                gestureVc.popBlock = ^{
                    dispatch_sync_on_main_queue(^{
                        AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                        delegate.isActiving = YES;
                        FileListViewController *vc = [[FileListViewController alloc] initWithIsRecentOpenFile:NO];
                        vc.modalPresentationStyle = 0;
                        [weakSelf.navigationController pushViewController:vc animated:YES];
                    });
                };
                [self.navigationController pushViewController:gestureVc animated:NO];
            }];
            [alertVc addAction:cancel];
            [alertVc addAction:set];
            [self presentViewController:alertVc animated:YES
                             completion:nil];
        }
        
    }
}

#pragma mark -
#pragma mark 登录账号

- (void)run
{
    if (!CHECK_IP_FORMAT(self.serverField.text)) {
        HUD_SHOW_MESSAGE(@"IP格式有误");
        STOP_SHOW_WAIT_MESSAGE();
        return;
    }
    
    WS(weakSelf);
    
    NSString* ip = self.serverField.text;
    NSString* account = self.emailField.text;
    NSString* password = self.passField.text;
    NSString* port = self.portField.text;
    BOOL isYuLogic = self.isYuLogin;
    
    //初始化
    [[MISPMailHelper sharedInstance] handleInitOperationWithIp:ip
                                                          port:port
                                                           key:@"6666"
                                                    completion:^(BOOL ifSuccess)
     {
         if (weakSelf)
         {
             if (!ifSuccess)
             {
//                 weakSelf.loginBtn.enabled = YES;
                 STOP_SHOW_WAIT_MESSAGE();
                 HUD_SHOW_MESSAGE(@"登录失败");
             }
             else
             {
                 //登录
                 [[MISPMailHelper sharedInstance] loginWithAccountName:account
                                                              password:password isYuLogin:isYuLogic completion:^(BOOL ifSuccess)
                  {
                      if (weakSelf)
                      {
                          if (!ifSuccess) {
//                              strongSelf.loginBtn.enabled = YES;
                              STOP_SHOW_WAIT_MESSAGE();
                              HUD_SHOW_MESSAGE(@"登录失败");

                          }
                          else {
                              
//                              strongSelf.loginBtn.enabled = YES;
                              STOP_SHOW_WAIT_MESSAGE();

                              /*
                              UIViewController* presentingViewController = self.presentingViewController;
                              [presentingViewController dismissViewControllerAnimated:YES completion:^{
                                  UIStoryboard* storyboard = [UIStoryboard storyboardWithName:STORYBOAR_MODULES bundle:[NSBundle mainBundle]];
                                  CGBindMailboxToChinasecViewController* v = (CGBindMailboxToChinasecViewController*)[storyboard instantiateViewControllerWithIdentifier:STORYBOAR_ID_BIND_MAILBOX_TO_CHINASEC];
                                  v.chinasecIp = ip;
                                  v.chinasecAccount = account;
                                  v.chinasecPassword = password;
                                  [presentingViewController presentViewController:v animated:YES completion:nil];
                              }];
                               */
                              
                              NSLog(@"--------跳转-------");
                              dispatch_async_on_main_queue(^{
                                  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                                  NSMutableDictionary *accountDic = [NSMutableDictionary new];
                                  [accountDic setObject:ip forKey:@"ip"];
                                  [accountDic setObject:account forKey:@"account"];
                                  [accountDic setObject:password forKey:@"password"];
                                  [accountDic setObject:port forKey:@"port"];
                                  [accountDic setObject:@(isYuLogic) forKey:@"isYuLogic"];
                                  [ud setObject:accountDic forKey:@"accountDic"];
                                  [ud synchronize];
                                  
                                  if ([[PCCircleViewConst getGestureWithKey:gestureFinalSaveKey] length]) {
                                      AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                                      delegate.isActiving = YES;
                                      FileListViewController *vc = [[FileListViewController alloc] initWithIsRecentOpenFile:NO];
                                      vc.modalPresentationStyle = 0;
                                      [weakSelf.navigationController pushViewController:vc animated:YES];
                                  }else {
                                      [weakSelf gestureLogin];
                                  }
                                  
                              });
                              
                          }
                      }
                  }];
             }
         }
     }];
}

@end
