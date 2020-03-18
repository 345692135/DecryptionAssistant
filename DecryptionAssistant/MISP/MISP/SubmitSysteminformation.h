//
//  SubmitSysteminformation.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-11-6.
//
//

#import "WSBaseObject.h"
#import "TCPAccess.h"

@interface SubmitSysteminformation : WSBaseObject<CommandResponseDelegate>
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

-(long) submit;

@end
