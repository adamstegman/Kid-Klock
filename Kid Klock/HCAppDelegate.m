#import "HCAppDelegate.h"
#import "HCMainViewController.h"
#import "HCUserDefaultsAlarmPersistence.h"
#import "HCUbiquitousAlarmPersistence.h"

@implementation HCAppDelegate

#pragma mark - UIApplicationDelegate

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
  // notify main view
  HCMainViewController *mainViewController = (HCMainViewController *)[[self window] rootViewController];
  [mainViewController updateAlarm:NO];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
  // TODO: handle changes in # of days per week in persisted alarms
  // TODO: change notifications for daylight savings, time update, etc.
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // create alarm persistence
  HCUserDefaultsAlarmPersistence *userDefaultsAlarmPersistence = [HCUserDefaultsAlarmPersistence standardUserDefaults];
  // FIXME: disabled for entitlements
//  HCUbiquitousAlarmPersistence *ubiquitousAlarmPersistence = [HCUbiquitousAlarmPersistence defaultStore];
  self.alarmPersistor = [[HCAlarmPersistor alloc] initWithPersistenceStores:@[userDefaultsAlarmPersistence/*, ubiquitousAlarmPersistence*/]];
  // FIXME: pass this to the main view

  // register for iCloud notifications
  // TODO: this may need to be done when entering foreground? depends if all references to the HCUbiquitousAlarmPersistence object are deallocated
  // FIXME: disabled for entitlements
//  [[NSNotificationCenter defaultCenter] addObserver:ubiquitousAlarmPersistence
//                                           selector:@selector(ubiquitousStoreDidChange:)
//                                               name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
//                                             object:[NSUbiquitousKeyValueStore defaultStore]];

  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  [[UIApplication sharedApplication] cancelAllLocalNotifications];
  // do not restore brightness, this may be just an alert
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  [[UIApplication sharedApplication] cancelAllLocalNotifications];

  // restore brightness for other applications
  HCMainViewController *mainViewController = (HCMainViewController *)[[self window] rootViewController];
  [mainViewController restoreBrightness:1.0];

  // TODO: save UI state?
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // TODO: restore UI state?
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  HCMainViewController *mainViewController = (HCMainViewController *)[[self window] rootViewController];
  mainViewController.alarmPersistor = self.alarmPersistor;
  [mainViewController updateAlarm:NO];
}

@end
