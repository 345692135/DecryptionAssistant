//
//  MailStrategyAnalysis.h
//  MISP
//
//  Created by iBlock on 14-6-5.
//
//

#import <Foundation/Foundation.h>

@interface MailStrategyAnalysis : NSObject

+ (id)sharedInstance;

- (NSArray *)getSendMailList:(NSMutableSet *)userList;
- (NSArray *)getSendAddressDataDicList:(NSMutableSet *)addressDataDicList;//😆

@end
