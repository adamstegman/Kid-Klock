#import "HCAlarmViewController.h"
#import "HCDictionaryAlarm.h"
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

@interface HCAlarmViewController ()
#pragma mark - Actions
- (void)dismissWaketime:(id)sender;
- (void)pickWaketime:(id)sender;
#pragma mark - Methods
- (void)setTableViewCell:(UITableViewCell *)cell editing:(BOOL)editing;
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

- (HCWaketimeTableViewCell *)waketimeCell {
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
    // FIXME: iPad uses the landscape picker size, but the frame size still reports portrait size (which I want)
    waketimePickerViewController.contentSizeForViewInPopover = self.waketimePicker.frame.size;
    _waketimePopoverController = [[UIPopoverController alloc] initWithContentViewController:waketimePickerViewController];
    _waketimePopoverController.delegate = self;
  }
  return _waketimePopoverController;
}

#pragma mark - Actions

- (IBAction)cancel:(id)sender {
  [self.alarmDelegate alarmViewController:self didFinishWithAlarm:nil];
}

- (IBAction)done:(id)sender {
  [self.alarmDelegate alarmViewController:self didFinishWithAlarm:self.alarm];
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
  // TODO: remove waketime accessory views if not visible
  if (self.waketimePopoverController && !self.waketimePopoverController.popoverVisible) {
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
      cell = [tableView dequeueReusableCellWithIdentifier:@"animalType"];
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
  }
}

#pragma mark - UIDatePicker events

- (void)waketimeDidUpdate:(id)sender {
  self.alarm.waketime = ((UIDatePicker *)sender).date;
  self.waketimeCell.textLabel.text = [self.alarm waketimeAsString];
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
  [self dismissWaketime:popoverController];
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
