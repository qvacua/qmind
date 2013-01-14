/**
 * Tae Won Ha
 * http://qvacua.com
 * https://bitbucket.org/qvacua
 *
 * See LICENSE
 */

#import "QMRootNode.h"

@implementation QMRootNode

@dynamic allChildren;
@synthesize leftChildren = _leftChildren;

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    if ([key isEqualToString:qNodeLeftChildrenKey]) {
        return YES;
    }

    return [super automaticallyNotifiesObserversForKey:key];
}

- (BOOL)isFolded {
    return NO;
}

- (void)setFolded {
    // noop
}

- (QMNode *)node {
    QMNode *result = [[QMNode alloc] init];
    result.stringValue = self.stringValue;
    result.font = self.font;
    result.unsupportedChildren = [[NSMutableArray alloc] initWithArray:self.unsupportedChildren copyItems:YES];
    for (QMNode *child in _children) {
        [result addObjectInChildren:[child copy]];
    }
    for (QMNode *child in _leftChildren) {
        [result addObjectInChildren:[child copy]];
    }
    for (NSString *icon in _icons) {
        [result addObjectInIcons:[icon copy]];
    }

    return result;
}

- (void)addObserver:(id)observer forKeyPath:(NSString *)keyPath {
    if ([keyPath isEqualToString:qNodeLeftChildrenKey]) {
        [self addObserver:observer forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
        return;
    }

    [super addObserver:observer forKeyPath:keyPath];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:_leftChildren forKey:qNodeLeftChildrenArchiveKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _leftChildren = [decoder decodeObjectForKey:qNodeLeftChildrenArchiveKey];
    }

    return self;
}

- (BOOL)isRoot {
    return YES;
}

- (BOOL)isLeaf {
    return self.allChildren.count == 0;
}

- (NSUInteger)countOfLeftChildren {
    return _leftChildren.count;
}

- (QMNode *)objectInLeftChildrenAtIndex:(NSUInteger)index {
    return [_leftChildren objectAtIndex:index];
}

- (void)insertObject:(QMNode *)childNode inLeftChildrenAtIndex:(NSUInteger)index {
    [[_undoManager prepareWithInvocationTarget:self] removeObjectFromLeftChildrenAtIndex:index];

    childNode.parent = self;
    childNode.undoManager = _undoManager;
    [_leftChildren insertObject:childNode atIndex:index];

    [self.observerInfos enumerateObjectsUsingBlock:^(QObserverInfo *info, BOOL *stop) {
        [childNode addObserver:info.observer forKeyPath:info.keyPath];
    }];
}

- (void)removeObjectFromLeftChildrenAtIndex:(NSUInteger)index {
    QMNode *nodeToDel = [_leftChildren objectAtIndex:index];
    nodeToDel.parent = nil;

    [[_undoManager prepareWithInvocationTarget:self] insertObject:nodeToDel inLeftChildrenAtIndex:index];

    [_leftChildren removeObjectAtIndex:index];

    [nodeToDel removeObserver:[[self.observerInfos anyObject] observer]];
}

- (void)addObjectInLeftChildren:(QMNode *)childNode {
    [self insertObject:childNode inLeftChildrenAtIndex:_leftChildren.count];
}

- (NSUInteger)countOfAllChildren {
    return self.allChildren.count;
}

- (NSArray *)allChildren {
    return [_children arrayByAddingObjectsFromArray:_leftChildren];
}

- (id)init {
    return [self initWithAttributes:nil];
}

- (id)initWithAttributes:(NSDictionary *)xmlAttributes {
    if ((self = [super initWithAttributes:xmlAttributes])) {
        _leftChildren = [[NSMutableArray alloc] initWithCapacity:2];
    }

    return self;
}


@end
