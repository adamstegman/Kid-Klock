#import "HCAlarmsViewController.h"
#import "HCAlarm.h"
#import "HCDictionaryAlarm.h"
#import "HCUserDefaultsPersistence+HCAlarm.h"
#import "HCAlarmTableViewCell.h"

@interface HCAlarmsViewController ()
- (id <HCAlarm>)alarmForIndex:(NSUInteger)index;
@end

@implementation HCAlarmsViewController

@synthesize alarmsDelegate = _alarmsDelegate;
@synthesize tableView = _tableView;
@synthesize settingsNavigationItem = _settingsNavigationItem;
@synthesize doneButtonItem = _doneButtonItem;

- (id <HCAlarm>)alarmForIndex:(NSUInteger)index {
  return [[HCUserDefaultsPersistence fetchAlarms] objectAtIndex:index];
}

- (id <HCAlarm>)newAlarm {
  NSDictionary *alarmAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], @"waketime",
                                   NSLocalizedString(@"alarm.name.default", @"Default new alarm name"), @"name",
                                   [NSNumber numberWithInt:HCNoAnimal], @"animalType", nil];
  return [HCDictionaryAlarm alarmWithAttributes:alarmAttributes];
}

#pragma mark - View lifecycle

- (void)awakeFromNib {
  self.contentSizeForViewInPopover = CGSizeMake(320.0f, 480.0f);
  [super awakeFromNib];
}

- (void)viewDidLoad {
  self.settingsNavigationItem.rightBarButtonItem = self.editButtonItem;
  [super viewDidLoad];
}

- (void)viewDidUnload {
  self.tableView = nil;
  self.settingsNavigationItem = nil;
  self.doneButtonItem = nil;
  [super viewDidUnload];
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
  }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  // TODO
  return YES;
}

#pragma mark - Actions

- (IBAction)done:(id)sender {
  [self.alarmsDelegate alarmsViewControllerDidFinish:self];
}

#pragma mark - HCAlarmViewControllerDelegate

- (void)alarmViewController:(HCAlarmViewController *)controller didFinishWithAlarm:(id<HCAlarm>)alarm {
  if (alarm) {
    // TODO: handle new alarm same as existing alarm name
    [HCUserDefaultsPersistence upsertAlarm:(HCDictionaryAlarm *)alarm];
    [self.tableView reloadData];
    [self.tableView setNeedsDisplay];
  }
  [self dismissModalViewControllerAnimated:YES];
  // if editing, deselect the row being edited
  if (_selectedAlarm) {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
  }
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
  // TODO: sorting
  id <HCAlarm> alarm = [self alarmForIndex:indexPath.row];
  HCAlarmTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"alarm"];
  if (!cell) {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HCAlarmTableViewCell" owner:self options:nil];
    cell = [nib objectAtIndex:0];
  }
  cell.labelLabel.text = alarm.name;
  cell.animalImageView.image = alarm.animal.icon;
  cell.timeLabel.text = [alarm waketimeAsString];
  cell.enabledSwitch.enabled = YES; // TODO
  // TODO: repeats
  return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    [HCUserDefaultsPersistence removeAlarm:[self alarmForIndex:indexPath.row].name];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
  }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [[HCUserDefaultsPersistence fetchAlarms] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 99.0f;
}

@end
