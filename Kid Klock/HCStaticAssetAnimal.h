//
//  HCStaticAssetAnimal.h
//  Kid Klock
//
//  Created by Adam Stegman on 5/15/12.
//  Copyright (c) 2012 Homemade Concoctions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HCAnimal.h"

@interface HCStaticAssetAnimal : NSObject <HCAnimal> {
  NSString *_name;
  HCAnimalType _type;
}

/**
 * Creates the animal corresponding with the predefined animal type.
 *
 * \param type the enumerated animal type
 * \return an animal connected to static assets
 */
+ (id <HCAnimal>)animalWithType:(HCAnimalType)type;

/**
 * Creates the animal corresponding with the predefined animal type.
 *
 * \param type the enumerated animal type
 * \return an animal connected to static assets
 */
- (id <HCAnimal>)initWithType:(HCAnimalType)type;

@end
