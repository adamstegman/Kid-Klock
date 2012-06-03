#import <UIKit/UIKit.h>
#import "HCDictionaryAlarm.h"

@class HCAlarmViewController;

@protocol HCAlarmViewControllerDelegate
- (void)alarmViewController:(HCAlarmViewController *)controller didFinishWithAlarm:(id <HCAlarm>)alarm;
@end

@interface HCAlarmViewController : UITableViewController <UITextFieldDelegate> {
  UITableViewCell *_editingCell;
}

@property (nonatomic, strong) id <HCAlarm> alarm;
@property (nonatomic, strong) id <HCAlarmViewControllerDelegate> alarmDelegate;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
