#import "HCAlarmViewController.h"
#import "HCDictionaryAlarm.h"
#import "HCStaticAssetAnimal.h"
#import "HCAlarmSettings.h"

// Row for each attribute
#define NAME_ROW 0
#define WAKETIME_ROW 1
#define ANIMAL_ROW 2

// Dimensions
#define ANIMAL_TYPE_PICKER_ROW_HEIGHT 68.0f
#define ANIMAL_TYPE_PICKER_COMPONENT_WIDTH 200.0f

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
#pragma mark - Methods
- (SEL)nextFieldSelector:(NSInteger)row;
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
@dynamic nextAccessoryView;
@dynamic doneAccessoryView;
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

- (UIToolbar *)nextAccessoryView {
  NSInteger row = [self.tableView indexPathForSelectedRow].row;
  if (!_nextAccessoryView) {
    _nextAccessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 32.0f)];
    _nextAccessoryView.barStyle = UIBarStyleBlack;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                            target:nil
                                                                            action:nil];
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"alarm.field.next", @"Go to next alarm field")
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:[self nextFieldSelector:row]];
    _nextAccessoryView.items = [NSArray arrayWithObjects:spacer, nextButton, nil];
  } else {
    // update next button action based on which row is selected
    UIBarButtonItem *nextButton = [[_nextAccessoryView items] objectAtIndex:1U];
    nextButton.action = [self nextFieldSelector:row];
  }
  return _nextAccessoryView;
}

- (UIToolbar *)doneAccessoryView {
  if (!_doneAccessoryView) {
    _doneAccessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.animalTypePicker.frame.size.width, 32.0f)];
    _doneAccessoryView.barStyle = UIBarStyleBlack;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                            target:nil
                                                                            action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(dismissAnimalType:)];
    _doneAccessoryView.items = [NSArray arrayWithObjects:spacer, doneButton, nil];
  }
  return _doneAccessoryView;
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
  NSCalendar *calendar = [NSCalendar currentCalendar];
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
  }
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
      self.animalTypeCell.inputAccessoryView = self.doneAccessoryView;
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
    self.alarm.waketime = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit)
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
      self.waketimeCell.inputAccessoryView = self.nextAccessoryView;
    }
    [self.waketimeCell becomeFirstResponder];
  }
}

- (void)waketimeDidReturn:(id)sender {
  // move to next cell
  [self selectRow:WAKETIME_ROW + 1];
}

#pragma mark - Methods

- (SEL)nextFieldSelector:(NSInteger)row {
  switch (row) {
    case NAME_ROW:
      return @selector(nameDidReturn:);
    case WAKETIME_ROW:
      return @selector(waketimeDidReturn:);
    default:
      return nil;
  }
}

- (void)selectRow:(NSInteger)row {
  NSIndexPath *newRow = [NSIndexPath indexPathForItem:row inSection:0];
  [self.tableView selectRowAtIndexPath:newRow animated:YES scrollPosition:UITableViewScrollPositionTop];
  [self tableView:self.tableView didSelectRowAtIndexPath:newRow];
}

#pragma mark - View lifecycle

- (void)didReceiveMemoryWarning {
  // TODO: test these
  if (_doneAccessoryView && ![self.animalTypeCell isFirstResponder]) {
    _animalTypePicker = nil;
    _doneAccessoryView = nil;
  }
  if (_animalTypePopoverController && !self.animalTypePopoverController.popoverVisible) {
    _animalTypePopoverController = nil;
    _animalTypePicker = nil;
  }

  if (_nextAccessoryView && ![self.waketimeCell isFirstResponder]) {
    _waketimePicker = nil;
    if (![self.nameField isFirstResponder]) {
      _nextAccessoryView = nil;
    }
  }
  if (_waketimePopoverController && !self.waketimePopoverController.popoverVisible) {
    _waketimePopoverController = nil;
    _waketimePicker = nil;
  }
}

- (void)viewWillAppear:(BOOL)animated {
  self.title = self.nameField.text = self.nameLabel.text = self.alarm.name;
  self.waketimeCell.detailTextLabel.text = [self.alarm waketimeAsString];
  self.animalTypeCell.imageView.image = self.alarm.animal.icon;
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
  NSCalendar *calendar = [NSCalendar currentCalendar]; // TODO: may be more efficient to use an instance variable and +autoupdatingCurrentCalendar
  self.alarm.waketime = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit)
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
    // TODO: subclass UIView for this?
    id <HCAnimal> animal = [HCStaticAssetAnimal animalWithType:row];
    CGRect animalTypeRowFrame = CGRectMake(0.0f, 0.0f, ANIMAL_TYPE_PICKER_COMPONENT_WIDTH, ANIMAL_TYPE_PICKER_ROW_HEIGHT);
    UIView *animalTypeRow = [[UIView alloc] initWithFrame:animalTypeRowFrame];
    UIImageView *animalIconView = [[UIImageView alloc] initWithImage:animal.icon];
    animalIconView.translatesAutoresizingMaskIntoConstraints = NO;
    [animalTypeRow addSubview:animalIconView];
    UILabel *animalLabel = [[UILabel alloc] initWithFrame:animalTypeRowFrame];
    animalLabel.text = animal.name;
    [animalLabel sizeToFit];
    animalLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [animalTypeRow addSubview:animalLabel];
    [animalTypeRow addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[animalIconView(48)]-[animalLabel]-10-|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(animalIconView, animalLabel)]];
    [animalTypeRow addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[animalIconView(48)]-10-|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(animalIconView)]];
    [animalTypeRow addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[animalLabel]-|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(animalLabel)]];
    return animalTypeRow;
  }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
  return ANIMAL_TYPE_PICKER_COMPONENT_WIDTH;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
  self.alarm.animalType = row;
  self.animalTypeCell.imageView.image = self.alarm.animal.icon;
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
