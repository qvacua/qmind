/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import "QMRootNode.h"

NSString * const qNodeLeftChildrenKey = @"leftChildren";

@interface QMRootNode ()

@property (readonly) NSMutableArray *mutableLeftChildren;

@end

@implementation QMRootNode {
    NSMutableArray *_leftChildren;
}

@dynamic allChildren;
@dynamic mutableLeftChildren;

#pragma mark Public
- (QMNode *)node {
    QMNode *result = [[QMNode alloc] init];
    result.stringValue = self.stringValue;
    result.font = self.font;
    result.unsupportedChildren = [[NSMutableArray alloc] initWithArray:self.unsupportedChildren copyItems:YES];
    for (QMNode *child in self.children) {
        [result addObjectInChildren:[child copy]];
    }
    for (QMNode *child in self.leftChildren) {
        [result addObjectInChildren:[child copy]];
    }
    for (NSString *icon in self.icons) {
        [result addObjectInIcons:[icon copy]];
    }

    return result;
}

- (NSUInteger)countOfLeftChildren {
    return self.leftChildren.count;
}

- (QMNode *)objectInLeftChildrenAtIndex:(NSUInteger)index {
    return [self.leftChildren objectAtIndex:index];
}

- (void)insertObject:(QMNode *)childNode inLeftChildrenAtIndex:(NSUInteger)index {
    [[self.undoManager prepareWithInvocationTarget:self] removeObjectFromLeftChildrenAtIndex:index];

    childNode.parent = self;
    childNode.undoManager = self.undoManager;
    [self.mutableLeftChildren insertObject:childNode atIndex:index];

    [self.observerInfos enumerateObjectsUsingBlock:^(QObserverInfo *info, BOOL *stop) {
        [childNode addObserver:info.observer forKeyPath:info.keyPath];
    }];
}

- (void)removeObjectFromLeftChildrenAtIndex:(NSUInteger)index {
    QMNode *nodeToDel = [self.leftChildren objectAtIndex:index];
    nodeToDel.parent = nil;

    [[self.undoManager prepareWithInvocationTarget:self] insertObject:nodeToDel inLeftChildrenAtIndex:index];

    [self.mutableLeftChildren removeObjectAtIndex:index];

    [nodeToDel removeObserver:[[self.observerInfos anyObject] observer]];
}

- (void)addObjectInLeftChildren:(QMNode *)childNode {
    [self insertObject:childNode inLeftChildrenAtIndex:self.leftChildren.count];
}

#pragma mark QMNode
- (BOOL)isFolded {
    return NO;
}

- (void)setFolded {
    // noop
}

- (BOOL)isRoot {
    return YES;
}

- (BOOL)isLeaf {
    return self.allChildren.count == 0;
}

- (NSUInteger)countOfAllChildren {
    return self.allChildren.count;
}

- (NSArray *)allChildren {
    return [self.children arrayByAddingObjectsFromArray:self.leftChildren];
}

#pragma mark QObservedObject
- (void)addObserver:(id)observer forKeyPath:(NSString *)keyPath {
    if ([keyPath isEqualToString:qNodeLeftChildrenKey]) {
        [self addObserver:observer forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
        return;
    }

    [super addObserver:observer forKeyPath:keyPath];
}

#pragma mark NSKeyValueObservingCustomization
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    if ([key isEqualToString:qNodeLeftChildrenKey]) {
        return YES;
    }

    return [super automaticallyNotifiesObserversForKey:key];
}

#pragma mark Initializer
- (id)init {
    return [self initWithAttributes:nil];
}

- (id)initWithAttributes:(NSDictionary *)xmlAttributes {
    if ((self = [super initWithAttributes:xmlAttributes])) {
        _leftChildren = [[NSMutableArray alloc] initWithCapacity:2];
    }

    return self;
}

#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:self.leftChildren forKey:qNodeLeftChildrenArchiveKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _leftChildren = [decoder decodeObjectForKey:qNodeLeftChildrenArchiveKey];
    }

    return self;
}

#pragma mark Private
- (NSMutableArray *)mutableLeftChildren {
    @synchronized (self) {
        return _leftChildren;
    }
}

@end
