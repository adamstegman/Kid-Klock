#import "HCDictionaryAlarm.h"
#import "HCStaticAssetAnimal.h"
#import "HCCalendarUtil.h"

@interface HCDictionaryAlarm()
/**
 * \return the given time on the current day
 */
- (NSDate *)todayAtTime:(NSDateComponents *)time;
@end

@implementation HCDictionaryAlarm

#pragma mark - Properties

@synthesize id = _id;
@dynamic name;
@dynamic waketime;
@dynamic animal;
@dynamic repeat;
@dynamic shouldDimDisplay;
@dynamic enabled;

- (NSString *)name {
  return [_attributes objectForKey:@"name"];
}

- (void)setName:(NSString *)name {
  if (name) {
    [_attributes setObject:[name copy] forKey:@"name"];
  }
}

- (NSDateComponents *)waketime {
  return [[_attributes objectForKey:@"waketime"] copy];
}

- (void)setWaketime:(NSDateComponents *)waketime {
  if (waketime) {
    // default components
    if ([waketime hour] == NSUndefinedDateComponent) {
      [waketime setHour:0];
    }
    if ([waketime minute] == NSUndefinedDateComponent) {
      [waketime setMinute:0];
    }
    
    // round to nearest minute interval
    NSInteger minutes = [waketime minute];
    NSInteger minuteInterval = [self minuteInterval];
    NSInteger minuteRemainder = minutes % minuteInterval;
    if (minuteRemainder != 0) {
      NSDate *todayWaketime = [self todayAtTime:waketime];
      NSInteger roundingAdjustment;
      if (minuteRemainder < minuteInterval / 2.0) {
        // round down
        roundingAdjustment = -60.0 * minuteRemainder;
      } else {
        // round up
        roundingAdjustment = 60.0 * (minuteInterval - minuteRemainder);
      }
      waketime = [[HCCalendarUtil currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit)
                                                     fromDate:[todayWaketime dateByAddingTimeInterval:roundingAdjustment]];
    }
    
    [waketime setSecond:0];
    [_attributes setObject:waketime forKey:@"waketime"];
  } else {
    [_attributes removeObjectForKey:@"waketime"];
  }
}

- (HCAnimalType)animalType {
  return [[_attributes objectForKey:@"animalType"] intValue];
}

- (void)setAnimalType:(HCAnimalType)animalType {
  [_attributes setObject:[NSNumber numberWithInt:animalType] forKey:@"animalType"];
}

- (id <HCAnimal>)animal {
  return [HCStaticAssetAnimal animalWithType:self.animalType];
}

- (NSArray *)repeat {
  return [_attributes objectForKey:@"repeat"];
}

- (void)setRepeat:(NSArray *)days {
  if ([days count] == [[HCCalendarUtil currentCalendar] maximumRangeOfUnit:NSWeekdayCalendarUnit].length) {
    [_attributes setObject:[days copy] forKey:@"repeat"];
  }
}

- (BOOL)shouldDimDisplay {
  return [[_attributes objectForKey:@"shouldDimDisplay"] boolValue];
}

- (void)setShouldDimDisplay:(BOOL)shouldDimDisplay {
  [_attributes setObject:[NSNumber numberWithBool:shouldDimDisplay] forKey:@"shouldDimDisplay"];
}

- (BOOL)enabled {
  return [[_attributes objectForKey:@"enabled"] boolValue];
}

- (void)setEnabled:(BOOL)enabled {
  [_attributes setObject:[NSNumber numberWithBool:enabled] forKey:@"enabled"];
}

#pragma mark - Methods

- (NSDictionary *)attributes {
  return [_attributes copy];
}

- (NSInteger)minuteInterval {
  return 5;
}

- (BOOL)isTooCloseTo:(id <HCAlarm>)alarm {
  BOOL before = ([self.waketime hour] < [alarm.waketime hour] ||
                 ([self.waketime hour] == [alarm.waketime hour] && [self.waketime minute] < [alarm.waketime minute]));
  NSInteger minuteDifference = 0;
  if (before) {
    // this alarm is before the given one, so need to ensure there is at least the minimum time after the given alarm
    // and before this one
    minuteDifference = ((24 - [alarm.waketime hour] + [self.waketime hour]) * 60) + [self.waketime minute];
  } else {
    // this alarm is after the given one, so need to ensure there is at least the minimum time between the two
    minuteDifference = (([self.waketime hour] - [alarm.waketime hour]) * 60) + [self.waketime minute];
  }
  if ([alarm.waketime minute] > 0) {
    // count the minute difference instead of the full hour difference
    minuteDifference -= [alarm.waketime minute];
  }
  return (minuteDifference * 60.0) < MINIMUM_SLEEP_IMAGE_DURATION;
}

- (NSDate *)nextWakeDate {
  if (!self.enabled || !self.waketime) {
    return nil;
  }

  NSDate *nextWakeDate = [self todayAtTime:self.waketime];
  if (nextWakeDate && [[self today] earlierDate:nextWakeDate] == nextWakeDate) {
    nextWakeDate = [nextWakeDate dateByAddingTimeInterval:86400];
  }
  NSInteger nextWakeWeekday = [[[HCCalendarUtil currentCalendar] components:NSWeekdayCalendarUnit
                                                                   fromDate:nextWakeDate]
                               weekday] - 1;
  if (![[self.repeat objectAtIndex:nextWakeWeekday] boolValue]) {
    // increment nextWakeDate day until repeat allows it
    NSInteger weekdayModification = 0,
              numWeekdays = [[HCCalendarUtil currentCalendar] maximumRangeOfUnit:NSWeekdayCalendarUnit].length - 1;
    do {
      weekdayModification++;
    } while (![[self.repeat objectAtIndex:((nextWakeWeekday + weekdayModification) % [self.repeat count])] boolValue] &&
             weekdayModification < numWeekdays);
    if (weekdayModification == numWeekdays) {
      // repeat is all false, the alarm should not go off
      return nil;
    } else {
      nextWakeDate = [nextWakeDate dateByAddingTimeInterval:86400 * weekdayModification];
    }
  }
  return nextWakeDate;
}

- (NSDate *)previousWakeDate {
  NSDate *previousWakeDate = [[self nextWakeDate] dateByAddingTimeInterval:-86400];
  if (previousWakeDate) {
    NSInteger previousWakeWeekday = [[[HCCalendarUtil currentCalendar] components:NSWeekdayCalendarUnit
                                                                         fromDate:previousWakeDate]
                                     weekday] - 1;
    if (![[self.repeat objectAtIndex:previousWakeWeekday] boolValue]) {
      // increment nextWakeDate day until repeat allows it
      NSInteger weekdayModification = 0,
                weekdayIndex = previousWakeWeekday;
      do {
        weekdayModification++;
        weekdayIndex = previousWakeWeekday - weekdayModification;
        if (weekdayIndex < 0) weekdayIndex = (NSInteger)[self.repeat count] + weekdayIndex; // wrap around
      } while (![[self.repeat objectAtIndex:weekdayIndex] boolValue]);
      previousWakeDate = [previousWakeDate dateByAddingTimeInterval:-86400 * weekdayModification];
    }
  }
  return previousWakeDate;
}

- (NSString *)repeatAsString {
  NSMutableString *repeatString = [NSMutableString string];
  NSArray *repeat = [_attributes objectForKey:@"repeat"];
  if (!repeat) return repeatString;
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  dateFormatter.locale = [NSLocale currentLocale];
  [[dateFormatter veryShortWeekdaySymbols] enumerateObjectsUsingBlock:^(id weekday, NSUInteger index, BOOL *stop){
    if ([[repeat objectAtIndex:index] boolValue]) [repeatString appendString:weekday];
  }];
  return repeatString;
}

- (NSString *)waketimeAsString {
  if (self.waketime) {
    return [NSDateFormatter localizedStringFromDate:[[HCCalendarUtil currentCalendar] dateFromComponents:self.waketime]
                                          dateStyle:NSDateFormatterNoStyle
                                          timeStyle:NSDateFormatterShortStyle];
  } else {
    return @"";
  }
}

#pragma mark - Constructors

+ (id)alarmWithAttributes:(NSDictionary *)attributes {
  return [[self alloc] initWithAttributes:attributes];
}

- (id)initWithAttributes:(NSDictionary *)attributes {
  self = [super init];
  if (self) {
    _attributes = [NSMutableDictionary dictionary];
    if (!attributes) {
      attributes = [NSDictionary dictionary];
    }
    [self setName:[attributes objectForKey:@"name"]];
    [self setWaketime:[attributes objectForKey:@"waketime"]];
    [self setAnimalType:[[attributes objectForKey:@"animalType"] intValue]];

    NSArray *repeat = [attributes objectForKey:@"repeat"];
    if (repeat) {
      [self setRepeat:repeat];
    } else {
      NSNumber *yes = [NSNumber numberWithBool:YES];
      NSMutableArray *repeat = [NSMutableArray array];
      for (NSInteger i = 0, len = [[HCCalendarUtil currentCalendar] maximumRangeOfUnit:NSWeekdayCalendarUnit].length;
           i < len; i++) {
        [repeat setObject:yes atIndexedSubscript:i];
      }
      [self setRepeat:repeat];
    }

    NSNumber *enabled = [attributes objectForKey:@"enabled"];
    if (enabled) {
      [self setEnabled:[enabled boolValue]];
    } else {
      [self setEnabled:YES];
    }

    NSNumber *shouldDimDisplay = [attributes objectForKey:@"shouldDimDisplay"];
    if (shouldDimDisplay) {
      [self setShouldDimDisplay:[shouldDimDisplay boolValue]];
    } else {
      [self setShouldDimDisplay:YES];
    }
  }
  return self;
}

- (id)init {
  return [self initWithAttributes:nil];
}

#pragma mark - Private methods

- (NSDate *)today {
  return [NSDate date];
}

- (NSDate *)todayAtTime:(NSDateComponents *)time {
  if (time) {
    NSDateComponents *nowComponents = [[HCCalendarUtil currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                                                          fromDate:[self today]];
    [nowComponents setHour:[time hour]];
    [nowComponents setMinute:[time minute]];
    [nowComponents setSecond:[time second]];
    return [[HCCalendarUtil currentCalendar] dateFromComponents:nowComponents];
  } else {
    return nil;
  }
}

@end
