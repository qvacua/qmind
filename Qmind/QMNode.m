/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import "QMNode.h"

NSString *const qNodeIdAttributeKey = @"ID";
NSString *const qNodeTextAttributeKey = @"TEXT";
NSString *const qNodeFoldedAttributeKey = @"FOLDED";
NSString *const qNodePositionAttributeKey = @"POSITION";

NSString *const qNodeParentArchiveKey = @"parent";
NSString *const qNodeChildrenArchiveKey = @"children";
NSString *const qNodeLeftChildrenArchiveKey = @"leftChildren";
NSString *const qNodeAttributesArchiveKey = @"attributes";
NSString *const qNodeUnsupportedChildrenArchiveKey = @"unsupportedChildren";
NSString *const qNodeFontArchiveKey = @"font";
NSString *const qNodeIconsArchiveKey = @"icons";

NSString *const qNodeUti = @"com.qvacua.mindmap.node";

NSString *const qNodeStringValueKey = @"stringValue";
NSString *const qNodeChildrenKey = @"children";
NSString *const qNodeFontKey = @"font";
NSString *const qNodeIconsKey = @"icons";
NSString *const qNodeFoldingKey = @"folded";

NSString *const qNonTextualNodeText = @"NON TEXTUAL NODE";
NSString *const qTrueStringValue = @"true";

@interface QMNode ()

@property(readonly) NSMutableArray *mutableChildren;
@property(readonly) NSMutableArray *mutableIcons;
@property(readonly) NSMutableDictionary *mutableAttributes;

@end

@implementation QMNode {
    NSMutableDictionary *_attributes;

    NSMutableArray *_children;
    NSMutableArray *_icons;

    NSFont *_font;
    __weak NSUndoManager *_undoManager;
}

@dynamic allChildren;
@dynamic root;
@dynamic font;
@dynamic nodeId;
@dynamic stringValue;
@dynamic folded;
@dynamic leaf;
@dynamic undoManager;
@dynamic mutableIcons;
@dynamic mutableChildren;
@dynamic mutableAttributes;

#pragma mark Public
- (NSUndoManager *)undoManager {
    @synchronized (self) {
        return _undoManager;
    }
}

- (void)setUndoManager:(NSUndoManager *)anUndoManager {
    @synchronized (self) {
        _undoManager = anUndoManager;
    }

    if (self.leaf) {
        return;
    }

    // using all children here, we've covered also the root node
    [self.allChildren enumerateObjectsUsingBlock:^(QMNode *childNode, NSUInteger index, BOOL *stop) {
        childNode.undoManager = anUndoManager;
    }];
}

- (BOOL)isRoot {
    return NO;
}

- (NSArray *)allChildren {
    @synchronized (self) {
        return _children;
    }
}

- (NSFont *)font {
    @synchronized (self) {
        return _font;
    }
}

- (void)setFont:(NSFont *)aFont {
    @synchronized (self) {
        [self.undoManager registerUndoWithTarget:self selector:@selector(setFont:) object:self.font];
        _font = aFont;
    }
}

- (BOOL)isLeaf {
    return (self.children.count == 0);
}

- (QMNode *)objectInChildrenAtIndex:(NSUInteger)index {
    return self.children[index];
}

- (NSUInteger)countOfChildren {
    return self.children.count;
}

- (void)insertObject:(QMNode *)childNode inChildrenAtIndex:(NSUInteger)index {
    [[self.undoManager prepareWithInvocationTarget:self] removeObjectFromChildrenAtIndex:index];

    childNode.parent = self;
    childNode.undoManager = self.undoManager;
    [self.mutableChildren insertObject:childNode atIndex:index];

    [self.observerInfos enumerateObjectsUsingBlock:^(QObserverInfo *info, BOOL *stop) {
        [childNode addObserver:info.observer forKeyPath:info.keyPath];
    }];
}

- (void)removeObjectFromChildrenAtIndex:(NSUInteger)index {
    QMNode *nodeToDel = self.children[index];
    nodeToDel.parent = nil;
    [[self.undoManager prepareWithInvocationTarget:self] insertObject:nodeToDel inChildrenAtIndex:index];

    [self.mutableChildren removeObjectAtIndex:index];

    [nodeToDel removeObserver:[self.observerInfos.anyObject observer]];
}

- (void)addObjectInChildren:(QMNode *)childNode {
    [self insertObject:childNode inChildrenAtIndex:self.children.count];
}

- (void)addObjectInIcons:(NSString *)icon {
    [self insertObject:icon inIconsAtIndex:self.icons.count];
}

- (NSUInteger)countOfIcons {
    return self.icons.count;
}

- (NSString *)objectInIconsAtIndex:(NSUInteger)index {
    return self.icons[index];
}

- (void)insertObject:(NSString *)iconCode inIconsAtIndex:(NSUInteger)index {
    [[self.undoManager prepareWithInvocationTarget:self] removeObjectFromIconsAtIndex:index];
    [self.mutableIcons insertObject:iconCode atIndex:index];
}

- (void)removeObjectFromIconsAtIndex:(NSUInteger)index {
    NSString *iconToDel = self.icons[index];

    [[self.undoManager prepareWithInvocationTarget:self] insertObject:iconToDel inIconsAtIndex:index];
    [self.mutableIcons removeObjectAtIndex:index];
}

- (NSString *)nodeId {
    return self.attributes[qNodeIdAttributeKey];
}

- (void)setNodeId:(NSString *)aNodeId {
    self.mutableAttributes[qNodeIdAttributeKey] = aNodeId.copy;
}

- (NSString *)stringValue {
    return self.attributes[qNodeTextAttributeKey];
}

- (void)setStringValue:(NSString *)strValue {
    [self.undoManager registerUndoWithTarget:self selector:@selector(setStringValue:) object:self.stringValue];

    // if we use just strValue and not [strValue copy], sometimes, the string gets changed unexpectedly.
    // TODO: do NOT use attributes...
    self.mutableAttributes[qNodeTextAttributeKey] = strValue.copy;
}

- (BOOL)isFolded {
    if ([self.attributes[qNodeFoldedAttributeKey] isEqualToString:qTrueStringValue]) {
        return YES;
    }

    return NO;
}

- (void)setFolded:(BOOL)value {
    if (value == YES) {
        self.mutableAttributes[qNodeFoldedAttributeKey] = qTrueStringValue;
    } else {
        [self.mutableAttributes removeObjectForKey:qNodeFoldedAttributeKey];
    }
}

#pragma mark NSObject
- (NSString *)description {
    return self.stringValue.stringByCropping;
}

#pragma mark NSPasteboardWriting
- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
    static NSArray *writableTypes = nil;

    if (writableTypes == nil) {
        // UTF-8 string is cheaper to create.
        // The full node object will be lazily created.
        writableTypes = @[NSPasteboardTypeString, qNodeUti];
    }

    return writableTypes;
}

- (NSPasteboardWritingOptions)writingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard {
    if ([type isEqualToString:qNodeUti]) {
        return NSPasteboardWritingPromised;
    }

    return 0;
}

- (id)pasteboardPropertyListForType:(NSString *)type {
    if ([type isEqualToString:NSPasteboardTypeString]) {
        return self.stringValue;
    }

    if ([type isEqualToString:qNodeUti]) {
        return [NSKeyedArchiver archivedDataWithRootObject:self];
    }

    return nil;
}

#pragma mark NSPasteboardReading
+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard {
    static NSArray *readableTypes = nil;

    if (readableTypes == nil) {
        readableTypes = @[qNodeUti];
    }

    return readableTypes;
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard {
    if ([type isEqualToString:qNodeUti]) {
        return NSPasteboardReadingAsKeyedArchive;
    }

    return NSPasteboardReadingAsData;
}

#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeConditionalObject:self.parent forKey:qNodeParentArchiveKey];
    [coder encodeObject:self.children forKey:qNodeChildrenArchiveKey];
    [coder encodeObject:self.attributes forKey:qNodeAttributesArchiveKey];
    [coder encodeObject:self.unsupportedChildren forKey:qNodeUnsupportedChildrenArchiveKey];
    [coder encodeObject:self.font forKey:qNodeFontArchiveKey];
    [coder encodeObject:self.icons forKey:qNodeIconsArchiveKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _parent = [decoder decodeObjectForKey:qNodeParentArchiveKey];
        _children = [decoder decodeObjectForKey:qNodeChildrenArchiveKey];
        _attributes = [decoder decodeObjectForKey:qNodeAttributesArchiveKey];
        _unsupportedChildren = [decoder decodeObjectForKey:qNodeUnsupportedChildrenArchiveKey];
        _font = [decoder decodeObjectForKey:qNodeFontArchiveKey];
        _icons = [decoder decodeObjectForKey:qNodeIconsArchiveKey];
    }

    return self;
}

#pragma mark NSKeyValueObservingCustomization
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    if ([key isEqualToString:qNodeStringValueKey]
            || [key isEqualToString:qNodeChildrenKey]
            || [key isEqualToString:qNodeIconsKey]
            || [key isEqualToString:qNodeFontKey]
            || [key isEqualToString:qNodeFoldingKey]) {
        return YES;
    }

    return NO;
}

#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)zone {
    QMNode *copy = [[QMNode alloc] init];
    copy.stringValue = self.stringValue;
    copy.folded = self.folded;
    copy.unsupportedChildren = [[NSMutableArray alloc] initWithArray:self.unsupportedChildren copyItems:YES];
    copy.font = self.font;

    /**
     * using all children here and adding all to children, ie right children because even when the root node gets copied,
     * when pasted, it won't be a root node anymore
     */
    [self.allChildren enumerateObjectsUsingBlock:^(QMNode *child, NSUInteger index, BOOL *stop) {
        [copy addObjectInChildren:child.copy];
    }];

    [self.icons enumerateObjectsUsingBlock:^(NSString *icon, NSUInteger index, BOOL *stop) {
        [copy addObjectInIcons:icon.copy];
    }];

    return copy;
}

#pragma mark QObservedObject
- (void)addObserver:(id)observer forKeyPath:(NSString *)keyPath {
    [super addObserver:observer forKeyPath:keyPath];

    if (self.leaf) {
        return;
    }

    // using all children here, we're covered also for the root node
    [self.allChildren enumerateObjectsUsingBlock:^(QMNode *childNode, NSUInteger index, BOOL *stop) {
        [childNode addObserver:observer forKeyPath:keyPath];
    }];
}

- (void)removeObserver:(id)observer {
    [super removeObserver:observer];

    if (self.leaf) {
        return;
    }

    // using all children here, we're covered also for the root node
    [self.allChildren enumerateObjectsUsingBlock:^(QMNode *childNode, NSUInteger index, BOOL *stop) {
        [childNode removeObserver:observer];
    }];
}

#pragma mark Initializer
- (id)init {
    return [self initWithAttributes:nil];
}

- (id)initWithAttributes:(NSDictionary *)xmlAttributes {
    if ((self = [super init])) {
        _children = [[NSMutableArray alloc] initWithCapacity:5];
        _icons = [[NSMutableArray alloc] initWithCapacity:1];

        if (xmlAttributes == nil) {
            _attributes = [[NSMutableDictionary alloc] initWithCapacity:2];
        } else {
            _attributes = [[NSMutableDictionary alloc] initWithDictionary:xmlAttributes];
        }

        _unsupportedChildren = [[NSMutableArray alloc] initWithCapacity:5];

        // TODO: Remove this when other node contents are ready
        if ([xmlAttributes objectForKey:qNodeTextAttributeKey] == nil) {
            [_attributes setObject:qNonTextualNodeText forKey:qNodeTextAttributeKey];
        }
    }

    return self;
}

#pragma mark Private
- (NSMutableArray *)mutableIcons {
    @synchronized (self) {
        return _icons;
    }
}

- (NSMutableArray *)mutableChildren {
    @synchronized (self) {
        return _children;
    }
}

- (NSMutableDictionary *)mutableAttributes {
    @synchronized (self) {
        return _attributes;
    }
}

@end
