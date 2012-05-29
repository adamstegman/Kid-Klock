//
//  HCAlarm.h
//  Kid Klock
//
//  Created by Adam Stegman on 5/13/12.
//  Copyright (c) 2012 Homemade Concoctions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HCAnimal.h"

/**
 * Alarm data model.
 */
@protocol HCAlarm <NSObject>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSDate *waketime;
@property (assign, nonatomic) HCAnimalType animalType;
@property (strong, nonatomic, readonly) id <HCAnimal> animal;

/**
 * Assign which days the alarm should repeat on. Does nothing if the given array does not have exactly seven elements.
 *
 * \param days BOOL values indexed to correspond to [NSDateFormatter -veryShortWeekdaySymbols].
 */
@property (copy, nonatomic) NSArray *repeat;

/**
 * \return a string appropriate for the user interface representing the waketime for this alarm
 */
- (NSString *)waketimeAsString;

/**
 * \return a string appropriate for the user interface representing which days of the week this alarm repeats on
 */
- (NSString *)repeatAsString;

@end
