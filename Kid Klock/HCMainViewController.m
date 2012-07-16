#import "HCMainViewController.h"
#import "HCUserDefaultsPersistence+HCAlarm.h"

// The brightness percentage to display the sleeping image at
#define DIM_BRIGHTNESS 0.01f

// Sometimes, notifications come a split-second too early, so -updateAlarm doesn't think it's time to wake up yet.
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
- (id <HCAlarm>)nextAlarm;
- (id <HCAlarm>)previousAlarm;
- (void)dimForSleep;
/**
 * \return all persisted alarms, sorted by their next occurring waketime
 */
- (NSArray *)sortedAlarms;
- (NSDate *)sleepTime;
@end

@implementation HCMainViewController

#pragma mark - Properties

@synthesize settingsPopoverController = _settingsPopoverController;
@synthesize alarmImage = _alarmImage;
@synthesize settingsButton = _settingsButton;

#pragma mark - Methods

- (void)restoreBrightness:(double)percentage {
  NSNumber *oldBrightness = [HCUserDefaultsPersistence settingsForKey:hcBrightnessKey];

  // espilon of 0.001, because let's not get ridiculous with preciseness
  if (percentage > 0.999) {
    [HCUserDefaultsPersistence setSettingsValue:nil forKey:hcBrightnessKey];
  }

  if (oldBrightness) {
    [UIScreen mainScreen].brightness = [oldBrightness floatValue] * percentage;
  }
}

- (void)updateAlarm {
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
  [self updateAlarm];
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
  // hide the status bar for the main view
  [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
  self.settingsPopoverController = nil;
}

#pragma mark - Private methods

- (void)alarmSleep {
  [[UIApplication sharedApplication] cancelAllLocalNotifications];
  if ([self nextAlarm]) {
    [self dimForSleep];
    self.alarmImage.image = [self nextAlarm].animal.sleepImage;
    // change to awakeImage on waketime
    UILocalNotification *wakeNotification = [[UILocalNotification alloc] init];
    wakeNotification.fireDate = [[[self nextAlarm] nextWakeDate] dateByAddingTimeInterval:SLEEP_TIME_FUDGE];
    wakeNotification.timeZone = [NSTimeZone localTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:wakeNotification];
  }
}

- (void)alarmWake {
  [[UIApplication sharedApplication] cancelAllLocalNotifications];
  if ([self previousAlarm]) {
    NSDate *now = [NSDate date];
    NSDate *sleepTime = [self sleepTime];

    // slowly increase brightness, over time
    double percentage = [now timeIntervalSinceDate:[[self previousAlarm] previousWakeDate]] / [sleepTime timeIntervalSinceDate:now];
    [self restoreBrightness:percentage];

    self.alarmImage.image = [self previousAlarm].animal.awakeImage;

    NSDate *brightnessIncrementTime = [now dateByAddingTimeInterval:BRIGHTNESS_DURATION];
    if ([brightnessIncrementTime earlierDate:sleepTime] == brightnessIncrementTime) {
      // schedule notification to increase brightness
      UILocalNotification *brightenNotification = [[UILocalNotification alloc] init];
      brightenNotification.fireDate = [now dateByAddingTimeInterval:BRIGHTNESS_DURATION];
      brightenNotification.timeZone = [NSTimeZone localTimeZone];
      [[UIApplication sharedApplication] scheduleLocalNotification:brightenNotification];
    } else {
      // schedule notification to go to sleep image for next alarm
      UILocalNotification *sleepNotification = [[UILocalNotification alloc] init];
      sleepNotification.fireDate = sleepTime;
      sleepNotification.timeZone = [NSTimeZone localTimeZone];
      [[UIApplication sharedApplication] scheduleLocalNotification:sleepNotification];
    }
  }
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

- (void)dimForSleep {
  NSNumber *oldBrightess = [HCUserDefaultsPersistence settingsForKey:hcBrightnessKey];
  if (!oldBrightess) {
    NSNumber *oldBrightness = [NSNumber numberWithFloat:[UIScreen mainScreen].brightness];
    [HCUserDefaultsPersistence setSettingsValue:oldBrightness forKey:hcBrightnessKey];
  }
  [UIScreen mainScreen].brightness = DIM_BRIGHTNESS;
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

@end
