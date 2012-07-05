#import "HCAlarmViewController.h"
#import "HCDictionaryAlarm.h"
#import "HCStaticAssetAnimal.h"
#import "HCAlarmSettings.h"

// Row for each attribute
#define ATTRIBUTE_ROWS 4
#define NAME_ROW 0
#define WAKETIME_ROW 1
#define ANIMAL_ROW 2
#define REPEAT_ROW 3

// IB view tags
#define HCALARM_TEXT_LABEL_TAG 1
#define HCALARM_TEXT_VIEW_TAG 2

// Dimensions
#define ANIMAL_TYPE_PICKER_ROW_HEIGHT 68.0f
#define ANIMAL_TYPE_PICKER_COMPONENT_WIDTH 200.0f

@interface HCAlarmViewController ()
#pragma mark - Actions
- (void)dismissAnimalType:(id)sender;
- (void)pickAnimalType:(id)sender;
- (void)dismissWaketime:(id)sender;
- (void)pickWaketime:(id)sender;
#pragma mark - Methods
- (void)setTableViewCell:(UITableViewCell *)cell editing:(BOOL)editing;
- (void)rotateAnimalTypePicker;
- (void)rotateWaketimePicker;
@end

@implementation HCAlarmViewController

#pragma mark - Properties

@synthesize alarm = _alarm;
@synthesize alarmDelegate = _alarmDelegate;
@synthesize editingCell = _editingCell;
@dynamic waketimeCell;
@dynamic waketimeAccessoryView;
@dynamic waketimePicker;
@dynamic waketimePopoverController;
@dynamic animalTypeCell;
@dynamic animalTypeAccessoryView;
@dynamic animalTypePicker;
@dynamic animalTypePopoverController;

- (HCResponderCell *)waketimeCell {
  if (!_waketimeCell) {
    _waketimeCell = [self.tableView dequeueReusableCellWithIdentifier:@"waketime"];
  }
  return _waketimeCell;
}

- (UIToolbar *)waketimeAccessoryView {
  if (!_waketimeAccessoryView) {
    _waketimeAccessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.waketimePicker.frame.size.width, 32.0f)];
    _waketimeAccessoryView.barStyle = UIBarStyleBlack;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissWaketime:)];
    _waketimeAccessoryView.items = [NSArray arrayWithObjects:spacer, doneButton, nil];
  }
  return _waketimeAccessoryView;
}

- (UIDatePicker *)waketimePicker {
  if (!_waketimePicker) {
    _waketimePicker = [[UIDatePicker alloc] init];
    _waketimePicker.datePickerMode = UIDatePickerModeTime;
    _waketimePicker.minuteInterval = [self.alarm minuteInterval];
    // date pickers do not have delegates, so force its hand
    [_waketimePicker addTarget:self action:@selector(waketimeDidUpdate:) forControlEvents:UIControlEventValueChanged];
  }
  [self rotateWaketimePicker];
  return _waketimePicker;
}

- (UIPopoverController *)waketimePopoverController {
  if (!_waketimePopoverController) {
    UIViewController *waketimePickerViewController = [[UIViewController alloc] init];
    waketimePickerViewController.view = self.waketimePicker;
    // FIXME: iPad uses the landscape picker size, but the frame size still reports portrait size (which I want) - see warnings in console
    waketimePickerViewController.contentSizeForViewInPopover = self.waketimePicker.frame.size;
    _waketimePopoverController = [[UIPopoverController alloc] initWithContentViewController:waketimePickerViewController];
    _waketimePopoverController.delegate = self;
  }
  return _waketimePopoverController;
}

- (HCResponderCell *)animalTypeCell {
  if (!_animalTypeCell) {
    _animalTypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"animalType"];
  }
  return _animalTypeCell;
}

- (UIToolbar *)animalTypeAccessoryView {
  if (!_animalTypeAccessoryView) {
    _animalTypeAccessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.animalTypePicker.frame.size.width, 32.0f)];
    _animalTypeAccessoryView.barStyle = UIBarStyleBlack;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissAnimalType:)];
    _animalTypeAccessoryView.items = [NSArray arrayWithObjects:spacer, doneButton, nil];
  }
  return _animalTypeAccessoryView;
}

- (UIPickerView *)animalTypePicker {
  if (!_animalTypePicker) {
    _animalTypePicker = [[UIPickerView alloc] init];
    _animalTypePicker.dataSource = self;
    _animalTypePicker.delegate = self;
  }
  [self rotateAnimalTypePicker];
  return _animalTypePicker;
}

- (UIPopoverController *)animalTypePopoverController {
  if (!_animalTypePopoverController) {
    UIViewController *animalTypePickerViewController = [[UIViewController alloc] init];
    animalTypePickerViewController.view = self.animalTypePicker;
    // FIXME: iPad uses the landscape picker size, but the frame size still reports portrait size (which I want) - see warnings in console
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

- (void)dismissAnimalType:(id)sender {
  [self.animalTypeCell resignFirstResponder];
  [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)pickAnimalType:(id)sender {
  if (!self.alarm.animal) {
    self.alarm.animalType = HCNoAnimal;
  }

  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    [self.animalTypePopoverController presentPopoverFromRect:self.animalTypeCell.frame
                                                      inView:self.tableView
                                    permittedArrowDirections:UIPopoverArrowDirectionAny
                                                    animated:YES];
  } else {
    if (!self.animalTypeCell.inputView) {
      self.animalTypeCell.inputView = self.animalTypePicker;
    }
    if (!self.animalTypeCell.inputAccessoryView) {
      self.animalTypeCell.inputAccessoryView = self.animalTypeAccessoryView;
    }
    [self.animalTypeCell becomeFirstResponder];
  }
}

- (void)dismissWaketime:(id)sender {
  [self.waketimeCell resignFirstResponder];
  [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)pickWaketime:(id)sender {
  if (!self.alarm.waketime) {
    self.alarm.waketime = [NSDate dateWithTimeIntervalSinceNow:0];
  }

  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    [self.waketimePopoverController presentPopoverFromRect:self.waketimeCell.frame
                                                    inView:self.tableView
                                  permittedArrowDirections:UIPopoverArrowDirectionAny
                                                  animated:YES];
  } else {
    if (!self.waketimeCell.inputView) {
      self.waketimeCell.inputView = self.waketimePicker;
    }
    if (!self.waketimeCell.inputAccessoryView) {
      self.waketimeCell.inputAccessoryView = self.waketimeAccessoryView;
    }
    [self.waketimeCell becomeFirstResponder];
  }
}

#pragma mark - Methods

- (void)rotateAnimalTypePicker {
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    // TODO: adjust inputView frame to orientation if necessary
  }
}

- (void)rotateWaketimePicker {
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    // TODO: adjust inputView frame to orientation if necessary
  }
}

- (void)setTableViewCell:(UITableViewCell *)cell editing:(BOOL)editing {
  // TODO: move to an alarm name cell class
  if (editing && cell != self.editingCell) {
    if (self.editingCell) {
      [self setTableViewCell:self.editingCell editing:NO];
    }
    self.editingCell = cell;
    if ([cell.reuseIdentifier isEqualToString:@"name"]) {
      UILabel *textLabel = (UILabel *)[cell viewWithTag:HCALARM_TEXT_LABEL_TAG];
      UITextField *textField = (UITextField *)[cell viewWithTag:HCALARM_TEXT_VIEW_TAG];
      textField.hidden = NO;
      textLabel.hidden = YES;
      [textField becomeFirstResponder];
    }
  } else if (!editing && cell == self.editingCell) {
    self.editingCell = nil;
    if ([cell.reuseIdentifier isEqualToString:@"name"]) {
      UILabel *textLabel = (UILabel *)[cell viewWithTag:HCALARM_TEXT_LABEL_TAG];
      UITextField *textField = (UITextField *)[cell viewWithTag:HCALARM_TEXT_VIEW_TAG];
      [textField resignFirstResponder];
      textLabel.hidden = NO;
      textField.hidden = YES;
    }
  }
}

#pragma mark - View lifecycle

- (void)didReceiveMemoryWarning {
  // TODO: test these
  if (!self.tableView.editing) {
    self.editingCell = nil;
  }

  if (_animalTypeAccessoryView && ![self.animalTypeCell isFirstResponder]) {
    _animalTypeAccessoryView = nil;
    _animalTypePicker = nil;
  }
  if (_animalTypePopoverController && !self.animalTypePopoverController.popoverVisible) {
    _animalTypePopoverController = nil;
    _animalTypePicker = nil;
  }

  if (_waketimeAccessoryView && ![self.waketimeCell isFirstResponder]) {
    _waketimeAccessoryView = nil;
    _waketimePicker = nil;
  }
  if (_waketimePopoverController && !self.waketimePopoverController.popoverVisible) {
    _waketimePopoverController = nil;
    _waketimePicker = nil;
  }
}

- (void)viewWillAppear:(BOOL)animated {
  self.title = self.alarm.name;
  self.editingCell = nil;
  [self.tableView reloadData];
  [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
  // rotate stored views
  [self rotateAnimalTypePicker];
  [self rotateWaketimePicker];
  [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"repeat"]) {
    id <HCAlarmSettings> alarmSettingsViewController = (id <HCAlarmSettings>)[segue destinationViewController];
    alarmSettingsViewController.alarm = self.alarm;
  }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return ATTRIBUTE_ROWS; // number of fields to set on the new alarm
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = nil;
  switch (indexPath.row) {
    case NAME_ROW: {
      cell = [tableView dequeueReusableCellWithIdentifier:@"name"];
      [[cell.contentView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
        [obj setText:self.alarm.name];
      }];
      break;
    }
    case WAKETIME_ROW: {
      cell = self.waketimeCell;
      cell.textLabel.text = [self.alarm waketimeAsString];
      break;
    }
    case ANIMAL_ROW: {
      // TODO: add icon
      cell = self.animalTypeCell;
      cell.textLabel.text = self.alarm.animal.name;
      break;
    }
    case REPEAT_ROW: {
      // TODO: set text to repeatAsString when appropriate
      cell = [tableView dequeueReusableCellWithIdentifier:@"repeat"];
      break;
    }
  }
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  switch (indexPath.row) {
    case NAME_ROW: {
      [tableView deselectRowAtIndexPath:indexPath animated:YES];
      [self setTableViewCell:[tableView cellForRowAtIndexPath:indexPath] editing:YES];
      break;
    }
    case WAKETIME_ROW: {
      [self pickWaketime:[tableView cellForRowAtIndexPath:indexPath]];
      break;
    }
    case ANIMAL_ROW: {
      [self pickAnimalType:[tableView cellForRowAtIndexPath:indexPath]];
      break;
    }
  }
}

#pragma mark - UIDatePicker events

- (void)waketimeDidUpdate:(id)sender {
  self.alarm.waketime = ((UIDatePicker *)sender).date;
  self.waketimeCell.textLabel.text = [self.alarm waketimeAsString];
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
  self.animalTypeCell.textLabel.text = self.alarm.animal.name;
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
  UILabel *textLabel = (UILabel *)[[textField superview] viewWithTag:HCALARM_TEXT_LABEL_TAG];
  self.alarm.name = textLabel.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
  return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self setTableViewCell:_editingCell editing:NO];
  // TODO: move to next cell
  return NO;
}

@end
