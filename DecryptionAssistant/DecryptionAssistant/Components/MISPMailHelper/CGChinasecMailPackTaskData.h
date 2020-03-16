//
//  CGChinasecMailPackTaskData.h
//  testMailCore
//
//  Created by 刘立业 on 2017/7/3.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CGChinasecMailPackTaskData : NSObject

@property (nonatomic, copy) NSString* encAction;
@property (nonatomic, copy) NSString* level;
@property (nonatomic, strong) NSMutableArray* userList;

- (instancetype)initWithEncAction:(NSString*)encAction
                            level:(NSString*)level;

@end
