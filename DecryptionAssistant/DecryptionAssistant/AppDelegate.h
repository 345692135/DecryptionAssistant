//
//  AppDelegate.h
//  DecryptionAssistant
//
//  Created by Granger on 2020/3/16.
//  Copyright © 2020 sain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalStatus.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) BOOL isActiving;
@property (strong, nonatomic) NSDictionary *dictionary;

/// root切换
/// @param toPageType toPageType description
-(void)changeRootWithToPageType: (ToPageType)toPageType;

@end

