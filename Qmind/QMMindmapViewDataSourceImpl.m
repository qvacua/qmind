/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import "QMDocument.h"
#import "QMIconManager.h"
#import <Qkit/Qkit.h>
#import <TBCacao/TBCacao.h>
#import "QMMindmapView.h"
#import "QMAppSettings.h"
#import "QMCell.h"
#import "QMMindmapViewDataSourceImpl.h"
#import "QMRootCell.h"
#import "QMIcon.h"

@implementation QMMindmapViewDataSourceImpl {
    __weak QMDocument *_doc;
    __weak NSUndoManager *_undoManager;
    __weak QMMindmapView *_view;
}

TB_MANUALWIRE_WITH_INSTANCE_VAR(settings, _settings)
TB_MANUALWIRE_WITH_INSTANCE_VAR(iconManager, _iconManager)

#pragma mark Public
- (BOOL)mindmapView:(QMMindmapView *)mindmapView isItemLeft:(id)item {
    return [_doc isNodeLeft:item];
}

- (NSInteger)mindmapView:(QMMindmapView *)mindmapView numberOfChildrenOfItem:(id)item {
    return [_doc numberOfChildrenOfNode:item];
}

- (id)mindmapView:(QMMindmapView *)mindmapView child:(NSInteger)index ofItem:(id)item {
    return [_doc child:index ofNode:item];
}

- (NSInteger)mindmapView:(QMMindmapView *)mindmapView numberOfLeftChildrenOfItem:(id)item {
    return [_doc numberOfLeftChildrenOfNode:item];
}

- (id)mindmapView:(QMMindmapView *)mindmapView leftChild:(NSInteger)index ofItem:(id)item {
    return [_doc leftChild:index ofNode:item];
}

- (BOOL)mindmapView:(QMMindmapView *)mindmapView isItemFolded:(id)item {
    return [_doc isNodeFolded:item];
}

- (BOOL)mindmapView:(QMMindmapView *)mindmapView isItemLeaf:(id)item {
    return [_doc isNodeLeaf:item];
}

- (id)mindmapView:(QMMindmapView *)mindmapView stringValueOfItem:(id)item {
    return [_doc stringValueOfNode:item];
}

- (id)mindmapView:(QMMindmapView *)mindmapView fontOfItem:(id)item {
    return [_doc fontOfNode:item];
}

- (id)mindmapView:(QMMindmapView *)mindmapView iconsOfItem:(id)item {
    NSArray *iconCodes = [_doc iconsOfNode:item];
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:iconCodes.count];

    for (NSString *code in iconCodes) {
        [result addObject:[[QMIcon alloc] initWithCode:code]];
    }

    return result;
}

- (id)mindmapView:(QMMindmapView *)mindmapView identifierForItem:(id)item {
    return [_doc identifierForItem:item];
}

- (void)mindmapView:(QMMindmapView *)mindmapView setStringValue:(NSString *)str ofItem:(id)item {
    [self doInsideUndoGroup:NSLocalizedString(@"undo.node.text.change", @"Change Text of Node") usingBlock:^{
        [_doc setStringValue:str ofItem:item];
    }];
}

- (void)mindmapView:(QMMindmapView *)mindmapView setFont:(NSFont *)font ofItems:(NSArray *)items {
    [self doInsideUndoGroup:NSLocalizedString(@"undo.node.font.change", @"Change Font of Node(s)") usingBlock:^{
        for (id item in items) {
            [_doc setFont:font ofItem:item];
        }
    }];
}

- (void)mindmapView:(QMMindmapView *)mindmapView addIcon:(QMIcon *)icon toItem:(id)item {
    [self doInsideUndoGroup:NSLocalizedString(@"undo.node.icon.add", @"Insert Icon") usingBlock:^{
        [_doc addIcon:icon.code toItem:item];
    }];
}

- (void)mindmapView:(QMMindmapView *)mindmapView deleteIconOfItem:(id)item atIndex:(NSUInteger)index {
    [self doInsideUndoGroup:NSLocalizedString(@"undo.node.icon.delete", @"Delete Icon") usingBlock:^{
        [_doc deleteIconOfItem:item atIndex:index];
    }];
}

- (void)mindmapView:(QMMindmapView *)mindmapView deleteAllIconsOfItem:(id)item {
    [self doInsideUndoGroup:NSLocalizedString(@"undo.node.icon.all.delete", @"Delete Icon") usingBlock:^{
        [_doc deleteAllIconsOfItem:item];
    }];
}

- (void)mindmapView:(QMMindmapView *)mindmapView moveItems:(NSArray *)itemsToMove toItem:(id)itemToModify inDirection:(QMDirection)direction {
    [self doInsideUndoGroup:NSLocalizedString(@"undo.node.move", @"Undo Move Node(s)") usingBlock:^{
        [_doc moveItems:itemsToMove toItem:itemToModify inDirection:direction];
    }];
}

- (void)mindmapView:(QMMindmapView *)mindmapView copyItems:(NSArray *)itemsToMove toItem:(id)itemToModify inDirection:(QMDirection)direction {
    [self doInsideUndoGroup:NSLocalizedString(@"undo.node.copy", @"Undo Copy Node(s)") usingBlock:^{
        [_doc copyItems:itemsToMove toItem:itemToModify inDirection:direction];
    }];
}

- (void)mindmapView:(QMMindmapView *)mindmapView addNewChildToItem:(id)item atIndex:(NSInteger)index {
    [self doAfterBeginUndoGroup:NSLocalizedString(@"undo.node.child.new", @"New Child Node") usingBlock:^{
        [_doc addNewChildToItem:item atIndex:(NSUInteger) index];
    }];
}

- (void)mindmapView:(QMMindmapView *)mindmapView addNewLeftChildToItem:(id)item atIndex:(NSInteger)index {
    [self doAfterBeginUndoGroup:NSLocalizedString(@"undo.node.child.left.new", @"New Left Child Node") usingBlock:^{
        [_doc addNewLeftChildToItem:item atIndex:(NSUInteger) index];
    }];
}

- (void)mindmapView:(QMMindmapView *)mindmapView addNewNextSiblingToItem:(id)item {
    [self doAfterBeginUndoGroup:NSLocalizedString(@"undo.node.sibling.next.new", @"New Next Sibling Node") usingBlock:^{
        [_doc addNewNextSiblingToItem:item];
    }];
}

- (void)mindmapView:(QMMindmapView *)mindmapView addNewPreviousSiblingToItem:(id)item {
    [self doAfterBeginUndoGroup:NSLocalizedString(@"undo.node.sibling.prev.new", @"New Previous Sibling Node") usingBlock:^{
        [_doc addNewPreviousSiblingToItem:item];
    }];
}

/**
* TODO: the following two methods are not datasource-like, but rather delegate methods...
*/
- (void)mindmapView:(QMMindmapView *)mindmapView editingEndedForItem:(id)item {
    [_doc markAsNotNew:item];
}

- (void)mindmapView:(QMMindmapView *)mindmapView editingCancelledForItem:(id)item withAttrString:(NSAttributedString *)newAttrStr {
    if ([_doc itemIsNewlyCreated:item]) {
        [_undoManager endUndoGrouping];

        [_undoManager disableUndoRegistration];
        [_doc setStringValue:newAttrStr.string ofItem:item];

        NSFont *font = [newAttrStr fontOfTheBeginning];
        if (font == nil) {
            font = [_settings settingForKey:qSettingDefaultFont];
        }

        [_doc setFont:font ofItem:item];
        [_undoManager enableUndoRegistration];

        [_doc markAsNotNew:item];
        [_undoManager undo];
    }
}

- (void)mindmapView:(QMMindmapView *)mindmapView deleteItems:(NSArray *)items {
    [_undoManager beginUndoGrouping];
    [_undoManager setActionName:NSLocalizedString(@"undo.node.deletion", @"Deletion of Node(s)")];

    for (id item in items) {
        [_doc deleteItem:item];
    }

    [_undoManager endUndoGrouping];
}

- (void)mindmapView:(QMMindmapView *)mindmapView toggleFoldingForItem:(id)item {
    [_doc toggleFoldingForItem:item];
    [_doc updateChangeCount:NSChangeDone];
}

- (void)mindmapView:(QMMindmapView *)mindmapView prepareDragAndDropWithCells:(NSArray *)draggedCells {
    NSPasteboard *board = [NSPasteboard pasteboardWithName:NSDragPboard];
    [board clearContents];

    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:[draggedCells count]];
    for (QMCell *cell in draggedCells) {
        [items addObject:cell.identifier];
    }

    [board writeObjects:items];
}

- (void)mindmapView:(QMMindmapView *)mindmapView insertChildrenFromPasteboard:(NSPasteboard *)pasteboard toItem:(id)item {
    id itemToModify = item;
    if (item == nil) {
        itemToModify = _view.rootCell.identifier;
    }

    if ([_doc isNodeFolded:itemToModify]) {
        [_doc toggleFoldingForItem:itemToModify];
    }

    [self doInsideUndoGroup:NSLocalizedString(@"undo.node.paste", @"Undo Paste") usingBlock:^{
        [_doc appendItemsFromPBoard:pasteboard asChildrenToItem:itemToModify];
    }];
}

- (void)mindmapView:(QMMindmapView *)mindmapView insertLeftChildrenFromPasteboard:(NSPasteboard *)pasteboard toItem:(id)item {
    id itemToModify = _view.rootCell.identifier;

    if ([_doc isNodeFolded:itemToModify]) {
        [_doc toggleFoldingForItem:itemToModify];
    }

    [self doInsideUndoGroup:NSLocalizedString(@"undo.node.paste", @"Undo Paste") usingBlock:^{
        [_doc appendItemsFromPBoard:pasteboard asLeftChildrenToItem:itemToModify];
    }];
}

- (void)mindmapView:(QMMindmapView *)mindmapView insertNextSiblingsFromPasteboard:(NSPasteboard *)pasteboard toItem:(id)item {
    [self doInsideUndoGroup:NSLocalizedString(@"undo.node.paste", @"Undo Paste") usingBlock:^{
        [_doc appendItemsFromPBoard:pasteboard asNextSiblingToItem:item];
    }];
}

- (void)mindmapView:(QMMindmapView *)mindmapView insertPreviousSiblingsFromPasteboard:(NSPasteboard *)pasteboard toItem:(id)item {
    [self doInsideUndoGroup:NSLocalizedString(@"undo.node.paste", @"Undo Paste") usingBlock:^{
        [_doc appendItemsFromPBoard:pasteboard asPreviousSiblingToItem:item];
    }];
}

- (id)initWithDoc:(QMDocument *)doc view:(QMMindmapView *)view {
    if ((self = [super init])) {
        _doc = doc;
        _view = view;
        _undoManager = _doc.undoManager;

        [[TBContext sharedContext] autowireSeed:self];
    }

    return self;
}

#pragma mark Private
- (void)doInsideUndoGroup:(NSString *)undoGroupName usingBlock:(void (^)())block {
    if (_undoManager.groupingLevel == 0) {
        [_undoManager beginUndoGrouping];
        [_undoManager setActionName:undoGroupName];
    }

    block();

    [_undoManager endUndoGrouping];
}

- (void)doAfterBeginUndoGroup:(NSString *)undoGroupName usingBlock:(void (^)())block {
    [_undoManager beginUndoGrouping];
    [_undoManager setActionName:undoGroupName];
    block();
}

@end
