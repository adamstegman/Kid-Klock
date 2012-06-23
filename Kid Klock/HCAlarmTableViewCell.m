#import "HCAlarmTableViewCell.h"

@implementation HCAlarmTableViewCell

@synthesize labelLabel = _labelLabel;
@synthesize animalImageView = _animalImageView;
@synthesize timeLabel = _timeLabel;
@synthesize enabledSwitch = _enabledSwitch;

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
  if (editing) {
    // setup constraints
    if (!_editLabelHorizontalConstraint) {
      UIView *label = self.labelLabel;
      _editLabelHorizontalConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[label]"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:NSDictionaryOfVariableBindings(label)];
    }
    if (!_editImageHorizontalConstraint) {
      UIView *image = self.animalImageView;
      _editImageHorizontalConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[image]"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:NSDictionaryOfVariableBindings(image)];
    }

    // hide enabled switch while editing
    self.enabledSwitch.hidden = YES;
    // ensure time label does not cover animal icon in edit mode
    [self addConstraints:_editLabelHorizontalConstraint];
    [self addConstraints:_editImageHorizontalConstraint];
  } else {
    self.enabledSwitch.hidden = NO;
    if (_editImageHorizontalConstraint) {
      [self removeConstraints:_editImageHorizontalConstraint];
    }
    if (_editLabelHorizontalConstraint) {
      [self removeConstraints:_editLabelHorizontalConstraint];
    }
  }
  [super setEditing:editing animated:animated];
}

@end
