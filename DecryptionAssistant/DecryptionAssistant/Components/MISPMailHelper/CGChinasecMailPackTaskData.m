//
//  CGChinasecMailPackTaskData.m
//  testMailCore
//
//  Created by 刘立业 on 2017/7/3.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "CGChinasecMailPackTaskData.h"

@implementation CGChinasecMailPackTaskData

- (instancetype)initWithEncAction:(NSString*)encAction
                            level:(NSString*)level
{
    self = [super init];
    if (self) {
        self.encAction = encAction;
        self.level = level;
        NSMutableArray* array = [[NSMutableArray alloc] init];
        self.userList = array;
    }
    return self;
}

@end
