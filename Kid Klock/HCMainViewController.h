//
//  HCMainViewController.h
//  Kid Klock
//
//  Created by Adam Stegman on 5/12/12.
//  Copyright (c) 2012 Cerner Corporation. All rights reserved.
//

#import "HCFlipsideViewController.h"

@interface HCMainViewController : UIViewController <HCFlipsideViewControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

@end
