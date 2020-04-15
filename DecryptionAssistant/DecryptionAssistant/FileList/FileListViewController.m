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
    [self.leftButton setTitle:@"" forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageNamed:@"safemail_top_back"] forState:UIControlStateNormal];
    [self.navigationView addSubview:self.leftButton];
    
    if (!self.isRecentOpenFile) {
        [self.rightBtn setTitle:@"最近打开" forState:UIControlStateNormal];
        self.rightBtn.frame = CGRectMake(kScreenWidth - kYSBL(15)-70, kStatusBarHeight + 4, 70, 40);
        [self.navigationView addSubview:self.rightBtn];
    }
    
    self.navigationView.backgroundColor = RGB(0, 164, 102);
    
    self.titleLabel.text = self.isRecentOpenFile?@"最近打开":@"文件列表";
    self.titleLabel.textColor = [UIColor whiteColor];
    [self.navigationView addSubview:self.titleLabel];
    
    [self.view addSubview:self.fileListView];
    
}

-(void)rightButtonClick {
    FileListViewController *vc = [[FileListViewController alloc] initWithIsRecentOpenFile:YES];
    vc.modalPresentationStyle = 0;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)initEvent {
    WS(weakSelf);
    self.fileListView.didSelectBlock = ^(NSString * _Nonnull fileName) {
        [weakSelf readLocalTextFromFileName:fileName];
    };
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
    NSArray *files = [NSArray arrayWithObjects:@"主动加密.txt",@"研发部绝密.txt",@"商务部加密.txt",@"售后培训.txt",@"encvlog.txt",@"工程实施部.txt",@"研发部机密.txt",@"普密1.txt", nil];
    if (self.isRecentOpenFile) {
        files = [FileManager.shared fileList];
    }
    [self.fileListView updateViewWithFiles:files];
}

-(void)readLocalTextFromFileName:(NSString*)fileName {
    WS(weakSelf);
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@""];
    if (self.isRecentOpenFile) {
        filePath = [FileManager.shared accountPath];
        filePath = [filePath stringByAppendingPathComponent:fileName];
    }
    [self.baseViewModel decryptionFileWithFilePath:filePath completion:^(NSString * _Nonnull text) {
        dispatch_async_on_main_queue(^{
            if (!self.isRecentOpenFile) {
                NSString *recentOpenFile = [FileManager.shared accountPath];
                [FileManager.shared createDir:recentOpenFile];
                [FileManager.shared copyFile:filePath toDir:recentOpenFile];
            }
            [weakSelf pushToFileDetailWithMessage:text title:fileName];
        });
    }];
}

-(void)pushToFileDetailWithMessage:(NSString*)message title:(NSString*)title {
    FileDetailViewController *vc = [[FileDetailViewController alloc] initWithMessage:message title:title];
    vc.modalPresentationStyle = 0;
    [self.navigationController pushViewController:vc animated:YES];
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
    NSString *recentOpenFile = [FileManager.shared accountPath];
    [FileManager.shared createDir:recentOpenFile];
    [FileManager.shared copyFile:filePath toDir:recentOpenFile];
    
    [self.baseViewModel decryptionFileWithFilePath:filePath completion:^(NSString * _Nonnull text) {
        dispatch_async_on_main_queue(^{
            [weakSelf pushToFileDetailWithMessage:text title:fileName];
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
