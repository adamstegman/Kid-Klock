#import "HCUserDefaultsAlarmPersistence.h"

static NSString *_hcAlarmSettingsKey = @"alarms";

@implementation HCUserDefaultsAlarmPersistence

- (id)initWithUserDefaults:(NSUserDefaults *)userDefaults {
  self = [super init];
  if (self) {
    _userDefaults = [[HCUserDefaultsPersistence alloc] initWithUserDefaults:userDefaults];
  }
  return self;
}

+ (id)standardUserDefaults {
  return [[self alloc] initWithUserDefaults:[NSUserDefaults standardUserDefaults]];
}

# pragma mark - HCAlarmPersistence protocol

- (NSArray *)fetchAlarms {
  NSDictionary *alarmsAttributes = [_userDefaults settingsForKey:_hcAlarmSettingsKey];
  NSMutableArray *alarms = [NSMutableArray array];
  if (alarmsAttributes) {
    [alarmsAttributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
      NSMutableDictionary *alarmAttributes = [(NSDictionary *)obj mutableCopy];
      NSData *decodedWaketime = [NSKeyedUnarchiver unarchiveObjectWithData:[alarmAttributes objectForKey:@"waketime"]];
      [alarmAttributes setValue:decodedWaketime forKey:@"waketime"];
      HCDictionaryAlarm *alarm = [HCDictionaryAlarm alarmWithAttributes:alarmAttributes];
      alarm.id = key;
      [alarms addObject:alarm];
    }];
  }
  return alarms;
}

- (void)clearAlarms {
  [_userDefaults setSettingsValue:nil forKey:_hcAlarmSettingsKey];
}

- (void)removeAlarm:(NSString *)alarmId {
  NSMutableDictionary *alarms = [[_userDefaults settingsForKey:_hcAlarmSettingsKey] mutableCopy];
  if (!alarms) {
    alarms = [NSMutableDictionary dictionary];
  }
  if ([alarms objectForKey:alarmId]) {
    [alarms removeObjectForKey:alarmId];
    [_userDefaults setSettingsValue:alarms forKey:_hcAlarmSettingsKey];
  }
}

- (void)upsertAlarm:(HCDictionaryAlarm *)alarm {
  if (alarm) {
    NSMutableDictionary *alarms = [[_userDefaults settingsForKey:_hcAlarmSettingsKey] mutableCopy];
    if (!alarms) {
      alarms = [NSMutableDictionary dictionary];
    }
    NSMutableDictionary *alarmAttributes = [alarm.attributes mutableCopy];
    if (alarm.waketime) {
      NSData *encodedWaketime = [NSKeyedArchiver archivedDataWithRootObject:[alarmAttributes objectForKey:@"waketime"]];
      [alarmAttributes setValue:encodedWaketime forKey:@"waketime"];
    }
    if (!alarm.id) {
      alarm.id = [NSString stringWithFormat:@"%u", [alarms count], nil];
    }
    [alarms setObject:alarmAttributes forKey:alarm.id];
    [_userDefaults setSettingsValue:alarms forKey:_hcAlarmSettingsKey];
  }
}

@end
