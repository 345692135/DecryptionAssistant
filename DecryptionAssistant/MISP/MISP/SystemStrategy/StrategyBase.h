//
//  StrategyBase.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-7-19.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

// This is a strategy base class - see the class methods below


#import "WSBaseObject.h"
#import "GDataXMLNode.h"

@interface StrategyBase : WSBaseObject
{
    GDataXMLDocument* strategyXMLData;    //strategy xml data
}

@property(atomic,retain)GDataXMLDocument* strategyXMLData;

/*!
    @method initWithStrategyData
    @abstract init strtegy object with XML Data
    @param data The strategy xml data
    @result Return System Strategy object 
 */
- (id)initWithStrategyData:(NSData*)data error:(NSError**) err;

/*!
    @method updateWithStrategyData
    @abstract update strtegy object with XML Data
    @param data The strategy xml data
    @result null 
 */
//- (void)updateWithStrategyData:(NSData*)data error:(NSError**) err;


/*!
    @method getStrategySHA1
    @abstract Get SHA1 from XML Data
    @result Return strategy SHA1
 */
- (NSString*)getStrategySHA1;

@end
