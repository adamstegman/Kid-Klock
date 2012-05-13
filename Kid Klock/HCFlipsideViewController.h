//
//  HCFlipsideViewController.h
//  Kid Klock
//
//  Created by Adam Stegman on 5/12/12.
//  Copyright (c) 2012 Cerner Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HCFlipsideViewController;

@protocol HCFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(HCFlipsideViewController *)controller;
@end

@interface HCFlipsideViewController : UIViewController

@property (weak, nonatomic) id <HCFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
