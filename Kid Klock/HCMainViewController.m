#import "HCMainViewController.h"
#import "HCUserDefaultsPersistence+HCAlarm.h"

// The brightness percentage to display the sleeping image at
#define DIM_BRIGHTNESS 0.01f

// Sometimes, notifications come a split-second too early, so -updateAlarm: doesn't think it's time to wake up yet.
// This is a kludge to get around that by delaying the notification by a certain number of seconds.
#define SLEEP_TIME_FUDGE 5.0

// How long to wait (in seconds) until increasing the brightness while the awake image is shown
#define BRIGHTNESS_DURATION 300.0

// The maximum amount of time (in seconds) to display the awake image for an alarm
#define MAXIMUM_AWAKE_IMAGE_DURATION 3600.0
// The minimum buffer time (in seconds) before an alarm's waketime that the alarm's sleeping image should be shown
#define MINIMUM_SLEEP_IMAGE_DURATION 3600.0

static NSString *hcBrightnessKey = @"brightness";

@interface HCMainViewController()
- (void)alarmSleep;
- (void)alarmWake;
- (void)dimForSleep;
- (id <HCAlarm>)nextAlarm;
- (id <HCAlarm>)previousAlarm;
- (NSDate *)sleepTime;
/**
 * \return all persisted alarms, sorted by their next occurring waketime
 */
- (NSArray *)sortedAlarms;
- (void)updateTime:(BOOL)schedule;
@end

@implementation HCMainViewController

#pragma mark - Properties

@synthesize settingsPopoverController = _settingsPopoverController;
@synthesize alarmImage = _alarmImage;
@synthesize settingsButton = _settingsButton;
@synthesize timeLabel = _timeLabel;

#pragma mark - Methods

- (void)restoreBrightness:(double)percentage {
  NSNumber *oldBrightness = [HCUserDefaultsPersistence settingsForKey:hcBrightnessKey];

  // epsilon of 0.001, because let's not get ridiculous with preciseness
  if (percentage > 0.999) {
    [HCUserDefaultsPersistence setSettingsValue:nil forKey:hcBrightnessKey];
  }

  if (oldBrightness) {
    [UIScreen mainScreen].brightness = [oldBrightness floatValue] * percentage;
  }
}

- (void)updateAlarm:(BOOL)schedule {
  [self updateTime:schedule];
  NSDate *now = [NSDate date];
  NSDate *earlierDate = [now earlierDate:[self sleepTime]];
  if (earlierDate == now) {
    [self alarmWake];
  } else {
    [self alarmSleep];
  }
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
  if ([self.settingsPopoverController isPopoverVisible]) {
    [self.settingsPopoverController dismissPopoverAnimated:YES];
    [self performSegueWithIdentifier:@"showSettings" sender:self.settingsButton];
  }
  [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)viewWillAppear:(BOOL)animated {
  [UIApplication sharedApplication].idleTimerDisabled = YES;
  [self updateAlarm:YES];
}

- (void)viewDidAppear:(BOOL)animated {
  if (![self nextAlarm]) {
    // go to alarms view if there are no alarms
    [self performSegueWithIdentifier:@"showSettings" sender:self.settingsButton];
  }
}

- (void)viewWillDisappear:(BOOL)animated {
  [UIApplication sharedApplication].idleTimerDisabled = NO;
  [self restoreBrightness:1.0];
}

- (void)viewDidDisappear:(BOOL)animated {
  [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"showSettings"]) {
    [(HCAlarmsViewController *)[segue destinationViewController] setAlarmsDelegate:self];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
      UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
      self.settingsPopoverController = popoverController;
      popoverController.delegate = self;
    }
    
    // show the status bar for the settings view
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
  }
}

#pragma mark - Flipside View Controller

- (void)alarmsViewControllerDidFinish:(HCAlarmsViewController *)controller {
  // hide the status bar for the main view
  [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
  
  // dismiss the settings view
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    [self dismissModalViewControllerAnimated:YES];
  } else {
    [self.settingsPopoverController dismissPopoverAnimated:YES];
    self.settingsPopoverController = nil;
  }

  [self updateAlarm:NO];
}

- (void)alarmsViewControllerDidUpdate:(HCAlarmsViewController *)controller {
  [self updateAlarm:NO];
}

- (void)hideAlarmsViewController:(HCAlarmsViewController *)controller {
  if ([self.settingsPopoverController isPopoverVisible]) {
    [self.settingsPopoverController dismissPopoverAnimated:YES];
  }
}

- (void)showAlarmsViewController:(HCAlarmsViewController *)controller {
  if (self.settingsPopoverController) {
    [self performSegueWithIdentifier:@"showSettings" sender:self.settingsButton];
  }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
  [self alarmsViewControllerDidFinish:(HCAlarmsViewController *)popoverController];
}

#pragma mark - Private methods

- (void)alarmSleep {
  // FIXME: time label color
  id <HCAlarm> nextAlarm = [self nextAlarm];
  if (nextAlarm) {
    if (nextAlarm.shouldDimDisplay) {
      [self dimForSleep];
    }
    self.alarmImage.image = nextAlarm.animal.sleepImage;
  }
}

- (void)alarmWake {
  // FIXME: time label color
  id <HCAlarm> previousAlarm = [self previousAlarm];
  if (previousAlarm) {
    NSDate *now = [NSDate date];
    NSDate *sleepTime = [self sleepTime];
    self.alarmImage.image = previousAlarm.animal.awakeImage;

    if (previousAlarm.shouldDimDisplay) {
      // slowly increase brightness, over time
      double percentage = [now timeIntervalSinceDate:[previousAlarm previousWakeDate]] / [sleepTime timeIntervalSinceDate:now];
      [self restoreBrightness:percentage];
    }
  }
}

- (void)dimForSleep {
  NSNumber *oldBrightess = [HCUserDefaultsPersistence settingsForKey:hcBrightnessKey];
  if (!oldBrightess) {
    NSNumber *oldBrightness = [NSNumber numberWithFloat:[UIScreen mainScreen].brightness];
    [HCUserDefaultsPersistence setSettingsValue:oldBrightness forKey:hcBrightnessKey];
  }
  [UIScreen mainScreen].brightness = DIM_BRIGHTNESS;
}

- (id <HCAlarm>)nextAlarm {
  NSArray *alarms = [self sortedAlarms];
  if ([alarms count] > 0) {
    return [alarms objectAtIndex:0U];
  } else {
    return nil;
  }
}

- (id <HCAlarm>)previousAlarm {
  NSArray *alarms = [self sortedAlarms];
  NSUInteger alarmCount = [alarms count];
  if (alarmCount > 0) {
    return [alarms objectAtIndex:alarmCount - 1];
  } else {
    return nil;
  }
}

- (NSDate *)sleepTime {
  NSDate *currentAlarmLatestSleepTime = [[[self nextAlarm] nextWakeDate] dateByAddingTimeInterval:-MINIMUM_SLEEP_IMAGE_DURATION];
  NSDate *previousAlarmWakeDate = [[self previousAlarm] previousWakeDate];
  NSDate *previousAlarmEarliestSleepTime;
  if (previousAlarmWakeDate) {
    previousAlarmEarliestSleepTime = [previousAlarmWakeDate dateByAddingTimeInterval:MAXIMUM_AWAKE_IMAGE_DURATION];
  } else {
    previousAlarmEarliestSleepTime = [NSDate distantPast];
  }
  
  NSDate *earlierDate = [previousAlarmEarliestSleepTime earlierDate:currentAlarmLatestSleepTime];
  if (earlierDate == previousAlarmEarliestSleepTime) {
    return previousAlarmEarliestSleepTime;
  } else {
    return currentAlarmLatestSleepTime;
  }
}

- (NSArray *)sortedAlarms {
  NSArray *allAlarms = [HCUserDefaultsPersistence fetchAlarms];
  allAlarms = [allAlarms filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K != NIL", @"nextWakeDate"]];
  return [allAlarms sortedArrayUsingComparator:^NSComparisonResult(id l, id r) {
    return [[(id <HCAlarm>)l nextWakeDate] compare:[(id <HCAlarm>)r nextWakeDate]];
  }];
}

- (void)updateTime:(BOOL)schedule {
  if (schedule) {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
  }
  NSDate *now = [NSDate date];
  self.timeLabel.text = [NSDateFormatter localizedStringFromDate:now
                                                       dateStyle:NSDateFormatterNoStyle
                                                       timeStyle:NSDateFormatterShortStyle];
  if (schedule) {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // drop seconds from the current date and add one minute
    NSDateComponents *currentTimeComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit)
                                                          fromDate:now];
    NSDate *fireTime = [[calendar dateFromComponents:currentTimeComponents] dateByAddingTimeInterval:60.0];
    // set up a notification to change the time when it changes next
    UILocalNotification *timeNotification = [[UILocalNotification alloc] init];
    timeNotification.fireDate = fireTime;
    timeNotification.timeZone = [calendar timeZone];
    timeNotification.repeatInterval = NSMinuteCalendarUnit;
    [[UIApplication sharedApplication] scheduleLocalNotification:timeNotification];
  }
}

@end
