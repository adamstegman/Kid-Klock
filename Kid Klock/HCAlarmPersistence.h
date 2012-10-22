#import <Foundation/Foundation.h>
#import "HCDictionaryAlarm.h"

/**
 * An alarm persistence interface.
 */
@protocol HCAlarmPersistence <NSObject>

/**
 * \return all persisted HCAlarm objects
 */
- (NSArray *)fetchAlarms;

/**
 * Removes all alarms.
 */
- (void)clearAlarms;

/**
 * Removes the alarm with the given identifier.
 */
- (void)removeAlarm:(NSString *)alarmId;

/**
 * Insert or update the given alarm, using the alarm's name as the primary key.
 */
- (void)upsertAlarm:(HCDictionaryAlarm *)alarm;

@end
