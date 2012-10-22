#import "HCUbiquitousAlarmPersistence.h"

@implementation HCUbiquitousAlarmPersistence

# pragma mark - Initializers

- (id)initWithUbiquitousStore:(NSUbiquitousKeyValueStore *)store {
  self = [super init];
  if (self) {
    _store = store;
  }
  return self;
}

+ (id)defaultStore {
  return [[self alloc] initWithUbiquitousStore:[NSUbiquitousKeyValueStore defaultStore]];
}

# pragma mark - HCAlarmPersistence protocol

- (NSArray *)fetchAlarms {
  NSDictionary *alarmsAttributes = [_store dictionaryRepresentation];
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
  NSDictionary *alarmsAttributes = [_store dictionaryRepresentation];
  if (alarmsAttributes) {
    [[alarmsAttributes allKeys] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      [_store removeObjectForKey:obj];
    }];
  }
}

- (void)removeAlarm:(NSString *)alarmId {
  [_store removeObjectForKey:alarmId];
}

- (void)upsertAlarm:(HCDictionaryAlarm *)alarm {
  if (alarm) {
    NSMutableDictionary *alarmAttributes = [alarm.attributes mutableCopy];
    if (alarm.waketime) {
      NSData *encodedWaketime = [NSKeyedArchiver archivedDataWithRootObject:[alarmAttributes objectForKey:@"waketime"]];
      [alarmAttributes setValue:encodedWaketime forKey:@"waketime"];
    }
    if (!alarm.id) {
      alarm.id = (__bridge_transfer NSString*) CFUUIDCreateString(kCFAllocatorDefault, CFUUIDCreate(kCFAllocatorDefault));
    }
    [_store setDictionary:alarmAttributes forKey:alarm.id];
  }
}

@end
