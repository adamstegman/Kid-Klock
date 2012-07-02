#import "HCWaketimeTableViewCell.h"

@implementation HCWaketimeTableViewCell

@synthesize inputAccessoryView;
@synthesize inputView;

- (BOOL)canBecomeFirstResponder {
  return YES;
}

@end
