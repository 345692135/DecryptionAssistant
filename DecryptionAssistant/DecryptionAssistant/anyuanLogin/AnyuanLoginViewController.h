//
//  AnyuanLoginViewController.h
//  SecretMail
//
//  Created by Granger on 2020/2/11.
//  Copyright © 2020 granger. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^BackBlock)(void);

@interface AnyuanLoginViewController : BaseViewController

@property (nonatomic,copy) BackBlock backBlock;

@end

NS_ASSUME_NONNULL_END
