/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import "QMManualBeanProvider.h"

@implementation QMManualBeanProvider

+ (NSArray *)beanContainers {
    static NSArray *manualBeans;

    if (manualBeans == nil) {
        manualBeans = @[
                [TBBeanContainer beanContainerWithBean:[NSFontManager sharedFontManager]]
        ];
    }

    return manualBeans;
}

@end
