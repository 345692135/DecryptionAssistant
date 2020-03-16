//
//  AFHTTPSessionManager+DecryptionAssistant.h
//  SecretMail
//
//  Created by Granger on 2019/11/19.
//  Copyright © 2019 granger. All rights reserved.
//

#import "AFHTTPSessionManager+DecryptionAssistant.h"

@implementation AFHTTPSessionManager (DecryptionAssistant)

static AFHTTPSessionManager *manager;
+ (AFHTTPSessionManager *)sharedManager {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        manager = [[AFHTTPSessionManager alloc] init];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    });
    
    return manager;
}


@end
