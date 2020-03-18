//
//  tbAccount.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-8-6.
//
//

#import "tbAccount.h"

@implementation tbAccount

@synthesize userSid;
@synthesize userAccountName;
@synthesize userAccountPasswordMd5;
@synthesize userAccountPasswordSha1;
@synthesize userCertCn;
@synthesize userCertMd5;

- (void)dealloc
{
    [userSid release];userSid = nil;
    [userAccountName release];userAccountName = nil;
    [userAccountPasswordMd5 release];userAccountPasswordMd5 = nil;
    [userAccountPasswordSha1 release];userAccountPasswordSha1 = nil;
    [userCertCn release];userCertCn = nil;
    [userCertMd5 release];userCertMd5 = nil;
    [super dealloc];
}

@end
