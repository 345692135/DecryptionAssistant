//
//  DirectoryTableViewCell.h
//  SecretMail
//
//  Created by Granger on 2020/3/23.
//  Copyright © 2020 granger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DirectoryModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DirectoryTableViewCell : UITableViewCell

-(void)updateViewWithDirectoryModel:(DirectoryModel*)model;

@end

NS_ASSUME_NONNULL_END
