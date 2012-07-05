#import "HCMainViewController.h"
#import "HCUserDefaultsPersistence.h"

@interface HCMainViewController()
- (void)setAlarmImage;
@end

@implementation HCMainViewController

#pragma mark - Properties

@dynamic currentAlarm;
@synthesize settingsPopoverController = _settingsPopoverController;
@synthesize alarmImage = _alarmImage;

- (id <HCAlarm>)currentAlarm {
  NSArray *alarms = [[HCUserDefaultsPersistence fetchAlarms] sortedArrayUsingComparator:^NSComparisonResult(id l, id r) {
    return [((id <HCAlarm>)l).waketime compare:((id <HCAlarm>)r).waketime];
  }];
  if ([alarms count] > 0) {
    // find current alarm
    NSDate *now = [NSDate date];
    for (NSUInteger i = 0U, len = [alarms count]; i < len; i++) {
      id <HCAlarm> alarm = [alarms objectAtIndex:i];
      if ([now compare:alarm.waketime] != NSOrderedDescending) {
        return alarm;
      }
    }
    // now is after all the alarms, so wrap around to the first alarm
    return [alarms objectAtIndex:0U];
  } else {
    // TODO: return something if there are no alarms, or go to alarms view?
    return nil;
  }
}

#pragma mark - Private methods

- (void)setAlarmImage {
  if (self.currentAlarm) {
    self.alarmImage.image = self.currentAlarm.animal.sleepImage;
    // TODO: change to awakeImage on waketime
  }
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

- (void)viewWillAppear:(BOOL)animated {
  [self setAlarmImage];
}

// FIXME: use autolayout to keep info icon in right place during rotation

#pragma mark - Flipside View Controller

- (void)alarmsViewControllerDidFinish:(HCAlarmsViewController *)controller {
  [self setAlarmImage];
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

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
  // hide the status bar for the main view
  [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
  self.settingsPopoverController = nil;
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

- (IBAction)togglePopover:(id)sender {
  if (self.settingsPopoverController) {
    [self.settingsPopoverController dismissPopoverAnimated:YES];
    self.settingsPopoverController = nil;
  } else {
    [self performSegueWithIdentifier:@"showSettings" sender:sender];
  }
}

@end
