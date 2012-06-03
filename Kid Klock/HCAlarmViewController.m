#import "HCAlarmViewController.h"
#import "HCDictionaryAlarm.h"
#import "HCAlarmSettings.h"

#define HCALARM_TEXT_LABEL_TAG 1
#define HCALARM_TEXT_VIEW_TAG 2

@interface HCAlarmViewController ()
- (void)setTableViewCell:(UITableViewCell *)cell editing:(BOOL)editing;
@end

@implementation HCAlarmViewController

@synthesize alarmDelegate = _alarmDelegate;

#pragma mark - Actions

- (IBAction)cancel:(id)sender {
  [self.alarmDelegate alarmViewController:self didFinishWithAlarm:nil];
}

- (IBAction)done:(id)sender {
  [self.alarmDelegate alarmViewController:self didFinishWithAlarm:_alarm];
}

#pragma mark - Methods

- (void)setTableViewCell:(UITableViewCell *)cell editing:(BOOL)editing {
  if (editing && cell != _editingCell) {
    if (_editingCell) {
      [self setTableViewCell:_editingCell editing:NO];
    }
    _editingCell = cell;
    if ([cell.reuseIdentifier isEqualToString:@"name"]) {
      UILabel *textLabel = (UILabel *)[cell viewWithTag:HCALARM_TEXT_LABEL_TAG];
      UITextField *textField = (UITextField *)[cell viewWithTag:HCALARM_TEXT_VIEW_TAG];
      textField.hidden = NO;
      textLabel.hidden = YES;
      [textField becomeFirstResponder];
    }
  } else if (!editing && cell == _editingCell) {
    _editingCell = nil;
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

- (void)viewDidLoad {
  // TODO: edit alarm
  NSDictionary *alarmAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], @"waketime",
                                   NSLocalizedString(@"alarm.name.default", @"Default new alarm name"), @"name",
                                   [NSNumber numberWithInt:HCNoAnimal], @"animalType", nil];
  _alarm = [HCDictionaryAlarm alarmWithAttributes:alarmAttributes];
  self.title = _alarm.name;
}

- (void)viewWillAppear:(BOOL)animated {
  _editingCell = nil;
  [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  // TODO
  return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"repeat"] || [segue.identifier isEqualToString:@"waketime"]) {
    id <HCAlarmSettings> alarmSettingsViewController = (id <HCAlarmSettings>)[segue destinationViewController];
    alarmSettingsViewController.alarm = _alarm;
  }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 4; // number of fields to set on the new alarm
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = nil;
  switch (indexPath.row) {
    case 0: {
      cell = [tableView dequeueReusableCellWithIdentifier:@"name"];
      [[cell.contentView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
        [obj setText:_alarm.name];
      }];
      break;
    }
    case 1: {
      cell = [tableView dequeueReusableCellWithIdentifier:@"waketime"];
      cell.textLabel.text = [_alarm waketimeAsString];
      break;
    }
    case 2: {
      // TODO: add icon
      cell = [tableView dequeueReusableCellWithIdentifier:@"animalType"];
      cell.textLabel.text = _alarm.animal.name;
      break;
    }
    case 3: {
      // TODO: set text to repeatAsString when appropriate
      cell = [tableView dequeueReusableCellWithIdentifier:@"repeat"];
      break;
    }
  }
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  [self setTableViewCell:[tableView cellForRowAtIndexPath:indexPath] editing:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  UILabel *textLabel = (UILabel *)[[textField superview] viewWithTag:HCALARM_TEXT_LABEL_TAG];
  _alarm.name = textLabel.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
  return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self setTableViewCell:_editingCell editing:NO];
  // TODO: move to next cell
  return NO;
}

@end
