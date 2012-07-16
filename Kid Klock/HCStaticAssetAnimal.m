#import "HCStaticAssetAnimal.h"

@implementation HCStaticAssetAnimal

#pragma mark - Properties

@dynamic icon;
@dynamic awakeImage;
@dynamic sleepImage;
@synthesize name = _name;
@dynamic type;

- (UIImage *)icon {
  return [UIImage imageNamed:_resourceName];
}

- (UIImage *)awakeImage {
  return [UIImage imageNamed:[_resourceName stringByAppendingString:@"-Day"]];
}

- (UIImage *)sleepImage {
  return [UIImage imageNamed:[_resourceName stringByAppendingString:@"-Night"]];
}

- (HCAnimalType)type {
  return _type;
}

- (void)setType:(HCAnimalType)type {
  _type = type;
  switch (_type) {
    case HCNoAnimal: {
      _name = NSLocalizedString(@"animal.name.none", @"Name of no animal");
      _resourceName = @"HCNoAnimal";
      break;
    }
    case HCClock: {
      _name = NSLocalizedString(@"animal.name.clock", @"Clock (instead of an animal) name");
      _resourceName = @"HCClock";
      break;
    }
    case HCBunny: {
      _name = NSLocalizedString(@"animal.name.bunny", @"Bunny animal name");
      _resourceName = @"HCBunny";
      break;
    }
    case HCDog: {
      _name = NSLocalizedString(@"animal.name.dog", @"Dog animal name");
      _resourceName = @"HCDog";
      break;
    }
  }
}

#pragma mark - Constructors

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
