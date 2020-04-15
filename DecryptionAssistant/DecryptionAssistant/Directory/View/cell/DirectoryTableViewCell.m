//
//  DirectoryTableViewCell.m
//  SecretMail
//
//  Created by Granger on 2020/3/23.
//  Copyright © 2020 granger. All rights reserved.
//

#import "DirectoryTableViewCell.h"

@interface DirectoryTableViewCell ()

@property (nonatomic,strong) UIImageView *iconIV;
@property (nonatomic,strong) UILabel *fileNameLabel;
@property (nonatomic,strong) UILabel *descriptionLabel;
@property (nonatomic,strong) UILabel *lineView;
@property (nonatomic,strong) UIImageView *rightIV;

@end

@implementation DirectoryTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initWithView];
        [self initEvent];
        [self initWithViewFrame];

    }
    return self;
}

- (void)initWithView {
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.iconIV];
    [self addSubview:self.fileNameLabel];
    [self addSubview:self.descriptionLabel];
    [self addSubview:self.rightIV];
    [self addSubview:self.lineView];
    
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
    [self.iconIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf).offset(kYSBL(10));
        make.centerY.equalTo(weakSelf);
        make.width.height.mas_equalTo(kYSBL(48));
    }];
    
    [self.rightIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf).offset(kYSBL(-14));
        make.centerY.equalTo(weakSelf);
        make.width.mas_equalTo(kYSBL(7));
        make.height.mas_equalTo(kYSBL(10));
    }];
    
    [self.fileNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.iconIV.mas_right).offset(kYSBL(15));
        make.top.equalTo(weakSelf.iconIV).offset(kYSBL(5));
        make.right.equalTo(weakSelf.rightIV.mas_left);
        make.height.mas_equalTo(kYSBL(22));
    }];
    
    [self.descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.fileNameLabel);
        make.top.equalTo(weakSelf.fileNameLabel.mas_bottom);
        make.right.equalTo(weakSelf.rightIV.mas_left);
        make.height.mas_equalTo(kYSBL(17));
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.iconIV);
        make.right.equalTo(weakSelf);
        make.height.mas_equalTo(LINE_WIDTH);
        make.bottom.equalTo(weakSelf.mas_bottom);
    }];
    
}


#pragma mark -懒加载

-(UIImageView*)iconIV {
    if (!_iconIV) {
        _iconIV = [UIImageView new];
        _iconIV.image = [UIImage imageNamed:@"safemail_Details_fujian15"];
    }
    return _iconIV;
}

-(UILabel*)fileNameLabel
{
    if (!_fileNameLabel) {
        _fileNameLabel = [UILabel new];
        _fileNameLabel.text = @"文件";
        _fileNameLabel.textColor = [UIColor blackColor];
        _fileNameLabel.font = [UIFont boldSystemFontOfSize:kYSBL(15)];
    }
    return _fileNameLabel;
}

-(UILabel*)descriptionLabel
{
    if (!_descriptionLabel) {
        _descriptionLabel = [UILabel new];
        _descriptionLabel.text = @"";
        _descriptionLabel.textColor = RGB(140, 140, 139);
        _descriptionLabel.font = [UIFont boldSystemFontOfSize:kYSBL(13)];
    }
    return _descriptionLabel;
}

-(UIImageView*)rightIV {
    if (!_rightIV) {
        _rightIV = [UIImageView new];
        _rightIV.image = [UIImage imageNamed:@"safemail_top_right"];
    }
    return _rightIV;
}

-(UILabel*)lineView {
    if (!_lineView) {
        _lineView = [UILabel new];
        _lineView.backgroundColor = COLOR_SEPARATOR;//RGB(237, 239, 238);
    }
    return _lineView;
}

-(void)updateViewWithDirectoryModel:(DirectoryModel*)model {
    self.iconIV.image = [UIImage imageNamed:model.icon];
    self.fileNameLabel.text = model.fileName;
    self.descriptionLabel.text = model.fileSize;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
