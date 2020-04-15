//
//  DirectoryView.h
//  SecretMail
//
//  Created by Granger on 2020/3/23.
//  Copyright © 2020 granger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DirectoryModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^DidSelectedBlock)(DirectoryModel *model);

@interface DirectoryView : UIView

@property (nonatomic,copy) DidSelectedBlock didSelectedBlock;

-(void)updateViewWithDatas:(NSArray*)datas;

@end

NS_ASSUME_NONNULL_END
