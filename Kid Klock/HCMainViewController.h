#import "HCAlarmsViewController.h"

@interface HCMainViewController : UIViewController <HCAlarmsViewControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *settingsPopoverController;

@end
