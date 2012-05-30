#import "HCAlarmsViewController.h"
#import "HCAlarm.h"
#import "HCUserDefaultsPersistence.h"
#import "HCAlarmTableViewCell.h"

@interface HCAlarmsViewController ()
- (id <HCAlarm>)alarmForIndex:(NSUInteger)index;
@end

@implementation HCAlarmsViewController

@synthesize alarmsDelegate = _settingsDelegate;
@synthesize tableView = _tableView;

- (id <HCAlarm>)alarmForIndex:(NSUInteger)index {
  return [[HCUserDefaultsPersistence fetchAlarms] objectAtIndex:index];
}

#pragma mark - View lifecycle

- (void)awakeFromNib {
  self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
  [super awakeFromNib];
}

- (void)viewDidLoad {
  self.tableView = [[self.view subviews] objectAtIndex:0U];
  [super viewDidLoad];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"addAlarm"]) {
    UINavigationController *alarmNavigationController = (UINavigationController *)[segue destinationViewController];
    [(HCAlarmViewController *)alarmNavigationController.topViewController setAlarmDelegate:self];
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
    [HCUserDefaultsPersistence upsert:(HCDictionaryAlarm *)alarm];
    [self.tableView reloadData];
    [self.tableView setNeedsDisplay];
  }
  [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [[HCUserDefaultsPersistence fetchAlarms] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 99;
}

@end
