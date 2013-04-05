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

TB_MANUALWIRE(userDefaults)
TB_MANUALWIRE(mainBundle)
TB_MANUALWIRE(documentController)

#pragma mark IBActions
- (IBAction)showPreferencesWindow:(id)sender {
    [self.preferencesWindow makeKeyAndOrderFront:self];
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
    NSInteger currentVersion = [[self.mainBundle objectForInfoDictionaryKey:qBundleVersionKey] integerValue];
    [self readPreferencesWithCurrentVersion:currentVersion];

#ifdef DEBUG
    NSString *template = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(), @"/Projects/qmind/Meta/TestFiles/%d.mm"];

    int count = 7;
    for (int i = 6; i < count; i++) {
        [self.documentController openDocumentWithContentsOfURL:[NSURL fileURLWithPath:[NSString stringWithFormat:template, i]] display:YES error:nil];
    }
#endif
}

#pragma mark Private
- (void)readPreferencesWithCurrentVersion:(NSInteger)currentVersion {
    NSInteger versionOfDefaults = [self.userDefaults integerForKey:qDefaultsVersionKey];

    if (versionOfDefaults == 0) {
        // user defaults does not exist
        [self.userDefaults setInteger:currentVersion forKey:qDefaultsVersionKey];
    }
}

@end
