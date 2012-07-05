#import "HCAlarmsViewController.h"

@interface HCMainViewController : UIViewController <HCAlarmsViewControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic, readonly) id <HCAlarm> currentAlarm;
@property (strong, nonatomic) UIPopoverController *settingsPopoverController;
@property (strong, nonatomic) IBOutlet UIImageView *alarmImage;

- (void)wakeAlarm;

@end
