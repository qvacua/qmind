#import <Foundation/Foundation.h>

@interface DummyObserver : NSObject

@property(readwrite, strong) id lastObservedObj;
@property(readwrite, copy) NSString *lastKeyPath;


@end
