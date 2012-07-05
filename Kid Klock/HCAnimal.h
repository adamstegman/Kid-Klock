#import <Foundation/Foundation.h>

#define HC_ANIMAL_TYPE_COUNT 3

typedef enum {
  HCNoAnimal,
  HCClock,
  HCBunny
} HCAnimalType;

/**
 * An animal that sleeps until the HCAlarm waketime, then wakes up.
 */
@protocol HCAnimal <NSObject>

@property (strong, nonatomic, readonly) UIImage *icon;
@property (strong, nonatomic, readonly) UIImage *awakeImage;
@property (strong, nonatomic, readonly) UIImage *sleepImage;
@property (strong, nonatomic, readonly) NSString *name;
@property (assign, nonatomic) HCAnimalType type;

@end
