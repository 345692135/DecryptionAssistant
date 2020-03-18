//
//  tbSysConfig.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-8-6.
//
//

#import "SQLitePersistentObject.h"

@interface tbSysConfig : SQLitePersistentObject
{
    int sysInitialized;
    NSString* ip;
    NSString* prot;
    NSString* productKey;
    NSString* guid;
    NSData* systemStrategyData;
    NSData* systemAuthority;
    
}

@property(atomic)int sysInitialized;
@property(atomic,retain)NSData* systemStrategyData;
@property(atomic,retain)NSData* systemAuthority;
@property(atomic,retain)NSString* ip;
@property(atomic,retain)NSString* prot;
@property(atomic,retain)NSString* productKey;
@property(atomic,retain)NSString* guid;

@end
