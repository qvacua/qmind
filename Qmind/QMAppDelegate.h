/**
 * Tae Won Ha
 * http://qvacua.com
 * https://bitbucket.org/qvacua
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

@end
