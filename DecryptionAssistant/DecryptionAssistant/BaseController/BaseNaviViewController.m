//
//  BaseNaviViewController.m
//  DecryptionAssistant
//
//  Created by Granger on 2019/10/22.
//  Copyright © 2019 granger. All rights reserved.
//

#import "BaseNaviViewController.h"

@interface BaseNaviViewController ()

@end

@implementation BaseNaviViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.topViewController.hidesBottomBarWhenPushed = YES;
    //self.tabBarController.tabBar.hidden = NO;
    self.topViewController.tabBarController.tabBar.hidden = YES;
//    if (![[super topViewController] isKindOfClass:[viewController class]]) {
        // 如果和上一个控制器一样，隔绝此操作
        [super pushViewController:viewController animated:animated];

//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
