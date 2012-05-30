#import <UIKit/UIKit.h>
#import "HCDictionaryAlarm.h"

@class HCAlarmViewController;

@protocol HCAlarmViewControllerDelegate
- (void)alarmViewController:(HCAlarmViewController *)controller didFinishWithAlarm:(id <HCAlarm>)alarm;
@end

@interface HCAlarmViewController : UITableViewController <UITextFieldDelegate> {
  HCDictionaryAlarm *_alarm;
  UITableViewCell *_editingCell;
}

@property (nonatomic, strong) id <HCAlarmViewControllerDelegate> alarmDelegate;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
