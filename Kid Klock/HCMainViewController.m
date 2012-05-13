//
//  HCMainViewController.m
//  Kid Klock
//
//  Created by Adam Stegman on 5/12/12.
//  Copyright (c) 2012 Homemade Concoctions. All rights reserved.
//

#import "HCMainViewController.h"

@interface HCMainViewController ()

@end

@implementation HCMainViewController

@synthesize settingsPopoverController = _settingsPopoverController;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

#pragma mark - Flipside View Controller

- (void)settingsViewControllerDidFinish:(HCSettingsViewController *)controller {
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    [self dismissModalViewControllerAnimated:YES];
  } else {
    [self.settingsPopoverController dismissPopoverAnimated:YES];
    self.settingsPopoverController = nil;
  }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
  self.settingsPopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"showSettings"]) {
    [[segue destinationViewController] setDelegate:self];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
      UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
      self.settingsPopoverController = popoverController;
      popoverController.delegate = self;
    }
  }
}

- (IBAction)togglePopover:(id)sender {
  if (self.settingsPopoverController) {
    [self.settingsPopoverController dismissPopoverAnimated:YES];
    self.settingsPopoverController = nil;
  } else {
    [self performSegueWithIdentifier:@"showSettings" sender:sender];
  }
}

@end
