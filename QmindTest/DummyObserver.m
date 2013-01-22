/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import "DummyObserver.h"

@implementation DummyObserver {
@private
    id _lastObservedObj;
    NSString *_lastKeyPath;
}

@synthesize lastObservedObj = _lastObservedObj;
@synthesize lastKeyPath = _lastKeyPath;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    _lastObservedObj = object;
    _lastKeyPath = keyPath;
}

@end
