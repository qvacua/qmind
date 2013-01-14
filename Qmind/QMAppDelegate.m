/**
 * Tae Won Ha
 * http://qvacua.com
 * https://bitbucket.org/qvacua
 *
 * See LICENSE
 */

#import "QMAppDelegate.h"

@implementation QMAppDelegate {
    __weak NSMenuItem *_insertNewChildNodeMenuItem;
    __weak NSMenuItem *_insertNewLeftChildNodeMenuItem;
}

@synthesize insertNewChildNodeMenuItem = _insertNewChildNodeMenuItem;
@synthesize insertNewLeftChildNodeMenuItem = _insertNewLeftChildNodeMenuItem;

#pragma mark NSApplicationDelegate
- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
#ifdef DEBUG
    return NO;
#else
    return YES;
#endif
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
#ifdef DEBUG
    NSString *template = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(), @"/Projects/qmind/Meta/TestFiles/%d.mm"];

    int count = 7;

    for (int i = 6; i < count; i++) {
        [[NSDocumentController sharedDocumentController]
                openDocumentWithContentsOfURL:[NSURL fileURLWithPath:[NSString stringWithFormat:template, i]]
                                      display:YES error:nil];
    }
#endif
}

@end
