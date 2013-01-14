/**
 * Tae Won Ha
 * http://qvacua.com
 * https://bitbucket.org/qvacua
 *
 * See LICENSE
 */

#import <Qkit/Qkit.h>
#import <objc/runtime.h>
#import <TBCacao/TBCacao.h>
#import "QMCacaoTestCase.h"

static TBContext *_context;

@implementation QMCacaoTestCase {
    Method _originalMethod;

    NSMutableDictionary *beansBackup;
    IMP _originalImpl;
}

@dynamic context;

- (void)setUp {
    if (_context == nil) {
        _context = [[TBContext alloc] init];
        [_context initContext];
    }

    [self exchangeSharedInstanceMethod];

    beansBackup = [[NSMutableDictionary alloc] init];
}

- (void)tearDown {
    method_setImplementation(_originalMethod, _originalImpl);

    [beansBackup enumerateKeysAndObjectsUsingBlock:^(NSString *identifier, id targetSource, BOOL *stop) {
        [self.context replaceBeanWithIdentifier:identifier withBean:targetSource];
    }];
}

- (void)replaceBeans:(NSArray *)targetSources {
    for (id targetSource in targetSources) {
        NSString *identifier;

        if ([[targetSource class] isEqual:[MKTObjectMock class]]) {
            identifier = [[targetSource mockedClass] description];
        } else {
            identifier = [[targetSource class] description];
        }

        beansBackup[identifier] = [self.context beanWithIdentifier:identifier];

        [self.context replaceBeanWithIdentifier:identifier withBean:targetSource];
    }
}

- (TBContext *)context {
    return _context;
}

- (void)exchangeSharedInstanceMethod {
    Method testMethod = class_getInstanceMethod([self class], @selector(context));
    IMP testImpl = method_getImplementation(testMethod);

    _originalMethod = class_getClassMethod([TBContext class], @selector(sharedContext));
    _originalImpl = method_setImplementation(_originalMethod, testImpl);
}

+ (TBContext *)context {
    return _context;
}

@end
