#import "HCRepeatViewController.h"
#import "HCCalendarUtil.h"

@interface HCRepeatViewController ()
- (void)initRepeat;
- (void)setRepeat:(BOOL)repeat forDay:(NSInteger)dayIndex;
@end

@implementation HCRepeatViewController

@synthesize alarm = _alarm;

#pragma mark - Methods

- (void)initRepeat {
  if (!self.alarm.repeat) {
    NSNumber *no = [NSNumber numberWithBool:NO];
    self.alarm.repeat = [NSArray arrayWithObjects:no, no, no, no, no, no, no, nil];
  }
}

- (void)setRepeat:(BOOL)repeat forDay:(NSInteger)dayIndex {
  NSMutableArray *repeating = [self.alarm.repeat mutableCopy];
  [repeating replaceObjectAtIndex:dayIndex withObject:[NSNumber numberWithBool:repeat]];
  self.alarm.repeat = repeating;
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
  [self initRepeat];
  _weekdaySymbols = [[[NSDateFormatter alloc] init] weekdaySymbols];
  [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [[HCCalendarUtil currentCalendar] maximumRangeOfUnit:NSWeekdayCalendarUnit].length;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellIdentifier = @"day";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  NSString *day = [_weekdaySymbols objectAtIndex:indexPath.row];
  cell.textLabel.text = day;
  if ([[self.alarm.repeat objectAtIndex:indexPath.row] boolValue]) {
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
  } else {
    cell.accessoryType = UITableViewCellAccessoryNone;
  }
  return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
    cell.accessoryType = UITableViewCellAccessoryNone;
    [self setRepeat:NO forDay:indexPath.row];
  } else {
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    [self setRepeat:YES forDay:indexPath.row];
  }
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
