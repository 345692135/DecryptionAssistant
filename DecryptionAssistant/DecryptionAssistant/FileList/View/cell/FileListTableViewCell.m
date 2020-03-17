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
@property (nonatomic,strong) UILabel *lineLabel;

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
    [self addSubview:self.lineLabel];
    
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
        make.left.equalTo(weakSelf).offset(kYSBL(15));
        make.centerY.equalTo(weakSelf);
        make.width.mas_equalTo(kYSBL(30));
        make.height.mas_equalTo(kYSBL(33));
    }];
    
    [self.fileLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       make.left.equalTo(weakSelf.iconIV.mas_right).offset(kYSBL(15));
       make.centerY.equalTo(weakSelf);
       make.right.equalTo(weakSelf).offset(kYSBL(-15));
       make.height.equalTo(weakSelf);
    }];
    
    [self.lineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       make.left.equalTo(weakSelf).offset(kYSBL(10));
       make.bottom.equalTo(weakSelf.fileLabel);
       make.right.equalTo(weakSelf);
       make.height.mas_equalTo(0.5);
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

-(UILabel*)lineLabel
{
    if (!_lineLabel) {
        _lineLabel = [UILabel new];
        _lineLabel.backgroundColor = UIColorHex(0xd7d7d7);
    }
    return _lineLabel;
}

-(void)setFileName:(NSString *)fileName {
    _fileName = [fileName copy];
    self.fileLabel.text = fileName;
    self.iconIV.image = [UIImage imageNamed:[self getImageNameWithFileName:fileName]];
    [self layoutIfNeeded];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(NSString*)getImageNameWithFileName:(NSString*)fileName {
    NSString* typeString = [fileName componentsSeparatedByString:@"."][1];
    NSString *imageName = @"unknown";
    if ([typeString isEqualToString:@"txt"] || [typeString isEqualToString:@"text"]) {
        imageName = @"txt";
    }
    return imageName;
}

@end
