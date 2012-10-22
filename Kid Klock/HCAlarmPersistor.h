#import <Foundation/Foundation.h>
#import "HCAlarmPersistence.h"

/**
 * Coordinator class for alarm persistence. Persists alarms in each necessary data store and handles conflicts.
 */
@interface HCAlarmPersistor : NSObject <HCAlarmPersistence> {
  NSArray *_persistenceStores;
}

/**
 * Creates a persistor with the given persistence stores. They will be updated in the order they are given, and only the
 * first will be queried.
 *
 * \param persistenceStores alarm persistence stores in priority order
 */
- (id)initWithPersistenceStores:(NSArray *)persistenceStores;

# pragma mark - iCloud notifications

- (void)ubiquitousStoreDidChange:(NSNotification *)notification;

@end
