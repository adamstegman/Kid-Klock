#import "Kiwi.h"
#import "HCUserDefaultsPersistence+HCAlarm.h"
#import "HCDictionaryAlarm.h"

SPEC_BEGIN(HCUserDefaultsPersistenceHCAlarmSpec)

describe(@"HCUserDefaultsPersistence+HCAlarm", ^{

  __block id mockUserDefaults;

  beforeEach(^{
    mockUserDefaults = [NSUserDefaults mock];
    [mockUserDefaults stub:@selector(persistentDomainForName:) andReturn:[NSDictionary dictionary]];
    [mockUserDefaults stub:@selector(setPersistentDomain:forName:)];
    [NSUserDefaults stub:@selector(standardUserDefaults) andReturn:mockUserDefaults];
  });

  describe(@"+fetchAlarms", ^{
    it(@"returns an empty array if no alarms have been upserted", ^{
      [[[HCUserDefaultsPersistence fetchAlarms] should] beEmpty];
    });

    it(@"finds all upserted alarms", ^{
      HCDictionaryAlarm *alarm1 = [HCDictionaryAlarm alarmWithAttributes:[NSDictionary dictionaryWithObject:@"testing" forKey:@"name"]];
      HCDictionaryAlarm *alarm2 = [HCDictionaryAlarm alarmWithAttributes:[NSDictionary dictionaryWithObject:@"another" forKey:@"name"]];
      NSDictionary *alarms = [NSDictionary dictionaryWithObjectsAndKeys:alarm1.attributes, alarm1.name,
                              alarm2.attributes, alarm2.name, nil];
      [mockUserDefaults stub:@selector(persistentDomainForName:) andReturn:[NSDictionary dictionaryWithObject:alarms forKey:@"alarms"]];
      NSArray *fetched = [HCUserDefaultsPersistence fetchAlarms];
      [[fetched should] haveCountOf:2];
      [[[[fetched objectAtIndex:0U] name] should] equal:@"testing"];
      [[[[fetched objectAtIndex:1U] name] should] equal:@"another"];
    });
  });

  describe(@"+clearAlarms", ^{
    it(@"removes all alarms from the user defaults", ^{
      KWCaptureSpy *domainSpy = [mockUserDefaults captureArgument:@selector(setPersistentDomain:forName:) atIndex:0];
      [HCUserDefaultsPersistence clearAlarms];
      [[domainSpy.argument should] beEmpty];
    });
  });

  describe(@"+removeAlarm:", ^{
    it(@"removes the alarm with the given name from the user defaults", ^{
      HCDictionaryAlarm *alarm1 = [HCDictionaryAlarm alarmWithAttributes:[NSDictionary dictionaryWithObject:@"testing" forKey:@"name"]];
      HCDictionaryAlarm *alarm2 = [HCDictionaryAlarm alarmWithAttributes:[NSDictionary dictionaryWithObject:@"another" forKey:@"name"]];
      NSDictionary *alarms = [NSDictionary dictionaryWithObjectsAndKeys:alarm1.attributes, alarm1.name,
                              alarm2.attributes, alarm2.name, nil];
      [mockUserDefaults stub:@selector(persistentDomainForName:) andReturn:[NSDictionary dictionaryWithObject:alarms forKey:@"alarms"]];
      KWCaptureSpy *domainSpy = [mockUserDefaults captureArgument:@selector(setPersistentDomain:forName:) atIndex:0];
      [HCUserDefaultsPersistence removeAlarm:@"another"];
      [[domainSpy.argument should] haveCountOf:1U];
      [[[domainSpy.argument objectForKey:@"alarms"] objectForKey:@"testing"] shouldNotBeNil];
    });

    it(@"does nothing if the given name does not exist", ^{
      HCDictionaryAlarm *alarm = [HCDictionaryAlarm alarmWithAttributes:[NSDictionary dictionaryWithObject:@"testing" forKey:@"name"]];
      NSDictionary *alarms = [NSDictionary dictionaryWithObjectsAndKeys:alarm.attributes, alarm.name, nil];
      [mockUserDefaults stub:@selector(persistentDomainForName:) andReturn:[NSDictionary dictionaryWithObject:alarms forKey:@"alarms"]];
      [[mockUserDefaults shouldNot] receive:@selector(setPersistentDomain:forName:)];
      [HCUserDefaultsPersistence removeAlarm:@"blah"];
    });
  });

  describe(@"+upsertAlarm:", ^{
    it(@"adds the given alarm to the user defaults", ^{
      HCDictionaryAlarm *alarm = [HCDictionaryAlarm alarmWithAttributes:[NSDictionary dictionaryWithObject:@"testing" forKey:@"name"]];
      KWCaptureSpy *domainSpy = [mockUserDefaults captureArgument:@selector(setPersistentDomain:forName:) atIndex:0];
      [HCUserDefaultsPersistence upsertAlarm:alarm];
      [[domainSpy.argument should] haveCountOf:1U];
      [[[domainSpy.argument objectForKey:@"alarms"] objectForKey:@"testing"] shouldNotBeNil];
    });

    it(@"updates an existing saved alarm", ^{
      HCDictionaryAlarm *alarm = [HCDictionaryAlarm alarmWithAttributes:[NSDictionary dictionaryWithObject:@"testing" forKey:@"name"]];
      NSDictionary *alarms = [NSDictionary dictionaryWithObjectsAndKeys:alarm.attributes, alarm.name, nil];
      [mockUserDefaults stub:@selector(persistentDomainForName:) andReturn:[NSDictionary dictionaryWithObject:alarms forKey:@"alarms"]];
      alarm.animalType = HCBunny;
      KWCaptureSpy *domainSpy = [mockUserDefaults captureArgument:@selector(setPersistentDomain:forName:) atIndex:0];
      [HCUserDefaultsPersistence upsertAlarm:alarm];
      [[domainSpy.argument should] haveCountOf:1U];
      NSLog(@"%@", [[[domainSpy.argument objectForKey:@"alarms"] objectForKey:@"testing"] description]);
      NSDictionary *bunnyAlarmAttributes = [[domainSpy.argument objectForKey:@"alarms"] objectForKey:@"testing"];
      [[[bunnyAlarmAttributes objectForKey:@"name"] should] equal:@"testing"];
      [[theValue([[bunnyAlarmAttributes objectForKey:@"animalType"] intValue]) should] equal:theValue(HCBunny)];
    });
  });
});

SPEC_END
