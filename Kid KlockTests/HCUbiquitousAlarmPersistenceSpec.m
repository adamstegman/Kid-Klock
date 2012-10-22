#import "Kiwi.h"
#import "HCUbiquitousAlarmPersistence.h"

SPEC_BEGIN(HCUbiquitousAlarmPersistenceSpec)

describe(@"HCUbiquitousAlarmPersistence", ^{

  __block id mockUbiquitousKeyValueStore;

  beforeEach(^{
    mockUbiquitousKeyValueStore = [NSUbiquitousKeyValueStore mock];
    [NSUbiquitousKeyValueStore stub:@selector(defaultStore) andReturn:mockUbiquitousKeyValueStore];
  });

  describe(@"+fetchAlarms", ^{
    it(@"returns an empty array if no alarms have been upserted", ^{
      [mockUbiquitousKeyValueStore stub:@selector(dictionaryRepresentation) andReturn:nil];
      [[[HCUbiquitousAlarmPersistence fetchAlarms] should] beEmpty];
    });

    it(@"finds all upserted alarms", ^{
      HCDictionaryAlarm *alarm1 = [HCDictionaryAlarm alarmWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:@"alarm1", @"name", nil]];
      HCDictionaryAlarm *alarm2 = [HCDictionaryAlarm alarmWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:@"alarm2", @"name", nil]];
      NSDictionary *alarms = [NSDictionary dictionaryWithObjectsAndKeys:alarm1.attributes, @"testing",
                              alarm2.attributes, @"another", nil];
      [mockUbiquitousKeyValueStore stub:@selector(dictionaryRepresentation) andReturn:alarms];
      NSArray *fetched = [HCUbiquitousAlarmPersistence fetchAlarms];
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
      HCDictionaryAlarm *alarm1 = [HCDictionaryAlarm alarmWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:@"alarm1", @"name", nil]];
      HCDictionaryAlarm *alarm2 = [HCDictionaryAlarm alarmWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:@"alarm2", @"name", nil]];
      NSDictionary *alarms = [NSDictionary dictionaryWithObjectsAndKeys:alarm1.attributes, @"testing",
                              alarm2.attributes, @"another", nil];
      [mockUbiquitousKeyValueStore stub:@selector(dictionaryRepresentation) andReturn:alarms];
      [[mockUbiquitousKeyValueStore should] receive:@selector(removeObjectForKey:) withArguments:@"testing"];
      [[mockUbiquitousKeyValueStore should] receive:@selector(removeObjectForKey:) withArguments:@"another"];
      [HCUbiquitousAlarmPersistence clearAlarms];
    });
  });

  describe(@"+removeAlarm:", ^{
    it(@"removes the alarm with the given id from the user defaults", ^{
      [[mockUbiquitousKeyValueStore should] receive:@selector(removeObjectForKey:) withArguments:@"another"];
      [HCUbiquitousAlarmPersistence removeAlarm:@"another"];
    });
  });

  describe(@"+upsertAlarm:", ^{
    it(@"does nothing given nil", ^{
      [[mockUbiquitousKeyValueStore shouldNot] receive:@selector(setDictionary:forKey:)];
      [HCUbiquitousAlarmPersistence upsertAlarm:nil];
    });

    it(@"adds the given alarm to the user defaults", ^{
      NSDictionary *alarmAttributes = [NSDictionary dictionaryWithObjectsAndKeys:@"alarm1", @"name", nil];
      HCDictionaryAlarm *alarm = [[HCDictionaryAlarm alloc] initWithAttributes:alarmAttributes];
      alarm.id = @"testing";
      KWCaptureSpy *alarmSpy = [mockUbiquitousKeyValueStore captureArgument:@selector(setDictionary:forKey:) atIndex:0U];
      KWCaptureSpy *idSpy = [mockUbiquitousKeyValueStore captureArgument:@selector(setDictionary:forKey:) atIndex:1U];
      [HCUbiquitousAlarmPersistence upsertAlarm:alarm];
      [[alarmSpy.argument should] equal:[alarm attributes]];
      [[idSpy.argument should] equal:@"testing"];
    });

    it(@"designates an identifier if the alarm does not have one", ^{
      KWCaptureSpy *idSpy = [mockUbiquitousKeyValueStore captureArgument:@selector(setDictionary:forKey:) atIndex:1U];
      [HCUbiquitousAlarmPersistence upsertAlarm:[[HCDictionaryAlarm alloc] init]];
      [[idSpy.argument shouldNot] beNil];
    });
  });
});

SPEC_END
