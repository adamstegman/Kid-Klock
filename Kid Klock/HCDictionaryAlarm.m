//
//  HCAlarmData.m
//  Kid Klock
//
//  Created by Adam Stegman on 5/13/12.
//  Copyright (c) 2012 Homemade Concoctions. All rights reserved.
//

#import "HCDictionaryAlarm.h"
#import "HCStaticAssetAnimal.h"

@implementation HCDictionaryAlarm

@dynamic name;
@dynamic bedtime;
@dynamic waketime;
@dynamic animal;

- (NSString *)name {
  return [_attributes objectForKey:@"name"];
}

- (void)setName:(NSString *)name {
  [_attributes setObject:[name copy] forKey:@"name"];
}

- (NSDate *)bedtime {
  return [_attributes objectForKey:@"bedtime"];
}

- (void)setBedtime:(NSDate *)bedtime {
  [_attributes setObject:bedtime forKey:@"bedtime"];
}

- (NSDate *)waketime {
  return [_attributes objectForKey:@"waketime"];
}

- (void)setWaketime:(NSDate *)waketime {
  [_attributes setObject:waketime forKey:@"waketime"];
}

- (HCAnimalType)animalType {
  return [[_attributes objectForKey:@"animalType"] intValue];
}

- (void)setAnimalType:(HCAnimalType)animalType {
  [_attributes setObject:[NSNumber numberWithInt:animalType] forKey:@"animalType"];
}

- (id <HCAnimal>)animal {
  return [HCStaticAssetAnimal animalWithType:self.animalType];
}

- (NSString *)repeatAsString {
  // TODO
  return nil;
}

- (void)setRepeatForSunday:(BOOL)sunday monday:(BOOL)monday tuesday:(BOOL)tuesday wednesday:(BOOL)wednesday
                  thursday:(BOOL)thursday friday:(BOOL)friday saturday:(BOOL)saturday {
  // TODO
}

+ (id)alarmWithAttributes:(NSDictionary *)attributes {
  return [[self alloc] initWithAttributes:attributes];
}

- (id)initWithAttributes:(NSDictionary *)attributes {
  self = [super init];
  if (self) {
    if (attributes) {
      _attributes = [attributes mutableCopy];
    } else {
      _attributes = [NSMutableDictionary dictionary];
    }
  }
  return self;
}

- (id)init {
  return [self initWithAttributes:nil];
}

- (NSDictionary *)attributes {
  return _attributes;
}

@end
