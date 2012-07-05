#import <UIKit/UIKit.h>
#import "HCResponderCell.h"
#import "HCDictionaryAlarm.h"

@class HCAlarmViewController;

@protocol HCAlarmViewControllerDelegate
- (void)alarmViewController:(HCAlarmViewController *)controller didFinishWithAlarm:(id <HCAlarm>)alarm;
@end

@interface HCAlarmViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate, UIPopoverControllerDelegate, UITextFieldDelegate> {
  HCResponderCell *_waketimeCell;
  UIToolbar *_waketimeAccessoryView;
  UIDatePicker *_waketimePicker;
  UIPopoverController *_waketimePopoverController;

  HCResponderCell *_animalTypeCell;
  UIToolbar *_animalTypeAccessoryView;
  UIPickerView *_animalTypePicker;
  UIPopoverController *_animalTypePopoverController;
}

@property (strong, nonatomic) id <HCAlarm> alarm;
@property (strong, nonatomic) id <HCAlarmViewControllerDelegate> alarmDelegate;

#pragma mark - Internal properties
@property (strong, nonatomic) UITableViewCell *editingCell;
@property (strong, nonatomic, readonly) HCResponderCell *waketimeCell;
@property (strong, nonatomic, readonly) UIToolbar *waketimeAccessoryView;
@property (strong, nonatomic, readonly) UIDatePicker *waketimePicker;
@property (strong, nonatomic, readonly) UIPopoverController *waketimePopoverController;
@property (strong, nonatomic, readonly) HCResponderCell *animalTypeCell;
@property (strong, nonatomic, readonly) UIToolbar *animalTypeAccessoryView;
@property (strong, nonatomic, readonly) UIPickerView *animalTypePicker;
@property (strong, nonatomic, readonly) UIPopoverController *animalTypePopoverController;

#pragma mark - Actions
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
