#import "HCAlarmViewController.h"
#import "HCDictionaryAlarm.h"
#import "HCRepeatViewController.h"

@interface HCAlarmViewController ()
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

#pragma mark - View lifecycle

- (void)viewDidLoad {
  // TODO: edit alarm
  NSDictionary *alarmAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], @"waketime",
                                   NSLocalizedString(@"alarm.name.default", @"Default new alarm name"), @"name",
                                   [NSNumber numberWithInt:HCNoAnimal], @"animalType", nil];
  _alarm = [HCDictionaryAlarm alarmWithAttributes:alarmAttributes];
  self.title = _alarm.name;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  // TODO
  return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"repeat"]) {
    HCRepeatViewController *repeatViewController = (HCRepeatViewController *)[segue destinationViewController];
    repeatViewController.alarm = _alarm;
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
    case 0:
      cell = [tableView dequeueReusableCellWithIdentifier:@"name"];
      cell.textLabel.text = _alarm.name;
      break;
    case 1:
      cell = [tableView dequeueReusableCellWithIdentifier:@"waketime"];
      cell.textLabel.text = [_alarm waketimeAsString];
      break;
    case 2:
      // TODO: add icon
      cell = [tableView dequeueReusableCellWithIdentifier:@"animalType"];
      cell.textLabel.text = _alarm.animal.name;
      break;
    case 3:
      // TODO: set text to repeatAsString when appropriate
      cell = [tableView dequeueReusableCellWithIdentifier:@"repeat"];
      break;
  }
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  // TODO
}

@end
