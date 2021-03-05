//
//  FileListView.m
//  DecryptionAssistant
//
//  Created by Granger on 2020/3/16.
//  Copyright © 2020 sain. All rights reserved.
//

#import "FileListView.h"
#import "FileListTableViewCell.h"

@interface FileListView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,strong) UIImageView *bgIV;
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSMutableArray* files;

@end

@implementation FileListView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initWithView];
        [self initEvent];
    }
    return self;
}

- (void)initWithView {
    [self addSubview:self.bgIV];
    [self addSubview:self.tableView];

}

-(void)initEvent {
    
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self initWithViewFrame];
}

-(void)initWithViewFrame
{
    WS(weakSelf);
    [self.bgIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf);
    }];
    
}

#pragma mark -懒加载

-(UIImageView *)bgIV
{
    if (!_bgIV) {
        _bgIV=[UIImageView new];
    }
    return _bgIV;
}

-(UITableView*)tableView {
    if (!_tableView) {
        _tableView = [UITableView new];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[FileListTableViewCell class] forCellReuseIdentifier:@"FileListTableViewCell"];
    }
    return _tableView;
}

-(NSMutableArray*)files {
    if (!_files) {
        _files = [NSMutableArray new];
    }
    return _files;
}


#pragma mark -UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"FileListTableViewCell";
    
    FileListTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.fileName = self.files[indexPath.row];
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kYSBL(60);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.didSelectBlock) {
        self.didSelectBlock(self.files[indexPath.row]);
    }
}

-(void)updateViewWithFiles:(NSArray*)files {
    if (files.count) {
        [self.files removeAllObjects];
        [self.files addObjectsFromArray:files];
    }
    [self.tableView reloadData];
}

@end
