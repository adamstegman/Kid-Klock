#import "HCAlarmViewController.h"
#import "HCDictionaryAlarm.h"
#import "HCStaticAssetAnimal.h"
#import "HCAlarmSettings.h"
#import "HCCalendarUtil.h"

// Row for each attribute
#define NAME_ROW 0
#define WAKETIME_ROW 1
#define ANIMAL_ROW 2
#define FIRST_INPUT_ROW 0
#define LAST_INPUT_ROW 2

// Dimensions
#define ANIMAL_TYPE_PICKER_ROW_HEIGHT 44.0f
#define ANIMAL_TYPE_PICKER_COMPONENT_WIDTH 200.0f
#define ANIMAL_TYPE_PICKER_X_MARGIN 10.0f
#define ANIMAL_TYPE_PICKER_Y_MARGIN 5.0f

@interface HCAlarmViewController ()
#pragma mark - Actions
- (void)dimmerDidUpdate:(id)sender;
- (void)dismissAnimalType:(id)sender;
- (void)pickAnimalType:(id)sender;
- (void)dismissName:(id)sender;
- (void)editName:(id)sender;
- (void)nameDidReturn:(id)sender;
- (void)dismissWaketime:(id)sender;
- (void)pickWaketime:(id)sender;
- (void)waketimeDidReturn:(id)sender;
- (void)dismissInput:(id)sender;
- (void)focusNextRow:(id)sender;
- (void)focusPreviousRow:(id)sender;
#pragma mark - Methods
- (void)selectRow:(NSInteger)row;
@end

// allow dismissal of the keyboard from this modal view
@implementation UINavigationController(KeyboardDismiss)
- (BOOL)disablesAutomaticKeyboardDismissal {
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    // allow the iPad to dismiss the keyboard so that the popovers are easier to use.
    return NO;
  } else {
    return YES;
  }
}
@end

@implementation HCAlarmViewController

#pragma mark - Properties

@synthesize alarm = _alarm;
@synthesize alarmDelegate = _alarmDelegate;
@dynamic accessoryView;
@synthesize nameField = _nameField;
@synthesize nameLabel = _nameLabel;
@synthesize waketimeCell = _waketimeCell;
@dynamic waketimePicker;
@dynamic waketimePopoverController;
@synthesize animalTypeCell = _animalTypeCell;
@dynamic animalTypePicker;
@dynamic animalTypePopoverController;
@synthesize repeatCell = _repeatCell;
@synthesize dimmerSwitch = _dimmerSwitch;

- (UIToolbar *)accessoryView {
  if (!_accessoryView) {
    _accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 32.0f)];
    _accessoryView.barStyle = UIBarStyleBlack;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                            target:nil
                                                                            action:nil];
    UIBarButtonItem *previousButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"alarm.field.previous", @"Go to previous alarm field")
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(focusPreviousRow:)];
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"alarm.field.next", @"Go to next alarm field")
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(focusNextRow:)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(dismissInput:)];
    _accessoryView.items = [NSArray arrayWithObjects:previousButton, nextButton, spacer, doneButton, nil];
  }

  NSInteger currentRow = [self.tableView indexPathForSelectedRow].row;
  UIBarButtonItem *previousButton = [_accessoryView.items objectAtIndex:0U];
  if (currentRow == FIRST_INPUT_ROW) {
    previousButton.enabled = NO;
  } else {
    previousButton.enabled = YES;
  }
  UIBarButtonItem *nextButton = [_accessoryView.items objectAtIndex:1U];
  if (currentRow == LAST_INPUT_ROW) {
    nextButton.enabled = NO;
  } else {
    nextButton.enabled = YES;
  }

  return _accessoryView;
}

- (UIDatePicker *)waketimePicker {
  if (!_waketimePicker) {
    _waketimePicker = [[UIDatePicker alloc] init];
    _waketimePicker.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _waketimePicker.datePickerMode = UIDatePickerModeTime;
    _waketimePicker.minuteInterval = [self.alarm minuteInterval];

    // date pickers do not have delegates, so force its hand
    [_waketimePicker addTarget:self action:@selector(waketimeDidUpdate:) forControlEvents:UIControlEventValueChanged];
  }
  NSCalendar *calendar = [HCCalendarUtil currentCalendar];
  NSDateComponents *nowComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                                fromDate:[NSDate date]];
  [nowComponents setHour:[self.alarm.waketime hour]];
  [nowComponents setMinute:[self.alarm.waketime minute]];
  [nowComponents setSecond:[self.alarm.waketime second]];
  _waketimePicker.date = [calendar dateFromComponents:nowComponents];
  return _waketimePicker;
}

- (UIPopoverController *)waketimePopoverController {
  if (!_waketimePopoverController) {
    UIViewController *waketimePickerViewController = [[UIViewController alloc] init];
    self.waketimePicker.autoresizingMask = UIViewAutoresizingNone;
    UIView *waketimePickerView = [[UIView alloc] initWithFrame:self.waketimePicker.frame];
    [waketimePickerView addSubview:self.waketimePicker];
    waketimePickerViewController.view = waketimePickerView;
    waketimePickerViewController.contentSizeForViewInPopover = self.waketimePicker.frame.size;
    _waketimePopoverController = [[UIPopoverController alloc] initWithContentViewController:waketimePickerViewController];
    _waketimePopoverController.delegate = self;
  }
  return _waketimePopoverController;
}

- (UIPickerView *)animalTypePicker {
  if (!_animalTypePicker) {
    _animalTypePicker = [[UIPickerView alloc] init];
    _animalTypePicker.dataSource = self;
    _animalTypePicker.delegate = self;
    _animalTypePicker.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _animalTypePicker.showsSelectionIndicator = YES;
  }
  [_animalTypePicker selectRow:self.alarm.animalType inComponent:0 animated:NO];
  return _animalTypePicker;
}

- (UIPopoverController *)animalTypePopoverController {
  if (!_animalTypePopoverController) {
    UIViewController *animalTypePickerViewController = [[UIViewController alloc] init];
    self.animalTypePicker.autoresizingMask = UIViewAutoresizingNone;
    UIView *animalTypePickerView = [[UIView alloc] initWithFrame:self.animalTypePicker.frame];
    [animalTypePickerView addSubview:self.animalTypePicker];
    animalTypePickerViewController.view = animalTypePickerView;
    animalTypePickerViewController.contentSizeForViewInPopover = self.animalTypePicker.frame.size;
    _animalTypePopoverController = [[UIPopoverController alloc] initWithContentViewController:animalTypePickerViewController];
    _animalTypePopoverController.delegate = self;
  }
  return _animalTypePopoverController;
}

#pragma mark - Actions

- (IBAction)cancel:(id)sender {
  [self.alarmDelegate alarmViewController:self didFinishWithAlarm:nil];
}

- (IBAction)done:(id)sender {
  [self.alarmDelegate alarmViewController:self didFinishWithAlarm:self.alarm];
}

- (void)dimmerDidUpdate:(id)sender {
  self.alarm.shouldDimDisplay = ((UISwitch *)sender).on;
}

- (void)dismissAnimalType:(id)sender {
  [self.animalTypeCell resignFirstResponder];
  [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForCell:self.animalTypeCell] animated:YES];
}

- (void)pickAnimalType:(id)sender {
  if (!self.alarm.animal) {
    self.alarm.animalType = HCNoAnimal;
  }

  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UIKeyboardDidHideNotification"
                                                  object:nil];
    [self.animalTypePopoverController presentPopoverFromRect:self.animalTypeCell.frame
                                                      inView:self.tableView
                                    permittedArrowDirections:UIPopoverArrowDirectionAny
                                                    animated:YES];
  } else {
    if (!self.animalTypeCell.inputView) {
      self.animalTypeCell.inputView = self.animalTypePicker;
    }
    if (!self.animalTypeCell.inputAccessoryView) {
      self.animalTypeCell.inputAccessoryView = self.accessoryView;
    }
    [self.animalTypeCell becomeFirstResponder];
  }
}

- (void)dismissName:(id)sender {
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:@"UIKeyboardWillHideNotification"
                                                object:nil];
  [self.nameField resignFirstResponder];
  self.nameLabel.hidden = NO;
  self.nameField.hidden = YES;
}

- (void)editName:(id)sender {
  self.nameField.hidden = NO;
  self.nameLabel.hidden = YES;

  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    self.nameField.inputAccessoryView = self.accessoryView;
  }

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(dismissName:)
                                               name:@"UIKeyboardWillHideNotification"
                                             object:nil];
  [self.nameField becomeFirstResponder];
}

- (void)nameDidReturn:(id)sender {
  // move to next cell
  [self selectRow:NAME_ROW + 1];
}

- (void)dismissWaketime:(id)sender {
  [self.waketimeCell resignFirstResponder];
  [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForCell:self.waketimeCell] animated:YES];
}

- (void)pickWaketime:(id)sender {
  if (!self.alarm.waketime) {
    self.alarm.waketime = [[HCCalendarUtil currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit)
                                                              fromDate:[NSDate date]];
  }

  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UIKeyboardDidHideNotification"
                                                  object:nil];
    [self.waketimePopoverController presentPopoverFromRect:self.waketimeCell.frame
                                                    inView:self.tableView
                                  permittedArrowDirections:UIPopoverArrowDirectionAny
                                                  animated:YES];
  } else {
    if (!self.waketimeCell.inputView) {
      self.waketimeCell.inputView = self.waketimePicker;
    }
    if (!self.waketimeCell.inputAccessoryView) {
      self.waketimeCell.inputAccessoryView = self.accessoryView;
    }
    [self.waketimeCell becomeFirstResponder];
  }
}

- (void)waketimeDidReturn:(id)sender {
  // move to next cell
  [self selectRow:WAKETIME_ROW + 1];
}

- (void)dismissInput:(id)sender {
  NSInteger currentRow = [self.tableView indexPathForSelectedRow].row;
  switch (currentRow) {
    case NAME_ROW: {
      [self dismissName:sender];
      break;
    }
    case WAKETIME_ROW: {
      [self dismissWaketime:sender];
      break;
    }
    case ANIMAL_ROW: {
      [self dismissAnimalType:sender];
      break;
    }
  }
}

- (void)focusNextRow:(id)sender {
  NSInteger currentRow = [self.tableView indexPathForSelectedRow].row;
  if (currentRow < LAST_INPUT_ROW) {
    [self selectRow:currentRow + 1];
  }
}

- (void)focusPreviousRow:(id)sender {
  NSInteger currentRow = [self.tableView indexPathForSelectedRow].row;
  if (currentRow > FIRST_INPUT_ROW) {
    [self selectRow:currentRow - 1];
  }
}

#pragma mark - Methods

- (void)selectRow:(NSInteger)row {
  NSIndexPath *newRow = [NSIndexPath indexPathForItem:row inSection:0];
  [self.tableView selectRowAtIndexPath:newRow animated:YES scrollPosition:UITableViewScrollPositionTop];
  [self tableView:self.tableView didSelectRowAtIndexPath:newRow];
}

#pragma mark - View lifecycle

- (void)didReceiveMemoryWarning {
  if (_accessoryView) {
    if (![self.waketimeCell isFirstResponder]) {
      _waketimePicker = nil;
    }
    if (![self.animalTypeCell isFirstResponder]) {
      _animalTypePicker = nil;
    }
    if (![self.nameField isFirstResponder] && ![self.waketimeCell isFirstResponder] &&
        ![self.animalTypeCell isFirstResponder]) {
      _accessoryView = nil;
    }
  }
  if (_animalTypePopoverController && !self.animalTypePopoverController.popoverVisible) {
    _animalTypePopoverController = nil;
    _animalTypePicker = nil;
  }
  if (_waketimePopoverController && !self.waketimePopoverController.popoverVisible) {
    _waketimePopoverController = nil;
    _waketimePicker = nil;
  }
}

- (void)viewWillAppear:(BOOL)animated {
  self.title = self.nameField.text = self.nameLabel.text = self.alarm.name;
  self.waketimeCell.detailTextLabel.text = [self.alarm waketimeAsString];
  self.animalTypeCell.detailTextLabel.text = self.alarm.animal.name;
  self.repeatCell.detailTextLabel.text = [self.alarm repeatAsString];
  self.dimmerSwitch.on = self.alarm.shouldDimDisplay;
  [self.dimmerSwitch addTarget:self action:@selector(dimmerDidUpdate:) forControlEvents:UIControlEventValueChanged];
  [self.tableView reloadData];
  [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    // dismiss popovers; reshow them afterward
    if (_waketimePopoverController && [self.waketimePopoverController isPopoverVisible]) {
      [self.waketimePopoverController dismissPopoverAnimated:YES];
    }
    if (_animalTypePopoverController && [self.animalTypePopoverController isPopoverVisible]) {
      [self.animalTypePopoverController dismissPopoverAnimated:YES];
    }
  }
  [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
  if (selectedCell == self.waketimeCell) {
    [self pickWaketime:nil];
  } else if (selectedCell == self.animalTypeCell) {
    [self pickAnimalType:nil];
  }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  [self.tableView endEditing:YES];
  if ([segue.identifier isEqualToString:@"repeat"]) {
    id <HCAlarmSettings> alarmSettingsViewController = (id <HCAlarmSettings>)[segue destinationViewController];
    alarmSettingsViewController.alarm = self.alarm;
  }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
  if (indexPath.row == NAME_ROW) {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self editName:selectedCell];
  } else {
    // If the name field is currently being edited, the keyboard must be dismissed before moving to another cell
    BOOL dismissingKeyboard = NO;
    if ([self.nameField isFirstResponder]) {
      dismissingKeyboard = YES;
      [self dismissName:selectedCell];
    }

    // The next cell should not be selected until the keyboard is done being dismissed
    switch (indexPath.row) {
      case WAKETIME_ROW: {
        if (dismissingKeyboard && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
          [[NSNotificationCenter defaultCenter] addObserver:self
                                                   selector:@selector(pickWaketime:)
                                                       name:@"UIKeyboardDidHideNotification"
                                                     object:nil];
        } else {
          [self pickWaketime:selectedCell];
        }
        break;
      }
      case ANIMAL_ROW: {
        if (dismissingKeyboard && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
          [[NSNotificationCenter defaultCenter] addObserver:self
                                                   selector:@selector(pickAnimalType:)
                                                       name:@"UIKeyboardDidHideNotification"
                                                     object:nil];
        } else {
          [self pickAnimalType:selectedCell];
        }
        break;
      }
    }
  }
}

#pragma mark - UIDatePicker events

- (void)waketimeDidUpdate:(id)sender {
  self.alarm.waketime = [[HCCalendarUtil currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit)
                                                            fromDate:((UIDatePicker *)sender).date];
  self.waketimeCell.detailTextLabel.text = [self.alarm waketimeAsString];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
  return HC_ANIMAL_TYPE_COUNT;
}

#pragma mark - UIPickerViewDelegate

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
  return ANIMAL_TYPE_PICKER_ROW_HEIGHT;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
  if (view) {
    return view;
  } else {
    id <HCAnimal> animal = [HCStaticAssetAnimal animalWithType:row];
    CGRect animalTypeRowFrame = CGRectMake(0.0f, 0.0f, ANIMAL_TYPE_PICKER_COMPONENT_WIDTH, ANIMAL_TYPE_PICKER_ROW_HEIGHT);
    CGRect animalTypeLabelFrame = CGRectMake(ANIMAL_TYPE_PICKER_X_MARGIN, ANIMAL_TYPE_PICKER_Y_MARGIN,
                                             ANIMAL_TYPE_PICKER_COMPONENT_WIDTH - ANIMAL_TYPE_PICKER_X_MARGIN,
                                             ANIMAL_TYPE_PICKER_ROW_HEIGHT - ANIMAL_TYPE_PICKER_Y_MARGIN);
    UIView *animalRowView = [[UIView alloc] initWithFrame:animalTypeRowFrame];
    UILabel *animalLabel = [[UILabel alloc] initWithFrame:animalTypeLabelFrame];
    animalLabel.backgroundColor = [UIColor clearColor];
    animalLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    animalLabel.text = animal.name;
    [animalLabel sizeToFit];
    [animalRowView addSubview:animalLabel];
    return animalLabel;
  }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
  return ANIMAL_TYPE_PICKER_COMPONENT_WIDTH;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
  self.alarm.animalType = row;
  self.animalTypeCell.detailTextLabel.text = self.alarm.animal.name;
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
  if (popoverController == _waketimePopoverController) {
    [self dismissWaketime:popoverController];
  } else if (popoverController == _animalTypePopoverController) {
    [self dismissAnimalType:popoverController];
  }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  self.alarm.name = self.nameLabel.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
  return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
  [self dismissName:textField];
  return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self nameDidReturn:textField];
  return YES;
}

@end
