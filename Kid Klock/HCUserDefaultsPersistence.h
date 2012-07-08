#import <Foundation/Foundation.h>

/**
 * NSUserDefaults persistence for objects.
 *
 * Categories on this class implement specific object persistence.
 */
@interface HCUserDefaultsPersistence : NSObject

/**
 * \return the settings for the given key for the application
 */
+ (id)settingsForKey:(NSString *)key;

/**
 * Persist the given setting identified by the given key for the application.
 */
+ (void)setSettingsValue:(id)value forKey:(NSString *)key;

@end
