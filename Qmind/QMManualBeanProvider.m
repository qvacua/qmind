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
                [TBBeanContainer beanContainerWithBean:[NSFontManager sharedFontManager]],
                [TBBeanContainer beanContainerWithBean:[NSUserDefaults standardUserDefaults]],
                [TBBeanContainer beanContainerWithBean:[NSBundle mainBundle]],
                [TBBeanContainer beanContainerWithBean:[NSDocumentController sharedDocumentController]],
        ];
    }

    return manualBeans;
}

@end
