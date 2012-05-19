//
//  HCAnimal.h
//  Kid Klock
//
//  Created by Adam Stegman on 5/13/12.
//  Copyright (c) 2012 Cerner Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  HCNoAnimal,
  HCClock,
  HCBunny
} HCAnimalType;

@protocol HCAnimal <NSObject>

@property (strong, nonatomic, readonly) NSString *name;
@property (assign, nonatomic) HCAnimalType type;

@end
