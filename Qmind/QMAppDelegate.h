/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Cocoa/Cocoa.h>

static NSString *const qBundleVersionKey = @"CFBundleVersion";
static NSString *const qDefaultsVersionKey = @"Version";

/**
* The NSApp delegate.
*
* @implements NSApplicationDelegate
*/
@interface QMAppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSMenuItem *insertNewChildNodeMenuItem;
@property (weak) IBOutlet NSMenuItem *insertNewLeftChildNodeMenuItem;

@property (unsafe_unretained) IBOutlet NSWindow *preferencesWindow;

@property NSUserDefaults *userDefaults;
@property NSBundle *mainBundle;
@property NSDocumentController *documentController;

- (IBAction)showPreferencesWindow:(id)sender;

@end
