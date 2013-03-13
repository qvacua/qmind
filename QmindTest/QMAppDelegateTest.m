/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import "QMBaseTestCase.h"
#import "QMAppDelegate.h"

@interface QMAppDelegateTest : QMBaseTestCase @end

@implementation QMAppDelegateTest {
    QMAppDelegate *appDelegate;

    NSUserDefaults *userDefaults;
}

- (void)setUp {
    [super setUp];

    userDefaults = mock([NSUserDefaults class]);

    appDelegate = [[QMAppDelegate alloc] init];
    appDelegate.userDefaults = userDefaults;
}

@end

