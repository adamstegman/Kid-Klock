#import "HCDictionaryAlarm.h"
#import "HCStaticAssetAnimal.h"

@implementation HCDictionaryAlarm

@dynamic name;
@dynamic waketime;
@dynamic animal;
@dynamic repeat;

- (NSString *)name {
  return [_attributes objectForKey:@"name"];
}

- (void)setName:(NSString *)name {
  [_attributes setObject:[name copy] forKey:@"name"];
}

- (NSDate *)waketime {
  return [_attributes objectForKey:@"waketime"];
}

- (NSString *)waketimeAsString {
  if (self.waketime) {
    return [NSDateFormatter localizedStringFromDate:self.waketime dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
  } else {
    return @"";
  }
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

- (void)setRepeat:(NSArray *)days {
  if ([days count] == 7U) [_attributes setObject:[days copy] forKey:@"repeat"];
}

- (NSArray *)repeat {
  return [_attributes objectForKey:@"repeat"];
}

- (NSString *)repeatAsString {
  NSMutableString *repeatString = [NSMutableString string];
  NSArray *repeat = [_attributes objectForKey:@"repeat"];
  if (!repeat) return repeatString;
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  dateFormatter.locale = [NSLocale autoupdatingCurrentLocale];
  [[dateFormatter veryShortWeekdaySymbols] enumerateObjectsUsingBlock:^(id weekday, NSUInteger index, BOOL *stop){
    if ([[repeat objectAtIndex:index] boolValue]) [repeatString appendString:weekday];
  }];
  return repeatString;
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
