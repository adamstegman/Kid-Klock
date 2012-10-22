#import <Foundation/Foundation.h>

/**
 * NSUserDefaults utility class.
 */
@interface HCUserDefaultsPersistence : NSObject {
  NSUserDefaults *_userDefaults;
}

# pragma mark - Initializers

/**
 * Wraps the given user defaults store.
 */
- (id)initWithUserDefaults:(NSUserDefaults *)userDefaults;

/**
 * Wraps +[NSUserDefaults standardUserDefaults].
 */
+ (id)standardUserDefaults;

# pragma mark - Methods

/**
 * \return the settings for the given key for the application
 */
- (id)settingsForKey:(NSString *)key;

/**
 * Persist the given setting identified by the given key for the application.
 */
- (void)setSettingsValue:(id)value forKey:(NSString *)key;

@end
