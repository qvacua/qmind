/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Cocoa/Cocoa.h>

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
@property (unsafe_unretained) IBOutlet NSWindow *preferencesWindow;

- (IBAction)checkForUpdateNow:(id)sender;

@end
