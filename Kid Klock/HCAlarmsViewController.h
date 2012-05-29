#import <UIKit/UIKit.h>
#import "HCAlarmViewController.h"

@class HCAlarmsViewController;

@protocol HCAlarmsViewControllerDelegate
- (void)alarmsViewControllerDidFinish:(HCAlarmsViewController *)controller;
@end

@interface HCAlarmsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, HCAlarmViewControllerDelegate>

@property (weak, nonatomic) id <HCAlarmsViewControllerDelegate> alarmsDelegate;
@property (strong, nonatomic) UITableView *tableView;

- (IBAction)done:(id)sender;

@end
