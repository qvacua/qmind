/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <TBCacao/TBCacao.h>
#import "QMBaseTestCase.h"
#import "QMAppSettings.h"
#import "QMDocument.h"
#import "QMMindmapView.h"
#import "QMNode.h"
#import "QMCell.h"
#import "QMBaseTestCase+Util.h"
#import "QMMindmapViewDataSourceImpl.h"
#import "QMCacaoTestCase.h"
#import "QMIcon.h"

@interface MindmapDataSourceTest : QMCacaoTestCase {
    QMMindmapViewDataSourceImpl *dataSource;

    QMDocument *doc;
    NSUndoManager *undoManager;
    NSPasteboard *pasteboard;
    QMMindmapView *view;

    id item;
    id otherItem;
}

@end

@implementation MindmapDataSourceTest {
    QMCell *rootCell;
    QMAppSettings *settings;
}

- (void)setUp {
    [super setUp];

    settings = [self.context beanWithClass:[QMAppSettings class]];

    doc = mock(QMDocument.class);
    view = mock([QMMindmapView class]);
    undoManager = mock([NSUndoManager class]);
    pasteboard = mock([NSPasteboard class]);
    [given([doc undoManager]) willReturn:undoManager];

    dataSource = [[QMMindmapViewDataSourceImpl alloc] initWithDoc:doc view:view];

    item = [[NSObject alloc] init];
    otherItem = [[NSObject alloc] init];

    rootCell = [self rootCellForTestWithView:nil];
}

/**
* @bug
*/
- (void)testInit {
    assertThat(dataSource.iconManager, isNot(nilValue()));
}

- (void)testAddIcon {
    QMIcon *icon = [[QMIcon alloc] initWithCode:@"icon1"];
    [dataSource mindmapView:view addIcon:icon toItem:item];

    [verify(undoManager) beginUndoGrouping];
    [verify(undoManager) setActionName:NSLocalizedString(@"undo.node.icon.add", @"Add Icon")];
    [verify(doc) addIcon:@"icon1" toItem:item];
    [verify(undoManager) endUndoGrouping];
}

- (void)testDeleteIcon {
    FAIL;
}

- (void)testIdentifier {
    [given([doc identifierForItem:nil]) willReturn:item];
    [given([doc identifierForItem:otherItem]) willReturn:otherItem];

    assertThat([dataSource mindmapView:view identifierForItem:nil], is(item));
    assertThat([dataSource mindmapView:view identifierForItem:otherItem], is(otherItem));
}

- (void)testInsertChildrenFromPBoard {
    [given([view rootCell]) willReturn:rootCell];
    [given([doc isNodeFolded:rootCell.identifier]) willReturnBool:YES];

    [dataSource mindmapView:view insertChildrenFromPasteboard:pasteboard toItem:nil];

    [verify(undoManager) beginUndoGrouping];
    [verify(undoManager) setActionName:NSLocalizedString(@"undo.node.paste", @"Undo Paste")];
    [verify(doc) toggleFoldingForItem:rootCell.identifier];
    [verify(doc) appendItemsFromPBoard:pasteboard asChildrenToItem:rootCell.identifier];
    [verify(undoManager) endUndoGrouping];

    [dataSource mindmapView:view insertChildrenFromPasteboard:pasteboard toItem:[CELL(4) identifier]];
    [verifyCount(undoManager, times(2)) beginUndoGrouping];
    [verifyCount(undoManager, times(2)) setActionName:NSLocalizedString(@"undo.node.paste", @"Undo Paste")];
    [verify(doc) appendItemsFromPBoard:pasteboard asChildrenToItem:[CELL(4) identifier]];
    [verifyCount(undoManager, times(2)) endUndoGrouping];
}

- (void)testInsertLeftChildrenFromPBoard {
    [given([view rootCell]) willReturn:rootCell];
    [given([doc isNodeFolded:rootCell.identifier]) willReturnBool:YES];

    [dataSource mindmapView:view insertLeftChildrenFromPasteboard:pasteboard toItem:nil];

    [verify(undoManager) beginUndoGrouping];
    [verify(undoManager) setActionName:NSLocalizedString(@"undo.node.paste", @"Undo Paste")];
    [verify(doc) toggleFoldingForItem:rootCell.identifier];
    [verify(doc) appendItemsFromPBoard:pasteboard asLeftChildrenToItem:rootCell.identifier];
    [verify(undoManager) endUndoGrouping];
}

- (void)testInsertPreviousSiblingsFromPBoard {
    [dataSource mindmapView:view insertPreviousSiblingsFromPasteboard:pasteboard toItem:[CELL(4) identifier]];
    [verify(undoManager) beginUndoGrouping];
    [verify(undoManager) setActionName:NSLocalizedString(@"undo.node.paste", @"Undo Paste")];
    [verify(doc) appendItemsFromPBoard:pasteboard asPreviousSiblingToItem:[CELL(4) identifier]];
    [verify(undoManager) endUndoGrouping];
}

- (void)testInsertNextSiblingsFromPBoard {
    [dataSource mindmapView:view insertNextSiblingsFromPasteboard:pasteboard toItem:[CELL(4) identifier]];
    [verify(undoManager) beginUndoGrouping];
    [verify(undoManager) setActionName:NSLocalizedString(@"undo.node.paste", @"Undo Paste")];
    [verify(doc) appendItemsFromPBoard:pasteboard asNextSiblingToItem:[CELL(4) identifier]];
    [verify(undoManager) endUndoGrouping];
}

- (void)testPrepareDragAndDrop {
    QMNode *node1 = [[QMNode alloc] init];
    QMNode *node2 = [[QMNode alloc] init];

    QMCell *cell1 = [[QMCell alloc] init];
    QMCell *cell2 = [[QMCell alloc] init];

    cell1.identifier = node1;
    cell2.identifier = node2;

    node1.stringValue = @"this is really a random text";
    node2.stringValue = @"this is really a random text and this....";

    NSPasteboard *board = [NSPasteboard pasteboardWithName:NSDragPboard];
    [dataSource mindmapView:view prepareDragAndDropWithCells:@[cell1, cell2]];

    NSArray *array = [board readObjectsForClasses:@[[QMNode class]] options:nil];
    assertThat([array[0] stringValue], is(@"this is really a random text"));
    assertThat([array[1] stringValue], is(@"this is really a random text and this...."));
}

- (void)testSetString {
    [dataSource mindmapView:view setStringValue:@"test str str" ofItem:item];

    [verify(undoManager) beginUndoGrouping];
    [verify(undoManager) setActionName:NSLocalizedString(@"undo.node.text.change", @"Change Text of Node")];

    [verify(doc) setStringValue:@"test str str" ofItem:item];

    [verify(undoManager) endUndoGrouping];
}

- (void)testSetFont {
    NSFont *const font = [NSFont boldSystemFontOfSize:50];

    [dataSource mindmapView:view setFont:font ofItems:@[item, otherItem]];

    [verify(undoManager) beginUndoGrouping];
    [verify(undoManager) setActionName:NSLocalizedString(@"undo.node.font.change", @"Change Font of Node(s)")];

    [verify(doc) setFont:font ofItem:item];
    [verify(doc) setFont:font ofItem:otherItem];

    [verify(undoManager) endUndoGrouping];
}

- (void)testMoveItems {
    NSObject *object1 = [[NSObject alloc] init];
    NSObject *object2 = [[NSObject alloc] init];

    NSArray *itemsToMove = @[object1];
    [dataSource mindmapView:view moveItems:itemsToMove toItem:object2 inDirection:QMDirectionBottom];

    [verify(undoManager) beginUndoGrouping];
    [verify(undoManager) setActionName:NSLocalizedString(@"undo.node.move", @"Undo Move Node(s)")];

    [verify(doc) moveItems:itemsToMove toItem:object2 inDirection:QMDirectionBottom];

    [verify(undoManager) endUndoGrouping];
}

- (void)testCopyItems {
    NSObject *object1 = [[NSObject alloc] init];
    NSObject *object2 = [[NSObject alloc] init];

    NSArray *itemsToMove = @[object1];
    [dataSource mindmapView:view copyItems:itemsToMove toItem:object2 inDirection:QMDirectionBottom];

    [verify(undoManager) beginUndoGrouping];
    [verify(undoManager) setActionName:NSLocalizedString(@"undo.node.copy", @"Undo Copy Node(s)")];

    [verify(doc) copyItems:itemsToMove toItem:object2 inDirection:QMDirectionBottom];

    [verify(undoManager) endUndoGrouping];
}

- (void)testInsertChild {
    NSObject *object1 = [[NSObject alloc] init];

    [dataSource mindmapView:view addNewChildToItem:object1 atIndex:4];

    [verify(undoManager) beginUndoGrouping];
    [verify(undoManager) setActionName:NSLocalizedString(@"undo.node.child.new", @"New Child Node")];

    [verify(doc) addNewChildToItem:object1 atIndex:4];

    [verifyCount(undoManager, never()) endUndoGrouping];
}

- (void)testInsertLeftChild {
    NSObject *object1 = [[NSObject alloc] init];

    [dataSource mindmapView:view addNewLeftChildToItem:object1 atIndex:4];

    [verify(undoManager) beginUndoGrouping];
    [verify(undoManager) setActionName:NSLocalizedString(@"undo.node.child.left.new", @"New Left Child Node")];

    [verify(doc) addNewLeftChildToItem:object1 atIndex:4];

    [verifyCount(undoManager, never()) endUndoGrouping];
}

- (void)testInsertNextSibling {
    NSObject *object1 = [[NSObject alloc] init];

    [dataSource mindmapView:view addNewNextSiblingToItem:object1];

    [verify(undoManager) beginUndoGrouping];
    [verify(undoManager) setActionName:NSLocalizedString(@"undo.node.sibling.next.new", @"New Next Sibling Node")];

    [verify(doc) addNewNextSiblingToItem:object1];

    [verifyCount(undoManager, never()) endUndoGrouping];
}

- (void)testInsertPrevSibling {
    NSObject *object1 = [[NSObject alloc] init];

    [dataSource mindmapView:view addNewPreviousSiblingToItem:object1];

    [verify(undoManager) beginUndoGrouping];
    [verify(undoManager) setActionName:NSLocalizedString(@"undo.node.sibling.prev.new", @"New Previous Sibling Node")];

    [verify(doc) addNewPreviousSiblingToItem:object1];

    [verifyCount(undoManager, never()) endUndoGrouping];
}

- (void)testEditingEnded {
    NSObject *object1 = [[NSObject alloc] init];

    [dataSource mindmapView:view editingEndedForItem:object1];

    [verify(doc) markAsNotNew:object1];
}

- (void)testEditingCancelled {
    NSObject *object1 = [[NSObject alloc] init];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"test" attributes:[settings settingForKey:qSettingDefaultStringAttributeDict]];

    [given([doc itemIsNewlyCreated:object1]) willReturnBool:YES];
    [dataSource mindmapView:view editingCancelledForItem:object1 withAttrString:attrStr];

    [verify(undoManager) endUndoGrouping];
    [verify(undoManager) disableUndoRegistration];
    [verify(doc) setStringValue:@"test" ofItem:object1];
    [verify(doc) setFont:[settings settingForKey:qSettingDefaultFont] ofItem:object1];
    [verify(undoManager) enableUndoRegistration];
    [verify(doc) markAsNotNew:object1];
    [verify(undoManager) undo];

    [given([doc itemIsNewlyCreated:object1]) willReturnBool:NO];
    [dataSource mindmapView:view editingCancelledForItem:object1 withAttrString:nil];
    [verifyCount(undoManager, times(1)) endUndoGrouping];
    [verifyCount(undoManager, times(1)) undo];
}

- (void)testDeleteNode {
    NSObject *const object1 = [[NSObject alloc] init];
    NSObject *const object2 = [[NSObject alloc] init];

    [dataSource mindmapView:view deleteItems:@[object1, object2]];

    [verify(undoManager) beginUndoGrouping];
    [verify(undoManager) setActionName:NSLocalizedString(@"undo.node.deletion", @"Deletion of Node(s)")];

    [verify(doc) deleteItem:object1];
    [verify(doc) deleteItem:object2];

    [verify(undoManager) endUndoGrouping];
}

- (void)testToggleFolding {
    NSObject *obj = [[NSObject alloc] init];
    [dataSource mindmapView:view toggleFoldingForItem:obj];

    [verify(doc) toggleFoldingForItem:obj];
    [verify(doc) updateChangeCount:NSChangeDone];
}

- (void)testView {
    [given([doc numberOfChildrenOfNode:item]) willReturnUnsignedInteger:1];
    assertThat(@([dataSource mindmapView:view numberOfChildrenOfItem:item]), is(@(1)));

    [given([doc child:8 ofNode:item]) willReturn:otherItem];
    assertThat([dataSource mindmapView:view child:8 ofItem:item], is(otherItem));

    [given([doc numberOfLeftChildrenOfNode:item]) willReturnUnsignedInteger:3];
    assertThat(@([dataSource mindmapView:view numberOfLeftChildrenOfItem:item]), is(@(3)));

    [given([doc leftChild:1 ofNode:item]) willReturn:otherItem];
    assertThat([dataSource mindmapView:view leftChild:1 ofItem:item], is(otherItem));

    [given([doc isNodeFolded:item]) willReturnBool:YES];
    assertThat(@([dataSource mindmapView:view isItemFolded:item]), isYes);

    [given([doc isNodeLeaf:item]) willReturnBool:NO];
    assertThat(@([dataSource mindmapView:view isItemLeaf:item]), isNo);

    [given([doc stringValueOfNode:item]) willReturn:@"string"];
    assertThat([dataSource mindmapView:view stringValueOfItem:item], is(@"string"));

    NSFont *font = [NSFont boldSystemFontOfSize:12];
    [given([doc fontOfNode:item]) willReturn:font];
    assertThat([dataSource mindmapView:view fontOfItem:item], is(font));

    [given([doc isNodeLeft:item]) willReturnBool:YES];
    assertThat(@([dataSource mindmapView:view isItemLeft:item]), isYes);
}

- (void)testIcon {
    // return unicode, pdf, unsupported
    [given([doc iconsOfNode:item]) willReturn:@[@"full-1", @"kmail", @"fkfkf"]];
    NSArray *result = [dataSource mindmapView:view iconsOfItem:item];

    QMIcon *icon1 = result[0];
    QMIcon *icon2 = result[1];
    QMIcon *icon3 = result[2];

    assertThat(icon1.code, is(@"full-1"));
    assertThat(icon2.code, is(@"kmail"));
    assertThat(icon3.code, is(@"fkfkf"));
}

@end
