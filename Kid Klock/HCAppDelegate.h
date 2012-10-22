#import <UIKit/UIKit.h>
#import "HCAlarmPersistor.h"

@interface HCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// FIXME: not sure if this is necessary
@property (strong, nonatomic) HCAlarmPersistor *alarmPersistor;

@end
