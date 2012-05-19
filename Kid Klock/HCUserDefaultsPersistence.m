//
//  HCAlarmPersistence.m
//  Kid Klock
//
//  Created by Adam Stegman on 5/13/12.
//  Copyright (c) 2012 Homemade Concoctions. All rights reserved.
//

#import "HCUserDefaultsPersistence.h"

static NSString *bundleIdentifier;

@interface HCUserDefaultsPersistence ()
+ (NSString *)domain;
+ (NSDictionary *)settings;
+ (void)setSettings:(NSDictionary *)settings;
@end

@implementation HCUserDefaultsPersistence

+ (NSArray *)fetchAlarms {
  NSArray *alarmAttributes = [[[self settings] objectForKey:@"alarms"] allValues];
  NSMutableArray *alarms = [NSMutableArray array];
  if (alarmAttributes) {
    [alarmAttributes enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
      [alarms addObject:[HCDictionaryAlarm alarmWithAttributes:obj]];
    }];
  }
  return alarms;
}

+ (void)clear {
  [self setSettings:[NSDictionary dictionary]];
}

+ (void)remove:(NSString *)alarmName {
  NSMutableDictionary *alarms = [[[self settings] objectForKey:@"alarms"] mutableCopy];
  if (!alarms) {
    alarms = [NSMutableDictionary dictionary];
  }
  if ([alarms objectForKey:alarmName]) {
    [alarms removeObjectForKey:alarmName];
    [self setSettings:[NSDictionary dictionaryWithObject:alarms forKey:@"alarms"]];
  }
}

+ (void)upsert:(HCDictionaryAlarm *)alarm {
  NSMutableDictionary *alarms = [[[self settings] objectForKey:@"alarms"] mutableCopy];
  if (!alarms) {
    alarms = [NSMutableDictionary dictionary];
  }
  [alarms setObject:alarm.attributes forKey:alarm.name];
  [self setSettings:[NSDictionary dictionaryWithObject:alarms forKey:@"alarms"]];
}

+ (NSDictionary *)settings {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  return [userDefaults persistentDomainForName:[self domain]];
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
