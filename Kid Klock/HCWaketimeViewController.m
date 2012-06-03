#import "HCWaketimeViewController.h"

@interface HCWaketimeViewController ()
- (void)initWaketime;
- (void)setWaketime:(NSDate *)waketime;
@end

@implementation HCWaketimeViewController

@synthesize alarm = _alarm;
@synthesize timePicker = _timePicker;

#pragma mark - Methods

- (void)initWaketime {
  if (!self.alarm.waketime) {
    self.alarm.waketime = [NSDate dateWithTimeIntervalSinceNow:0];
  }
  [self.timePicker setDate:self.alarm.waketime animated:YES];
}

- (void)setWaketime:(NSDate *)waketime {
  self.alarm.waketime = waketime;
}

- (void)waketimeDidUpdate:(id)sender {
  UIDatePicker *timePicker = (UIDatePicker *)sender;
  [self setWaketime:timePicker.date];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
  self.timePicker.minuteInterval = [self.alarm minuteInterval];
  // date pickers do not have delegates, so force its hand
  [self.timePicker addTarget:self action:@selector(waketimeDidUpdate:) forControlEvents:UIControlEventValueChanged];
  [super viewDidLoad];
}

- (void)viewDidUnload {
  self.timePicker = nil;
  [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
  [self initWaketime];
  [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  // TODO
  return YES;
}

@end
