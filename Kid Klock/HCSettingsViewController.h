//
//  HCSettingsViewController.h
//  Kid Klock
//
//  Created by Adam Stegman on 5/12/12.
//  Copyright (c) 2012 Homemade Concoctions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HCSettingsViewController;

@protocol HCSettingsViewControllerDelegate
- (void)settingsViewControllerDidFinish:(HCSettingsViewController *)controller;
@end

@interface HCSettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) id <HCSettingsViewControllerDelegate> settingsDelegate;
@property (strong, nonatomic) UITableView *tableView;

- (IBAction)done:(id)sender;

@end
