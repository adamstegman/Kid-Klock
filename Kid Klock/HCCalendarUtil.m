#import "HCCalendarUtil.h"

static NSCalendar *_calendar = nil;

@implementation HCCalendarUtil

+ (NSCalendar *)currentCalendar {
  if (!_calendar) {
    _calendar = [NSCalendar autoupdatingCurrentCalendar];
  }
  return _calendar;
}

+ (void)clean {
  _calendar = nil;
}

@end
