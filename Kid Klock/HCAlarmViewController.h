#import <UIKit/UIKit.h>
#import "HCWaketimeTableViewCell.h"
#import "HCDictionaryAlarm.h"

@class HCAlarmViewController;

@protocol HCAlarmViewControllerDelegate
- (void)alarmViewController:(HCAlarmViewController *)controller didFinishWithAlarm:(id <HCAlarm>)alarm;
@end

@interface HCAlarmViewController : UITableViewController <UITextFieldDelegate, UIPopoverControllerDelegate> {
  HCWaketimeTableViewCell *_waketimeCell;
  UIToolbar *_waketimeAccessoryView;
  UIDatePicker *_waketimePicker;
  UIPopoverController *_waketimePopoverController;
}

@property (strong, nonatomic) id <HCAlarm> alarm;
@property (strong, nonatomic) id <HCAlarmViewControllerDelegate> alarmDelegate;

#pragma mark - Internal properties
@property (strong, nonatomic) UITableViewCell *editingCell;
@property (strong, nonatomic, readonly) HCWaketimeTableViewCell *waketimeCell;
@property (strong, nonatomic, readonly) UIToolbar *waketimeAccessoryView;
@property (strong, nonatomic, readonly) UIDatePicker *waketimePicker;
@property (strong, nonatomic, readonly) UIPopoverController *waketimePopoverController;

#pragma mark - Actions
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
