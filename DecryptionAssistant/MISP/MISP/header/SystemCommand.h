//
//  SystemCommand.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-8-5.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//
// This is a command helper class ,used by dispatch resquest and response with system command object -see the class methods below

#import "WSBaseObject.h"
#import "GDataXMLNode.h"

@interface SystemCommand : WSBaseObject
{
    GDataXMLDocument* head;
    GDataXMLDocument* body;
}

@property(atomic,retain)GDataXMLDocument* head;
@property(atomic,retain)GDataXMLDocument* body;

/*!
    @method setModuleId:module:code
    @abstract set command module id and opcode
    @param module The module id
    @param code The opcode
    @result Return nil
 */
- (void)setModuleId:(NSString*)module opcode:(NSString*)code;

/*!
    @method getModuleid
    @abstract get module id
    @result Return nil
 */
- (NSString*)getModuleid;

/*!
    @method getOpcode
    @abstract get Opcode
    @result Return nil
 */
- (NSString*)getOpcode;

/*!
    @method getReturnCode
    @abstract get return code
    @result Return nil
 */
- (NSString*)getReturnCode;

/*!
    @method getErrorDescribe
    @abstract get error describe
    @result Return nil
 */
- (NSString*)getErrorDescribe;

/*!
    @method getPackageDataObject
    @abstract get data object
    @result Return nil
 */
- (GDataXMLElement*)getPackageDataObject;

/*!
    @method setPackageDataObejectWithXmlString:xml:err
    @abstract set data object
    @param xml The xml string
    @param err The err
    @result Return 0 if success
 */
- (long)setPackageDataObejectWithXmlString:(NSString*)xml error:(NSError**)err;

/*!
    @method setPackageDataObejectWithElement:element:err
    @abstract set data object
    @param xml The xml element
    @param err The err
    @result Return 0 if success
 */
- (long)setPackageDataObejectWithElement:(GDataXMLElement*)element error:(NSError**)err;

@end
