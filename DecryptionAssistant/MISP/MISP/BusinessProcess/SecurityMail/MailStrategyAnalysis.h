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
//是否有
-(BOOL)haveEncStrategy;
-(BOOL)havePlainStrategy;
-(NSArray *)getPlainStrategy;

- (BOOL) haveCarryAttachedFile; //add by lijuan 20170603

@end
