#import <Foundation/Foundation.h>
#import "HCAlarm.h"

/**
 * A serializable-dictionary-backed implementation of HCAlarm.
 */
@interface HCDictionaryAlarm : NSObject <HCAlarm> {
  NSMutableDictionary *_attributes;
}

/**
 * Uses the data in the given dictionary to initialize the attributes of a new alarm.
 */
+ (id)alarmWithAttributes:(NSDictionary *)attributes;

/**
 * Uses the data in the given dictionary to initialize the attributes of this alarm.
 */
- (id)initWithAttributes:(NSDictionary *)attributes;

/**
 * \return the serializable attributes of this alarm
 */
- (NSDictionary *)attributes;

@end
