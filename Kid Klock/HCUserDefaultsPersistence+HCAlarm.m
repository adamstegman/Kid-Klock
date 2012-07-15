#import "HCUserDefaultsPersistence+HCAlarm.h"

static NSString *hcAlarmSettingsKey = @"alarms";

@implementation HCUserDefaultsPersistence (HCAlarm)

+ (NSArray *)fetchAlarms {
  NSDictionary *alarmsAttributes = [self settingsForKey:hcAlarmSettingsKey];
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

+ (void)clearAlarms {
  [self setSettingsValue:nil forKey:hcAlarmSettingsKey];
}

+ (void)removeAlarm:(NSString *)alarmId {
  NSMutableDictionary *alarms = [[self settingsForKey:hcAlarmSettingsKey] mutableCopy];
  if (!alarms) {
    alarms = [NSMutableDictionary dictionary];
  }
  if ([alarms objectForKey:alarmId]) {
    [alarms removeObjectForKey:alarmId];
    [self setSettingsValue:alarms forKey:hcAlarmSettingsKey];
  }
}

+ (void)upsertAlarm:(HCDictionaryAlarm *)alarm {
  if (alarm) {
    NSMutableDictionary *alarms = [[self settingsForKey:hcAlarmSettingsKey] mutableCopy];
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
    [self setSettingsValue:alarms forKey:hcAlarmSettingsKey];
  }
}

@end
