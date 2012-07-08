#import "HCAlarmsViewController.h"

@interface HCMainViewController : UIViewController <HCAlarmsViewControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *settingsPopoverController;
@property (strong, nonatomic) IBOutlet UIImageView *alarmImage;

/**
 * Displays the correct alarm image.
 *
 * If the current time is not within the previous alarm's maximum awake image interval, the current alarm's sleep image
 * will be displayed.
 *
 * If the current time is within the previous alarm's maximum awake image interval, the previous alarm's awake image
 * will be displayed; unless the minimum sleep image interval of the current alarm includes the current time, in which
 * case the current alarm's sleep image will be displayed.
 */
- (void)updateAlarm;

@end
