//
//  FileListViewController.m
//  DecryptionAssistant
//
//  Created by Granger on 2020/3/16.
//  Copyright © 2020 sain. All rights reserved.
//

#import "FileListViewController.h"
#import "FileListView.h"
#import "FileDetailViewController.h"
#import "FileManager.h"
#import "AppDelegate.h"
#import "PCCircleViewConst.h"
#import "DirectoryViewController.h"

@interface FileListViewController ()

@property (nonatomic, strong) FileListView *fileListView;
@property (nonatomic,assign) BOOL isRecentOpenFile;

@end

@implementation FileListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initWithViewFrame];
    [self initEvent];
    
    [self initData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileNotification:) name:@"FileNotification" object:nil];
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if (delegate.dictionary) {
        NSDictionary *dictionary = [NSDictionary dictionaryWithDictionary:delegate.dictionary];
        delegate.dictionary = nil;
        [self fileDictionary:dictionary];
    }
    
    //    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
}

-(instancetype)initWithIsRecentOpenFile:(BOOL)isRecentOpenFile {
    if (self=[super init]) {
        self.isRecentOpenFile = isRecentOpenFile;
    }
    return self;
}

-(void)initView {
    
    if (!self.isRecentOpenFile) {
        [self.rightBtn setTitle:@"最近打开" forState:UIControlStateNormal];
        self.rightBtn.frame = CGRectMake(kScreenWidth - kYSBL(15)-70, kStatusBarHeight + 4, 70, 40);
        [self.navigationView addSubview:self.rightBtn];
    }else {
        [self.leftButton setTitle:@"" forState:UIControlStateNormal];
        [self.leftButton setImage:[UIImage imageNamed:@"safemail_top_back"] forState:UIControlStateNormal];
        [self.navigationView addSubview:self.leftButton];
    }
    
    self.navigationView.backgroundColor = RGB(0, 164, 102);
    
    self.titleLabel.text = self.isRecentOpenFile?@"最近打开":@"文件列表";
    self.titleLabel.textColor = [UIColor whiteColor];
    [self.navigationView addSubview:self.titleLabel];
    
    [self.view addSubview:self.fileListView];
    
}

-(void)back {
//    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    delegate.isActiving = NO;
    [PCCircleViewConst saveGesture:nil Key:gestureFinalSaveKey];//清空手势密码
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:@{} forKey:@"accountDic"];
    [ud synchronize];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightButtonClick {
    FileListViewController *vc = [[FileListViewController alloc] initWithIsRecentOpenFile:YES];
    vc.modalPresentationStyle = 0;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)initEvent {
    WS(weakSelf);
    self.fileListView.didSelectBlock = ^(NSString * _Nonnull fileName) {
        [weakSelf handleSourceWithFileName:fileName];
    };
}

-(void)handleSourceWithFileName:(NSString*)fileName {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@""];
    if (self.isRecentOpenFile || !filePath) {
        filePath = [FileManager.shared recentOpenFilePath];
        filePath = [filePath stringByAppendingPathComponent:fileName];
    }
    kAttachmentType attachmentType = [FileManager.shared getAttachmentTypeWithPath:fileName];
    WS(weakSelf);
    if (attachmentType == kcgAttachmentType_zip) {
        dispatch_async_on_main_queue(^{
            [FileManager.shared openFileWithPath:filePath password:nil complete:^(NSArray * models) {
                dispatch_async_on_main_queue(^{
                    if (models && models.count) {
                        DirectoryModel *model = models[0];
                        NSData *data = [NSData dataWithContentsOfFile:filePath];
                        if (model.fileSize.length == 0 && data.length > 0) {
                            //加密压缩包
                            NSLog(@"我是加密压缩包");
                            [weakSelf showPasswordViewWithFilePath:filePath];
                            
                        }else {
                            [weakSelf pushDirectoryWithModels:models];
                        }
                        
                    }
                    
                    
                });
            }];
        });
    }else {
        [self readLocalTextFromFileName:fileName];
    }
    
}

-(void)showPasswordViewWithFilePath:(NSString*)filePath {
    WS(weakSelf);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:nil preferredStyle:UIAlertControllerStyleAlert];
    //增加确定按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
      //获取第1个输入框；
//      UITextField *userNameTextField = alertController.textFields.firstObject;
      
      //获取第2个输入框；
      UITextField *passwordTextField = alertController.textFields.lastObject;
      
      NSLog(@"密码 = %@",passwordTextField.text);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf openFileWithFilePath:filePath password:passwordTextField.text.stringByTrim];
        });
    }]];
    
    //增加取消按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    
//    //定义第一个输入框；
//    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//      textField.placeholder = @"请输入密码";
//    }];
    //定义第二个输入框；
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
      textField.placeholder = @"请输入密码";
    }];
    
    [self presentViewController:alertController animated:true completion:nil];
    
}

-(void)openFileWithFilePath:(NSString*)filePath password:(NSString*)password {
    WS(weakSelf);
    [FileManager.shared openFileWithPath:filePath password:password complete:^(NSArray * models) {
        dispatch_sync_on_main_queue(^{
            if (models && models.count) {
                DirectoryModel *model = models[0];
                NSData *data = [NSData dataWithContentsOfFile:filePath];
                if (model.fileSize.length == 0 && data.length > 0) {
                    //压缩包
                    NSLog(@"解压异常");
                    [ToastManager showMsg:@"解压异常"];
                }else {
                    [weakSelf pushDirectoryWithModels:models];
                }
                
            }
            
            
        });
    }];
}

-(void)pushDirectoryWithModels:(NSArray*)models {
    DirectoryViewController *vc = [[DirectoryViewController alloc] init];
    [vc.directoryView updateViewWithDatas:models];
    vc.modalPresentationStyle = 0;
    DirectoryModel *model = models[0];
    vc.fileName = model.fileName;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)initWithViewFrame {
    WS(weakSelf);
    [self.fileListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.navigationView.mas_bottom);
    }];
}

//-(void)loginHandleByUserName:(NSString*)userName password:(NSString*)password {
//
//
//}

#pragma mark -懒加载

-(FileListView*)fileListView {
    if (!_fileListView) {
        _fileListView = [FileListView new];
    }
    return _fileListView;
}

-(void)initData {
    NSArray *files = [NSArray arrayWithObjects:@"a.html",@"商务密邮安元版ios.xlsx",@"test.xlsx",@"文本测试文件.txt",@"测试文档5.docx",@"主动加密.txt",@"研发部绝密.txt",@"商务部加密.txt",@"售后培训.txt",@"encvlog.txt",@"工程实施部.txt",@"研发部机密.txt",@"普密1.txt", nil];
    if (self.isRecentOpenFile) {
        files = [FileManager.shared fileList];
    }
    [self.fileListView updateViewWithFiles:files];
    
}

-(void)readLocalTextFromFileName:(NSString*)fileName {
    WS(weakSelf);
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@""];
    if (self.isRecentOpenFile) {
        filePath = [FileManager.shared recentOpenFilePath];
        filePath = [filePath stringByAppendingPathComponent:fileName];
    }
    [self.baseViewModel decryptionFileWithFilePath:filePath completion:^(NSString * _Nonnull decPath) {
        dispatch_async_on_main_queue(^{
            if (!self.isRecentOpenFile) {
                NSString *recentOpenFile = [FileManager.shared recentOpenFilePath];
                [FileManager.shared createDir:recentOpenFile];
                [FileManager.shared copyFile:filePath toDir:recentOpenFile];
            }
            [weakSelf pushToFileDetailWithFilePath:decPath originalFilePath:filePath title:fileName];
            
        });
    }];
}

-(void)pushToFileDetailWithMessage:(NSString*)message title:(NSString*)title {
    FileDetailViewController *vc = [[FileDetailViewController alloc] initWithMessage:message title:title];
    vc.modalPresentationStyle = 0;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)pushToFileDetailWithFilePath:(NSString*)filePath originalFilePath:(NSString*)originalFilePath title:(NSString*)title {
    if ([filePath.pathExtension.lowercaseString isEqualToString:@"zip"] || [filePath .pathExtension.lowercaseString isEqualToString:@"rar"] || [filePath.pathExtension.lowercaseString isEqualToString:@"7z"]) {
        [self handleSourceWithFileName:title];
    }else {
        FileDetailViewController *vc = [[FileDetailViewController alloc] initWithFilePath:filePath originalFilePath:originalFilePath title:title];
        vc.modalPresentationStyle = 0;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

-(void)fileDictionary:(NSDictionary*)dictionary {
    NSDictionary *info = dictionary;
    // fileName是文件名称、filePath是文件存储在本地的路径
    // jfkdfj123a.pdf
    NSString *fileName = [info objectForKey:@"fileName"];
    // /private/var/mobile/Containers/Data/Application/83643509-E90E-40A6-92EA-47A44B40CBBF/Documents/Inbox/jfkdfj123a.pdf
    NSString *filePath = [info objectForKey:@"filePath"];
    NSLog(@"fileName=%@---filePath=%@", fileName, filePath);
    
    WS(weakSelf);
    NSString *recentOpenFile = [FileManager.shared recentOpenFilePath];
    [FileManager.shared createDir:recentOpenFile];
    [FileManager.shared copyFile:filePath toDir:recentOpenFile];
    
    [self.baseViewModel decryptionFileWithFilePath:filePath completion:^(NSString * _Nonnull decPath) {
        dispatch_async_on_main_queue(^{
            [weakSelf pushToFileDetailWithFilePath:decPath originalFilePath:filePath title:fileName];
            
        });
    }];
}

- (void)fileNotification:(NSNotification *)notifcation {
    NSDictionary *info = notifcation.userInfo;
    [self fileDictionary:info];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
