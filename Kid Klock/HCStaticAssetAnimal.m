//
//  HCStaticAssetAnimal.m
//  Kid Klock
//
//  Created by Adam Stegman on 5/15/12.
//  Copyright (c) 2012 Homemade Concoctions. All rights reserved.
//

#import "HCStaticAssetAnimal.h"

@implementation HCStaticAssetAnimal

@synthesize name = _name;
@dynamic type;

- (HCAnimalType)type {
  return _type;
}

- (void)setType:(HCAnimalType)type {
  _type = type;
  switch (_type) {
    case HCNoAnimal:
      _name = NSLocalizedString(@"animal.name.none", @"Name of no animal");
      break;
    case HCClock:
      _name = NSLocalizedString(@"animal.name.clock", @"Clock (instead of an animal) name");
      break;
    case HCBunny:
      _name = NSLocalizedString(@"animal.name.bunny", @"Bunny animal name");
      break;
  }
}

+ (id <HCAnimal>)animalWithType:(HCAnimalType)type {
  return [[self alloc] initWithType:type];
}

- (id <HCAnimal>)initWithType:(HCAnimalType)type {
  self = [super init];
  if (self) {
    self.type = type;
  }
  return self;
}

- (id)init {
  return [self initWithType:HCNoAnimal];
}

@end
