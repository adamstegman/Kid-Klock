#import "HCUserDefaultsPersistence.h"

static NSString *bundleIdentifier;

@interface HCUserDefaultsPersistence()
+ (NSString *)domain;
+ (NSMutableDictionary *)settings;
+ (void)setSettings:(NSDictionary *)settings;
@end

@implementation HCUserDefaultsPersistence

#pragma mark - Methods

+ (id)settingsForKey:(NSString *)key {
  return [[self settings] objectForKey:key];
}

+ (void)setSettingsValue:(id)value forKey:(NSString *)key {
  NSMutableDictionary *settings = [self settings];
  if (value) {
    [settings setValue:value forKey:key];
  } else {
    [settings removeObjectForKey:key];
  }
  [self setSettings:settings];
}

#pragma mark - Private methods

+ (NSMutableDictionary *)settings {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  NSDictionary *settings = [userDefaults persistentDomainForName:[self domain]];
  // FIXME: test
  if (!settings) {
    settings = [NSDictionary dictionary];
  }
  return [settings mutableCopy];
}

+ (void)setSettings:(NSDictionary *)settings {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  [userDefaults setPersistentDomain:settings forName:[self domain]];
}

+ (NSString *)domain {
  if (!bundleIdentifier) {
    bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
  }
  return bundleIdentifier;
}

@end
