//
//  BaseViewController.m
//  DecryptionAssistant
//
//  Created by Granger on 2019/10/22.
//  Copyright © 2019 granger. All rights reserved.
//

#import "BaseViewController.h"
#import "UIView+Toast.h"

@interface BaseViewController ()

@property(nonatomic, strong) UIView *toastMaskView;

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 11, *)) {
        [UIScrollView appearance].contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever; //iOS11 解决SafeArea的问题，同时能解决pop时上级页面scrollView抖动的问题
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
//    self.extendedLayoutIncludesOpaqueBars = NO;
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.hidden = YES;
    [self initNavigationView];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    NSLog(@"%@ viewDidLoad", NSStringFromClass([self class]));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideToastActivity];
}

- (void)initNavigationView {
    _navigationView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth,  kNavigationBarHeight)];
    _navigationView.userInteractionEnabled = YES;
    //view.backgroundColor = [UIColor getColorWithColor:KblueColor];
    [self.view addSubview:_navigationView];
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth / 2, 0, kScreenWidth-120, 17)];
    _titleLabel.centerY = kNavigationBarHeight == 88? 64:42;
    //kNavigationBarHeight / 2+kTBarBottomHeight/2;
    _titleLabel.centerX = kScreenWidth / 2;
    _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (HotAreaButton *)leftButton {
    if (!_leftButton) {
        _leftButton = [HotAreaButton buttonWithType:UIButtonTypeCustom];
        _leftButton.frame = CGRectMake(kYSBL(15), kStatusBarHeight + 8, kYSBL(100), 18);
        _leftButton.centerY = kStatusBarHeight + 44 / 2;
        [_leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_leftButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        //_leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        _leftButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:kYSBL(14)
                                       ];
        //_leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, 20, 0, -20);
        // [_leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [_leftButton setTitle:@"返回" forState:UIControlStateNormal];
        [_leftButton setImage:[UIImage imageNamed:@"ava_back"] forState:UIControlStateNormal];
        _leftButton.centerY = kStatusBarHeight + 44 / 2;
        _leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    return _leftButton;
}

- (UIButton *)rightBtn {
    if (!_rightBtn) {
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightBtn.frame = CGRectMake(kScreenWidth - 50, kStatusBarHeight + 4, 50, 40);
        [_rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_rightBtn addTarget:self action:@selector(rightButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _rightBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    }
    return _rightBtn;
}

- (UIImageView *)titleImageView {
    if (!_titleImageView) {
        _titleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_titleLabel.left - 40, 0, 30, 30)];
        _titleImageView.centerY = _titleLabel.centerY;
        _titleImageView.backgroundColor = [UIColor redColor];
    }
    return _titleImageView;
}
- (void)back{
    __weak typeof(self) weakself = self;
    dispatch_barrier_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakself;
        [strongSelf.navigationController popViewControllerAnimated:YES];
    });
}

-(void)rightButtonClick {
    //子类去重写实现
}

- (void)showMess {
    //[ToastManager showMsg:@"功能尚未开发" duration:2.0];
    UILabel *messLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kScreenHeight / 2, kScreenWidth, 20)];
    messLabel.textColor = [UIColor grayColor];
    messLabel.textAlignment = NSTextAlignmentCenter;
    messLabel.text = @"当前模块正在开发中……";
    [self.view addSubview:messLabel];
}

- (void)makeToastActivity {
    [CSToastManager setQueueEnabled:YES];
    UIView *window = [[[UIApplication sharedApplication] windows] firstObject];
    [window addSubview:self.toastMaskView];
    //[self.toastMaskView makeToast:@"test" duration:20 position:CSToastPositionCenter style:nil];
    [self.toastMaskView makeToastActivity:CSToastPositionCenter];
}

- (void)hideToastActivity {
    [self.toastMaskView hideToastActivity];
    [self.toastMaskView removeFromSuperview];
}

- (UIView *)toastMaskView {
    if (!_toastMaskView) {
        _toastMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight, kScreenWidth, kScreenHeight - kNavigationBarHeight)];
        _toastMaskView.backgroundColor = [UIColor clearColor];
    }
    return _toastMaskView;
}

- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}


//- (BOOL)hidesBottomBarWhenPushed{
//    return (self.navigationController.topViewController == self);
//}

-(void)autoResizeLabel:(UILabel*)label{
    NSDictionary *attribute = @{NSFontAttributeName: label.font};
    CGSize labelSize = [label.text boundingRectWithSize:CGSizeMake(label.frame.size.width, 5000) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    //200为UILabel的宽度，5000是预设的一个高度，表示在这个范围内
    
    //注意：之前使用了NSString类的sizeWithFont: constrainedToSize: lineBreakMode:方法，但是该方法已经被iOS7 Deprecated了，而iOS7新出了一个boudingRectWithSize: options: attributes: context:方法来代替。
    
    label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, labelSize.height);
    
    //保持原来Label的位置和宽度，只是改变高度。
    
    label.numberOfLines = 0;//表示label可以多行显示
    
}

#pragma mark -懒加载
-(BaseViewModel*)baseViewModel {
    if (!_baseViewModel) {
        _baseViewModel = [BaseViewModel new];
    }
    return _baseViewModel;
}

-(void)dealloc{
    NSLog(@"🍀🍀🍀🍀🍀 %@ dealloc",NSStringFromClass([self class]));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
