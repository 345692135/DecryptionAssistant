//
//  NSData+Crypto.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-9-12.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

// This is a NSData category class ，used by create encrypt file or read encrypt file - see the class methods below

#import <Foundation/Foundation.h>

@interface NSData (Crypto)

/*!
    @method writeToEncFile:path
    @abstract write data to encrypt file
    @param path The encrypt file full path
    @result Return value if success retrun YES
 */
- (BOOL)writeToEncFile:(NSString*)path;

/*!
    @method dataWithContentsOfEncFile
    @abstract read data from encrypt file
    @param path The encrypt file full path
    @result Return NSData objects plain data
 */
+ (id)dataWithContentsOfEncFile:(NSString *)path;

/*!
    @method dataWithEncContentsOfURL
    @abstract read data from url file
    @param path The encrypt file url
    @result Return NSData objects plain data
 */
+ (id)dataWithEncContentsOfURL:(NSURL *)url;

@end
