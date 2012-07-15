#import <Foundation/Foundation.h>
#import "HCAnimal.h"

/**
 * Alarm data model.
 */
@protocol HCAlarm <NSObject>

/**
 * The persistence identifier for this alarm.
 */
@property (strong, nonatomic) NSString *id;

/**
 * The user-specified alarm name.
 */
@property (strong, nonatomic) NSString *name;

/**
 * Returns the time of day this alarm should wake up. Only the hour and minute sections are in this value, the other
 * date sections should not be used.
 */
@property (strong, nonatomic) NSDateComponents *waketime;

/**
 * The type of animal used for this alarm.
 */
@property (assign, nonatomic) HCAnimalType animalType;

/**
 * \return the animal object for this alarm
 */
@property (strong, nonatomic, readonly) id <HCAnimal> animal;

/**
 * Assign which days the alarm should repeat on. Does nothing if the given array does not have exactly seven elements.
 *
 * \param days BOOL values indexed to correspond to [NSDateFormatter -veryShortWeekdaySymbols].
 */
@property (copy, nonatomic) NSArray *repeat;

/**
 * Whether the alarm is currently enabled.
 */
@property (assign, nonatomic) BOOL enabled;

/**
 * \return the next date and time this alarm should go off
 */
- (NSDate *)nextWakeDate;

/**
 * \return a string appropriate for the user interface representing the waketime for this alarm
 */
- (NSString *)waketimeAsString;

/**
 * \return a string appropriate for the user interface representing which days of the week this alarm repeats on
 */
- (NSString *)repeatAsString;

/**
 * Returns the interval used between minutes when setting the alarm. The alarm will not support minute precision more
 * granular than this number. When -setWaketime: is called, it will round to the nearest minute matching this number.
 *
 * \return the interval between minutes allowed when setting the alarm
 */
- (NSInteger)minuteInterval;

@end
