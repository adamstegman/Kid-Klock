#import <UIKit/UIKit.h>
#import "HCResponderCell.h"
#import "HCDictionaryAlarm.h"

@class HCAlarmViewController;

@protocol HCAlarmViewControllerDelegate
- (void)alarmViewController:(HCAlarmViewController *)controller didFinishWithAlarm:(id <HCAlarm>)alarm;
@end

@interface HCAlarmViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate, UIPopoverControllerDelegate, UITextFieldDelegate> {
  UIToolbar *_nextAccessoryView;
  UIToolbar *_doneAccessoryView;

  UITableViewCell *_nameCell;
  UITextField *_nameField;
  UILabel *_nameLabel;

  HCResponderCell *_waketimeCell;
  UIDatePicker *_waketimePicker;
  UIPopoverController *_waketimePopoverController;

  HCResponderCell *_animalTypeCell;
  UIPickerView *_animalTypePicker;
  UIPopoverController *_animalTypePopoverController;
}

@property (strong, nonatomic) id <HCAlarm> alarm;
@property (strong, nonatomic) id <HCAlarmViewControllerDelegate> alarmDelegate;

#pragma mark - Internal properties
@property (strong, nonatomic, readonly) UIToolbar *nextAccessoryView;
@property (strong, nonatomic, readonly) UIToolbar *doneAccessoryView;
@property (strong, nonatomic, readonly) UITableViewCell *nameCell;
@property (strong, nonatomic, readonly) UITextField *nameField;
@property (strong, nonatomic, readonly) UILabel *nameLabel;
@property (strong, nonatomic, readonly) HCResponderCell *waketimeCell;
@property (strong, nonatomic, readonly) UIDatePicker *waketimePicker;
@property (strong, nonatomic, readonly) UIPopoverController *waketimePopoverController;
@property (strong, nonatomic, readonly) HCResponderCell *animalTypeCell;
@property (strong, nonatomic, readonly) UIPickerView *animalTypePicker;
@property (strong, nonatomic, readonly) UIPopoverController *animalTypePopoverController;

#pragma mark - Actions
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
