#import "Kiwi.h"
#import "HCDictionaryAlarm.h"

SPEC_BEGIN(HCDictionaryAlarmSpec)

describe(@"HCDictionaryAlarm", ^{

  __block HCDictionaryAlarm *alarm;

  beforeEach(^{
    alarm = [[HCDictionaryAlarm alloc] init];
  });

  describe(@"+alarmWithAttributes:", ^{
    it(@"allocates and initializes an alarm with the given attributes", ^{
      NSNumber *yes = [NSNumber numberWithBool:YES];
      NSNumber *no = [NSNumber numberWithBool:NO];
      NSDateComponents *waketime = [[NSDateComponents alloc] init];
      [waketime setHour:1];
      [waketime setMinute:0];
      NSArray *repeat = [NSArray arrayWithObjects:no, no, yes, no, no, no, no, nil];
      NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:@"testing", @"name",
                                  [NSDate dateWithTimeIntervalSinceReferenceDate:5.0], @"bedtime",
                                  waketime, @"waketime",
                                  [NSNumber numberWithInt:HCBunny], @"animalType",
                                  repeat, @"repeat",
                                  yes, @"enabled", nil];
      alarm = [HCDictionaryAlarm alarmWithAttributes:attributes];
      [[alarm.name should] equal:@"testing"];
      [[alarm.waketime should] equal:waketime];
      [[theValue(alarm.animalType) should] equal:theValue(HCBunny)];
      [[alarm.repeat should] equal:repeat];
      [[theValue(alarm.enabled) should] equal:theValue(YES)];
    });
  });

  describe(@"-initWithAttributes:", ^{
    it(@"stores the given attributes", ^{
      NSNumber *yes = [NSNumber numberWithBool:YES];
      NSNumber *no = [NSNumber numberWithBool:NO];
      NSDateComponents *waketime = [[NSDateComponents alloc] init];
      [waketime setHour:1];
      [waketime setMinute:0];
      NSArray *repeat = [NSArray arrayWithObjects:no, no, yes, no, no, no, no, nil];
      NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:@"testing", @"name",
                                  waketime, @"waketime",
                                  [NSNumber numberWithInt:HCBunny], @"animalType",
                                  repeat, @"repeat",
                                  yes, @"enabled", nil];
      alarm = [[HCDictionaryAlarm alloc] initWithAttributes:attributes];
      [[alarm.name should] equal:@"testing"];
      [[alarm.waketime should] equal:waketime];
      [[theValue(alarm.animalType) should] equal:theValue(HCBunny)];
      [[alarm.repeat should] equal:repeat];
      [[theValue(alarm.enabled) should] equal:theValue(YES)];
    });

    it(@"handles nil gracefully", ^{
      alarm = [[HCDictionaryAlarm alloc] initWithAttributes:nil];
      [alarm.name shouldBeNil];
      [alarm.waketime shouldBeNil];
      [[theValue(alarm.animalType) should] equal:theValue(0)];
      [[alarm.repeat should] haveCountOf:7U];
      [alarm.repeat enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [[obj should] beTrue];
      }];
      [[theValue(alarm.enabled) should] equal:theValue(YES)];
    });
  });

  describe(@"-init", ^{
    it(@"stores empty attributes", ^{
      alarm = [[HCDictionaryAlarm alloc] init];
      [alarm.name shouldBeNil];
      [alarm.waketime shouldBeNil];
      [[theValue(alarm.animalType) should] equal:theValue(0)];
      [[alarm.repeat should] haveCountOf:7U];
      [alarm.repeat enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [[obj should] beTrue];
      }];
    });
  });

  describe(@"-name", ^{
    it(@"copies the assigned name", ^{
      NSMutableString *name = [@"test" mutableCopy];
      alarm.name = name;
      [name appendString:@"ing"];
      [[alarm.name should] equal:@"test"];
    });
  });

  describe(@"-waketime", ^{
    it(@"rounds waketime down to the nearest minute interval", ^{
      NSDateComponents *waketime = [[NSDateComponents alloc] init];
      [waketime setHour:1];
      [waketime setMinute:2];
      alarm.waketime = waketime;
      [[theValue([alarm.waketime hour]) should] equal:theValue(1)];
      [[theValue([alarm.waketime minute]) should] equal:theValue(0)];
    });

    it(@"rounds waketime up to the nearest minute interval", ^{
      NSDateComponents *waketime = [[NSDateComponents alloc] init];
      [waketime setHour:1];
      [waketime setMinute:3];
      alarm.waketime = waketime;
      [[theValue([alarm.waketime hour]) should] equal:theValue(1)];
      [[theValue([alarm.waketime minute]) should] equal:theValue(5)];
    });
    
    it(@"rounds waketime up to the next hour if necessary", ^{
      NSDateComponents *waketime = [[NSDateComponents alloc] init];
      [waketime setHour:1];
      [waketime setMinute:58];
      alarm.waketime = waketime;
      [[theValue([alarm.waketime hour]) should] equal:theValue(2)];
      [[theValue([alarm.waketime minute]) should] equal:theValue(0)];
    });
    
    it(@"does not round waketime if not necessary", ^{
      NSDateComponents *waketime = [[NSDateComponents alloc] init];
      [waketime setHour:1];
      [waketime setMinute:5];
      alarm.waketime = waketime;
      [[theValue([alarm.waketime hour]) should] equal:theValue(1)];
      [[theValue([alarm.waketime minute]) should] equal:theValue(5)];
    });
    
    it(@"sets the seconds to 0", ^{
      NSDateComponents *waketime = [[NSDateComponents alloc] init];
      [waketime setSecond:1];
      alarm.waketime = waketime;
      [[theValue([alarm.waketime second]) should] equal:theValue(0)];
    });
    
    it(@"defaults hours and minutes to 0", ^{
      alarm.waketime = [[NSDateComponents alloc] init];
      [[theValue([alarm.waketime hour]) should] equal:theValue(0)];
      [[theValue([alarm.waketime minute]) should] equal:theValue(0)];
    });
    
    it(@"stores a nil waketime", ^{
      alarm.waketime = [[NSDateComponents alloc] init];
      alarm.waketime = nil;
      [alarm.waketime shouldBeNil];
    });
  });
  
  describe(@"-waketimeAsString", ^{
    it(@"creates a localized hour:minute string", ^{
      NSCalendar *calendar = [NSCalendar currentCalendar];
      alarm.waketime = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
      NSString *expected = [NSDateFormatter localizedStringFromDate:[calendar dateFromComponents:alarm.waketime]
                                                          dateStyle:NSDateFormatterNoStyle
                                                          timeStyle:NSDateFormatterShortStyle];
      [[[alarm waketimeAsString] should] equal:expected];
    });
    
    it(@"returns an empty string if no waketime exists", ^{
      alarm.waketime = nil;
      [[[alarm waketimeAsString] should] equal:@""];
    });
  });
  
  describe(@"-nextWakeDate", ^{
    it(@"returns the next day if waketime is before now", ^{
      NSCalendar *calendar = [NSCalendar currentCalendar];
      NSDate *now = [NSDate date];
      NSDate *past = [now dateByAddingTimeInterval:[alarm minuteInterval] * -60.0];
      alarm.waketime = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:past];
      
      NSUInteger comparableComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit);
      NSDateComponents *tomorrowAdjustment = [[NSDateComponents alloc] init];
      [tomorrowAdjustment setDay:1];
      NSDate *tomorrow = [calendar dateByAddingComponents:tomorrowAdjustment toDate:now options:0];
      NSDateComponents *tomorrowComponents = [calendar components:comparableComponents fromDate:tomorrow];
      NSDateComponents *nextWakeDateComponents = [calendar components:comparableComponents
                                                             fromDate:[alarm nextWakeDate]];
      [[theValue([nextWakeDateComponents year]) should] equal:theValue([tomorrowComponents year])];
      [[theValue([nextWakeDateComponents month]) should] equal:theValue([tomorrowComponents month])];
      [[theValue([nextWakeDateComponents day]) should] equal:theValue([tomorrowComponents day])];
      [[theValue([nextWakeDateComponents hour]) should] equal:theValue([alarm.waketime hour])];
      [[theValue([nextWakeDateComponents minute]) should] equal:theValue([alarm.waketime minute])];
      [[theValue([nextWakeDateComponents second]) should] equal:theValue([alarm.waketime second])];
    });
    
    it(@"returns the correct day if waketime is after now", ^{
      NSCalendar *calendar = [NSCalendar currentCalendar];
      NSDate *now = [NSDate date];
      NSDate *future = [now dateByAddingTimeInterval:[alarm minuteInterval] * 60.0];
      alarm.waketime = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:future];
      
      NSUInteger comparableComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit);
      NSDate *day = [now dateByAddingTimeInterval:[alarm minuteInterval] * 60.0];
      NSDateComponents *dayComponents = [calendar components:comparableComponents fromDate:day];
      NSDateComponents *nextWakeDateComponents = [calendar components:comparableComponents
                                                             fromDate:[alarm nextWakeDate]];
      [[theValue([nextWakeDateComponents year]) should] equal:theValue([dayComponents year])];
      [[theValue([nextWakeDateComponents month]) should] equal:theValue([dayComponents month])];
      [[theValue([nextWakeDateComponents day]) should] equal:theValue([dayComponents day])];
      [[theValue([nextWakeDateComponents hour]) should] equal:theValue([alarm.waketime hour])];
      [[theValue([nextWakeDateComponents minute]) should] equal:theValue([alarm.waketime minute])];
      [[theValue([nextWakeDateComponents second]) should] equal:theValue([alarm.waketime second])];
    });
    
    it(@"returns the correct day even if waketime is from a different day", ^{
      NSCalendar *calendar = [NSCalendar currentCalendar];
      NSDate *now = [NSDate date];
      NSDateComponents *anotherDayAdjustment = [[NSDateComponents alloc] init];
      [anotherDayAdjustment setDay:30];
      [anotherDayAdjustment setMinute:[alarm minuteInterval]];
      NSDate *anotherDay = [calendar dateByAddingComponents:anotherDayAdjustment
                                                     toDate:now
                                                    options:0];
      alarm.waketime = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:anotherDay];
      
      NSUInteger comparableComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit);
      NSDate *day = [now dateByAddingTimeInterval:[alarm minuteInterval] * 60.0];
      NSDateComponents *dayComponents = [calendar components:comparableComponents fromDate:day];
      NSDateComponents *nextWakeDateComponents = [calendar components:comparableComponents
                                                             fromDate:[alarm nextWakeDate]];
      [[theValue([nextWakeDateComponents year]) should] equal:theValue([dayComponents year])];
      [[theValue([nextWakeDateComponents month]) should] equal:theValue([dayComponents month])];
      [[theValue([nextWakeDateComponents day]) should] equal:theValue([dayComponents day])];
      [[theValue([nextWakeDateComponents hour]) should] equal:theValue([alarm.waketime hour])];
      [[theValue([nextWakeDateComponents minute]) should] equal:theValue([alarm.waketime minute])];
      [[theValue([nextWakeDateComponents second]) should] equal:theValue([alarm.waketime second])];
    });
    
    it(@"considers repeat days", ^{
      NSCalendar *calendar = [NSCalendar currentCalendar];
      NSDate *now = [NSDate date];
      NSDate *future = [now dateByAddingTimeInterval:[alarm minuteInterval] * 60.0];
      alarm.waketime = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:future];

      NSUInteger comparableComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit);
      NSDateComponents *nowComponents = [calendar components:(NSWeekdayCalendarUnit) fromDate:now];
      NSNumber *yes = [NSNumber numberWithBool:YES];
      NSNumber *no = [NSNumber numberWithBool:NO];
      NSMutableArray *repeat = [NSMutableArray arrayWithObjects:yes, yes, yes, yes, yes, yes, yes, nil];
      [repeat setObject:no atIndexedSubscript:[nowComponents weekday] - 1];
      alarm.repeat = repeat;
      NSDate *day = [[now dateByAddingTimeInterval:[alarm minuteInterval] * 60.0] dateByAddingTimeInterval:86400];
      NSDateComponents *dayComponents = [calendar components:comparableComponents fromDate:day];
      NSDateComponents *nextWakeDateComponents = [calendar components:comparableComponents
                                                             fromDate:[alarm nextWakeDate]];
      [[theValue([nextWakeDateComponents year]) should] equal:theValue([dayComponents year])];
      [[theValue([nextWakeDateComponents month]) should] equal:theValue([dayComponents month])];
      [[theValue([nextWakeDateComponents day]) should] equal:theValue([dayComponents day])];
      [[theValue([nextWakeDateComponents hour]) should] equal:theValue([alarm.waketime hour])];
      [[theValue([nextWakeDateComponents minute]) should] equal:theValue([alarm.waketime minute])];
      [[theValue([nextWakeDateComponents second]) should] equal:theValue([alarm.waketime second])];
    });

    it(@"returns nil if there are no repeat days", ^{
      NSNumber *no = [NSNumber numberWithBool:NO];
      alarm.repeat = [NSArray arrayWithObjects:no, no, no, no, no, no, no, nil];
      alarm.waketime = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
      [[alarm nextWakeDate] shouldBeNil];
    });

    it(@"returns nil if enabled is false", ^{
      alarm.enabled = NO;
      alarm.waketime = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
      [[alarm nextWakeDate] shouldBeNil];
    });

    it(@"returns nil if waketime is nil", ^{
      alarm.waketime = nil;
      [[alarm nextWakeDate] shouldBeNil];
    });
  });

  describe(@"-animalType", ^{
    it(@"assigns an animal type", ^{
      alarm.animalType = HCClock;
      [[theValue(alarm.animalType) should] equal:theValue(HCClock)];
    });

    it(@"returns 0 if no animal type is set", ^{
      [[theValue(alarm.animalType) should] equal:theValue(0)];
    });
  });

  describe(@"-animal", ^{
    it(@"constructs an animal from the stored type", ^{
      alarm.animalType = HCBunny;
      [[theValue(alarm.animal.type) should] equal:theValue(HCBunny)];
    });
  });

  describe(@"-repeat", ^{
    it(@"assigns an array of seven elements", ^{
      NSNumber *yes = [NSNumber numberWithBool:YES];
      NSArray *allYes = [NSArray arrayWithObjects:yes, yes, yes, yes, yes, yes, yes, nil];
      alarm.repeat = allYes;
      [[alarm.repeat should] equal:allYes];
    });

    it(@"ignores the argument if does not have seven elements", ^{
      NSArray *expected = alarm.repeat;
      alarm.repeat = [NSArray arrayWithObjects:@"", @"", @"", @"", @"", @"", nil];
      [[alarm.repeat should] equal:expected];
      alarm.repeat = [NSArray arrayWithObjects:@"", @"", @"", @"", @"", @"", @"", @"", nil];
      [[alarm.repeat should] equal:expected];
    });
  });

  describe(@"-repeatAsString", ^{
    it(@"lists the very short form of the days", ^{
      NSArray *weekdaySymbols = [[[NSDateFormatter alloc] init] veryShortWeekdaySymbols];
      NSNumber *yes = [NSNumber numberWithBool:YES];
      NSNumber *no = [NSNumber numberWithBool:NO];
      alarm.repeat = [NSArray arrayWithObjects:yes, no, yes, no, yes, no, yes, nil];
      NSString *repeatDays = [NSString stringWithFormat:@"%@%@%@%@",
                              [weekdaySymbols objectAtIndex:0],
                              [weekdaySymbols objectAtIndex:2],
                              [weekdaySymbols objectAtIndex:4],
                              [weekdaySymbols objectAtIndex:6]];
      [[[alarm repeatAsString] should] equal:repeatDays];
    });

    it(@"prints the very short form of a single day", ^{
      NSArray *weekdaySymbols = [[[NSDateFormatter alloc] init] veryShortWeekdaySymbols];
      NSNumber *yes = [NSNumber numberWithBool:YES];
      NSNumber *no = [NSNumber numberWithBool:NO];
      alarm.repeat = [NSArray arrayWithObjects:no, no, yes, no, no, no, no, nil];
      [[[alarm repeatAsString] should] equal:[weekdaySymbols objectAtIndex:2]];
    });
  });
});

SPEC_END
