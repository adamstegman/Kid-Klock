#import <Foundation/Foundation.h>
#import "HCAlarmPersistence.h"
#import "HCUserDefaultsPersistence.h"

/**
 * NSUserDefaults storage for HCAlarm objects.
 */
@interface HCUserDefaultsAlarmPersistence : NSObject <HCAlarmPersistence> {
  HCUserDefaultsPersistence *_userDefaults;
}

/**
 * Stores alarms in the given NSUserDefaults store.
 */
- (id)initWithUserDefaults:(NSUserDefaults *)userDefaults;

/**
 * Stores alarms in +[NSUserDefaults standardUserDefaults].
 */
+ (id)standardUserDefaults;

@end
