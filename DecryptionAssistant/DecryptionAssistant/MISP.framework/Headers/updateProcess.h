//
//  updateProcess.h
//  MISP
//
//  Created by Mr.Cooriyou on 12-9-9.
//
//

#import "WSBaseObject.h"
#import "TCPAccess.h"

@interface updateProcess : WSBaseObject<CommandResponseDelegate>
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

- (long)updateDefaultUeserStrategy;
- (long)updateUeserStrategyByUsersid:(NSString*)sid;
- (long)updateSystemPermission;
- (long)updateSystemStrategy;


@end
