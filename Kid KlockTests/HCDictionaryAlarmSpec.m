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
      [[alarm.bedtime should] equal:[NSDate dateWithTimeIntervalSinceReferenceDate:5.0]];
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
      [[alarm.bedtime should] equal:[NSDate dateWithTimeIntervalSinceReferenceDate:5.0]];
      [[alarm.waketime should] equal:[NSDate dateWithTimeIntervalSinceReferenceDate:1500.0]];
      [[theValue(alarm.animalType) should] equal:theValue(HCBunny)];
      // TODO: repeatAsString
    });

    it(@"handles nil gracefully", ^{
      alarm = [[HCDictionaryAlarm alloc] initWithAttributes:nil];
      [[alarm.attributes should] beEmpty];
      [alarm.name shouldBeNil];
      [alarm.bedtime shouldBeNil];
      [alarm.waketime shouldBeNil];
      [[theValue(alarm.animalType) should] equal:theValue(0)];
      [alarm.repeatAsString shouldBeNil];
    });
  });

  describe(@"-init", ^{
    it(@"stores empty attributes", ^{
      alarm = [[HCDictionaryAlarm alloc] init];
      [[alarm.attributes should] beEmpty];
      [alarm.name shouldBeNil];
      [alarm.bedtime shouldBeNil];
      [alarm.waketime shouldBeNil];
      [[theValue(alarm.animalType) should] equal:theValue(0)];
      [alarm.repeatAsString shouldBeNil];
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

  describe(@"-bedtime", ^{
    it(@"assigns a bedtime", ^{
      NSDate *bedtime = [NSDate dateWithTimeIntervalSinceReferenceDate:5.0];
      alarm.bedtime = bedtime;
      [[alarm.bedtime should] equal:bedtime];
    });
  });

  describe(@"-waketime", ^{
    it(@"assigns a waketime", ^{
      NSDate *waketime = [NSDate dateWithTimeIntervalSinceReferenceDate:1500.0];
      alarm.waketime = waketime;
      [[alarm.waketime should] equal:waketime];
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

  // TODO: any other scenarios
  describe(@"-repeatAsString", ^{
    pending(@"prints \"every day\" if every day is selected", ^{});

    pending(@"prints \"weekends\" if both weekend days are selected", ^{});

    pending(@"prints \"weekdays\" if all weekdays are selected", ^{});

    pending(@"lists the days if no pattern applies", ^{});
  });
});

SPEC_END
