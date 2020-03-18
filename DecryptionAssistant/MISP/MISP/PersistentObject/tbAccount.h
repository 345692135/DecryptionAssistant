//
//  tbAccount.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-8-6.
//
//

#import "SQLitePersistentObject.h"

@interface tbAccount : SQLitePersistentObject
{
//    NSString* userSid;
//    NSString* userAccountName;
//    NSString* userAccountPasswordMD5;
//    NSString* userAccountPasswordSHA1;
//    NSString* userCertCN;
//    NSString* userCertMD5;
}

@property(atomic,retain)NSString* userSid;
@property(atomic,retain)NSString* userAccountName;
@property(atomic,retain)NSString* userAccountPasswordMd5;
@property(atomic,retain)NSString* userAccountPasswordSha1;
@property(atomic,retain)NSString* userCertCn;
@property(atomic,retain)NSString* userCertMd5;

@end
