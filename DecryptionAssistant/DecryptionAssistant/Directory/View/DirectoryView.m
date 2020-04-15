//
//  DirectoryView.m
//  SecretMail
//
//  Created by Granger on 2020/3/23.
//  Copyright © 2020 granger. All rights reserved.
//

#import "DirectoryView.h"
#import "DirectoryTableViewCell.h"

@interface DirectoryView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *datas;

@end

@implementation DirectoryView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initWithView];
        [self initEvent];
        [self initWithViewFrame];
    }
    return self;
}

- (void)initWithView {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.tableView];
    
}

-(void)initEvent {
    
}

-(void)layoutSubviews
{
    [super layoutSubviews];
}

-(void)initWithViewFrame
{

    WS(weakSelf);
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf);
    }];
    
}


#pragma mark -懒加载

-(UITableView*)tableView {
    if (!_tableView) {
        _tableView = [UITableView new];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        [_tableView registerClass:[DirectoryTableViewCell class] forCellReuseIdentifier:@"DirectoryTableViewCell"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
    }
    return _tableView;
}

-(NSMutableArray*)datas {
    if (!_datas) {
        _datas = [NSMutableArray new];
    }
    return _datas;
}


#pragma mark -UITableView Datasource Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return self.datas.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DirectoryModel *model = self.datas[indexPath.row];
    NSString * cellIdet = @"DirectoryTableViewCell";
    DirectoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdet];
    if (!cell)
    {
        cell = [[DirectoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdet];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell updateViewWithDirectoryModel:model];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kYSBL(62);
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.didSelectedBlock) {
        self.didSelectedBlock(self.datas[indexPath.row]);
    }
}

-(void)updateViewWithDatas:(NSArray*)datas {
    [self.datas removeAllObjects];
    [self.datas addObjectsFromArray:datas];
    [self.tableView reloadData];
}

- (NSString*)sizeStringWithByteLength:(NSInteger)length
{
    CGFloat fLength = length;
    //B
    if (fLength / 1024 < 1) {
         return [NSString stringWithFormat:@"%.0fB", fLength];
    }
    
    //KB
    fLength /= 1024;
    if (fLength / 1024 < 1) {
        return [NSString stringWithFormat:@"%.2fKB", fLength];
    }
    
    //MB
    fLength /= 1024;
    if (fLength / 1024 < 1) {
        return [NSString stringWithFormat:@"%.2fMB", fLength];
    }
    
    //GB
    fLength /= 1024;
    if (fLength / 1024 < 1) {
        return [NSString stringWithFormat:@"%.2fGB", fLength];
    }
    
    return nil;
}

@end
