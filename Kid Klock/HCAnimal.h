#import <Foundation/Foundation.h>

typedef enum {
  HCNoAnimal,
  HCClock,
  HCBunny
} HCAnimalType;

@protocol HCAnimal <NSObject>

@property (strong, nonatomic, readonly) UIImage *icon;
@property (strong, nonatomic, readonly) NSString *name;
@property (assign, nonatomic) HCAnimalType type;

@end
