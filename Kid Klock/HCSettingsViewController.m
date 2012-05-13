//
//  HCSettingsViewController.m
//  Kid Klock
//
//  Created by Adam Stegman on 5/12/12.
//  Copyright (c) 2012 Cerner Corporation. All rights reserved.
//

#import "HCSettingsViewController.h"

@interface HCSettingsViewController ()

@end

@implementation HCSettingsViewController

@synthesize delegate = _delegate;

- (void)awakeFromNib
{
  self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
      return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
  } else {
      return YES;
  }
}

#pragma mark - Actions

- (IBAction)done:(id)sender {
    [self.delegate settingsViewControllerDidFinish:self];
}

@end
