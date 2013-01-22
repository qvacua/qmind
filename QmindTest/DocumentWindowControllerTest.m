/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import "QMMindmapView.h"
#import "QMBaseTestCase.h"
#import "QMBaseTestCase+Util.h"
#import "QMRootCell.h"
#import "QMNode.h"
#import "QMDocumentWindowController.h"
#import "QMDocument.h"
#import "QMMindmapViewDataSourceImpl.h"
#import "QMIconManager.h"

@interface DocumentWindowControllerTest : QMBaseTestCase @end

@implementation DocumentWindowControllerTest {
    QMDocumentWindowController *controller;

    QMDocument *doc;
    QMMindmapViewDataSourceImpl *dataSource;
    QMMindmapView *view;
    NSPasteboard *pasteboard;
    NSUndoManager *undoManager;
    QMIconManager *iconManager;

    id item;
    id otherItem;

    NSFont *NEW_FONT;
    QMRootCell *rootCell;
}

- (void)setUp {
    view = mock(QMMindmapView.class);
    doc = mock(QMDocument.class);
    dataSource = mock([QMMindmapViewDataSourceImpl class]);
    pasteboard = mock([NSPasteboard class]);
    undoManager = mock([NSUndoManager class]);
    iconManager = mock([QMIconManager class]);
    [given([doc undoManager]) willReturn:undoManager];

    rootCell = [self rootCellForTestWithView:view];
    [given([view rootCell]) willReturn:rootCell];

    controller = [[QMDocumentWindowController alloc] init];
    [controller setMindmapView:view];

    [controller setInstanceVarTo:doc];
    [controller setInstanceVarTo:pasteboard];
    [controller setInstanceVarTo:dataSource implementingProtocol:@protocol(QMMindmapViewDataSource)];
    controller.iconManager = iconManager;

    item = [[NSObject alloc] init];
    otherItem = [[NSObject alloc] init];

    NEW_FONT = [NSFont boldSystemFontOfSize:50];
}

- (void)testCutIbAction {
    [given([view hasSelectedCells]) willReturnBool:NO];
    [given([view selectedCells]) willReturn:[NSArray array]];
    [controller cut:self];
    [verifyCount(doc, never()) cutItemsToPasteboard:anything()];

    [given([view hasSelectedCells]) willReturnBool:YES];
    [given([view selectedCells]) willReturn:@[rootCell]];
    [controller cut:self];
    [verifyCount(doc, never()) cutItemsToPasteboard:anything()];

    [given([view hasSelectedCells]) willReturnBool:YES];
    [given([view selectedCells]) willReturn:@[CELL(3), CELL(5)]];
    [controller cut:self];
    [verify(undoManager) beginUndoGrouping];
    [verify(undoManager) setActionName:NSLocalizedString(@"undo.node.cut", @"Undo Cut")];
    [verify(doc) cutItemsToPasteboard:consistsOf([CELL(3) identifier], [CELL(5) identifier])];
    [verify(undoManager) endUndoGrouping];
}

- (void)testDeselectIbAction {
    [controller clearSelection:self];
    [verify(view) clearSelection];
}

- (void)testCopyIbAction {
    [given([view hasSelectedCells]) willReturnBool:NO];
    [given([view selectedCells]) willReturn:[NSArray array]];
    [controller copy:self];
    [verifyCount(doc, never()) copyItemsToPasteboard:anything()];

    [given([view hasSelectedCells]) willReturnBool:YES];
    [given([view selectedCells]) willReturn:@[CELL(3), CELL(5)]];
    [controller copy:self];
    [verify(doc) copyItemsToPasteboard:consistsOf([CELL(3) identifier], [CELL(5) identifier])];
}

- (void)testPasteIbAction {
    [given([view hasSelectedCells]) willReturnBool:NO];
    [given([view selectedCells]) willReturn:[NSArray array]];
    [controller paste:self];
    [verify(dataSource) mindmapView:view insertChildrenFromPasteboard:pasteboard toItem:rootCell.identifier];

    [given([view hasSelectedCells]) willReturnBool:YES];
    [given([view selectedCells]) willReturn:@[CELL(4)]];
    [controller paste:self];
    [verify(dataSource) mindmapView:view insertChildrenFromPasteboard:pasteboard toItem:[CELL(4) identifier]];
}

- (void)testPasteLeftIbAction {
    [given([view hasSelectedCells]) willReturnBool:NO];
    [given([view selectedCells]) willReturn:[NSArray array]];
    [controller pasteLeft:self];
    [verify(dataSource) mindmapView:view insertLeftChildrenFromPasteboard:pasteboard toItem:rootCell.identifier];

    [given([view hasSelectedCells]) willReturnBool:YES];
    [given([view selectedCells]) willReturn:@[rootCell]];
    [controller pasteLeft:self];
    [verifyCount(dataSource, times(2)) mindmapView:view insertLeftChildrenFromPasteboard:pasteboard toItem:rootCell.identifier];
}

- (void)testPasteAsPrevSiblingIbAction {
    [given([view hasSelectedCells]) willReturnBool:YES];
    [given([view selectedCells]) willReturn:@[CELL(4)]];
    [controller pasteAsPreviousSibling:self];
    [verify(dataSource) mindmapView:view insertPreviousSiblingsFromPasteboard:pasteboard toItem:[CELL(4) identifier]];
}

- (void)testPasteAsNextSiblingIbAction {
    [given([view hasSelectedCells]) willReturnBool:YES];
    [given([view selectedCells]) willReturn:@[CELL(4)]];
    [controller pasteAsNextSibling:self];
    [verify(dataSource) mindmapView:view insertNextSiblingsFromPasteboard:pasteboard toItem:[CELL(4) identifier]];
}

- (NSFont *)convertFont:(NSFont *)aFont {
    return NEW_FONT;
}

- (void)testInsertNewChildNode {
    [controller newChildNode:self];
    [verify(view) insertChild];
}

- (void)testInsertNewLeftChildNode {
    [controller newLeftChildNode:self];
    [verify(view) insertLeftChild];
}

- (void)testInsertNextSiblingNode {
    [controller newNextSiblingNode:self];
    [verify(view) insertNextSibling];
}

- (void)testInsertPrevSiblingNode {
    [controller newPreviousSiblingNode:self];
    [verify(view) insertPreviousSibling];
}

- (void)testChangeFont {
    NSObject *const object = [[NSObject alloc] init];
    NSObject *const otherObject = [[NSObject alloc] init];

    [CELL(1) setIdentifier:object];
    [CELL(5) setIdentifier:otherObject];
    [CELL(1) setFont:[NSFont systemFontOfSize:10]];
    [CELL(5) setFont:NEW_FONT];
    [given([view hasSelectedCells]) willReturnBool:YES];
    [given([view selectedCells]) willReturn:@[CELL(1), CELL(5)]];

    [controller changeFont:self];

    [verify(dataSource) mindmapView:view setFont:NEW_FONT ofItems:@[[CELL(1) identifier]]];
    [verifyCount(doc, never()) setFont:NEW_FONT ofItem:otherObject];
}

- (void)testChangeFontNoSelectedCells {
    [given([view hasSelectedCells]) willReturnBool:NO];

    [controller changeFont:self];

    [verifyCount(view, never()) selectedCells];
}

- (void)testInitController {
    [controller windowDidLoad];
    [verify(view) initMindmapViewWithDataSource:instanceOf([QMMindmapViewDataSourceImpl class])];
}

- (void)testValidateNewNodeMenu {
    NSMenuItem *menuItem = [[NSMenuItem alloc] init];
    [given([view rootCell]) willReturn:rootCell];

    [menuItem setAction:@selector(iconsPaneToggleAction:)];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isYes);

    [menuItem setAction:@selector(newChildNode:)];
    [given([view hasSelectedCells]) willReturnBool:NO];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isYes);

    [given([view hasSelectedCells]) willReturnBool:YES];
    [given([view selectedCells]) willReturn:@[CELL(1)]];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isYes);

    [given([view selectedCells]) willReturn:@[LCELL(1)]];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isYes);

    [given([view selectedCells]) willReturn:@[CELL(1), CELL(4)]];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isNo);

    [menuItem setAction:@selector(newLeftChildNode:)];
    [given([view hasSelectedCells]) willReturnBool:NO];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isYes);

    [given([view hasSelectedCells]) willReturnBool:YES];
    [given([view selectedCells]) willReturn:@[rootCell]];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isYes);

    [given([view selectedCells]) willReturn:@[LCELL(1), LCELL(4)]];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isNo);

    [menuItem setAction:@selector(newNextSiblingNode:)];
    [given([view hasSelectedCells]) willReturnBool:YES];
    [given([view selectedCells]) willReturn:@[rootCell]];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isNo);

    [given([view selectedCells]) willReturn:@[CELL(1)]];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isYes);

    [given([view selectedCells]) willReturn:@[CELL(1), CELL(5)]];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isNo);

    [menuItem setAction:@selector(newPreviousSiblingNode:)];
    [given([view hasSelectedCells]) willReturnBool:YES];
    [given([view selectedCells]) willReturn:@[rootCell]];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isNo);

    [given([view selectedCells]) willReturn:@[LCELL(1)]];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isYes);

    [given([view selectedCells]) willReturn:@[LCELL(1), LCELL(5)]];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isNo);
}

- (void)testValidateDeleteNodeMenu {
    NSMenuItem *menuItem = [[NSMenuItem alloc] init];
    [menuItem setAction:@selector(deleteSelectedNodes:)];

    [given([view hasSelectedCells]) willReturnBool:YES];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isYes);

    [given([view hasSelectedCells]) willReturnBool:NO];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isNo);

    menuItem = [[NSMenuItem alloc] init];
    [menuItem setAction:@selector(copy:)];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isNo);
}

- (void)testValidateDeleteNodeMenuWhenRootSelected {
    NSMenuItem *menuItem = [[NSMenuItem alloc] init];
    [menuItem setAction:@selector(deleteSelectedNodes:)];

    [given([view hasSelectedCells]) willReturnBool:YES];
    [given([view selectedCells]) willReturn:@[rootCell]];
    [given([view rootCellSelected]) willReturnBool:YES];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isNo);
}

- (void)testValidateCutMenu {
    NSMenuItem *menuItem = [[NSMenuItem alloc] init];
    [menuItem setAction:@selector(cut:)];

    [given([view hasSelectedCells]) willReturnBool:YES];
    [given([view rootCellSelected]) willReturnBool:NO];
    [given([view selectedCells]) willReturn:@[CELL(5)]];

    assertThat(@([controller validateUserInterfaceItem:menuItem]), isYes);

    [given([view hasSelectedCells]) willReturnBool:NO];
    [given([view selectedCells]) willReturn:[NSArray array]];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isNo);

    [given([view rootCellSelected]) willReturnBool:YES];
    [given([view selectedCells]) willReturn:@[rootCell]];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isNo);
}

- (void)testValidateCopyMenu {
    NSMenuItem *menuItem = [[NSMenuItem alloc] init];
    [menuItem setAction:@selector(copy:)];

    [given([view hasSelectedCells]) willReturnBool:YES];
    [given([view rootCellSelected]) willReturnBool:NO];
    [given([view selectedCells]) willReturn:@[CELL(5)]];

    assertThat(@([controller validateUserInterfaceItem:menuItem]), isYes);

    [given([view hasSelectedCells]) willReturnBool:NO];
    [given([view selectedCells]) willReturn:[NSArray array]];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isNo);

    [given([view rootCellSelected]) willReturnBool:YES];
    [given([view selectedCells]) willReturn:@[rootCell]];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isYes);
}

- (void)testValidatePasteMenu {
    NSMenuItem *menuItem = [[NSMenuItem alloc] init];
    [menuItem setAction:@selector(paste:)];

    [given([view hasSelectedCells]) willReturnBool:NO];
    [given([view selectedCells]) willReturn:[NSArray array]];
    [given([pasteboard types]) willReturn:@[qNodeUti]];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isYes);

    [given([pasteboard types]) willReturn:@[qNodeUti]];
    [given([view hasSelectedCells]) willReturnBool:YES];
    [given([view selectedCells]) willReturn:@[CELL(5)]];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isYes);

    [given([pasteboard types]) willReturn:@[NSStringPboardType]];
    [given([view hasSelectedCells]) willReturnBool:YES];
    [given([view selectedCells]) willReturn:@[CELL(5)]];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isYes);

    [given([pasteboard types]) willReturn:@[NSSoundPboardType]];
    [given([view hasSelectedCells]) willReturnBool:YES];
    [given([view selectedCells]) willReturn:@[CELL(5)]];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isNo);

    [given([pasteboard types]) willReturn:@[NSStringPboardType]];
    [given([view hasSelectedCells]) willReturnBool:YES];
    [given([view selectedCells]) willReturn:@[CELL(5), CELL(6)]];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isNo);
}

- (void)testValidatePasteToLeftMenu {
    NSMenuItem *menuItem = [[NSMenuItem alloc] init];
    [menuItem setAction:@selector(pasteLeft:)];

    [given([view hasSelectedCells]) willReturnBool:NO];
    [given([view selectedCells]) willReturn:[NSArray array]];
    [given([pasteboard types]) willReturn:@[qNodeUti]];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isYes);

    [given([pasteboard types]) willReturn:@[qNodeUti]];
    [given([view hasSelectedCells]) willReturnBool:YES];
    [given([view selectedCells]) willReturn:@[rootCell]];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isYes);

    [given([pasteboard types]) willReturn:@[NSStringPboardType]];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isYes);

    [given([pasteboard types]) willReturn:@[NSSoundPboardType]];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isNo);

    [given([view hasSelectedCells]) willReturnBool:YES];
    [given([pasteboard types]) willReturn:@[qNodeUti]];
    [given([view selectedCells]) willReturn:@[CELL(5)]];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isNo);
}

- (void)testValidatePasteAsSibling {
    NSMenuItem *prevMenuItem = [[NSMenuItem alloc] init];
    NSMenuItem *nextMenuItem = [[NSMenuItem alloc] init];
    [prevMenuItem setAction:@selector(pasteAsPreviousSibling:)];
    [nextMenuItem setAction:@selector(pasteAsNextSibling:)];

    [given([view hasSelectedCells]) willReturnBool:NO];
    [given([view selectedCells]) willReturn:[NSArray array]];
    [given([pasteboard types]) willReturn:@[qNodeUti]];
    assertThat(@([controller validateUserInterfaceItem:prevMenuItem]), isNo);
    assertThat(@([controller validateUserInterfaceItem:nextMenuItem]), isNo);

    [given([view hasSelectedCells]) willReturnBool:NO];
    [given([view selectedCells]) willReturn:@[rootCell]];
    [given([pasteboard types]) willReturn:@[qNodeUti]];
    assertThat(@([controller validateUserInterfaceItem:prevMenuItem]), isNo);
    assertThat(@([controller validateUserInterfaceItem:nextMenuItem]), isNo);

    [given([pasteboard types]) willReturn:@[qNodeUti]];
    [given([view hasSelectedCells]) willReturnBool:YES];
    [given([view selectedCells]) willReturn:@[CELL(3)]];
    assertThat(@([controller validateUserInterfaceItem:prevMenuItem]), isYes);
    assertThat(@([controller validateUserInterfaceItem:nextMenuItem]), isYes);
}

- (void)testValidateZoomMenu {
    NSMenuItem *menuItem = [[NSMenuItem alloc] init];

    [menuItem setAction:@selector(zoomToActualSize:)];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isYes);

    [menuItem setAction:@selector(zoomInView:)];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isYes);

    [menuItem setAction:@selector(zoomOutView:)];
    assertThat(@([controller validateUserInterfaceItem:menuItem]), isYes);
}

- (void)testFoldingMenu {
    NSMenuItem *expandItem = [[NSMenuItem alloc] init];
    NSMenuItem *collapseItem = [[NSMenuItem alloc] init];

    [expandItem setAction:@selector(expandNodeAction:)];
    [collapseItem setAction:@selector(collapseNodeAction:)];

    [given([view hasSelectedCells]) willReturnBool:YES];
    [given([view rootCellSelected]) willReturnBool:NO];
    [given([view selectedCells]) willReturn:@[CELL(4)]];

    [CELL(4) setFolded:YES];
    assertThat(@([controller validateUserInterfaceItem:expandItem]), isYes);
    assertThat(@([controller validateUserInterfaceItem:collapseItem]), isNo);

    [CELL(4) setFolded:NO];
    assertThat(@([controller validateUserInterfaceItem:expandItem]), isNo);
    assertThat(@([controller validateUserInterfaceItem:collapseItem]), isYes);

    [given([view hasSelectedCells]) willReturnBool:YES];
    [given([view rootCellSelected]) willReturnBool:YES];
    [given([view selectedCells]) willReturn:@[rootCell]];
    assertThat(@([controller validateUserInterfaceItem:expandItem]), isNo);
    assertThat(@([controller validateUserInterfaceItem:collapseItem]), isNo);
}

- (void)testZoomIBActions {
    [controller zoomToActualSize:self];
    [verify(view) zoomToActualSize];

    [controller zoomInView:self];
    [verify(view) zoomByFactor:qZoomInStep];

    [controller zoomOutView:self];
    [verify(view) zoomByFactor:qZoomOutStep];
}

- (void)testZoomByModeIBAction {
    id sender = mock([NSSegmentedCell class]);
    [given([sender selectedSegment]) willReturnInt:0];
    [controller zoomByMode:sender];
    [verify(view) zoomByFactor:qZoomOutStep];

    [given([sender selectedSegment]) willReturnInt:1];
    [controller zoomByMode:sender];
    [verify(view) zoomToActualSize];

    [given([sender selectedSegment]) willReturnInt:2];
    [controller zoomByMode:sender];
    [verify(view) zoomByFactor:qZoomInStep];
}

- (void)testNodeDeleteIBActions {
    [given([view hasSelectedCells]) willReturnBool:NO];
    [controller deleteSelectedNodes:self];
    [verifyCount(doc, never()) deleteItem:anything()];

    id const id41 = [[NSObject alloc] init];
    id const id47 = [[NSObject alloc] init];
    [LCELL(4, 1) setIdentifier:id41];
    [LCELL(4, 7) setIdentifier:id47];
    [given([view hasSelectedCells]) willReturnBool:YES];
    [given([view selectedCells]) willReturn:@[LCELL(4, 1), LCELL(4, 7)]];

    [controller deleteSelectedNodes:self];
    [verify(view) clearSelection];
    NSArray *const idArray = @[[LCELL(4, 1) identifier], [LCELL(4, 7) identifier]];
    [verify(dataSource) mindmapView:view deleteItems:idArray];
}

- (void)testFoldingIBActions {
    [controller expandNodeAction:self];
    [verify(view) toggleFoldingOfSelectedCell];

    [controller collapseNodeAction:self];
    [verifyCount(view, times(2)) toggleFoldingOfSelectedCell];
}

- (void)testTriggerUpdateCell {
    [controller updateCellWithIdentifier:item];
    [verify(view) updateCellWithIdentifier:item];
}

- (void)testTriggerUpdateCellFamily {
    [controller updateCellForChildRemovalWithIdentifier:item];
    [verify(view) updateCellFamilyForRemovalWithIdentifier:item];

    [controller updateCellForLeftChildRemovalWithIdentifier:item];
    [verify(view) updateLeftCellFamilyForRemovalWithIdentifier:item];

    [controller updateCellForChildInsertionWithIdentifier:item];
    [verify(view) updateCellFamilyForInsertionWithIdentifier:item];

    [controller updateCellForLeftChildInsertionWithIdentifier:item];
    [verify(view) updateLeftCellFamilyForInsertionWithIdentifier:item];

    [controller updateCellFoldingWithIdentifier:item];
    [verify(view) updateCellFoldingWithIdentifier:item];
}

- (void)testTriggerUpdateCellFamilyUponNewChild {
    [controller updateCellWithIdentifier:item withNewChild:otherItem];
    [verify(view) updateCellFamily:item forNewCell:otherItem];

    [controller updateCellWithIdentifier:item withNewLeftChild:otherItem];
    [verify(view) updateLeftCellFamily:item forNewCell:otherItem];
}

- (void)testWindowDidResize {
    // TODO
}

- (void)testWindowWillResize {
    // TODO
}

@end
