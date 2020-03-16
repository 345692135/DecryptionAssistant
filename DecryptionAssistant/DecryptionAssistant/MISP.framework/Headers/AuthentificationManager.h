//
//  AuthentificationManager.h
//  MISP
//
//  Created by yangli on 12-8-6.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICertify.h"

@interface AuthentificationManager : NSObject

/*!
 @method getInstance
 @abstract Get AuthentificationManager instance
 @result Return AuthentificationManager singleton class object
 */
+ (AuthentificationManager*)getInstance;


- (id<ICertify>)getUserNameCertifyPrivder;

@end
