/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <objc/runtime.h>
#import <TBCacao/TBCacao.h>
#import "QMBaseTestCase.h"

@implementation QMBaseTestCase {
    Method _originalMethod;
    IMP _originalImpl;
}

- (void)setUp {
    [self exchangeSharedInstanceMethod];
}

- (void)tearDown {
    method_setImplementation(_originalMethod, _originalImpl);
}

- (void)exchangeSharedInstanceMethod {
    Method testMethod = class_getInstanceMethod([self class], @selector(context));
    IMP testImpl = method_getImplementation(testMethod);

    _originalMethod = class_getClassMethod([TBContext class], @selector(sharedContext));
    _originalImpl = method_setImplementation(_originalMethod, testImpl);
}

+ (TBContext *)context {
    return nil;
}

@end
