//
//  tbStrategy.m
//  MISP
//
//  Created by Mr.Cooriyou on 12-8-6.
//
//

#import "tbStrategy.h"

@implementation tbStrategy

@synthesize strategySid;
@synthesize xmlData;

- (void)dealloc
{
    [strategySid release];strategySid = nil;
    [xmlData release]; xmlData = nil;
    [super dealloc];
}

@end
