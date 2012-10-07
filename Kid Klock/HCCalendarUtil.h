#import <Foundation/Foundation.h>

/**
 * Calendar utility class. Not thread-safe.
 */
@interface HCCalendarUtil : NSObject

/**
 * \return a statically-held instance of the auto-updating current calendar.
 */
+ (NSCalendar *)currentCalendar;

/**
 * Clean up as much memory as possible.
 */
+ (void)clean;

@end
