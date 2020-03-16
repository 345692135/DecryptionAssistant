//
//  CryptoCoreData.h
//  Security
//
//  Created by Mr.Cooriyou on 12-11-27.
//
//

#import <Foundation/Foundation.h>


@interface CryptoCoreData : NSObject

@property(atomic)BOOL isInit;

+ (NSDictionary*) getLevelKeysDictionary;

- (id)initWithLevel:(NSString*)name total:(long long)size;

- (NSData*)getElectronLabel;

- (long)cryptUpdateData:(unsigned char*)inData inLength:(int)inlen outData:(unsigned char*)outData outLen:(int*) outLen;
- (long)cryptFinalData:(unsigned char*) outData outLen:(int*)outLen;

- (id)initWithElectronLabelHead:(NSData*)label;

- (id)initWithAttachedFileLabelHead:(NSData*)label;

@end
