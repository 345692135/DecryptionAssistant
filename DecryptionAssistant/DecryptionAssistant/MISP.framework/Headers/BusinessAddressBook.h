//
//  BusinessAddressBook.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-12-28.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//
// This is a get address book from v3 server class ,used by address book - see the class methods below

#import "WSBaseObject.h"
#import "TCPAccess.h"
#import "GDataXMLNode.h"

@interface BusinessAddressBook : WSBaseObject<CommandResponseDelegate>
{
    int step;
    long err;
    BOOL isRecv;
    TCPAccess* access;
}
@property(atomic,retain)TCPAccess* access;
@property(atomic)int step;
@property(atomic)BOOL isRecv;
@property(atomic)long err;
@property(retain,atomic)GDataXMLElement* addressBook;

- (GDataXMLElement* )getBusinessAddressBook;

@end
