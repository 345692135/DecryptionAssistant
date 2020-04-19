//
//  DirectoryViewController.h
//  SecretMail
//
//  Created by Granger on 2020/3/23.
//  Copyright © 2020 granger. All rights reserved.
//

#import "BaseViewController.h"
#import "DirectoryView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DirectoryViewController : BaseViewController

@property (nonatomic, strong) DirectoryView *directoryView;
@property (nonatomic, strong) NSString *fileName;

@end

NS_ASSUME_NONNULL_END
