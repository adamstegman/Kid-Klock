#import <UIKit/UIKit.h>

@interface HCAlarmTableViewCell : UITableViewCell {
  NSArray *_editTimeLabelHorizontalConstraint;
}

/**
 * The color at the top of the cell gradient.
 */
@property (strong, nonatomic) UIColor *topColor;
/**
 * The color in the middle (roughly) of the cell gradient.
 */
@property (strong, nonatomic) UIColor *middleColor;
/**
 * The color at the bottom of the cell gradient.
 */
@property (strong, nonatomic) UIColor *bottomColor;

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *repeatLabel;
@property (strong, nonatomic) IBOutlet UISwitch *enabledSwitch;

@end
