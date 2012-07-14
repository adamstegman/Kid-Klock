#import "HCAppDelegate.h"
#import "HCMainViewController.h"

@implementation HCAppDelegate

#pragma mark - Properties

@synthesize window = _window;

#pragma mark - UIApplicationDelegate

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
  // notify main view
  HCMainViewController *mainViewController = (HCMainViewController *)[[self window] rootViewController];
  [mainViewController updateAlarm];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
  // TODO: daylight savings, time update, etc.
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.
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
  [mainViewController updateAlarm];
}

@end
