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
@property (strong, nonatomic) NSDate *bedtime;
@property (strong, nonatomic) NSDate *waketime;
@property (assign, nonatomic) HCAnimalType animalType;
@property (strong, nonatomic, readonly) id <HCAnimal> animal;

/**
 * \return a string appropriate for the user interface representing which days of the week this alarm repeats on
 */
- (NSString *)repeatAsString;

/**
 * Assign which days the alarm should repeat on.
 */
- (void)setRepeatForSunday:(BOOL)sunday monday:(BOOL)monday tuesday:(BOOL)tuesday wednesday:(BOOL)wednesday
                  thursday:(BOOL)thursday friday:(BOOL)friday saturday:(BOOL)saturday;

@end
