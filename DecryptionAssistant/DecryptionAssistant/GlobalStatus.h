//
//  GlobalStatus.h
//  DecryptionAssistant
//
//  Created by Granger on 2020/3/16.
//  Copyright © 2020 granger. All rights reserved.
//

#ifndef GlobalStatus_h
#define GlobalStatus_h

typedef NS_ENUM (NSInteger, ToPageType) {
    ToPageTypeLogin = 0,
    ToPageTypeList
};

typedef enum : NSUInteger {
    kLoginStatus_normal,
    kLoginStatus_logining,
    kLoginStatus_canceling
}kLoginStatus;

#endif /* GlobalStatus_h */
