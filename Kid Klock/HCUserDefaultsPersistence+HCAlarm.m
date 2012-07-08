#import "HCUserDefaultsPersistence+HCAlarm.h"

static NSString *hcAlarmSettingsKey = @"alarms";

@implementation HCUserDefaultsPersistence (HCAlarm)

+ (NSArray *)fetchAlarms {
  NSArray *alarmAttributes = [[self settingsForKey:hcAlarmSettingsKey] allValues];
  NSMutableArray *alarms = [NSMutableArray array];
  if (alarmAttributes) {
    [alarmAttributes enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
      NSMutableDictionary *alarmAttributes = [(NSDictionary *)obj mutableCopy];
      NSData *decodedWaketime = [NSKeyedUnarchiver unarchiveObjectWithData:[alarmAttributes objectForKey:@"waketime"]];
      [alarmAttributes setValue:decodedWaketime forKey:@"waketime"];
      [alarms addObject:[HCDictionaryAlarm alarmWithAttributes:alarmAttributes]];
    }];
  }
  return alarms;
}

+ (void)clearAlarms {
  [self setSettingsValue:nil forKey:hcAlarmSettingsKey];
}

+ (void)removeAlarm:(NSString *)alarmName {
  NSMutableDictionary *alarms = [[self settingsForKey:hcAlarmSettingsKey] mutableCopy];
  if (!alarms) {
    alarms = [NSMutableDictionary dictionary];
  }
  if ([alarms objectForKey:alarmName]) {
    [alarms removeObjectForKey:alarmName];
    [self setSettingsValue:alarms forKey:hcAlarmSettingsKey];
  }
}

+ (void)upsertAlarm:(HCDictionaryAlarm *)alarm {
  NSMutableDictionary *alarms = [[self settingsForKey:hcAlarmSettingsKey] mutableCopy];
  if (!alarms) {
    alarms = [NSMutableDictionary dictionary];
  }
  NSMutableDictionary *alarmAttributes = [alarm.attributes mutableCopy];
  NSData *encodedWaketime = [NSKeyedArchiver archivedDataWithRootObject:[alarmAttributes objectForKey:@"waketime"]];
  [alarmAttributes setValue:encodedWaketime forKey:@"waketime"];
  [alarms setObject:alarmAttributes forKey:alarm.name];
  [self setSettingsValue:alarms forKey:hcAlarmSettingsKey];
}

@end
