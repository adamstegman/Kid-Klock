#import "Kiwi.h"
#import "HCUserDefaultsPersistence.h"
#import "HCDictionaryAlarm.h"

SPEC_BEGIN(HCUserDefaultsPersistenceSpec)

describe(@"HCUserDefaultsPersistence", ^{
  
  __block id mockUserDefaults;
  
  beforeEach(^{
    mockUserDefaults = [NSUserDefaults mock];
    [mockUserDefaults stub:@selector(persistentDomainForName:) andReturn:[NSDictionary dictionary]];
    [mockUserDefaults stub:@selector(setPersistentDomain:forName:)];
    [NSUserDefaults stub:@selector(standardUserDefaults) andReturn:mockUserDefaults];
  });
  
  describe(@"+settingsForKey:", ^{
    it(@"returns nil if no settings exist for that key", ^{
      [[HCUserDefaultsPersistence settingsForKey:@"test"] shouldBeNil];
    });
    
    it(@"returns the stored settings value", ^{
      id value = [NSObject mockWithName:@"testValue"];
      [mockUserDefaults stub:@selector(persistentDomainForName:) andReturn:[NSDictionary dictionaryWithObject:value forKey:@"test"]];
      id fetched = [HCUserDefaultsPersistence settingsForKey:@"test"];
      [[fetched should] equal:value];
    });
  });
  
  describe(@"+setSettingsValue:forKey:", ^{
    it(@"adds the given value to the user defaults", ^{
      id value = [NSObject mockWithName:@"testValue"];
      KWCaptureSpy *domainSpy = [mockUserDefaults captureArgument:@selector(setPersistentDomain:forName:) atIndex:0];
      [HCUserDefaultsPersistence setSettingsValue:value forKey:@"test"];
      [[domainSpy.argument should] haveCountOf:1U];
      [[[domainSpy.argument objectForKey:@"test"] should] equal:value];
    });
  });
});

SPEC_END
