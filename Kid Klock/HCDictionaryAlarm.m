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
  if (name) {
    [_attributes setObject:[name copy] forKey:@"name"];
  }
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
  // FIXME: this is not rounding correctly?
  if (waketime) {
    // round to nearest minute interval
    NSDateComponents *waketimeComponents = [[NSCalendar currentCalendar] components:NSMinuteCalendarUnit fromDate:waketime];
    NSInteger minutes = [waketimeComponents minute];
    NSInteger minuteInterval = [self minuteInterval];
    NSInteger minuteRemainder = minutes % minuteInterval;
    if (minuteRemainder < minuteInterval / 2) {
      // round down
      waketime = [waketime dateByAddingTimeInterval:(-60 * minuteRemainder)];
    } else {
      // round up
      waketime = [waketime dateByAddingTimeInterval:(60 * (minuteInterval - minuteRemainder))];
    }
    [_attributes setObject:waketime forKey:@"waketime"];
  }
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
    _attributes = [NSMutableDictionary dictionary];
    if (attributes) {
      [self setName:[attributes objectForKey:@"name"]];
      [self setWaketime:[attributes objectForKey:@"waketime"]];
      [self setAnimalType:[[attributes objectForKey:@"animalType"] intValue]];
      [self setRepeat:[attributes objectForKey:@"repeat"]];
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

- (NSInteger)minuteInterval {
  return 5;
}

@end
