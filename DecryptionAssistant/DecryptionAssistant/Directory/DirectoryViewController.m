//
//  DirectoryViewController.m
//  SecretMail
//
//  Created by Granger on 2020/3/23.
//  Copyright © 2020 granger. All rights reserved.
//

#import "DirectoryViewController.h"
#import "FileManager.h"
#import "BaseNaviViewController.h"
#import <WebKit/WebKit.h>
#import "FileDetailViewController.h"

@interface DirectoryViewController ()

@property (nonatomic,assign) BOOL isPushing;

@end

@implementation DirectoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initEvent];
    [self initWithViewFrame];
    self.view.backgroundColor = [UIColor whiteColor];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    
}

-(void)initView {
    [self.leftButton setTitle:@"" forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageNamed:@"safemail_top_back"] forState:UIControlStateNormal];
    [self.navigationView addSubview:self.leftButton];
    
    self.navigationView.backgroundColor = RGB(0, 164, 102);
    
    [self.view addSubview:self.directoryView];
//    [self.view bringSubviewToFront:self.navigationView];
//    [self.leftButton setTitle:@"" forState:UIControlStateNormal];
//    [self.leftButton setImage:[UIImage imageNamed:@"back_btn_safemail_lookView"] forState:UIControlStateNormal];
//    [self.navigationView addSubview:self.leftButton];
    
}

-(void)initEvent {
    WS(weakSelf);
    self.directoryView.didSelectedBlock = ^(DirectoryModel * _Nonnull model) {
        if (!weakSelf.isPushing) {
            weakSelf.isPushing = YES;
            //打开文件或者进入目录
            if (model.isDir) {
                if (model.innerFilePaths.count) {
                    NSMutableArray *modelArray = [NSMutableArray new];
                    dispatch_group_t group = dispatch_group_create();
                    for (NSString *fileName in model.innerFilePaths) {
                        dispatch_group_enter(group);
                        NSString *filePath = [model.filePath stringByAppendingPathComponent:fileName];
                        [FileManager.shared openFileWithPath:filePath password:nil complete:^(NSArray * _Nonnull models) {
                            [modelArray addObjectsFromArray:models];
                        }];
                        dispatch_group_leave(group);
                    }
                    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                        [weakSelf pushDirectoryWithModels:modelArray];
                        weakSelf.isPushing = NO;
                    });
                }
            }else {
                dispatch_async_on_main_queue(^{
                    [weakSelf pushPreviewWithModel:model];
                    weakSelf.isPushing = NO;
                });
            }
        }
        
    };
    
}

-(void)initWithViewFrame {
    WS(weakSelf);
    [self.directoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.navigationView.mas_bottom);
        make.bottom.equalTo(weakSelf.view).offset(-kTBarBottomHeight);
    }];
}


/// 懒加载
-(DirectoryView*)directoryView {
    if (!_directoryView) {
        _directoryView = [DirectoryView new];
        _directoryView.backgroundColor = [UIColor clearColor];
    }
    return _directoryView;
}

-(void)pushDirectoryWithModels:(NSArray*)models {
    DirectoryViewController *vc = [[DirectoryViewController alloc] init];
    [vc.directoryView updateViewWithDatas:models];
    vc.modalPresentationStyle = 0;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)pushPreviewWithModel:(DirectoryModel*)model {
    [self readLocalTextFromFileName:model.fileName andFilePath:model.filePath];
    
}

-(void)readLocalTextFromFileName:(NSString*)fileName andFilePath:(NSString*)theFilePath {
    WS(weakSelf);
    NSString *filePath = theFilePath;
    [self.baseViewModel decryptionFileWithFilePath:filePath completion:^(NSString * _Nonnull text) {
        dispatch_async_on_main_queue(^{
            if (text != nil) {
                [weakSelf pushToFileDetailWithMessage:text title:fileName];
            }else {
                [weakSelf pushToFileDetailWithFilePath:filePath title:fileName];
            }
            
        });
    }];
}

-(void)pushToFileDetailWithMessage:(NSString*)message title:(NSString*)title {
    FileDetailViewController *vc = [[FileDetailViewController alloc] initWithMessage:message title:title];
    vc.modalPresentationStyle = 0;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)pushToFileDetailWithFilePath:(NSString*)filePath title:(NSString*)title {
    FileDetailViewController *vc = [[FileDetailViewController alloc] initWithFilePath:filePath title:title];
    vc.modalPresentationStyle = 0;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
