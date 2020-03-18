//
//  tbStrategy.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-8-6.
//
//

#import "SQLitePersistentObject.h"

@interface tbStrategy : SQLitePersistentObject
{
//    NSString* strategySid;
//    NSString* xmlString;
}

@property(atomic,retain)NSString* strategySid;
@property(atomic,retain)NSData* xmlData;

@end
