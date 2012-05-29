#import <UIKit/UIKit.h>

@interface HCAlarmTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelLabel;
@property (strong, nonatomic) IBOutlet UIImageView *animalImageView;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UISwitch *enabledSwitch;

@end
