/**
 * Tae Won Ha
 * http://qvacua.com
 * https://bitbucket.org/qvacua
 *
 * See LICENSE
 */

#import "QMNode.h"

static NSString * const qNonTextualNodeText = @"NON TEXTUAL NODE";
static NSString * const qTrueStringValue = @"true";

@implementation QMNode

@dynamic allChildren;
@dynamic root;
@dynamic font;
@dynamic stringValue;
@dynamic folded;
@dynamic leaf;
@dynamic undoManager;
@synthesize attributes = _attributes;
@synthesize children = _children;
@synthesize parent = _parent;
@synthesize unsupportedChildren = _unsupportedChildren;
@synthesize icons = _icons;
@synthesize createdNewly = _createdNewly;

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
        [copy addObjectInChildren:[child copy]];
    }];

    [self.icons enumerateObjectsUsingBlock:^(NSString *icon, NSUInteger index, BOOL *stop) {
        [copy addObjectInIcons:[icon copy]];
    }];

    return copy;
}

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

- (NSUndoManager *)undoManager {
    return _undoManager;
}

- (void)setUndoManager:(NSUndoManager *)anUndoManager {
    _undoManager = anUndoManager;

    if ([self isLeaf]) {
        return;
    }

    // using all children here, we're covered also for the root node
    [self.allChildren enumerateObjectsUsingBlock:^(QMNode *childNode, NSUInteger index, BOOL* stop) {
        childNode.undoManager = anUndoManager;
    }];
}

- (void)addObserver:(id)observer forKeyPath:(NSString *)keyPath {
    [super addObserver:observer forKeyPath:keyPath];

    if ([self isLeaf]) {
        return;
    }

    // using all children here, we're covered also for the root node
    [self.allChildren enumerateObjectsUsingBlock:^(QMNode *childNode, NSUInteger index, BOOL* stop) {
        [childNode addObserver:observer forKeyPath:keyPath];
    }];
}

- (void)removeObserver:(id)observer {
    [super removeObserver:observer];

    if ([self isLeaf]) {
        return;
    }

    // using all children here, we're covered also for the root node
    [self.allChildren enumerateObjectsUsingBlock:^(QMNode *childNode, NSUInteger index, BOOL* stop) {
        [childNode removeObserver:observer];
    }];
}

- (BOOL)isRoot {
    return NO;
}

- (NSArray *)allChildren {
    return _children;
}

- (NSFont *)font {
    return _font;
}

- (void)setFont:(NSFont *)aFont {
    [_undoManager registerUndoWithTarget:self selector:@selector(setFont:) object:_font];

    _font = aFont;
}

- (BOOL)isLeaf {
    return ([_children count] == 0);
}

- (QMNode *)objectInChildrenAtIndex:(NSUInteger)index {
    return _children[index];
}

- (NSUInteger)countOfChildren {
    return [_children count];
}

- (void)insertObject:(QMNode *)childNode inChildrenAtIndex:(NSUInteger)index {
    [[_undoManager prepareWithInvocationTarget:self] removeObjectFromChildrenAtIndex:index];

    childNode.parent = self;
    childNode.undoManager = _undoManager;
    [_children insertObject:childNode atIndex:index];

    [self.observerInfos enumerateObjectsUsingBlock:^(QObserverInfo *info, BOOL *stop) {
        [childNode addObserver:info.observer forKeyPath:info.keyPath];
    }];
}

- (void)removeObjectFromChildrenAtIndex:(NSUInteger)index {
    QMNode *nodeToDel = [_children objectAtIndex:index];
    nodeToDel.parent = nil;
    [[_undoManager prepareWithInvocationTarget:self] insertObject:nodeToDel inChildrenAtIndex:index];

    [_children removeObjectAtIndex:index];

    [nodeToDel removeObserver:[[self.observerInfos anyObject] observer]];
}

- (void)addObjectInChildren:(QMNode *)childNode {
    [self insertObject:childNode inChildrenAtIndex:[_children count]];
}

- (void)addObjectInIcons:(NSString *)icon {
    [self insertObject:icon inIconsAtIndex:[_icons count]];
}

- (NSUInteger)countOfIcons {
    return [_icons count];
}

- (NSString *)objectInIconsAtIndex:(NSUInteger)index {
    return _icons[index];
}

- (void)insertObject:(NSString *)iconCode inIconsAtIndex:(NSUInteger)index {
    [[_undoManager prepareWithInvocationTarget:self] removeObjectFromIconsAtIndex:index];
    [_icons insertObject:iconCode atIndex:index];
}

- (void)removeObjectFromIconsAtIndex:(NSUInteger)index {
    NSString *iconToDel = _icons[index];

    [[_undoManager prepareWithInvocationTarget:self] insertObject:iconToDel inIconsAtIndex:index];
    [_icons removeObjectAtIndex:index];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeConditionalObject:_parent forKey:qNodeParentArchiveKey];
    [coder encodeObject:_children forKey:qNodeChildrenArchiveKey];
    [coder encodeObject:_attributes forKey:qNodeAttributesArchiveKey];
    [coder encodeObject:_unsupportedChildren forKey:qNodeUnsupportedChildrenArchiveKey];
    [coder encodeObject:_font forKey:qNodeFontArchiveKey];
    [coder encodeObject:_icons forKey:qNodeIconsArchiveKey];
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
        return [self stringValue];
    }

    if ([type isEqualToString:qNodeUti]) {
        return [NSKeyedArchiver archivedDataWithRootObject:self];
    }

    return nil;
}

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

- (NSString *)stringValue {
    return self.attributes[qNodeTextAttributeKey];
}

- (void)setStringValue:(NSString *)strValue {
    [_undoManager registerUndoWithTarget:self selector:@selector(setStringValue:) object:self.stringValue];

    // if we use just strValue and not [strValue copy], sometimes, the string gets changed unexpectedly.
    // TODO: do NOT use attributes...
    _attributes[qNodeTextAttributeKey] = [strValue copy];
}

- (BOOL)isFolded {
    if ([self.attributes[qNodeFoldedAttributeKey] isEqualToString:qTrueStringValue]) {
        return YES;
    }

    return NO;
}

- (void)setFolded:(BOOL)value {
    if (value == YES) {
        _attributes[qNodeFoldedAttributeKey] = qTrueStringValue;
    } else {
        [_attributes removeObjectForKey:qNodeFoldedAttributeKey];
    }
}

- (NSString *)description {
    return [self.stringValue stringByCropping];
}

@end
