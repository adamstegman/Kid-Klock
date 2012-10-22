#import "HCAlarmPersistor.h"
#import "HCUserDefaultsAlarmPersistence.h"
#import "HCUbiquitousAlarmPersistence.h"

@implementation HCAlarmPersistor

- (id)initWithPersistenceStores:(NSArray *)persistenceStores {
  self = [super init];
  if (self) {
    if (persistenceStores) {
      _persistenceStores = [persistenceStores copy];
    } else {
      _persistenceStores = [NSArray array];
    }
  }
  return self;
}

- (id)init {
  return [self initWithPersistenceStores:[NSArray array]];
}

# pragma mark - HCAlarmPersistence protocol

- (NSArray *)fetchAlarms {
  if ([_persistenceStores count] > 0U) {
    return [[_persistenceStores objectAtIndex:0U] fetchAlarms];
  } else {
    return [NSArray array];
  }
}

- (void)clearAlarms {
  [_persistenceStores enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    [obj clearAlarms];
  }];
}

- (void)removeAlarm:(NSString *)alarmId {
  [_persistenceStores enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    [obj removeAlarm:alarmId];
  }];
}

- (void)upsertAlarm:(HCDictionaryAlarm *)alarm {
  [_persistenceStores enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    [obj upsertAlarm:alarm];
  }];
}

# pragma mark - iCloud notifications

- (void)ubiquitousStoreDidChange:(NSNotification *)notification {
  // FIXME (and test)
}

@end
