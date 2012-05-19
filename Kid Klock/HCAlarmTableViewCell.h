//
//  HCAlarmTableViewCell.h
//  Kid Klock
//
//  Created by Adam Stegman on 5/18/12.
//  Copyright (c) 2012 Homemade Concoctions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HCAlarmTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelLabel;
@property (strong, nonatomic) IBOutlet UIImageView *animalImageView;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UISwitch *enabledSwitch;

@end
