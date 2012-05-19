//
//  HCAlarmPersistence.h
//  Kid Klock
//
//  Created by Adam Stegman on 5/13/12.
//  Copyright (c) 2012 Homemade Concoctions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HCDictionaryAlarm.h"

@interface HCUserDefaultsPersistence : NSObject

/**
 * \return all persisted HCAlarm objects
 */
+ (NSArray *)fetchAlarms;

/**
 * Removes all alarms.
 */
+ (void)clear;

/**
 * Removes the alarm with the given name.
 */
+ (void)remove:(NSString *)alarmName;

/**
 * Insert or update the given alarm, using the alarm's name as the primary key.
 */
+ (void)upsert:(HCDictionaryAlarm *)alarm;

@end
