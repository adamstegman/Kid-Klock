//
//  HCMainViewController.h
//  Kid Klock
//
//  Created by Adam Stegman on 5/12/12.
//  Copyright (c) 2012 Homemade Concoctions. All rights reserved.
//

#import "HCSettingsViewController.h"

@interface HCMainViewController : UIViewController <HCSettingsViewControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *settingsPopoverController;

@end
