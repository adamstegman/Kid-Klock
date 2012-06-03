#import <Foundation/Foundation.h>
#import "HCAlarm.h"

@protocol HCAlarmSettings <NSObject>

@property (strong, nonatomic) id <HCAlarm> alarm;

@end
