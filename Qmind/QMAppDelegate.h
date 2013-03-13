/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Cocoa/Cocoa.h>

@class QMUpdateManager;

static NSString *const qBundleVersionKey = @"CFBundleVersion";
static NSString *const qDefaultsVersionKey = @"Version";
static NSString *const qDefaultsAutomaticallyCheckUpdate = @"AutomaticallyCheckUpdate";
static NSString *const qDefaultsLastUpdateCheckDate = @"LastUpdateCheckDate";

/**
* The NSApp delegate.
*
* @implements NSApplicationDelegate
*/
@interface QMAppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSMenuItem *insertNewChildNodeMenuItem;
@property (weak) IBOutlet NSMenuItem *insertNewLeftChildNodeMenuItem;
@property (weak) IBOutlet NSButton *automaticUpdateCheckbox;
@property (weak) IBOutlet NSTextField *lastCheckedLabel;
@property (weak) IBOutlet NSTextField *versionInfoLabel;
@property (weak) IBOutlet NSButton *downloadButton;

@property (unsafe_unretained) IBOutlet NSWindow *preferencesWindow;

@property NSUserDefaults *userDefaults;
@property NSBundle *mainBundle;
@property NSDocumentController *documentController;
@property QMUpdateManager *updateManager;

- (IBAction)toggleAutomaticUpdateCheck:(id)sender;
- (IBAction)checkForUpdateNow:(id)sender;
- (IBAction)showPreferencesWindow:(id)sender;
- (IBAction)downloadNewerVersion:(id)sender;

@end
