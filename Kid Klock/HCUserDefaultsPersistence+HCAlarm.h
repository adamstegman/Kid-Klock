#import "HCUserDefaultsPersistence.h"
#import "HCDictionaryAlarm.h"

@interface HCUserDefaultsPersistence (HCAlarm)

/**
 * \return all persisted HCAlarm objects
 */
+ (NSArray *)fetchAlarms;

/**
 * Removes all alarms.
 */
+ (void)clearAlarms;

/**
 * Removes the alarm with the given name.
 */
+ (void)removeAlarm:(NSString *)alarmName;

/**
 * Insert or update the given alarm, using the alarm's name as the primary key.
 */
+ (void)upsertAlarm:(HCDictionaryAlarm *)alarm;

@end
