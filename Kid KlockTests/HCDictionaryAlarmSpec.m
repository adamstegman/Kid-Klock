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
      NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:@"testing", @"name",
                                  [NSDate dateWithTimeIntervalSinceReferenceDate:5.0], @"bedtime",
                                  [NSDate dateWithTimeIntervalSinceReferenceDate:1500.0], @"waketime",
                                  [NSNumber numberWithInt:HCBunny], @"animalType",
                                  [NSNumber numberWithInt:0x55], @"repeat", nil];
      alarm = [HCDictionaryAlarm alarmWithAttributes:attributes];
      [[alarm.name should] equal:@"testing"];
      [[alarm.waketime should] equal:[NSDate dateWithTimeIntervalSinceReferenceDate:1500.0]];
      [[theValue(alarm.animalType) should] equal:theValue(HCBunny)];
      // TODO: repeatAsString
    });
  });

  describe(@"-initWithAttributes:", ^{
    it(@"stores the given attributes", ^{
      NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:@"testing", @"name",
                                  [NSDate dateWithTimeIntervalSinceReferenceDate:5.0], @"bedtime",
                                  [NSDate dateWithTimeIntervalSinceReferenceDate:1500.0], @"waketime",
                                  [NSNumber numberWithInt:HCBunny], @"animalType",
                                  [NSNumber numberWithInt:0x55], @"repeat", nil];
      alarm = [[HCDictionaryAlarm alloc] initWithAttributes:attributes];
      [[alarm.name should] equal:@"testing"];
      [[alarm.waketime should] equal:[NSDate dateWithTimeIntervalSinceReferenceDate:1500.0]];
      [[theValue(alarm.animalType) should] equal:theValue(HCBunny)];
      // TODO: repeatAsString
    });

    it(@"handles nil gracefully", ^{
      alarm = [[HCDictionaryAlarm alloc] initWithAttributes:nil];
      [[alarm.attributes should] beEmpty];
      [alarm.name shouldBeNil];
      [alarm.waketime shouldBeNil];
      [[theValue(alarm.animalType) should] equal:theValue(0)];
      [[alarm.repeatAsString should] equal:@""];
    });
  });

  describe(@"-init", ^{
    it(@"stores empty attributes", ^{
      alarm = [[HCDictionaryAlarm alloc] init];
      [[alarm.attributes should] beEmpty];
      [alarm.name shouldBeNil];
      [alarm.waketime shouldBeNil];
      [[theValue(alarm.animalType) should] equal:theValue(0)];
      [[alarm.repeatAsString should] equal:@""];
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
    it(@"assigns a waketime", ^{
      NSDate *waketime = [NSDate dateWithTimeIntervalSinceReferenceDate:1500.0];
      alarm.waketime = waketime;
      [[alarm.waketime should] equal:waketime];
    });
  });
  
  describe(@"-waketimeAsString", ^{
    pending(@"prints a 12-hour time correctly", ^{});
    
    pending(@"prints a 24-hour time correctly", ^{});
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
      alarm.repeat = [NSArray arrayWithObjects:@"", @"", @"", @"", @"", @"", nil];
      [alarm.repeat shouldBeNil];
      alarm.repeat = [NSArray arrayWithObjects:@"", @"", @"", @"", @"", @"", @"", @"", nil];
      [alarm.repeat shouldBeNil];
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

    it(@"prints an empty string if no days are selected", ^{
      alarm.repeat = [NSArray array];
      [[[alarm repeatAsString] should] equal:@""];
    });

    it(@"prints an empty string if repeat is nil", ^{
      alarm.repeat = nil;
      [[[alarm repeatAsString] should] equal:@""];
    });
  });
});

SPEC_END
