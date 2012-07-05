#import "HCResponderCell.h"

@implementation HCResponderCell

@synthesize inputAccessoryView;
@synthesize inputView;

- (BOOL)canBecomeFirstResponder {
  return YES;
}

@end
