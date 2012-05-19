//
//  HCSettingsViewController.m
//  Kid Klock
//
//  Created by Adam Stegman on 5/12/12.
//  Copyright (c) 2012 Homemade Concoctions. All rights reserved.
//

#import "HCSettingsViewController.h"
#import "HCAlarm.h"
#import "HCUserDefaultsPersistence.h"

@interface HCSettingsViewController ()
- (id <HCAlarm>)alarmForIndex:(NSUInteger)index;
- (NSString *)formatTime:(NSDate *)time;
@end

@implementation HCSettingsViewController

@synthesize settingsDelegate = _settingsDelegate;
@synthesize tableView = _tableView;

- (void)addAlarm:(id)sender {
  // TODO: collect name
  [self createAlarm:[self formatTime:[NSDate date]]];
}

- (void)createAlarm:(NSString *)name {
  HCDictionaryAlarm *alarm = [[HCDictionaryAlarm alloc] init];
  alarm.name = [self formatTime:[NSDate date]];
  [HCUserDefaultsPersistence upsert:alarm];
  [self.tableView reloadData];
  [self.tableView setNeedsDisplay];
}

- (id <HCAlarm>)alarmForIndex:(NSUInteger)index {
  return [[HCUserDefaultsPersistence fetchAlarms] objectAtIndex:index];
}

- (NSString *)formatTime:(NSDate *)time {
  return [NSDateFormatter localizedStringFromDate:time dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
}

#pragma mark - View lifecycle

- (void)awakeFromNib {
  self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
  [super awakeFromNib];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

- (void)viewDidLoad {
  self.tableView = [[self.view subviews] objectAtIndex:0U];
}

- (void)viewWillAppear:(BOOL)animated {
  // show the status bar for the settings view
  [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewWillDisappear:(BOOL)animated {
  // hide the status bar for the main view
  [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

#pragma mark - Actions

- (IBAction)done:(id)sender {
  [self.settingsDelegate settingsViewControllerDidFinish:self];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSUInteger section = [indexPath indexAtPosition:0U];
  if ([[HCUserDefaultsPersistence fetchAlarms] count] > section) {
    // TODO
  } else {
    // last section is "add an alarm" button
    [self addAlarm:self.tableView];
  }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSUInteger section = [indexPath indexAtPosition:0U];
  if ([[HCUserDefaultsPersistence fetchAlarms] count] > section) {
    id <HCAlarm> alarm = [self alarmForIndex:section];
    NSString *value = @"";
    // FIXME: are the values formatted here or on the model?
    switch ([indexPath indexAtPosition:1U]) {
      case 0:
        value = [self formatTime:alarm.bedtime];
        break;
      case 1:
        value = [self formatTime:alarm.waketime];
        break;
      case 2:
        value = [alarm repeatAsString];
        break;
      case 3:
        value = alarm.animal.name;
        break;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"label"];
    cell.textLabel.text = value;
    return cell;
  } else {
    // last section is "add an alarm" button
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addAlarm"];
    // TODO: plus icon
    return cell;
  }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [[HCUserDefaultsPersistence fetchAlarms] count] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if ([[HCUserDefaultsPersistence fetchAlarms] count] > section) {
    return 5; // number of fields in HCAlarm
  } else {
    return 1; // last section is "add an alarm" button
  }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  if ([[HCUserDefaultsPersistence fetchAlarms] count] > section) {
    return [[self alarmForIndex:section] name];
  } else {
    return @""; // last section is "add an alarm" button
  }
}

@end
