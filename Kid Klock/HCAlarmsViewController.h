#import <UIKit/UIKit.h>
#import "HCAlarmViewController.h"

@class HCAlarmsViewController;

@protocol HCAlarmsViewControllerDelegate
- (void)alarmsViewControllerDidFinish:(HCAlarmsViewController *)controller;
- (void)alarmsViewControllerDidUpdate:(HCAlarmsViewController *)controller;
- (void)hideAlarmsViewController:(HCAlarmsViewController *)controller;
- (void)showAlarmsViewController:(HCAlarmsViewController *)controller;
@end

@interface HCAlarmsViewController : UIViewController
    <UITableViewDelegate, UITableViewDataSource, HCAlarmViewControllerDelegate> {
  NSArray *_alarmCellColors;
  NSArray *_conflictingAlarmCellColors;
  id <HCAlarm> _selectedAlarm;
  NSArray *_sortedAlarms;
}

@property (weak, nonatomic) id <HCAlarmsViewControllerDelegate> alarmsDelegate;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UINavigationItem *settingsNavigationItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButtonItem;

- (IBAction)done:(id)sender;

@end
