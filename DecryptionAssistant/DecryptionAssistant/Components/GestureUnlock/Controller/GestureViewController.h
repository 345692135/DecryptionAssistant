
#import <UIKit/UIKit.h>
#import "BaseViewController.h"

typedef enum{
    GestureViewControllerTypeSetting = 1,
    GestureViewControllerTypeLogin
}GestureViewControllerType;

typedef enum{
    buttonTagReset = 1,
    buttonTagManager,
    buttonTagForget
    
}buttonTag;

typedef void(^PopBlock)(void);

@interface GestureViewController : BaseViewController

@property (nonatomic,copy) PopBlock popBlock;

/**
 *  控制器来源类型
 */
@property (nonatomic, assign) GestureViewControllerType type;

@end
