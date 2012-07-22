#import "HCAlarmTableViewCell.h"

#define WHITE 1.0f, 1.0f, 1.0f, 1.0f // #fff
#define LIGHT_GRAY 0.805f, 0.805f, 0.805f, 1.0f // #cecece
#define TOP_RGBA WHITE
#define MIDDLE_RGBA WHITE
#define BOTTOM_RGBA LIGHT_GRAY
#define NUM_GRADIENT_PARTS 3
#define GRADIENT_COLORS (const CGFloat[12]){TOP_RGBA, MIDDLE_RGBA, BOTTOM_RGBA}
#define GRADIENT_STOPS (const CGFloat[NUM_GRADIENT_PARTS]){0.0f, 0.33f, 1.0f}

@implementation HCAlarmTableViewCell

@synthesize nameLabel = _nameLabel;
@synthesize timeLabel = _timeLabel;
@synthesize repeatLabel = _repeatLabel;
@synthesize enabledSwitch = _enabledSwitch;

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();

  CGContextSaveGState(context);
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace,
      GRADIENT_COLORS, GRADIENT_STOPS, NUM_GRADIENT_PARTS);

  CGContextDrawLinearGradient(context,
                              gradient,
                              CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMinY(self.bounds)),
                              CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMaxY(self.bounds)),
                              0);

  CGColorSpaceRelease(colorSpace);
  CGContextRestoreGState(context);
  [super drawRect:rect];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
  if (editing) {
    // setup constraints
    if (!_editTimeLabelHorizontalConstraint) {
      UIView *label = self.timeLabel;
      _editTimeLabelHorizontalConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[label]"
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:NSDictionaryOfVariableBindings(label)];
    }

    // hide enabled switch while editing
    self.enabledSwitch.hidden = YES;
    // ensure edit control does not cover labels in edit mode
    [self addConstraints:_editTimeLabelHorizontalConstraint];
  } else {
    self.enabledSwitch.hidden = NO;
    if (_editTimeLabelHorizontalConstraint) {
      [self removeConstraints:_editTimeLabelHorizontalConstraint];
    }
  }
  [super setEditing:editing animated:animated];
}

@end
