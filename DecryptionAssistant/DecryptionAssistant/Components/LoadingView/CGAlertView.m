//
//  CGAlertView.m
//  together
//
//  Created by 刘立业 on 2017/6/5.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "CGAlertView.h"
#import "CGMacros.h"

#define LINE_SPACE 4
#define FONT_SIZE 13

@interface CGAlertView ()

@property (nonatomic, weak) IBOutlet  UILabel* label;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView* activityIndicatorView;

@end

@implementation CGAlertView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _title = [title copy];
    if (!self.activityIndicatorView.isAnimating) {
        [self.activityIndicatorView startAnimating];
    }
    [self updateUI];
    [self appear];
}

- (void)appear
{
    self.layer.opacity = 0;
    self.transform = CGAffineTransformMakeScale(1.5, 1.5);
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.layer.opacity = 1;
        self.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)disappear
{
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.layer.opacity = 0;
//        self.transform = CGAffineTransformMakeScale(0.8, 0.8);
    } completion:^(BOOL finished) {
        if (self.activityIndicatorView.isAnimating) {
            [self.activityIndicatorView stopAnimating];
        }
    }];
}

- (void)initUI
{
    UIBlurEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    self.effect = blurEffect;
    self.layer.cornerRadius = 12;
    self.layer.masksToBounds = YES;
    self.layer.anchorPoint = CGPointMake(0.5, 0.5);

    //创建label
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textColor = [UIColor colorWithHex:0x0];
//    NSArray* families = [UIFont familyNames];
//    for (NSString* family in families) {
//        if ([family isEqualToString:@"Helvetica Neue"]) {
//            NSArray* a = [UIFont fontNamesForFamilyName:family];
//            for (NSString* fontName in a) {
//                NSLog(@"name = %@", fontName);
//            }
//        }
//    }

    
    label.font = [UIFont systemFontOfSize:FONT_SIZE];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    [self.contentView addSubview:label];
    self.label = label;

    //创建指示器
    UIActivityIndicatorView* activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.contentView addSubview:activityIndicatorView];
    self.activityIndicatorView = activityIndicatorView;
}

- (void)updateUI
{
    CGFloat width_label = [self calculateWidthWithContent:self.title];
    self.label.frame = CGRectMake(0, 0, width_label, 10);
    
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 4;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:self.title attributes:@{NSFontAttributeName:self.label.font, NSParagraphStyleAttributeName:paragraphStyle}];
    self.label.attributedText = attributedString;
    
    [self.label sizeToFit];
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(15, 15, 16, 15);
    CGFloat linespace = 19;
    self.bounds = CGRectMake(0, 0, width_label + edgeInsets.left + edgeInsets.right, edgeInsets.top + CGRectGetHeight(self.label.bounds) + linespace + CGRectGetHeight(self.activityIndicatorView.bounds) + edgeInsets.bottom);
    CGRect frame_label = self.label.frame;
    frame_label.origin = CGPointMake(floorf((CGRectGetWidth(self.bounds) - CGRectGetWidth(self.label.bounds)) / 2), edgeInsets.top);
    self.label.frame = frame_label;
    self.activityIndicatorView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMaxY(self.label.frame) + linespace + CGRectGetMidY(self.activityIndicatorView.bounds));
}

- (CGFloat)calculateWidthWithContent:(NSString*)content
{
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = LINE_SPACE;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary* dic = @{
                          NSFontAttributeName:self.label.font, NSParagraphStyleAttributeName:paragraphStyle
                          };
    CGSize size = [content sizeWithAttributes:dic];
    CGFloat width = size.width;
    CGFloat area = width * (self.label.font.pointSize + LINE_SPACE);
    CGFloat result = sqrt(area / (8 * 3)) * 8;
    return fmaxf(120, fminf(result, CGRectGetWidth([UIScreen mainScreen].bounds) * 0.6));
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
