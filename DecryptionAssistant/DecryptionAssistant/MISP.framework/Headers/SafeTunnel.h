//
//  SafeTunnel.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-12-17.
//
//

#import "WSBaseObject.h"

@interface SafeTunnel : WSBaseObject

+ (SafeTunnel*)getInstance;

-(void)start;

-(void)stop;

-(NSArray*)getApplicationList;

@end
