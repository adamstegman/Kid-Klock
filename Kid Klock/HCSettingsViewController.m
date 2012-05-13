//
//  HCSettingsViewController.m
//  Kid Klock
//
//  Created by Adam Stegman on 5/12/12.
//  Copyright (c) 2012 Homemade Concoctions. All rights reserved.
//

#import "HCSettingsViewController.h"

@interface HCSettingsViewController ()

@end

@implementation HCSettingsViewController

@synthesize delegate = _delegate;

#pragma mark - View lifecycle

- (void)awakeFromNib {
  self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
  [super awakeFromNib];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

#pragma mark - Actions

- (IBAction)done:(id)sender {
    [self.delegate settingsViewControllerDidFinish:self];
}

@end
