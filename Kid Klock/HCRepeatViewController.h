#import <UIKit/UIKit.h>
#import "HCAlarmSettings.h"

@interface HCRepeatViewController : UITableViewController <HCAlarmSettings> {
  NSArray *_weekdaySymbols;
}

@end
