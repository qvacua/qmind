/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <TBCacao/TBCacao.h>
#import "QMDocument.h"
#import "QMNode.h"
#import "QMDocumentWindowController.h"
#import "QMMindmapReader.h"
#import "QMMindmapWriter.h"
#import "QMRootNode.h"
#import "QMAppSettings.h"
#import "QMCell.h"

static NSString *const qDocumentNibName = @"Document";

@interface QMDocument ()

@property(weak) NSPasteboard *pasteboard;
@property QMRootNode *rootNode;

@end

@implementation QMDocument

TB_MANUALWIRE(settings)
TB_MANUALWIRE(mindmapReader)
TB_MANUALWIRE(mindmapWriter)

#pragma mark Public
- (void)copyItemsToPasteboard:(NSArray *)items {
    NSArray *const copyItems = [[NSArray alloc] initWithArray:items copyItems:YES];

    [self.pasteboard clearContents];
    [self.pasteboard writeObjects:copyItems];
}

- (void)cutItemsToPasteboard:(NSArray *)items {
    QMNode *anyItem = items.lastObject;
    QMNode *parent = anyItem.parent;

    [self.windowController clearSelection:self];

    if (parent.root && [self isNodeLeft:anyItem]) {
        for (QMNode *child in items) {
            [self.rootNode removeObjectFromLeftChildrenAtIndex:[self.rootNode.leftChildren indexOfObject:child]];
        }
    } else {
        for (QMNode *child in items) {
            [parent removeObjectFromChildrenAtIndex:[parent.children indexOfObject:child]];
        }
    }

    [self.pasteboard clearContents];
    [self.pasteboard writeObjects:items];
}

- (void)appendItemsFromPBoard:(NSPasteboard *)pasteboard asChildrenToItem:(QMNode *)item {
    [self processNodesFromPasteboard:pasteboard usingBlock:^(NSArray *itemsFromPasteboard) {
        for (QMNode *aNode in itemsFromPasteboard) {
            [item addObjectInChildren:aNode];
        }
    }];
}

- (void)appendItemsFromPBoard:(NSPasteboard *)pasteboard asLeftChildrenToItem:(QMNode *)item {
    [self processNodesFromPasteboard:pasteboard usingBlock:^(NSArray *itemsFromPasteboard) {
        for (QMNode *aNode in itemsFromPasteboard) {
            [self.rootNode addObjectInLeftChildren:aNode];
        }
    }];
}

- (void)appendItemsFromPBoard:(NSPasteboard *)pasteboard asPreviousSiblingToItem:(QMNode *)item {
    // mind the root node
    [self processNodesFromPasteboard:pasteboard usingBlock:^(NSArray *itemsFromPBoard) {
        QMNode *parent = item.parent;
        NSUInteger indexOfItem;

        if ([self isNodeLeft:item]) {
            indexOfItem = [self.rootNode.leftChildren indexOfObject:item];
            for (QMNode *aNode in itemsFromPBoard) {
                [self.rootNode insertObject:aNode inLeftChildrenAtIndex:indexOfItem];
                indexOfItem++;
            }

            return;
        }

        indexOfItem = [parent.children indexOfObject:item];
        for (QMNode *aNode in itemsFromPBoard) {
            [parent insertObject:aNode inChildrenAtIndex:indexOfItem];
            indexOfItem++;
        }
    }];
}

- (void)appendItemsFromPBoard:(NSPasteboard *)pasteboard asNextSiblingToItem:(QMNode *)item {
    // mind the root node
    [self processNodesFromPasteboard:pasteboard usingBlock:^(NSArray *itemsToPaste) {
        QMNode *parent = item.parent;
        NSUInteger indexOfItem;

        if ([self isNodeLeft:item]) {
            indexOfItem = [self.rootNode.leftChildren indexOfObject:item];
            for (QMNode *aNode in itemsToPaste) {
                [self.rootNode insertObject:aNode inLeftChildrenAtIndex:indexOfItem + 1];
                indexOfItem++;
            }

            return;
        }

        indexOfItem = [parent.children indexOfObject:item];
        for (QMNode *aNode in itemsToPaste) {
            [parent insertObject:aNode inChildrenAtIndex:indexOfItem + 1];
            indexOfItem++;
        }
    }];
}

- (id)identifierForItem:(QMNode *)item {
    if (item == nil) {
        return self.rootNode;
    }

    return item;
}

- (void)markAsNotNew:(QMNode *)item {
    item.createdNewly = NO;
}

- (void)setStringValue:(NSString *)str ofItem:(QMNode *)item {
    QMNode *node = item == nil ? self.rootNode : item;

    node.stringValue = str;
}

- (void)setFont:(NSFont *)font ofItem:(QMNode *)item {
    if ([font isEqual:[self.settings settingForKey:qSettingDefaultFont]]) {
        item.font = nil;
        return;
    }

    [item setFont:font];
}

- (void)addIcon:(NSString *)iconCode toItem:(QMNode *)item {
    [item addObjectInIcons:iconCode];
}

- (void)deleteIconOfItem:(id)item atIndex:(NSUInteger)index {
    [item removeObjectFromIconsAtIndex:index];
}

- (void)deleteAllIconsOfItem:(QMNode *)item {
    while ([item countOfIcons] > 0) {
        [item removeObjectFromIconsAtIndex:0];
    }
}

- (BOOL)itemIsNewlyCreated:(QMNode *)item {
    return item.createdNewly;
}

- (void)moveItems:(NSArray *)itemsToMove toItem:(QMNode *)targetItem inDirection:(QMDirection)direction {
    for (QMNode *node in itemsToMove) {
        if ([self item:targetItem isDescendantOfItem:node]) {
            return;
        }
    }

    if ([targetItem isRoot]) {
        if (direction == QMDirectionRight) {
            for (QMNode *node in itemsToMove) {
                [self deleteItem:node];
                [targetItem insertObject:node inChildrenAtIndex:[targetItem countOfChildren]];
            }

            return;
        }

        if (direction == QMDirectionLeft) {
            for (QMNode *node in itemsToMove) {
                [self deleteItem:node];
                [self.rootNode insertObject:node inLeftChildrenAtIndex:[self.rootNode countOfLeftChildren]];
            }

            return;
        }

        return;
    }

    for (QMNode *node in itemsToMove) {
        [self deleteItem:node];
    }

    if (direction == QMDirectionRight || direction == QMDirectionLeft) {
        for (QMNode *node in itemsToMove) {
            [targetItem insertObject:node inChildrenAtIndex:[targetItem countOfChildren]];
        }

        return;
    }

    BOOL targetIsLeftAndChildOfRoot = [self isNodeLeft:targetItem] && targetItem.parent == self.rootNode;
    NSUInteger indexOfTargetItem;

    if (targetIsLeftAndChildOfRoot) {
        indexOfTargetItem = [self.rootNode.leftChildren indexOfObject:targetItem];
    } else {
        indexOfTargetItem = [targetItem.parent.children indexOfObject:targetItem];
    }

    if (direction == QMDirectionTop) {
        if (targetIsLeftAndChildOfRoot) {
            for (QMNode *node in [itemsToMove reverseObjectEnumerator]) {
                [self.rootNode insertObject:node inLeftChildrenAtIndex:indexOfTargetItem];
            }
        } else {
            for (QMNode *node in [itemsToMove reverseObjectEnumerator]) {
                [targetItem.parent insertObject:node inChildrenAtIndex:indexOfTargetItem];
            }
        }

        return;
    }

    if (direction == QMDirectionBottom) {
        if (targetIsLeftAndChildOfRoot) {
            for (QMNode *node in [itemsToMove reverseObjectEnumerator]) {
                [self.rootNode insertObject:node inLeftChildrenAtIndex:indexOfTargetItem + 1];
            }
        } else {
            for (QMNode *node in [itemsToMove reverseObjectEnumerator]) {
                [targetItem.parent insertObject:node inChildrenAtIndex:indexOfTargetItem + 1];
            }
        }

        return;
    }
}

- (void)copyItems:(NSArray *)itemsToMove toItem:(QMNode *)targetItem inDirection:(QMDirection)direction {
    for (QMNode *node in itemsToMove) {
        if ([self item:targetItem isDescendantOfItem:node]) {
            return;
        }
    }

    if ([targetItem isRoot]) {
        if (direction == QMDirectionRight) {
            for (QMNode *node in itemsToMove) {
                [targetItem insertObject:[node copy] inChildrenAtIndex:[targetItem countOfChildren]];
            }

            return;
        }

        if (direction == QMDirectionLeft) {
            for (QMNode *node in itemsToMove) {
                [self.rootNode insertObject:[node copy] inLeftChildrenAtIndex:[self.rootNode countOfLeftChildren]];
            }

            return;
        }

        return;
    }

    if (direction == QMDirectionRight || direction == QMDirectionLeft) {
        for (QMNode *node in itemsToMove) {
            [targetItem insertObject:[node copy] inChildrenAtIndex:[targetItem countOfChildren]];
        }

        return;
    }

    BOOL targetIsLeftAndChildOfRoot = [self isNodeLeft:targetItem] && targetItem.parent == self.rootNode;
    NSUInteger indexOfTargetItem;

    if (targetIsLeftAndChildOfRoot) {
        indexOfTargetItem = [self.rootNode.leftChildren indexOfObject:targetItem];
    } else {
        indexOfTargetItem = [targetItem.parent.children indexOfObject:targetItem];
    }

    if (direction == QMDirectionTop) {
        if (targetIsLeftAndChildOfRoot) {
            for (QMNode *node in [itemsToMove reverseObjectEnumerator]) {
                [self.rootNode insertObject:[node copy] inLeftChildrenAtIndex:indexOfTargetItem];
            }
        } else {
            for (QMNode *node in [itemsToMove reverseObjectEnumerator]) {
                [targetItem.parent insertObject:[node copy] inChildrenAtIndex:indexOfTargetItem];
            }
        }

        return;
    }

    if (direction == QMDirectionBottom) {
        if (targetIsLeftAndChildOfRoot) {
            for (QMNode *node in [itemsToMove reverseObjectEnumerator]) {
                [self.rootNode insertObject:[node copy] inLeftChildrenAtIndex:indexOfTargetItem + 1];
            }
        } else {
            for (QMNode *node in [itemsToMove reverseObjectEnumerator]) {
                [targetItem.parent insertObject:[node copy] inChildrenAtIndex:indexOfTargetItem + 1];
            }
        }

        return;
    }
}

- (QMNode *)preparedNewNode {
    QMNode *node = [[QMNode alloc] init];

    node.stringValue = @"";
    node.createdNewly = YES;

    return node;
}

- (void)addNewChildToItem:(QMNode *)item atIndex:(NSUInteger)index {
    QMNode *node = [self preparedNewNode];

    [item insertObject:node inChildrenAtIndex:index];
}

- (void)addNewLeftChildToItem:(QMRootNode *)item atIndex:(NSUInteger)index {
    QMNode *node = [self preparedNewNode];

    [item insertObject:node inLeftChildrenAtIndex:index];
}

- (void)addNewNextSiblingToItem:(QMNode *)item {
    QMNode *node = [self preparedNewNode];
    QMNode *parent = item.parent;

    if ([parent isRoot] && [self isNodeLeft:item]) {
        [self.rootNode insertObject:node inLeftChildrenAtIndex:[self.rootNode.leftChildren indexOfObject:item] + 1];
        return;
    }

    [parent insertObject:node inChildrenAtIndex:[parent.children indexOfObject:item] + 1];
}

- (void)addNewPreviousSiblingToItem:(QMNode *)item {
    QMNode *node = [self preparedNewNode];
    QMNode *parent = item.parent;

    if ([parent isRoot] && [self isNodeLeft:item]) {
        [self.rootNode insertObject:node inLeftChildrenAtIndex:[self.rootNode.leftChildren indexOfObject:item]];
        return;
    }

    [parent insertObject:node inChildrenAtIndex:[parent.children indexOfObject:item]];
}

- (void)deleteItem:(QMNode *)item {
    QMNode *parent = item.parent;
    NSArray *children;
    NSUInteger indexOfItemToDel;

    if (parent.isRoot && [self isNodeLeft:item]) {
        children = self.rootNode.leftChildren;
        indexOfItemToDel = [children indexOfObject:item];
        [self.rootNode removeObjectFromLeftChildrenAtIndex:indexOfItemToDel];

        return;
    }

    children = parent.children;
    indexOfItemToDel = [children indexOfObject:item];
    [parent removeObjectFromChildrenAtIndex:indexOfItemToDel];
}

- (void)toggleFoldingForItem:(QMNode *)item {
    if (item.root) {
        return;
    }

    if (item.leaf) {
        return;
    }

    BOOL oldValue = item.folded;
    item.folded = !oldValue;
}

- (BOOL)isNodeLeft:(QMNode *)item {
    if (item == nil || item.root) {
        return NO;
    }

    return [self isNodeLeftInternal:item];
}

- (NSInteger)numberOfChildrenOfNode:(id)item {
    QMNode *node = [self nodeFromItem:item];
    return node.countOfChildren;
}

- (id)child:(NSInteger)index ofNode:(id)item {
    QMNode *node = [self nodeFromItem:item];
    return [node objectInChildrenAtIndex:(NSUInteger) index];
}

- (NSInteger)numberOfLeftChildrenOfNode:(id)item {
    if (item == nil) {
        return self.rootNode.leftChildren.count;
    }

    return 0;
}

- (id)leftChild:(NSInteger)index ofNode:(id)item {
    if (item == nil) {
        return [self.rootNode objectInLeftChildrenAtIndex:(NSUInteger) index];
    }

    return nil;
}

- (BOOL)isNodeFolded:(id)item {
    QMNode *node = [self nodeFromItem:item];
    return node.folded;
}

- (BOOL)isNodeLeaf:(id)item {
    QMNode *node = [self nodeFromItem:item];
    return node.leaf;
}

- (id)stringValueOfNode:(id)item {
    QMNode *node = [self nodeFromItem:item];
    return node.stringValue;
}

- (id)fontOfNode:(id)item {
    QMNode *node = [self nodeFromItem:item];
    return node.font;
}

- (id)iconsOfNode:(id)item {
    QMNode *node = [self nodeFromItem:item];

    return node.icons;
}

#pragma mark NSDocument
- (void)makeWindowControllers {
    _windowController = [[QMDocumentWindowController alloc] initWithWindowNibName:qDocumentNibName];

    [self addWindowController:self.windowController];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
    [super windowControllerDidLoadNib:aController];
}

/**
* -init is invoked when opening an existing document. Then -readFromURL:ofType:error is called. If you are creating
* a new document, -init is NOT called.
*/
- (id)init {
    if ((self = [super init])) {
        self.hasUndoManager = YES;
        [self.undoManager setGroupsByEvent:NO];

        [self initSingletons];
    }

    return self;
}

- (void)dealloc {
    [self.rootNode removeObserver:self];
}

- (void)initRootNodeProperties {
    self.rootNode.undoManager = self.undoManager;
    [self.rootNode addObserver:self forKeyPath:qNodeStringValueKey];
    [self.rootNode addObserver:self forKeyPath:qNodeFontKey];
    [self.rootNode addObserver:self forKeyPath:qNodeChildrenKey];
    [self.rootNode addObserver:self forKeyPath:qNodeLeftChildrenKey];
    [self.rootNode addObserver:self forKeyPath:qNodeFoldingKey];
    [self.rootNode addObserver:self forKeyPath:qNodeIconsKey];
}

/**
* This is called creating a new document. -init is NOT called before or after this call.
*/
- (id)initWithType:(NSString *)typeName error:(NSError **)outError {

    /**
    * public.objective-c-plus-plus-source wins over net.freemind.mindmap
    */
    if (![typeName isEqualToString:qMindmapUti] && ![typeName isEqualToString:qObjectiveCppUti]) {
        log4Warn(@"Trying to open an unsupported file: %@", typeName);
        return nil;
    }

    if ((self = [super init])) {
        self.hasUndoManager = YES;
        [self.undoManager setGroupsByEvent:NO];

        [self initSingletons];

        NSMutableDictionary *attributes = [[NSMutableDictionary allocWithZone:nil] initWithCapacity:1];
        [attributes setObject:@"New Mindmap" forKey:qNodeTextAttributeKey];

        _rootNode = [[QMRootNode allocWithZone:nil] initWithAttributes:attributes];
        [self initRootNodeProperties];
    }

    return self;
}

- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper ofType:(NSString *)typeName error:(NSError **)outError {
    [self.undoManager disableUndoRegistration];

    _rootNode = [self.mindmapReader rootNodeForFileUrl:[self fileURL]];

    if (_rootNode == nil) {
        log4Warn(@"Error reading the file %@", [[self fileURL] path]);
        return NO;
    }

    [self initRootNodeProperties];

    [self.undoManager enableUndoRegistration];

    log4Debug(@"Successfully read the mindmap \"%@\".", [self fileURL]);

    // TODO: should we do this? maybe an observation of self.rootNode is the right way to do it?
    // when a version is restored, this is needed...
    [self.windowController reInitView];

    return YES;
}

- (NSFileWrapper *)fileWrapperOfType:(NSString *)typeName error:(NSError **)outError {
    /**
    * public.objective-c-plus-plus-source wins over net.freemind.mindmap.
    */
    if (![typeName isEqualToString:qMindmapUti] && ![typeName isEqualToString:qObjectiveCppUti]) {
        log4Warn(@"Trying to save an unsupported file: %@", typeName);
        return nil;
    }

    NSData *data = [self.mindmapWriter dataForRootNode:self.rootNode];

    return [[NSFileWrapper alloc] initRegularFileWithContents:data];
}

+ (BOOL)autosavesInPlace {
#ifdef DEBUG
    return NO;
#else
    return YES;
#endif
}

#pragma mark NSKeyValueChangeObserving
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    if (![object isKindOfClass:[QMNode class]]) {
        return;
    }

    if ([keyPath isEqualToString:qNodeFoldingKey]) {
        [self.windowController updateCellFoldingWithIdentifier:object];
        return;
    }

    if ([keyPath isEqualToString:qNodeStringValueKey]) {
        [self.windowController updateCellWithIdentifier:object];
        return;
    }

    if ([keyPath isEqualToString:qNodeFontKey]) {
        [self.windowController updateCellWithIdentifier:object];
        return;
    }

    if ([[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue] == NSKeyValueChangeRemoval) {

        if ([keyPath isEqualToString:qNodeIconsKey]) {
            [self.windowController updateCellWithIdentifier:object];
            return;
        }

        if ([keyPath isEqualToString:qNodeChildrenKey]) {
            [self.windowController updateCellForChildRemovalWithIdentifier:object];
            return;
        }

        if ([keyPath isEqualToString:qNodeLeftChildrenKey]) {
            [self.windowController updateCellForLeftChildRemovalWithIdentifier:object];
            return;
        }

    }

    if ([[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue] == NSKeyValueChangeInsertion) {

        if ([keyPath isEqualToString:qNodeIconsKey]) {
            [self.windowController updateCellWithIdentifier:object];
            return;
        }

        QMNode *insertedNode = [[change objectForKey:NSKeyValueChangeNewKey] lastObject];

        if ([keyPath isEqualToString:qNodeChildrenKey]) {

            if (insertedNode.isCreatedNewly) {
                [self.windowController updateCellWithIdentifier:object withNewChild:insertedNode];
            } else {
                [self.windowController updateCellForChildInsertionWithIdentifier:object];
            }

            return;
        }

        if ([keyPath isEqualToString:qNodeLeftChildrenKey]) {

            if (insertedNode.isCreatedNewly) {
                [self.windowController updateCellWithIdentifier:object withNewLeftChild:insertedNode];
            } else {
                [self.windowController updateCellForLeftChildInsertionWithIdentifier:object];
            }

            return;
        }
    }
}

#pragma mark Private
- (void)initSingletons {
    [[TBContext sharedContext] autowireSeed:self];
    _pasteboard = [NSPasteboard pasteboardWithName:NSGeneralPboard];
}

- (void)processNodesFromPasteboard:(NSPasteboard *)pasteboard usingBlock:(void (^)(NSArray *itemsFromPasteboard))block {
    NSArray *classes = @[[QMNode class], [NSString class]];
    NSDictionary *options = [NSDictionary dictionary];
    NSArray *itemsFromPb = [pasteboard readObjectsForClasses:classes options:options];

    if (itemsFromPb == nil) {
        return;
    }

    id anItem = itemsFromPb.lastObject;
    BOOL isNode = [anItem isKindOfClass:[QMNode class]];
    BOOL isText = [anItem isKindOfClass:[NSString class]];

    if (!isNode && !isText) {
        return;
    }

    if (isNode) {
        if ([anItem isRoot]) {
            QMNode *nodeToPaste = [(QMRootNode *) anItem node];
            itemsFromPb = [NSArray arrayWithObject:nodeToPaste];
        }

        block(itemsFromPb);
        return;
    }

    // isText
    QMNode *nodeToInsert = [[QMNode alloc] init];
    nodeToInsert.stringValue = itemsFromPb.lastObject;

    block(@[nodeToInsert]);
}

- (BOOL)isNodeLeftInternal:(QMNode *)node {
    if (node.parent.isRoot) {
        QMRootNode *rootNode = (QMRootNode *) node.parent;

        return [rootNode.leftChildren containsObject:node];
    }

    return [self isNodeLeftInternal:node.parent];
}

- (QMNode *)nodeFromItem:(id)item {
    return (item == nil ? self.rootNode : (QMNode *) item);
}

- (BOOL)item:(QMNode *)givenItem isDescendantOfItem:(QMNode *)potentialParentNode {
    QMNode *currentParent = givenItem.parent;

    while (currentParent != nil) {
        if (potentialParentNode == currentParent) {
            return YES;
        }

        currentParent = currentParent.parent;
    }

    return NO;
}

@end
