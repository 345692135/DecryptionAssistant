//
//  EncryptSQLiteManager.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-8-7.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

// This is a encrypt sqlite manager class ,used by management sys database - see the class methods below


#import <UIKit/UIKit.h>

@interface EncryptSQLiteManager : NSObject
{
    BOOL bInitialized;
}

@property(atomic)BOOL bInitialized;


/*!
    @method getInstance
    @abstract Get encrypt sqlite database manager instance
    @result Return database manager singleton class object
 */
+ (EncryptSQLiteManager*)getInstance;

@end
