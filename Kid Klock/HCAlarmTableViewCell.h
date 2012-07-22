#import <UIKit/UIKit.h>

@interface HCAlarmTableViewCell : UITableViewCell {
  NSArray *_editTimeLabelHorizontalConstraint;
}

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *repeatLabel;
@property (strong, nonatomic) IBOutlet UISwitch *enabledSwitch;

@end
