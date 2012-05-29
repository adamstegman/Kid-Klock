#import <UIKit/UIKit.h>
#import "HCAlarm.h"

@interface HCRepeatViewController : UITableViewController {
  NSArray *_weekdaySymbols;
}

@property (strong, nonatomic) id <HCAlarm> alarm;

@end
