#import "Kiwi.h"
#import "HCUserDefaultsAlarmPersistence.h"

SPEC_BEGIN(HCUserDefaultsAlarmPersistenceSpec)

describe(@"HCUserDefaultsAlarmPersistence", ^{

  __block id mockUserDefaults;

  beforeEach(^{
    mockUserDefaults = [NSUserDefaults mock];
    [mockUserDefaults stub:@selector(persistentDomainForName:) andReturn:[NSDictionary dictionary]];
    [mockUserDefaults stub:@selector(setPersistentDomain:forName:)];
    [NSUserDefaults stub:@selector(standardUserDefaults) andReturn:mockUserDefaults];
  });

  describe(@"+fetchAlarms", ^{
    it(@"returns an empty array if no alarms have been upserted", ^{
      [[[HCUserDefaultsAlarmPersistence fetchAlarms] should] beEmpty];
    });

    it(@"finds all upserted alarms", ^{
      HCDictionaryAlarm *alarm1 = [HCDictionaryAlarm alarmWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:@"alarm1", @"name", nil]];
      HCDictionaryAlarm *alarm2 = [HCDictionaryAlarm alarmWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:@"alarm2", @"name", nil]];
      NSDictionary *alarms = [NSDictionary dictionaryWithObjectsAndKeys:alarm1.attributes, @"testing",
                              alarm2.attributes, @"another", nil];
      [mockUserDefaults stub:@selector(persistentDomainForName:) andReturn:[NSDictionary dictionaryWithObject:alarms forKey:@"alarms"]];
      NSArray *fetched = [HCUserDefaultsAlarmPersistence fetchAlarms];
      [[fetched should] haveCountOf:2];
      id <HCAlarm> alarm = [fetched objectAtIndex:0U];
      [[alarm.id should] equal:@"testing"];
      [[alarm.name should] equal:@"alarm1"];
      alarm = [fetched objectAtIndex:1U];
      [[alarm.id should] equal:@"another"];
      [[alarm.name should] equal:@"alarm2"];
    });
  });

  describe(@"+clearAlarms", ^{
    it(@"removes all alarms from the user defaults", ^{
      KWCaptureSpy *domainSpy = [mockUserDefaults captureArgument:@selector(setPersistentDomain:forName:) atIndex:0];
      [HCUserDefaultsAlarmPersistence clearAlarms];
      [[domainSpy.argument should] beEmpty];
    });
  });

  describe(@"+removeAlarm:", ^{
    it(@"removes the alarm with the given id from the user defaults", ^{
      NSDictionary *alarms = [NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionary], @"testing",
                              [NSDictionary dictionary], @"another", nil];
      [mockUserDefaults stub:@selector(persistentDomainForName:) andReturn:[NSDictionary dictionaryWithObject:alarms forKey:@"alarms"]];
      KWCaptureSpy *domainSpy = [mockUserDefaults captureArgument:@selector(setPersistentDomain:forName:) atIndex:0];
      [HCUserDefaultsAlarmPersistence removeAlarm:@"another"];
      [[domainSpy.argument should] haveCountOf:1U];
      [[[domainSpy.argument objectForKey:@"alarms"] objectForKey:@"testing"] shouldNotBeNil];
    });

    it(@"does nothing if the given name does not exist", ^{
      NSDictionary *alarms = [NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionary], @"testing", nil];
      [mockUserDefaults stub:@selector(persistentDomainForName:) andReturn:[NSDictionary dictionaryWithObject:alarms forKey:@"alarms"]];
      [[mockUserDefaults shouldNot] receive:@selector(setPersistentDomain:forName:)];
      [HCUserDefaultsAlarmPersistence removeAlarm:@"blah"];
    });
  });

  describe(@"+upsertAlarm:", ^{
    it(@"does nothing given nil", ^{
      [HCUserDefaultsAlarmPersistence upsertAlarm:nil];
    });

    it(@"adds the given alarm to the user defaults", ^{
      HCDictionaryAlarm *alarm = [[HCDictionaryAlarm alloc] init];
      alarm.id = @"testing";
      KWCaptureSpy *domainSpy = [mockUserDefaults captureArgument:@selector(setPersistentDomain:forName:) atIndex:0];
      [HCUserDefaultsAlarmPersistence upsertAlarm:alarm];
      [[domainSpy.argument should] haveCountOf:1U];
      [[[domainSpy.argument objectForKey:@"alarms"] objectForKey:@"testing"] shouldNotBeNil];
    });

    it(@"designates an incrementing identifier if the alarm does not have one", ^{
      NSDictionary *alarms = [NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionary], @"testing", nil];
      [mockUserDefaults stub:@selector(persistentDomainForName:) andReturn:[NSDictionary dictionaryWithObject:alarms forKey:@"alarms"]];
      KWCaptureSpy *domainSpy = [mockUserDefaults captureArgument:@selector(setPersistentDomain:forName:) atIndex:0];
      [HCUserDefaultsAlarmPersistence upsertAlarm:[[HCDictionaryAlarm alloc] init]];
      NSDictionary *newAlarms = [domainSpy.argument objectForKey:@"alarms"];
      [[newAlarms should] haveCountOf:2U];
      [[newAlarms objectForKey:@"testing"] shouldNotBeNil];
      [[newAlarms objectForKey:@"1"] shouldNotBeNil];
    });

    it(@"updates an existing saved alarm", ^{
      HCDictionaryAlarm *alarm = [HCDictionaryAlarm alarmWithAttributes:[NSDictionary dictionaryWithObject:@"testing" forKey:@"name"]];
      alarm.id = @"0";
      NSDictionary *alarms = [NSDictionary dictionaryWithObjectsAndKeys:alarm.attributes, alarm.id, nil];
      [mockUserDefaults stub:@selector(persistentDomainForName:) andReturn:[NSDictionary dictionaryWithObject:alarms forKey:@"alarms"]];
      alarm.animalType = HCBunny;
      KWCaptureSpy *domainSpy = [mockUserDefaults captureArgument:@selector(setPersistentDomain:forName:) atIndex:0];
      [HCUserDefaultsAlarmPersistence upsertAlarm:alarm];
      [[domainSpy.argument should] haveCountOf:1U];
      NSDictionary *bunnyAlarmAttributes = [[domainSpy.argument objectForKey:@"alarms"] objectForKey:alarm.id];
      [[[bunnyAlarmAttributes objectForKey:@"name"] should] equal:@"testing"];
      [[theValue([[bunnyAlarmAttributes objectForKey:@"animalType"] intValue]) should] equal:theValue(HCBunny)];
    });
  });
});

SPEC_END
