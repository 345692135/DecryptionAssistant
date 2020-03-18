//
//  FileListView.h
//  DecryptionAssistant
//
//  Created by Granger on 2020/3/16.
//  Copyright © 2020 sain. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^DidSelectBlock)(NSString *fileName);

@interface FileListView : UIView

@property (nonatomic,copy) DidSelectBlock didSelectBlock;

-(void)updateViewWithFiles:(NSArray*)files;

@end

NS_ASSUME_NONNULL_END
