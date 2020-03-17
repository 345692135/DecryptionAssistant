//
//  FileListViewController.m
//  DecryptionAssistant
//
//  Created by Granger on 2020/3/16.
//  Copyright © 2020 sain. All rights reserved.
//

#import "FileListViewController.h"
#import "FileListView.h"

@interface FileListViewController ()

@property (nonatomic, strong) FileListView *fileListView;

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

-(void)initView {
    [self.leftButton setTitle:@"" forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageNamed:@"safemail_top_back"] forState:UIControlStateNormal];
    [self.navigationView addSubview:self.leftButton];
    self.navigationView.backgroundColor = RGB(0, 164, 102);
    
    self.titleLabel.text = @"文件列表";
    self.titleLabel.textColor = [UIColor whiteColor];
    [self.navigationView addSubview:self.titleLabel];
    
    [self.view addSubview:self.fileListView];
    
}

-(void)initEvent {
    
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
    [self.fileListView updateViewWithFiles:files];
}

@end
