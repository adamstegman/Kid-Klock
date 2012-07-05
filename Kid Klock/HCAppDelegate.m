#import "HCAppDelegate.h"
#import "HCMainViewController.h"

@implementation HCAppDelegate

@synthesize window = _window;

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
  // notify main view
  // FIXME: what happens if another view is visible on iPad? on iPhone?
  HCMainViewController *mainViewController = (HCMainViewController *)[[self window] rootViewController];
  [mainViewController wakeAlarm];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
  // TODO: daylight savings, time update, etc.
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.
  return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
  // TODO
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // TODO
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // TODO
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // TODO
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // TODO
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
