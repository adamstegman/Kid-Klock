#import "HCUserDefaultsPersistence.h"

static NSString *bundleIdentifier;

@interface HCUserDefaultsPersistence()
- (NSMutableDictionary *)settings;
- (void)setSettings:(NSDictionary *)settings;
+ (NSString *)domain;
@end

@implementation HCUserDefaultsPersistence

# pragma mark - Initializers

- (id)initWithUserDefaults:(NSUserDefaults *)userDefaults {
  self = [super init];
  if (self) {
    _userDefaults = userDefaults;
  }
  return self;
}

- (id)init {
  return [self initWithUserDefaults:[NSUserDefaults standardUserDefaults]];
}

+ (id)standardUserDefaults {
  return [[self alloc] initWithUserDefaults:[NSUserDefaults standardUserDefaults]];
}

#pragma mark - Methods

- (id)settingsForKey:(NSString *)key {
  return [[self settings] objectForKey:key];
}

- (void)setSettingsValue:(id)value forKey:(NSString *)key {
  NSMutableDictionary *settings = [self settings];
  if (value) {
    [settings setValue:value forKey:key];
  } else {
    [settings removeObjectForKey:key];
  }
  [self setSettings:settings];
}

#pragma mark - Private methods

- (NSMutableDictionary *)settings {
  NSDictionary *settings = [_userDefaults persistentDomainForName:[[self class] domain]];
  if (!settings) {
    settings = [NSDictionary dictionary];
  }
  return [settings mutableCopy];
}

- (void)setSettings:(NSDictionary *)settings {
  [_userDefaults setPersistentDomain:settings forName:[[self class] domain]];
}

+ (NSString *)domain {
  if (!bundleIdentifier) {
    bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
  }
  return bundleIdentifier;
}

@end
