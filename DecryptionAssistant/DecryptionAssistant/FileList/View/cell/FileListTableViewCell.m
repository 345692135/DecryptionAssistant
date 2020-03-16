//
//  FileListTableViewCell.m
//  DecryptionAssistant
//
//  Created by Granger on 2020/3/16.
//  Copyright © 2020 sain. All rights reserved.
//

#import "FileListTableViewCell.h"

@interface FileListTableViewCell ()

@property (nonatomic,strong) UIImageView *iconIV;
@property (nonatomic,strong) UILabel *fileLabel;

@end

@implementation FileListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initWithView];
        [self initWithViewFrame];
        [self initEvent];

    }
    return self;
}

- (void)initWithView {
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.iconIV];
    [self addSubview:self.fileLabel];
    
}

-(void)initEvent {

}

-(void)layoutSubviews
{
    [super layoutSubviews];
}

-(void)initWithViewFrame
{
    [self.iconIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.centerY.equalTo(self);
        make.width.mas_equalTo(kYSBL(42));
        make.height.mas_equalTo(kYSBL(42));
    }];
    
    [self.fileLabel mas_makeConstraints:^(MASConstraintMaker *make) {
           make.left.equalTo(self.iconIV.mas_right).offset(kYSBL(7));
           make.centerY.equalTo(self);
           make.right.equalTo(self);
           make.height.mas_equalTo(kYSBL(42));
    }];
    
}


#pragma mark -懒加载

-(UIImageView*)iconIV {
    if (!_iconIV) {
        _iconIV = [UIImageView new];
        _iconIV.image = [UIImage imageNamed:@"unknown"];
    }
    return _iconIV;
}

-(UILabel*)fileLabel
{
    if (!_fileLabel) {
        _fileLabel = [UILabel new];
        _fileLabel.text = @"";
        _fileLabel.textColor = [UIColor blackColor];
        _fileLabel.font = [UIFont systemFontOfSize:kYSBL(17)];
    }
    return _fileLabel;
}

-(void)setFileName:(NSString *)fileName {
    _fileName = [fileName copy];
//    _emailLabel.text = _accountName;
//    [self.iconIV setName:accountName address:accountName];
    [self layoutIfNeeded];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
