//
//  NSData+UTF8.h
//  DecryptionAssistant
//
//  Created by Granger on 2020/3/17.
//  Copyright © 2020 sain. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (UTF8)

- (NSString *)utf8ToString;
- (NSData *)UTF8Data;

@end

NS_ASSUME_NONNULL_END
