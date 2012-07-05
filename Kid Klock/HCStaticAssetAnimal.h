#import <Foundation/Foundation.h>
#import "HCAnimal.h"

/**
 * An HCAnimal whose images are backed by static assets in the bundle.
 */
@interface HCStaticAssetAnimal : NSObject <HCAnimal> {
  NSString *_name;
  NSString *_resourceName;
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
