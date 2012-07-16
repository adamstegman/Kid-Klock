#import "Kiwi.h"
#import "HCStaticAssetAnimal.h"

SPEC_BEGIN(HCStaticAssetAnimalSpec)

describe(@"HCStaticAssetAnimal", ^{

  __block HCStaticAssetAnimal *animal;

  beforeEach(^{
    animal = [[HCStaticAssetAnimal alloc] init];
  });

  describe(@"+animalWithAnimalType:", ^{
    it(@"allocates and initializes the given animal type", ^{
      animal = [HCStaticAssetAnimal animalWithType:HCBunny];
      [[animal.name should] equal:NSLocalizedString(@"animal.name.bunny", @"Bunny animal name")];
      [[theValue(animal.type) should] equal:theValue(HCBunny)];
    });
  });

  describe(@"-initWithAnimalType:", ^{
    it(@"initializes the given animal type", ^{
      animal = [[HCStaticAssetAnimal alloc] initWithType:HCBunny];
      [[animal.name should] equal:NSLocalizedString(@"animal.name.bunny", @"Bunny animal name")];
      [[theValue(animal.type) should] equal:theValue(HCBunny)];
    });
  });

  describe(@"-init", ^{
    it(@"initializes with a \"No Animal\" animal", ^{
      animal = [[HCStaticAssetAnimal alloc] init];
      [[animal.name should] equal:NSLocalizedString(@"animal.name.none", @"Name of no animal")];
      [[theValue(animal.type) should] equal:theValue(0)];
    });
  });

  describe(@"-setType:", ^{
    it(@"assigns the type and none name for the none type", ^{
      animal.type = HCNoAnimal;
      [[animal.name should] equal:NSLocalizedString(@"animal.name.none", @"Name of no animal")];
      [[theValue(animal.type) should] equal:theValue(HCNoAnimal)];
    });

    it(@"assigns the type and clock name for the clock type", ^{
      animal.type = HCClock;
      [[animal.name should] equal:NSLocalizedString(@"animal.name.clock", @"Clock (instead of an animal) name")];
      [[theValue(animal.type) should] equal:theValue(HCClock)];
    });

    it(@"assigns the type and bunny name for the bunny type", ^{
      animal.type = HCBunny;
      [[animal.name should] equal:NSLocalizedString(@"animal.name.bunny", @"Bunny animal name")];
      [[theValue(animal.type) should] equal:theValue(HCBunny)];
    });

    it(@"assigns the type and dog name for the dog type", ^{
      animal.type = HCDog;
      [[animal.name should] equal:NSLocalizedString(@"animal.name.dog", @"Dog animal name")];
      [[theValue(animal.type) should] equal:theValue(HCDog)];
    });
  });

});

SPEC_END
