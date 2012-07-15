#import "HCDictionaryAlarm.h"
#import "HCStaticAssetAnimal.h"

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
      NSCalendar *calendar = [NSCalendar currentCalendar];
      NSDate *todayWaketime = [self todayAtTime:waketime];
      NSInteger roundingAdjustment;
      if (minuteRemainder < minuteInterval / 2.0) {
        // round down
        roundingAdjustment = -60.0 * minuteRemainder;
      } else {
        // round up
        roundingAdjustment = 60.0 * (minuteInterval - minuteRemainder);
      }
      waketime = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit)
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
  if ([days count] == [[NSCalendar currentCalendar] maximumRangeOfUnit:NSWeekdayCalendarUnit].length) {
    [_attributes setObject:[days copy] forKey:@"repeat"];
  }
}

- (BOOL)enabled {
  return [[_attributes objectForKey:@"enabled"] boolValue];
}

- (void)setEnabled:(BOOL)enabled {
  [_attributes setObject:[NSNumber numberWithBool:enabled] forKey:@"enabled"];
}

#pragma mark - Methods

- (NSDictionary *)attributes {
  return _attributes;
}

- (NSInteger)minuteInterval {
  return 5;
}

- (NSDate *)nextWakeDate {
  if (!self.enabled) {
    return nil;
  }

  NSDate *nextWakeDate = [self todayAtTime:self.waketime];
  if (nextWakeDate && [[NSDate date] earlierDate:nextWakeDate] == nextWakeDate) {
    nextWakeDate = [nextWakeDate dateByAddingTimeInterval:86400];
  }
  NSInteger nextWakeWeekday = [[[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit
                                                               fromDate:nextWakeDate]
                               weekday] - 1;
  if (![[self.repeat objectAtIndex:nextWakeWeekday] boolValue]) {
    // increment nextWakeDate day until repeat allows it
    NSInteger weekdayModification = 0,
              numWeekdays = [[NSCalendar currentCalendar] maximumRangeOfUnit:NSWeekdayCalendarUnit].length - 1;
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
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [NSDateFormatter localizedStringFromDate:[calendar dateFromComponents:self.waketime]
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
    if (attributes) {
      [self setName:[attributes objectForKey:@"name"]];
      [self setWaketime:[attributes objectForKey:@"waketime"]];
      [self setAnimalType:[[attributes objectForKey:@"animalType"] intValue]];

      NSArray *repeat = [attributes objectForKey:@"repeat"];
      if (repeat) {
        [self setRepeat:repeat];
      } else {
        NSNumber *yes = [NSNumber numberWithBool:YES];
        NSMutableArray *repeat = [NSMutableArray array];
        for (NSInteger i = 0, len = [[NSCalendar currentCalendar] maximumRangeOfUnit:NSWeekdayCalendarUnit].length; i < len; i++) {
          [repeat setObject:yes atIndexedSubscript:i];
        }
        [self setRepeat:repeat];
      }

      NSNumber *enabled = [attributes objectForKey:@"enabled"];
      if (enabled) {
        [self setEnabled:[[attributes objectForKey:@"enabled"] boolValue]];
      } else {
        [self setEnabled:YES];
      }
    }
  }
  return self;
}

- (id)init {
  return [self initWithAttributes:nil];
}

#pragma mark - Private methods

- (NSDate *)todayAtTime:(NSDateComponents *)time {
  if (time) {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *nowComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                                  fromDate:[NSDate date]];
    [nowComponents setHour:[time hour]];
    [nowComponents setMinute:[time minute]];
    [nowComponents setSecond:[time second]];
    return [calendar dateFromComponents:nowComponents];
  } else {
    return nil;
  }
}

@end
