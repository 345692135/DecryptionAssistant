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

@end
