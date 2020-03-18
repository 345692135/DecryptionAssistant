//
//  AccountManagement.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-7-21.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import "AccountManagement.h"
#import "tbAccount.h"
#import "NSData+Degist.h"
#import "NSString+Degist.h"
#import "Context.h"


@interface AccountManagement()
{
    NSMutableArray* managementAccountList;
}

@property(atomic,retain)NSMutableArray* managementAccountList;

@end

@implementation AccountManagement

static AccountManagement* actInstance = nil;

@synthesize managementAccountList;

+ (MODULEID)getModuleId
{
    return BUSINESS_PROCESS_ACCOUNT_MANAGEMENT;
}

#pragma mark singleton class method

+ (AccountManagement*)getInstance
{
    @synchronized(self) {
        if (!actInstance) {
            actInstance = [NSAllocateObject([self class], 0, NULL) init];
        }
    }
    return actInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (actInstance == nil) {
            actInstance = [super allocWithZone:zone];
        }
    }
    return actInstance;  // assignment and return on first allocation
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSIntegerMax;
}

- (id)autorelease
{
    return self;
}

- (oneway void)release
{
    //DO Nothing
}
- (id)copyWithZone:(NSZone*)zone
{
    return self;
}

- (void)dealloc
{
    if (managementAccountList != nil) {
        [managementAccountList removeAllObjects];
        [managementAccountList release];managementAccountList = nil;
    }
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        //To do init managementAccountList opt
        if (managementAccountList != nil) {
            [managementAccountList removeAllObjects];
            [managementAccountList release];managementAccountList = nil;
            TRACK(@"remove all managementAccountList");
        }
        managementAccountList = [[NSMutableArray alloc]init];

        //get default account
        tbAccount* account = (tbAccount*)[tbAccount findByPK:1];
        SystemAccount* defaultAccount = [[SystemAccount alloc]init];
        [defaultAccount setAccount_st:WSAccountStatusUnknow];
        [defaultAccount setActiveTypeNow:WSAccountActiveUnknow];
        [defaultAccount setUserSid:[account userSid]];

        //set dictionary value
        NSMutableDictionary* dicAccount = [[NSMutableDictionary alloc]init];
        [dicAccount setObject:[NSNumber numberWithBool:YES] forKey:@"INDB"];
        [dicAccount setObject:[NSNumber numberWithBool:YES] forKey:@"ACTIVE"];
        [dicAccount setObject:defaultAccount forKey:@"ACCOUNT"]; //set default account
        [defaultAccount release];defaultAccount = nil; //release defaultAccount

        //add dictionary to managementAccountList
        [managementAccountList addObject:dicAccount];
        // release dictionary
        [dicAccount release];dicAccount = nil;
        [tbAccount clearCache];
        
        //add observer
        
        NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
        [notifyCenter addObserver:self selector:@selector(offlineActiveAccount) name:@"HEART_BEAT_TIMEOUT" object:nil];
        [notifyCenter addObserver:self selector:@selector(offlineActiveAccount) name:@"HEART_BEAT_ERROR" object:nil];
    }
    return self;
}

#pragma mark observer callback

- (void)offlineActiveAccount
{
    if ([self getActiveAccountCount] == 0) {
        return;
    }
    
    [self changeAccountStatus:WSAccountStatusOffine];
    NSString* strMessage = @"user is offine";
    NSNotification* notify = [NSNotification notificationWithName:@"ACCOUNT_CHANGED_OFFLINE" object:strMessage];
    NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
    [notifyCenter postNotification:notify];
    
//    TRACK(@"------Heart_Beat_Timeout------")
}

#pragma mark Business method

- (SystemAccount*)registerAccountWithUserAccount:(UserAccount*)account error:(NSError**)err
{
    SystemAccount* systemAccount = nil;
    
    if (account == nil) {
        [self makeError:err domain:@"user account is nil!" errCode:0x3600];
        return nil;
    }
    @synchronized(self){
    //check active account count
    int activeCount = [self getActiveAccountCount];
    if (activeCount > 0) {
        TRACK(@"active count is > 0,please unregister old account before!");
        [self makeError:err domain:@"active count is > 0,please unregister old account before!" errCode:0x3601];
        TRACK(@"err : %@",*err);
        return nil;
    }
    
    if ([account getAccountType] == WSAccountTypeUnknow) {
        //To do nothing
        [self makeError:err domain:@"unkonw user type (WSAccountTypeUnknow)!" errCode:0x3602];
        TRACK(@"err : %@",*err);
        return nil;
    }else if([account getAccountType] == WSAccountTypePassword){
        //To do user password appraise
        systemAccount = [self trustEvaluationForPassword:account error:err];
        
    }else if([account getAccountType] == WSAccountTypeCertificate){
        systemAccount = [self trustEvaluationForCertificate:account error:err];
    }else{
        //TO do nothing
        return nil;
    }
//    TRACK(@"err : %@",*err);
//    TRACK(@"system account \r activeTypeNow:%d \r account_st:%d \r pin: %@ \r sid: %@",
//          [systemAccount activeTypeNow],
//          [systemAccount account_st],
//          [[systemAccount cerAct] pin],
//          [systemAccount userSid]);
    }
    return systemAccount;
}

- (long)unregisterAccountWithUserAccount:(UserAccount*)account
{
    @synchronized(self){
        [self unregisterActiveAccount];
    }
    return 0;
}

- (int)getActiveAccountCount
{
    return ([managementAccountList count]-1);
}

- (SystemAccount*)getActiveAccount
{
    NSMutableDictionary* dic = [managementAccountList objectAtIndex:([managementAccountList count]-1)];
//    TRACK(@"ActiveAccount is %@",dic);
    return (SystemAccount*)[dic objectForKey:@"ACCOUNT"];
}

- (SystemAccount*)getDefaultAccount
{
    NSMutableDictionary* dic = [managementAccountList objectAtIndex:0];
    return (SystemAccount*)[dic objectForKey:@"ACCOUNT"];
}

- (void)unregisterActiveAccount
{
    if ([self getActiveAccountCount]>0) {
        [managementAccountList removeObjectAtIndex:1];
    }
}

- (void)changeAccountStatus:(WSAccountStatus)status
{
    @synchronized(self){
        int nCount = [self getActiveAccountCount];
        if (nCount == 0) {
            return;
        }
        SystemAccount* account = [self getActiveAccount];
        switch (status) {
            case WSAccountStatusUnknow:
                //do nothing
                break;
            case WSAccountStatusOffine:
                [account setAccount_st:status];
                break;
            case WSAccountStatusOnline:
                [self changeAccountTrustOnline:[account userSid]];
                break;
            case WSAccountStatusMistrust:
                break;
            default:
                break;
        }
        
    }//@synchronized
    
}

- (void)setActiveAccountUsersid:(NSString*)sid token:(NSString*)token key:(NSData*)key
{
    SystemAccount* account = nil;
    if ([self getActiveAccountCount] == 0
        ||[sid length] == 0
        ||[token length] == 0
        ||[key length] == 0) {
        return;
    }
    //set value
    account = [self getActiveAccount];
    [account setUserSid:sid];
    [account setToken:token];
    [account setSessionKey:key];
    
}

- (void)changePassword
{
    NSMutableDictionary* dic = [managementAccountList objectAtIndex:([managementAccountList count]-1)];
    if (dic == nil) {
        return;
    }
//    NSNumber* indb = (NSNumber*)[dic objectForKey:@"INDB"];
    SystemAccount* account = (SystemAccount*)[dic objectForKey:@"ACCOUNT"];
//    if([indb boolValue] == YES){ //account in db
        if ([account activeTypeNow] == WSAccountActivePassword) {
            NSString* sql = [NSString stringWithFormat:@"WHERE user_sid = '%@'",[account userSid]];
            tbAccount* act =(tbAccount*)[tbAccount findFirstByCriteria:sql];
            if (act != nil) {
                [act setUserAccountPasswordMd5:[[account pwdAct]userPasswordMD5]];
                [act setUserAccountPasswordSha1:[[account pwdAct]userPasswordSHA1]];
                [act save];
                [tbAccount clearCache];
            }
        }
//    }
    
}

- (void)changeAccountTrustOnline:(NSString*)usersid
{
    NSMutableDictionary* dic = [managementAccountList objectAtIndex:([managementAccountList count]-1)];
    if (dic == nil) {
        return;
    }
    NSNumber* indb = (NSNumber*)[dic objectForKey:@"INDB"];
    SystemAccount* account = (SystemAccount*)[dic objectForKey:@"ACCOUNT"];
    if([indb boolValue] == YES){ //account in db
        [account setAccount_st:WSAccountStatusOnline];
        if ([account activeTypeNow] == WSAccountActivePassword) {
            NSString* sql = [NSString stringWithFormat:@"WHERE user_sid = '%@'",usersid];
            tbAccount* act =(tbAccount*)[tbAccount findFirstByCriteria:sql];
            if (act != nil) {
                [act setUserAccountName:[[account pwdAct]userName]];
                [act setUserAccountPasswordMd5:[[account pwdAct]userPasswordMD5]];
                [act setUserAccountPasswordSha1:[[account pwdAct]userPasswordSHA1]];
                [act setUserSid:usersid];
                [act save];
                [tbAccount clearCache];
            }else{
                TRACK(@"[WARING]usersid is changed!")
                NSString* sql2 = [NSString stringWithFormat:@"WHERE user_account_name = '%@'",[[account pwdAct]userName]];
                tbAccount* act2 =(tbAccount*)[tbAccount findFirstByCriteria:sql2];
                if (act2 != nil) {
                    [act2 setUserAccountName:[[account pwdAct]userName]];
                    [act2 setUserAccountPasswordMd5:[[account pwdAct]userPasswordMD5]];
                    [act2 setUserAccountPasswordSha1:[[account pwdAct]userPasswordSHA1]];
                    [act2 setUserSid:usersid];
                    [act2 save];
                    [tbAccount clearCache];
                }
            }
        }else{
            NSString* sql = [NSString stringWithFormat:@"WHERE user_sid = '%@'",usersid];
            tbAccount* act =(tbAccount*)[tbAccount findFirstByCriteria:sql];
            if (act != nil) {
                [act setUserCertMd5:[[[[account cerAct]certifykeyDelegate]getCertificateData]md5]];
                [act setUserSid:usersid];
                [act save];
                [tbAccount clearCache];
            }
        }
        
    }else{
        [account setAccount_st:WSAccountStatusOnline];
        if ([account activeTypeNow] == WSAccountActivePassword) {
            NSString* sql = [NSString stringWithFormat:@"WHERE user_sid = '%@'",usersid];
            tbAccount* act =(tbAccount*)[tbAccount findFirstByCriteria:sql];
            if (act == nil) {//can not find usersid this is a new account
                tbAccount* newAct = [[tbAccount alloc]init];
                [newAct setUserAccountName:[[account pwdAct]userName]];
                [newAct setUserAccountPasswordMd5:[[account pwdAct]userPasswordMD5]];
                [newAct setUserAccountPasswordSha1:[[account pwdAct]userPasswordSHA1]];
                [newAct setUserSid:usersid];
                [newAct save];
                [tbAccount clearCache];
                [newAct release];newAct = nil;
            }else{
                [act setUserAccountName:[[account pwdAct]userName]];
                [act setUserAccountPasswordMd5:[[account pwdAct]userPasswordMD5]];
                [act setUserAccountPasswordSha1:[[account pwdAct]userPasswordSHA1]];
                [act setUserSid:usersid];
                [act save];
                [tbAccount clearCache];
            }
            
        }else{
            NSString* sql = [NSString stringWithFormat:@"WHERE user_sid = '%@'",usersid];
            tbAccount* act =(tbAccount*)[tbAccount findFirstByCriteria:sql];
            if (act == nil) {//can not find usersid this is a new account
                tbAccount* newAct = [[tbAccount alloc]init];
                [newAct setUserCertMd5:[[[[account cerAct]certifykeyDelegate]getCertificateData]md5]];
                [newAct setUserSid:usersid];
                [newAct save];
                [tbAccount clearCache];
                [newAct release];newAct = nil;
            }else{
                [act setUserCertMd5:[[[[account cerAct]certifykeyDelegate]getCertificateData]md5]];
                [act setUserSid:usersid];
                [act save];
                [tbAccount clearCache];
            }
        }
    }
}

#pragma mark trust evaluation method

- (SystemAccount*)trustEvaluationForPassword:(UserAccount*)account error:(NSError**)err
{
    SystemAccount* systemAccont = nil;
    NSString* sql = [NSString stringWithFormat:@"WHERE user_account_name = '%@'",[account getUserName]];
    tbAccount* act =(tbAccount*)[tbAccount findFirstByCriteria:sql];
    if (act == nil) {//the new account
        [self newAccountToAccountListByPasswordAccount:account];
    }else{//truct account
        [self oldAccountToAccountListByPasswordAccount:account tbAccount:act];
    }
    
    systemAccont = [self getActiveAccount];
    
    return systemAccont;
}


- (SystemAccount*)trustEvaluationForCertificate:(UserAccount*)account error:(NSError**)err
{
    SystemAccount* systemAccont = nil;
    //get key driver
    id<CertificateKeyDelegate> key = [[Context getInstance]getKeyDriver];
    if (key == nil) {
        [self makeError:err domain:@"key driver is exception（driver nil）" errCode:0x3603];
        return systemAccont;
    }
    
    //verify pin
    BOOL bVerifyPin = [key verifyPin:[account getPin]];
    if (bVerifyPin == NO) {
        [self makeError:err domain:@"verify pin is lose " errCode:0x3604];
        return systemAccont;
    }
    
    //trust evaluation
    NSString* md5 = [[key getCertificateData]md5];
    if ([md5 length] == 0) {
        [self makeError:err domain:@"user certificate data is exception" errCode:0x3605];
        return systemAccont;
    }
    
    NSString* sql = [NSString stringWithFormat:@"WHERE user_cert_md_5 = '%@'",md5];
    tbAccount* act =(tbAccount*)[tbAccount findFirstByCriteria:sql];
    if (act == nil) {//the new account
        [self newAccountToAccountListByCertificateAccount:account];
    }else{//truct account
        [self oldAccountToAccountListByCertificateAccount:account tbAccount:act];
    }
    
    TRACK(@"%@",[managementAccountList objectAtIndex:0]);
    TRACK(@"%@",[managementAccountList objectAtIndex:1]);
    
    systemAccont = [self getActiveAccount];
    
    TRACK(@"%d",[systemAccont account_st]);
    
    return systemAccont;
}

#pragma mark trust evaluation Tools method

- (void)newAccountToAccountListByPasswordAccount:(UserAccount*)account
{
    SystemAccount* systemAccont = [[SystemAccount alloc]init];
    PwdAccount* pwdAccount = [[PwdAccount alloc]init];
    
    //set user password account value
    [pwdAccount setUserName:[account getUserName]];
    [pwdAccount setUserPassword:[account getPassword]];
    NSString* md5 = [[pwdAccount userPassword]md5];
    NSString* sha1 = [[pwdAccount userPassword]sha1];
    [pwdAccount setUserPasswordMD5:md5];
    [pwdAccount setUserPasswordSHA1:sha1];
    
    //set account status : new account
    [systemAccont setAccount_st:WSAccountStatusMistrust];
    
    //set active type now : password mode
    [systemAccont setActiveTypeNow:WSAccountActivePassword];
    [systemAccont setPwdAct:pwdAccount];
    [pwdAccount release];pwdAccount = nil; //release pwdAccount
    
    //set dictionary value
    NSMutableDictionary* dicAccount = [[NSMutableDictionary alloc]init];
    [dicAccount setObject:[NSNumber numberWithBool:NO] forKey:@"INDB"];
    [dicAccount setObject:[NSNumber numberWithBool:YES] forKey:@"ACTIVE"];
    [dicAccount setObject:systemAccont forKey:@"ACCOUNT"]; //set account
    [systemAccont release];systemAccont = nil; //release account
    
    //add dictionary to managementAccountList
    [managementAccountList addObject:dicAccount];
    
    // release dictionary
    [dicAccount release];dicAccount = nil;
    
    //change active account
    NSMutableDictionary* dicDefault = (NSMutableDictionary*)[managementAccountList objectAtIndex:0];
    [dicDefault setObject:[NSNumber numberWithBool:NO] forKey:@"ACTIVE"];
    
    [tbAccount clearCache];
}

- (void)oldAccountToAccountListByPasswordAccount:(UserAccount*)account tbAccount:(tbAccount*)act
{
    SystemAccount* systemAccont = [[SystemAccount alloc]init];
    PwdAccount* pwdAccount = [[PwdAccount alloc]init];
    
    //set user password account value
    [pwdAccount setUserName:[account getUserName]];
    [pwdAccount setUserPassword:[account getPassword]];
    NSString* md5 = [[pwdAccount userPassword]md5];
    NSString* sha1 = [[pwdAccount userPassword]sha1];
    [pwdAccount setUserPasswordMD5:md5];
    [pwdAccount setUserPasswordSHA1:sha1];
    
    /**add offline strategy juge
     */
    //set account status : trust account
    if ([pwdAccount.userPasswordMD5 isEqualToString:[act userAccountPasswordMd5]]) {
        [systemAccont setAccount_st:WSAccountStatusOffine]; //trust account
    }else{
        [systemAccont setAccount_st:WSAccountStatusUnknow]; //trust account but password not equivalent need online certify
    }
    
    //set active type now : password mode
    [systemAccont setActiveTypeNow:WSAccountActivePassword];
    [systemAccont setPwdAct:pwdAccount];
    [pwdAccount release];pwdAccount = nil; //release pwdAccount
    
    //set usersid
    [systemAccont setUserSid:[act userSid]];
    
    //set dictionary value
    NSMutableDictionary* dicAccount = [[NSMutableDictionary alloc]init];
    [dicAccount setObject:[NSNumber numberWithBool:YES] forKey:@"INDB"];  //in database
    [dicAccount setObject:[NSNumber numberWithBool:YES] forKey:@"ACTIVE"];
    [dicAccount setObject:systemAccont forKey:@"ACCOUNT"]; //set trust account
    [systemAccont release];systemAccont = nil; //release account
    
    //add dictionary to managementAccountList
    [managementAccountList addObject:dicAccount];
    
    // release dictionary
    [dicAccount release];dicAccount = nil;
    
    //change active account
    NSMutableDictionary* dicDefault = (NSMutableDictionary*)[managementAccountList objectAtIndex:0];
    [dicDefault setObject:[NSNumber numberWithBool:NO] forKey:@"ACTIVE"];
    
    [tbAccount clearCache];
    
}

- (void)newAccountToAccountListByCertificateAccount:(UserAccount*)account
{
    SystemAccount* systemAccont = [[SystemAccount alloc]init];
    CerAccount* cerAccount = [[CerAccount alloc]init];
    //set cert account
    [cerAccount setCertifykeyDelegate:[[Context getInstance]getKeyDriver]];
    [cerAccount setPin:[account getPin]];
    
    //set account status : new account
    [systemAccont setAccount_st:WSAccountStatusMistrust];
    
    //set active type now : certificate mode
    [systemAccont setActiveTypeNow:WSAccountActivecertificate];
    [systemAccont setCerAct:cerAccount];
    [cerAccount release];cerAccount = nil;
    
    //set dictionary value
    NSMutableDictionary* dicAccount = [[NSMutableDictionary alloc]init];
    [dicAccount setObject:[NSNumber numberWithBool:NO] forKey:@"INDB"];
    [dicAccount setObject:[NSNumber numberWithBool:YES] forKey:@"ACTIVE"];
    [dicAccount setObject:systemAccont forKey:@"ACCOUNT"]; //set account
    [systemAccont release];systemAccont = nil; //release account
    
    //add dictionary to managementAccountList
    [managementAccountList addObject:dicAccount];
    
    // release dictionary
    [dicAccount release];dicAccount = nil;
    
    //change active account
    NSMutableDictionary* dicDefault = (NSMutableDictionary*)[managementAccountList objectAtIndex:0];
    [dicDefault setObject:[NSNumber numberWithBool:NO] forKey:@"ACTIVE"];
    
    [tbAccount clearCache];
    
}


- (void)oldAccountToAccountListByCertificateAccount:(UserAccount*)account tbAccount:(tbAccount*)act
{
    SystemAccount* systemAccont = [[SystemAccount alloc]init];
    CerAccount* cerAccount = [[CerAccount alloc]init];
    //set cert account
    [cerAccount setCertifykeyDelegate:[[Context getInstance]getKeyDriver]];
    [cerAccount setPin:[account getPin]];
    
    //set account status : trust account
    NSString* md5 = [[[cerAccount certifykeyDelegate]getCertificateData]md5];
    if ([md5 isEqualToString:[act userCertMd5]]) {
        [systemAccont setAccount_st:WSAccountStatusOffine]; //trust account
    }else{//Invalid branch
        [systemAccont setAccount_st:WSAccountStatusUnknow]; //trust account but cert md5 not equivalent need online certify
    }
    
    //set active type now : certificate mode
    [systemAccont setActiveTypeNow:WSAccountActivecertificate];
    [systemAccont setCerAct:cerAccount];
    [cerAccount release];cerAccount = nil;
    
    //set usersid
    [systemAccont setUserSid:[act userSid]];
    
    //set dictionary value
    NSMutableDictionary* dicAccount = [[NSMutableDictionary alloc]init];
    [dicAccount setObject:[NSNumber numberWithBool:YES] forKey:@"INDB"];
    [dicAccount setObject:[NSNumber numberWithBool:YES] forKey:@"ACTIVE"];
    [dicAccount setObject:systemAccont forKey:@"ACCOUNT"]; //set account
    [systemAccont release];systemAccont = nil; //release account
    
    //add dictionary to managementAccountList
    [managementAccountList addObject:dicAccount];
    
    // release dictionary
    [dicAccount release];dicAccount = nil;
    
    //change active account
    NSMutableDictionary* dicDefault = (NSMutableDictionary*)[managementAccountList objectAtIndex:0];
    [dicDefault setObject:[NSNumber numberWithBool:NO] forKey:@"ACTIVE"];
    
    [tbAccount clearCache];
    
}

- (int)getAccountCountInDatabase
{
    return  [tbAccount count];
}

@end
