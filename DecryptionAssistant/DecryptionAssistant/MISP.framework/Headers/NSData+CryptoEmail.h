//
//  NSData+CryptoEmail.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-12-1.
//
//

#import <Foundation/Foundation.h>

@interface NSData (CryptoEmail)

/*!
    @method encryptWriteToFile:path
    @abstract write data to encrypt file
    @param path The encrypt file full path
    @result Return value if success retrun YES
 */
- (BOOL)encryptWriteToFile:(NSString *)path withLevel:(NSString *)levelName;

/*!
     @method encryptNSDataWithFile
     @abstract 加密文件并返回加密后的文件流
     @param levelName The encrypt levelName
     @result encryptNSData
 */
- (NSData *)encryptDataWithLevel:(NSString *)levelName;

/*!
    @method dataWithEncryptContentsOfFile:path
    @abstract read data from encrypt file
    @param path The encrypt file full path
    @result Return NSData objects plain data
 */
+ (id)dataWithEncryptContentsOfFile:(NSString *)path;

//😆
+ (id)dataWithEncryptContentsOfData:(NSData *)data;

/*!
 @method dataWithEncryptContentsOfAttachedFile:path
 @abstract read data from encrypt attached file
 @param path The encrypt file full path
 @result Return NSData objects plain data
 */
+ (id)dataWithEncryptContentsOfAttachedFile:(NSString *)path;


/*!
    @method dataWithEncryptContentsOfURL url
    @abstract read data from url file
    @param path The encrypt file url
    @result Return NSData objects plain data
 */
+ (id)dataWithEncryptContentsOfURL:(NSURL *)url;

/*!
    @method dataWithEncryptContentsOfAttachedData:data
    @abstract read data from encrypt data
    @param path The encrypt file data
    @result Return NSData objects plain data
 */
+ (id)dataWithEncryptContentsOfAttachedData:(NSData *)data;

//判断解密是否成功 😆
- (BOOL)isEncData;

@end
