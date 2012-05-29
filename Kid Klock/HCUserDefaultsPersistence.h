#import <Foundation/Foundation.h>
#import "HCDictionaryAlarm.h"

@interface HCUserDefaultsPersistence : NSObject

/**
 * \return all persisted HCAlarm objects
 */
+ (NSArray *)fetchAlarms;

/**
 * Removes all alarms.
 */
+ (void)clear;

/**
 * Removes the alarm with the given name.
 */
+ (void)remove:(NSString *)alarmName;

/**
 * Insert or update the given alarm, using the alarm's name as the primary key.
 */
+ (void)upsert:(HCDictionaryAlarm *)alarm;

@end
