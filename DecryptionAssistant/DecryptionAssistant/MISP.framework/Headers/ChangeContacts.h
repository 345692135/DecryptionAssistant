//
//  ChangeContacts.h
//  MISP
//
//  Created by Mr.Cooriyou on 13-3-4.
//
//

#import "WSBaseObject.h"
#import "TCPAccess.h"

@interface ChangeContacts : WSBaseObject<CommandResponseDelegate>
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

-(long) changeContactsWithPhone:(NSString*)number mailbox:(NSString*)address;

@end
