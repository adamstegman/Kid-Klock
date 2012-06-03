#import <UIKit/UIKit.h>
#import "HCAlarmSettings.h"

@interface HCWaketimeViewController : UIViewController <HCAlarmSettings>

@property (strong, nonatomic) IBOutlet UIDatePicker *timePicker;

@end
