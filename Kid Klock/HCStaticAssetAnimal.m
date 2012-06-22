#import "HCStaticAssetAnimal.h"

@implementation HCStaticAssetAnimal

@dynamic icon;
@synthesize name = _name;
@dynamic type;

- (UIImage *)icon {
  NSString *resource = nil;
  switch (_type) {
    case HCNoAnimal:
      resource = @"HCNoAnimal";
      break;
    default:
      return nil;
  }
  return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:resource ofType:@"png"]];
}

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
