//
//  MISP.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-7-19.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import "MISP.h"
#import "CertificateHelper.h"
#import "KeyStore.h"
#import "ws_systemsecurity.h"
#import "AccountManagement.h"
#import "SystemAccount.h"
#import "SystemStrategy.h"
#import "UserStrategy.h"
#import "IConfig.h"
#import "ConfigManager.h"

#import "SecLevelKeyHelper.h"

@implementation MISP


- (void) sayHello
{
 
    CRYPTO_malloc_init();
    OpenSSL_add_all_algorithms();
    
    NSString *certPath = [[NSBundle mainBundle] pathForResource:@"person" ofType:@"pfx"];
    NSString *pwd = @"111111a";
    CFStringRef pwdRef = (CFStringRef)pwd;
    
    CFDataRef dataRef;
    size_t bCertLen;
    
    CertificateHelper *certInstance = [CertificateHelper alloc];
    
    [certInstance getCertificateFromPath:certPath password:pwdRef certContent:&dataRef certLen:&bCertLen];
    NSLog(@"certData = %@",dataRef);
    
    const char *certData = [(NSData *)dataRef bytes];
    
    //X509 *x509Cert = getX509CertData((unsigned char *)certData, [(NSData *)dataRef length]);
    X509 *x509Cert = [certInstance Certify_GetX509CertData:(unsigned char *)certData dataLen:[(NSData *)dataRef length]];
    if (x509Cert == NULL) {
        NSLog(@"读取失败");
    }
    
    
    NSString *rootCert = [[NSBundle mainBundle] pathForResource:@"ycd" ofType:@"cer"];
    
    //long uRet = Tool_Cert_ByRootCert_Verify((char *)[rootCert UTF8String], x509Cert);
    int uRet = [certInstance Certify_Verify_RootCert:rootCert x509Cert:x509Cert];
    if(uRet != 0){
        
        NSLog(@"验证失败");
    }
    
    
    KeyStore *keyInstance = [[KeyStore alloc] initWithType:kCERTIFICATE_PKCS12];
    
    [keyInstance load:certPath password:pwd];
    
    SecKeyRef myPubKey = [keyInstance returnPublicKey];
    SecKeyRef myPriKey = [keyInstance returnPrivateKey];
    
    NSLog(@"myPubKe=%p \n myPriKey=%p",myPubKey,myPriKey);
    
    [keyInstance release];
    [certInstance release];
   
}
/*
 NSLog(@"Hello, Welcome to Mobile Information Security Platform !");
 
 GDataXMLDocument* xml = [[GDataXMLDocument alloc]initWithXMLString:@"<root><row></row></root>" options:0 error:nil];
 
 NSData* data = [xml XMLData];
 
 NSString* xmlString = [NSString stringWithCString:[data bytes] encoding:NSUTF8StringEncoding];
 
 NSLog(@"%@",xmlString);
 
 [xml release];
 
 //[self TestforDBInit];
 [self TestforAccountManagementCERT];
 */

//- (void)TestforDBInit
//{
//    [EncryptSQLiteManager getInstance];
//}
//
//- (void)TestforAccountManagementPWD
//{
//    UserAccount* uact = [[UserAccount alloc]initWithUserName:@"wangbingyang" password:@"1234qwer"];
//    
//    AccountManagement* amg = [AccountManagement getInstance];
//    NSError* err = nil;
//    [amg registerAccountWithUserAccount:uact error:&err];
//    [uact release];
//}
//
//- (void)TestforAccountManagementCERT
//{
//    UserAccount* uact = [[UserAccount alloc]initWithPin:@"12345678"];
//    
//    AccountManagement* amg = [AccountManagement getInstance];
//    NSError* err = nil;
//    [amg registerAccountWithUserAccount:uact error:&err];
//    [uact release];
//}

-(void)testIkey
{
    long lRet = 0;
    unsigned char text[5] = "1234";
    unsigned char cipherText[161] = {0};
    unsigned char plainText[100] = {0};
    
    unsigned char signText[200] = {0};
    size_t len = 0;
    lRet = Ikey_Encrypt(text, 4, cipherText, &len);
    NSLog(@"Ikey_Encrypt Ret : %ld",lRet);

    
    lRet = Ikey_Decrypt(cipherText, 160, plainText, &len);
    NSLog(@"Ikey_Decrypt Ret : %ld",lRet);
    NSLog(@"Text is : %s",plainText);
    
    lRet = IKeyRawSignSha1(cipherText, 160, signText, &len);
    NSLog(@"%ld",len);
    NSLog(@"IKeyRawSignSha1 Ret : %ld",lRet);
    
    lRet = IKeyRawVerifySha1(signText, len,cipherText, 160);
    NSLog(@"IKeyRawVerifySha1 Ret : %ld",lRet);
    
    
}

- (void)testLevelKey
{
    
    long lRet = 0;
    size_t len = 0;
    unsigned char text[5] = "1234";
    unsigned char cipherText[161] = {0};
//    unsigned char cipherText1[161] = {0};
    unsigned char plainText[100] = {0};
    
//    lRet = Ikey_Encrypt(text, 4, cipherText1, &len);
//    NSLog(@"Ikey_Encrypt Ret : %ld",lRet);
    
    
//    NSString* key = @"8177611F94A371A1D5B0C4880DBC304651F26AD41BAC89E215DEA0A957C46F575311789EFB4A2F3B21A4E211A2C220C43E35465BEDC0A121CFCE499431141DA4E54857C43A6B6E54D49B785BA515124DD04633B53357FE5DAF6BD616BA27D1BE6512AC15D58E6DA9CA6CB2D2090BFD373C1D00BF7A764F98D9A06672F094D45B437EA374110C3F5C65EFC59F52EC8B1DBD6E8005905EE16A94F3044228EFFDA56F654CF882CC74EBC5EFD5AC3A4A819DFD86F48E485B3360D89F0CEFBCFF4B261DB85E1D6FA8281A2F142B771C708FEAC5D7E67DE2CE68E6660F5ACDC2676C9DD9679780D5847E3F6009FC355B9BA7E8F422801DBF1FF859EDDF3EEE2A039C2F03F61783C8049D22C75E1B7F37E40DF3915730CBB06FD7B67635085AA6A33A1AD06FB62CCAE94192A0788DB52797F2A0C43B7B21B126EA262BD7FACC4581A8C9";
    
    NSString* key = @"A0F1FD49B93D3A7B0B5C11AE361F140B225D4D9AFC73F7634EF4E7601A348D71ADC5957B604A32B36168F91B56ECAB29B01DBCCE6DF04038EBA81AE42B007C001E8D45DE7234B768DD6DE5FF8C65D3128165D2737735B2C5740B93BB049F277DB01ABDED20F60FD1FF01303389EC899A310343F23B5755346C0132C694ECB00A4BD42DD2AC20F711A7E6550BFC26D5FA32E074852EF02F671FB654FB8B90D57CEF85F7D7368F73BCA758FD1E2055100E0EDB7B905C4D8143138D4725C639F3B00334A6D78A624E2D495D49E2E86A70B9CC0389E16CADD66DEF38C5196D5FDF5FDD3EC4583BF76DF34F4FC963B893E7F7E015FEA27F8BD7E88B38A66384222B8BF3C9E9FB38EFE7091D9708A394F5539ACDB386DF19A5701511DF06249E68D904F112536C1F7A0EDA92BA70F379904FD22356F4D2B73BB82B376E0A26E68CFD81";
    
    SecLevelKeyHelper* levelKey = [[SecLevelKeyHelper alloc]initWithLevelKeyString:key];
    
    lRet = [levelKey levelKeyEncrypt:text length:4 cipherText:cipherText outLength:&len];
    TRACK(@"out 1 len is: [%zd] ,return <%lu>",len,lRet)
    
    [levelKey levelKeyDecrypt:cipherText length:len plainText:plainText outLength:&len];
    TRACK(@"out 2 len is: [%zd],return <%lu>",len,lRet)
    TRACK(@"out 2 len is: [%s]",plainText)
    
//    lRet = LevelKey_Encrypt([key UTF8String], text, 4, cipherText, &len);
//    TRACK(@"out 1 len is: [%zd] ,return <%lu>",len,lRet)
//    
//    lRet = LevelKey_Decrypt([key UTF8String], cipherText, len, plainText, &len);
//    TRACK(@"out 2 len is: [%zd],return <%lu>",len,lRet)
//    TRACK(@"out 2 len is: [%s]",plainText)
    
    [levelKey release];
    
}

- (void)testStrategy
{
    AccountManagement* amg = [AccountManagement getInstance];
    
    NSArray* arry = [[[amg getActiveAccount]getStrategy]getItemByGroupId:@"268763137"];
    
    TRACK(@"Count = %ld" , (unsigned long)[arry count])
    
}

- (void)testSysStrategy
{
    ConfigManager* configManager = [ConfigManager getInstance];
    
    id<IConfig> config = [configManager getConifgPrivder];
    
    SystemStrategy* sysStrategy = [config getValueByKey:WSConfigItemSystemStrategy];
    
    NSArray* arr = [sysStrategy getSecPubKeybyGroupId:@"537001985" secLevel:@"zkK8flXd-xFFSNR0c-sirscXfX-hJeQO91w"];
    
    if (arr != NULL) {
        GDataXMLNode* node = (GDataXMLNode*)[arr objectAtIndex:0];
             
        TRACK(@"Key = %@",[node stringValue])
    }
}




@end
