/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import "QMBaseTestCase.h"
#import "QMAppDelegate.h"
#import "QMUpdateManager.h"

static const int CURRENT_VERSION = 15;

@interface QMAppDelegateTest : QMBaseTestCase @end

@implementation QMAppDelegateTest {
    QMAppDelegate *appDelegate;

    NSUserDefaults *userDefaults;
    NSBundle *mainBundle;
    QMUpdateManager *updateManager;
}

- (void)setUp {
    [super setUp];

    userDefaults = mock([NSUserDefaults class]);
    mainBundle = mock([NSBundle class]);
    updateManager = mock([QMUpdateManager class]);

    appDelegate = [[QMAppDelegate alloc] init];
    appDelegate.userDefaults = userDefaults;
    appDelegate.mainBundle = mainBundle;
    appDelegate.updateManager = updateManager;

    [given([mainBundle objectForInfoDictionaryKey:qBundleVersionKey]) willReturn:@(CURRENT_VERSION)];
}

- (void)testAppFinishedLaunchingWithoutDefaults {
    [given([userDefaults integerForKey:qDefaultsVersionKey]) willReturnInteger:0];

    [appDelegate applicationDidFinishLaunching:nil];

    [verify(userDefaults) setInteger:CURRENT_VERSION forKey:qDefaultsVersionKey];
    [verify(userDefaults) setBool:YES forKey:qDefaultsAutomaticallyCheckUpdate];
    [verify(userDefaults) setObject:instanceOf([NSDate class]) forKey:qDefaultsLastUpdateCheckDate];

    [verify(updateManager) checkForUpdate];
}

@end

