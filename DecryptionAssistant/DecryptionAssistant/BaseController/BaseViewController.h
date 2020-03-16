//
//  BaseViewController.h
//  DecryptionAssistant
//
//  Created by Granger on 2019/10/22.
//  Copyright © 2019 granger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HotAreaButton.h"
#import "BaseViewModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController
@property(nonatomic, strong) UIImageView *navigationView;
@property(nonatomic, strong) UIImageView *titleImageView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) HotAreaButton *leftButton;
@property(nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, strong) BaseViewModel *baseViewModel;

- (void)showMess;

//- (void)makeToastActivity;
//
//- (void)hideToastActivity;

- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;
-(void)autoResizeLabel:(UILabel*)label;
@end

NS_ASSUME_NONNULL_END
