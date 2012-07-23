#import "HCAlarmsViewController.h"

@interface HCMainViewController : UIViewController <HCAlarmsViewControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *settingsPopoverController;
@property (strong, nonatomic) IBOutlet UIImageView *alarmImage;
@property (strong, nonatomic) IBOutlet UIButton *settingsButton;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

/**
 * Restore the saved brightness of the screen to the specified percentage of the original setting when the app was
 * opened.
 *
 * If percentage is 1.0, the saved setting will be removed after restoring it.
 *
 * Does nothing if no brightness setting is saved.
 *
 * \param the percentage of the saved brightness setting to restore, between 0.0 and 1.0.
 */
- (void)restoreBrightness:(double)percentage;

/**
 * Displays the correct alarm image.
 *
 * If the current time is not within the previous alarm's maximum awake image interval, the current alarm's sleep image
 * will be displayed.
 *
 * If the current time is within the previous alarm's maximum awake image interval, the previous alarm's awake image
 * will be displayed; unless the minimum sleep image interval of the current alarm includes the current time, in which
 * case the current alarm's sleep image will be displayed.
 *
 * \param schedule if true, schedule a recurring notification to update the display. Should only be set to YES once.
 */
- (void)updateAlarm:(BOOL)schedule;

@end
