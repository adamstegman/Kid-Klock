#import <Foundation/Foundation.h>
#import "HCAlarmPersistence.h"

/**
 * NSUbiquitousKeyValueStore storage for HCAlarm objects.
 */
@interface HCUbiquitousAlarmPersistence : NSObject <HCAlarmPersistence> {
  NSUbiquitousKeyValueStore *_store;
}

/**
 * Stores alarms in the given NSUbiquitousKeyValueStore.
 */
- (id)initWithUbiquitousStore:(NSUbiquitousKeyValueStore *)store;

/**
 * Stores alarms in +[NSUbiquitousKeyValueStore defaultStore].
 */
+ (id)defaultStore;

@end
