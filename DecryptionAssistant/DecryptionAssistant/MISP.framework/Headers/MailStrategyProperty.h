//
//  EncMailStrategy.h
//  MISP
//
//  Created by iBlock on 14-5-30.
//
//

#import <Foundation/Foundation.h>

@interface MailStrategyProperty : NSObject

@property(nonatomic, copy)NSString *strategyName;

@property(nonatomic, copy)NSString *level;

@property(nonatomic, copy)NSString *encAction;

@property(nonatomic, retain)NSArray *userList;

@end
