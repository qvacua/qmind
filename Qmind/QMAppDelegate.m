/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import "QMAppDelegate.h"
#import "TBCacao/TBCacao.h"

@implementation QMAppDelegate

TB_MANUALWIRE_WITH_INSTANCE_VAR(userDefaults, _userDefaults)
TB_MANUALWIRE_WITH_INSTANCE_VAR(mainBundle, _mainBundle)

@synthesize insertNewChildNodeMenuItem = _insertNewChildNodeMenuItem;
@synthesize insertNewLeftChildNodeMenuItem = _insertNewLeftChildNodeMenuItem;
@synthesize lastCheckedLabel = _lastCheckedLabel;
@synthesize preferencesWindow = _preferencesWindow;
@synthesize automaticUpdateCheckbox = _automaticUpdateCheckbox;

#pragma mark IBActions

- (IBAction)checkForUpdateNow:(id)sender {

}

- (IBAction)showPreferencesWindow:(id)sender {
    [self.preferencesWindow makeKeyAndOrderFront:self];
}

- (IBAction)toggleAutomaticUpdateCheck:(id)sender {

}

#pragma mark NSObject
- (id)init {
    self = [super init];
    if (self) {
        [[TBContext sharedContext] autowireSeed:self];
    }

    return self;
}


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
