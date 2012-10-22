#import "HCAlarmsViewController.h"
#import "HCAlarm.h"
#import "HCDictionaryAlarm.h"
#import "HCAlarmTableViewCell.h"
#import "HCCalendarUtil.h"

@interface HCAlarmsViewController ()
#pragma mark - Actions
- (void)toggleAlarm:(id)sender;
#pragma mark - Methods
- (NSArray *)alarmCellColors;
- (id <HCAlarm>)alarmForIndex:(NSUInteger)index;
- (NSArray *)alarms;
- (NSArray *)conflictingAlarmCellColors;
- (void)markCell:(HCAlarmTableViewCell *)cell ifAlarm:(id <HCAlarm>)alarm isTooCloseTo:(id <HCAlarm>)otherAlarm;
- (id <HCAlarm>)newAlarm;
@end

@implementation HCAlarmsViewController

#pragma mark - Properties

@synthesize alarmsDelegate = _alarmsDelegate;
@synthesize tableView = _tableView;
@synthesize settingsNavigationItem = _settingsNavigationItem;
@synthesize doneButtonItem = _doneButtonItem;

#pragma mark - Actions

- (void)toggleAlarm:(id)sender {
  UITableViewCell *alarmCell = (UITableViewCell *)[[sender superview] superview];
  id <HCAlarm> alarm = [self alarmForIndex:[self.tableView indexPathForCell:alarmCell].row];
  alarm.enabled = !alarm.enabled;
  [self.alarmPersistor upsertAlarm:alarm];
  [self.alarmsDelegate alarmsViewControllerDidUpdate:self];
}

#pragma mark - Methods

- (NSArray *)alarmCellColors {
  if (!_alarmCellColors) {
    // #fff, #fff, #cecece
    _alarmCellColors = [NSArray arrayWithObjects:[UIColor whiteColor], [UIColor whiteColor],
                        [UIColor colorWithRed:0.805f green:0.805f blue:0.805f alpha:1.0f], nil];
  }
  return _alarmCellColors;
}

- (id <HCAlarm>)alarmForIndex:(NSUInteger)index {
  return [[self alarms] objectAtIndex:index];
}

- (NSArray *)alarms {
  NSCalendar *calendar = [HCCalendarUtil currentCalendar];
  if (!_sortedAlarms) {
    _sortedAlarms = [self.alarmPersistor fetchAlarms];
    _sortedAlarms = [_sortedAlarms sortedArrayUsingComparator:^NSComparisonResult(id l, id r) {
      NSDate *leftWaketime = [calendar dateFromComponents:((id <HCAlarm>)l).waketime];
      NSDate *rightWaketime = [calendar dateFromComponents:((id <HCAlarm>)r).waketime];
      return [leftWaketime compare:rightWaketime];
    }];
  }
  return _sortedAlarms;
}

- (NSArray *)conflictingAlarmCellColors {
  if (!_conflictingAlarmCellColors) {
    // #fff, #fff, #ffc4c6
    _conflictingAlarmCellColors = [NSArray arrayWithObjects:[[self alarmCellColors] objectAtIndex:0U],
                                   [[self alarmCellColors] objectAtIndex:1U],
                                   [UIColor colorWithRed:1.0 green:0.771166 blue:0.777525 alpha:1.0], nil];
  }
  return _conflictingAlarmCellColors;
}

- (void)markCell:(HCAlarmTableViewCell *)cell ifAlarm:(id <HCAlarm>)alarm isTooCloseTo:(id <HCAlarm>)otherAlarm {
  if ([alarm isTooCloseTo:otherAlarm]) {
    // TODO: use attributed string to color conflictSuffix
    NSString *conflictSuffix = NSLocalizedString(@"alarms.time.conflict",
                                                 @"Label suffix that designates that the adjacent time conflicts with the previous alarm");
    cell.timeLabel.text = [cell.timeLabel.text stringByAppendingString:conflictSuffix];
    cell.topColor = [[self conflictingAlarmCellColors] objectAtIndex:0U];
    cell.middleColor = [[self conflictingAlarmCellColors] objectAtIndex:1U];
    cell.bottomColor = [[self conflictingAlarmCellColors] objectAtIndex:2U];
  }
}

- (id <HCAlarm>)newAlarm {
  NSDateComponents *waketime = [[HCCalendarUtil currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit)
                                                                   fromDate:[NSDate date]];
  NSDictionary *alarmAttributes = [NSDictionary dictionaryWithObjectsAndKeys:waketime, @"waketime",
                                   NSLocalizedString(@"alarm.name.default", @"Default new alarm name"), @"name",
                                   [NSNumber numberWithInt:HCNoAnimal], @"animalType", nil];
  return [HCDictionaryAlarm alarmWithAttributes:alarmAttributes];
}

#pragma mark - View lifecycle

- (void)awakeFromNib {
  self.contentSizeForViewInPopover = CGSizeMake(320.0f, 480.0f);
  [super awakeFromNib];
}

- (void)viewWillAppear:(BOOL)animated {
  self.settingsNavigationItem.rightBarButtonItem = self.editButtonItem;
  _alarmCellColors = nil;
  _conflictingAlarmCellColors = nil;
  _selectedAlarm = nil;
  _sortedAlarms = nil;
  [self setEditing:NO animated:NO];
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
  // go to new alarm page if no alarms exist
  if ([[self alarms] count] == 0) {
    [self performSegueWithIdentifier:@"editAlarm" sender:self.tableView];
  }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
  // hide Done button if editing
  if (editing) {
    self.settingsNavigationItem.leftBarButtonItem = nil;
  } else {
    self.settingsNavigationItem.leftBarButtonItem = self.doneButtonItem;
  }
  [self.tableView setEditing:editing animated:animated];
  [super setEditing:editing animated:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"editAlarm"]) {
    UINavigationController *alarmNavigationController = (UINavigationController *)[segue destinationViewController];
    HCAlarmViewController *alarmViewController = (HCAlarmViewController *)alarmNavigationController.topViewController;
    if (_selectedAlarm) {
      alarmViewController.alarm = _selectedAlarm;
    } else {
      alarmViewController.alarm = [self newAlarm];
    }
    alarmViewController.alarmDelegate = self;

    // hide this popover to avoid conflicts with the modal alarm view
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
      [self.alarmsDelegate hideAlarmsViewController:self];
    }
  }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

#pragma mark - Actions

- (IBAction)done:(id)sender {
  [self.alarmsDelegate alarmsViewControllerDidFinish:self];
}

#pragma mark - HCAlarmViewControllerDelegate

- (void)alarmViewController:(HCAlarmViewController *)controller didFinishWithAlarm:(id <HCAlarm>)alarm {
  if (alarm) {
    [self.alarmPersistor upsertAlarm:(HCDictionaryAlarm *)alarm];
    [self.alarmsDelegate alarmsViewControllerDidUpdate:self];
    [self.tableView reloadData];
    [self.tableView setNeedsDisplay];
  }

  [self dismissViewControllerAnimated:YES completion:^(void){
    // show the popover again now that the modal view is gone
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
      [self.alarmsDelegate showAlarmsViewController:self];
    }

    // if editing, deselect the row being edited
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
  }];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
  _selectedAlarm = nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  _selectedAlarm = [self alarmForIndex:indexPath.row];
  [self performSegueWithIdentifier:@"editAlarm" sender:tableView];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  id <HCAlarm> alarm = [self alarmForIndex:indexPath.row];
  HCAlarmTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"alarm"];
  if (!cell) {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HCAlarmTableViewCell" owner:self options:nil];
    cell = [nib objectAtIndex:0];
    cell.topColor = [[self alarmCellColors] objectAtIndex:0U];
    cell.middleColor = [[self alarmCellColors] objectAtIndex:1U];
    cell.bottomColor = [[self alarmCellColors] objectAtIndex:2U];
  }
  cell.nameLabel.text = alarm.name;
  cell.timeLabel.text = [alarm waketimeAsString];
  cell.enabledSwitch.on = alarm.enabled;
  cell.repeatLabel.text = [alarm repeatAsString];

  // compare to adjacent alarms, highlight if conflicting
  NSUInteger alarmCount = [[self alarms] count];
  id <HCAlarm> previousAlarm;
  if (indexPath.row > 0) {
    previousAlarm = [self alarmForIndex:indexPath.row - 1];
  } else {
    previousAlarm = [self alarmForIndex:alarmCount - 1];
  }
  // FIXME: not working (or being called?) when returning from alarm view
  [self markCell:cell ifAlarm:alarm isTooCloseTo:previousAlarm];

  // switches do not have delegates, so force its hand
  [cell.enabledSwitch addTarget:self action:@selector(toggleAlarm:) forControlEvents:UIControlEventValueChanged];

  return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    [self.alarmPersistor removeAlarm:[self alarmForIndex:indexPath.row].name];
    [self.alarmsDelegate alarmsViewControllerDidUpdate:self];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
  }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [[self alarms] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 108.0f;
}

@end
