/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import "QMNode.h"
#import "QMBaseTestCase+Util.h"
#import "QMMindmapReader.h"
#import "QMMindmapWriter.h"
#import "QMRootNode.h"
#import "QMAppSettings.h"
#import "QMDocumentWindowController.h"
#import "QMDocument.h"
#import "QMMindmapView.h"

static NSString * const MINDMAP_FILE_NAME = @"mindmap-reader-test";
static NSString * const MINDMAP_EXTENSION = @"mm";

@interface DocumentTest : QMBaseTestCase
@end

@implementation DocumentTest {
    QMDocument *doc;

    QMMindmapReader *reader;
    QMMindmapWriter *writer;
    QMDocumentWindowController *controller;

    QMRootNode *rootNode;
    NSUndoManager *undoManager;
    NSPasteboard *pasteboard;
    QMAppSettings *settings;
}

- (void)setUp {
    [super setUp];

    settings = [[QMAppSettings alloc] init];

    reader = mock(QMMindmapReader.class);
    writer = mock(QMMindmapWriter.class);
    controller = mock([QMDocumentWindowController class]);
    undoManager = mock([NSUndoManager class]);
    pasteboard = mock([NSPasteboard class]);

    rootNode = [self rootNodeForTest];
    rootNode.undoManager = undoManager;

    doc = [[QMDocument alloc] init];
    doc.settings = settings;
    [doc setUndoManager:undoManager];
    [doc setInstanceVarTo:pasteboard];
    [doc setWindowController:controller];
    wireRootNodeOfDoc(doc, rootNode);
}

- (void)testCopyItemsToPasteboard {
    [doc copyItemsToPasteboard:@[NODE(3), NODE(5)]];

    [verify(pasteboard) clearContents];
    [verify(pasteboard) writeObjects:hasSize(2)];
    [verify(pasteboard) writeObjects:isNot(consistsOf(NODE(3), NODE(5)))];
}

- (void)testCutItemsToPasteboard {
    QMNode *node3 = NODE(3);
    QMNode *node5 = NODE(5);
    NSArray *const items = @[node3, node5];

    [doc cutItemsToPasteboard:items];

    assertThat(rootNode.children, hasSize(NUMBER_OF_CHILD - 2));
    assertThat(rootNode.children, isNot(hasItems(node3, node5, nil)));
    [verify(controller) clearSelection:anything()];
    [verify(pasteboard) clearContents];
    [verify(pasteboard) writeObjects:items];
}

- (void)testCutLeftItemsToPasteboard {
    QMNode *lnode3 = LNODE(3);
    QMNode *lnode5 = LNODE(5);
    NSArray *const itemsToPaste = @[lnode3, lnode5];
    [doc cutItemsToPasteboard:itemsToPaste];

    assertThat(rootNode.leftChildren, hasSize(NUMBER_OF_LEFT_CHILD - 2));
    assertThat(rootNode.leftChildren, isNot(hasItems(lnode3, lnode5, nil)));
    [verify(pasteboard) clearContents];
    [verify(pasteboard) writeObjects:itemsToPaste];
}

- (void)testAppendItemsFromPBoardAsChildren {
    QMNode *node1, *node2;
    [self createNodeOne:&node1 nodeTwo:&node2];

    [given([pasteboard readObjectsForClasses:consistsOf([QMNode class], [NSString class]) options:anything()]) willReturn:@[node1, node2]];
    [doc appendItemsFromPBoard:pasteboard asChildrenToItem:NODE(4)];

    assertThat([NODE(4) children], hasSize(NUMBER_OF_GRAND_CHILD + 2));
    assertThat(NODE(4, NUMBER_OF_GRAND_CHILD), is(node1));
    assertThat(NODE(4, NUMBER_OF_GRAND_CHILD + 1), is(node2));

    assertThat(node1.undoManager, is(undoManager));
    assertThat(node2.undoManager, is(undoManager));
    assertThat(node1.parent, is(NODE(4)));
    assertThat(node2.parent, is(NODE(4)));
    assertThat(node1.observerInfos, hasSize(5));
    assertThat(node2.observerInfos, hasSize(5));
    assertThat([[node1 objectInChildrenAtIndex:0] observerInfos], hasSize(5));
}

- (void)testAppendRootNodeFromPBoardAsChild {
    QMRootNode *rootToPaste = [[QMRootNode alloc] init];
    rootToPaste.stringValue = @"root to paste";
    [rootToPaste addObjectInIcons:@"anIcon"];

    QMNode *node1, *node2;
    [self createNodeOne:&node1 nodeTwo:&node2];
    [node1 addObjectInIcons:@"anIcon"];

    [rootToPaste addObjectInChildren:node1];
    [rootToPaste addObjectInLeftChildren:node2];

    [given([pasteboard readObjectsForClasses:consistsOf([QMNode class], [NSString class]) options:anything()]) willReturn:@[rootToPaste]];
    [doc appendItemsFromPBoard:pasteboard asChildrenToItem:NODE(4)];

    assertThat([NODE(4) children], hasSize(NUMBER_OF_GRAND_CHILD + 1));
    assertThat([NODE(4, NUMBER_OF_GRAND_CHILD) stringValue], is(rootToPaste.stringValue));

    assertThat([NODE(4, NUMBER_OF_GRAND_CHILD) icons], hasSize(1));
    assertThat([NODE(4, NUMBER_OF_GRAND_CHILD, 0) stringValue], is(node1.stringValue));
    assertThat([NODE(4, NUMBER_OF_GRAND_CHILD, 0) icons], hasSize(1));
    assertThat([NODE(4, NUMBER_OF_GRAND_CHILD, 0) children], hasSize(1));
    assertThat([NODE(4, NUMBER_OF_GRAND_CHILD, 1) stringValue], is(node2.stringValue));
}

- (void)testAppendTextAsChildFromPBoard {
    [given([pasteboard readObjectsForClasses:consistsOf([QMNode class], [NSString class]) options:anything()]) willReturn:@[@"test"]];
    [doc appendItemsFromPBoard:pasteboard asChildrenToItem:NODE(4)];

    assertThat([NODE(4) children], hasSize(NUMBER_OF_GRAND_CHILD + 1));
    QMNode *child = NODE(4, NUMBER_OF_GRAND_CHILD);

    assertThat(child.undoManager, is(undoManager));
    assertThat(child.parent, is(NODE(4)));
    assertThat(child.observerInfos, hasSize(5));
    assertThat(child.stringValue, is(@"test"));
}

- (void)testAppendNodesAsLeftChildFromPBoard {
    // we know that we use the same internal method to do this, thus, no duplicate tests...
    // however, if we should refactor the inner working of QMDoc, we should test this separately
    QMNode *node1, *node2;
    [self createNodeOne:&node1 nodeTwo:&node2];

    [given([pasteboard readObjectsForClasses:consistsOf([QMNode class], [NSString class]) options:anything()]) willReturn:@[node1, node2]];
    [doc appendItemsFromPBoard:pasteboard asLeftChildrenToItem:rootNode];

    assertThat([rootNode leftChildren], hasSize(NUMBER_OF_LEFT_CHILD + 2));
    assertThat(LNODE(NUMBER_OF_LEFT_CHILD), is(node1));
    assertThat(LNODE(NUMBER_OF_LEFT_CHILD + 1), is(node2));
}

- (void)testAppendNodesAsPrevSiblingFromPasteboard {
    QMNode *node1, *node2;
    [self createNodeOne:&node1 nodeTwo:&node2];

    [given([pasteboard readObjectsForClasses:consistsOf([QMNode class], [NSString class]) options:anything()]) willReturn:@[node1, node2]];
    [doc appendItemsFromPBoard:pasteboard asPreviousSiblingToItem:NODE(4, 4)];

    assertThat([NODE(4) children], hasSize(NUMBER_OF_GRAND_CHILD + 2));
    assertThat(NODE(4, 4), is(node1));
    assertThat(NODE(4, 5), is(node2));
}

- (void)createNodeOne:(QMNode **)node1 nodeTwo:(QMNode **)node2 {
    *node1 = [[QMNode alloc] init];
    [*node1 setStringValue:@"node 1 from pasteboard"];

    QMNode *child1 = [[QMNode alloc] init];
    child1.stringValue = @"child of node 1 from pasteboard";

    [*node1 addObjectInChildren:child1];

    *node2 = [[QMNode alloc] init];
    [*node2 setStringValue:@"node 2 from pasteboard"];
}

- (void)testAppendNodesAsLeftPrevSiblingFromPasteboard {
    QMNode *node1, *node2;
    [self createNodeOne:&node1 nodeTwo:&node2];

    [given([pasteboard readObjectsForClasses:consistsOf([QMNode class], [NSString class]) options:anything()]) willReturn:@[node1, node2]];
    [doc appendItemsFromPBoard:pasteboard asPreviousSiblingToItem:LNODE(4)];

    assertThat([rootNode leftChildren], hasSize(NUMBER_OF_LEFT_CHILD + 2));
    assertThat([rootNode objectInLeftChildrenAtIndex:4], is(node1));
    assertThat([rootNode objectInLeftChildrenAtIndex:5], is(node2));
}

- (void)testAppendNodesAsLeftNextSiblingFromPasteboard {
    QMNode *node1, *node2;
    [self createNodeOne:&node1 nodeTwo:&node2];

    [given([pasteboard readObjectsForClasses:consistsOf([QMNode class], [NSString class]) options:anything()]) willReturn:@[node1, node2]];
    [doc appendItemsFromPBoard:pasteboard asNextSiblingToItem:LNODE(4)];

    assertThat([rootNode leftChildren], hasSize(NUMBER_OF_LEFT_CHILD + 2));
    assertThat([rootNode objectInLeftChildrenAtIndex:5], is(node1));
    assertThat([rootNode objectInLeftChildrenAtIndex:6], is(node2));
}

- (void)testAppendNodesAsNextSiblingFromPasteboard {
    QMNode *node1, *node2;
    [self createNodeOne:&node1 nodeTwo:&node2];

    [given([pasteboard readObjectsForClasses:consistsOf([QMNode class], [NSString class]) options:anything()]) willReturn:@[node1, node2]];
    [doc appendItemsFromPBoard:pasteboard asNextSiblingToItem:NODE(4, 4)];

    assertThat([NODE(4) children], hasSize(NUMBER_OF_GRAND_CHILD + 2));
    assertThat([NODE(4) objectInChildrenAtIndex:5], is(node1));
    assertThat([NODE(4) objectInChildrenAtIndex:6], is(node2));
}

- (void)testMoveItemsToDescendant {
    QMNode *nodeToMove1 = NODE(3);
    QMNode *nodeToMove2 = NODE(5);
    QMNode *targetNode = NODE(3, 1);
    QMRootNode *sourceNode = rootNode;
    [doc moveItems:@[nodeToMove1, nodeToMove2] toItem:targetNode inDirection:QMDirectionLeft];

    assertThat(sourceNode.children, hasSize(NUMBER_OF_CHILD));
    assertThat(sourceNode.children, hasItems(nodeToMove1, nodeToMove2, nil));
    assertThat([targetNode children], isNot(hasItems(nodeToMove1, nodeToMove2, nil)));
}

- (void)testMoveItemsLeftToNonRootNode {
    QMNode *nodeToMove1 = NODE(3);
    QMNode *nodeToMove2 = NODE(5);
    QMNode *targetNode = LNODE(4);
    QMRootNode *sourceNode = rootNode;
    [doc moveItems:@[nodeToMove1, nodeToMove2] toItem:targetNode inDirection:QMDirectionLeft];

    assertThat(sourceNode.children, hasSize(NUMBER_OF_CHILD - 2));
    assertThat(sourceNode.children, isNot(hasItems(nodeToMove1, nodeToMove2, nil)));
    assertThat([targetNode children], hasItems(nodeToMove1, nodeToMove2, nil));
    assertThat([targetNode objectInChildrenAtIndex:NUMBER_OF_LEFT_GRAND_CHILD], is(nodeToMove1));
    assertThat([targetNode objectInChildrenAtIndex:NUMBER_OF_LEFT_GRAND_CHILD + 1], is(nodeToMove2));
}

- (void)testMoveItemsRightToNonRootNode {
    QMNode *nodeToMove1 = LNODE(3);
    QMNode *nodeToMove2 = LNODE(5);
    QMNode *targetNode = NODE(4);
    QMRootNode *sourceNode = rootNode;
    [doc moveItems:@[nodeToMove1, nodeToMove2] toItem:targetNode inDirection:QMDirectionRight];

    assertThat(sourceNode.leftChildren, hasSize(NUMBER_OF_LEFT_CHILD - 2));
    assertThat(sourceNode.leftChildren, isNot(hasItems(nodeToMove1, nodeToMove2, nil)));
    assertThat([targetNode children], hasItems(nodeToMove1, nodeToMove2, nil));
    assertThat([targetNode objectInChildrenAtIndex:NUMBER_OF_GRAND_CHILD], is(nodeToMove1));
    assertThat([targetNode objectInChildrenAtIndex:NUMBER_OF_GRAND_CHILD + 1], is(nodeToMove2));
}

- (void)testMoveItemsTopToNonRootNode {
    QMRootNode *sourceNode = LNODE(3);
    QMNode *nodeToMove1 = LNODE(3, 0);
    QMNode *nodeToMove2 = LNODE(3, 1);
    QMNode *targetNode = NODE(4);
    [doc moveItems:@[nodeToMove1, nodeToMove2] toItem:targetNode inDirection:QMDirectionTop];

    assertThat(sourceNode.children, hasSize(NUMBER_OF_LEFT_GRAND_CHILD - 2));
    assertThat(sourceNode.children, isNot(hasItems(nodeToMove1, nodeToMove2, nil)));

    QMRootNode *parentOfTargetNode = rootNode;
    assertThat(parentOfTargetNode.children, hasItems(nodeToMove1, nodeToMove2, nil));
    assertThat([parentOfTargetNode objectInChildrenAtIndex:4], is(nodeToMove1));
    assertThat([parentOfTargetNode objectInChildrenAtIndex:5], is(nodeToMove2));
    assertThat([parentOfTargetNode objectInChildrenAtIndex:6], is(targetNode));
}

- (void)testMoveItemsBottomToNonRootNode {
    QMNode *sourceNode = NODE(3);
    QMNode *nodeToMove1 = NODE(3, 0);
    QMNode *nodeToMove2 = NODE(3, 1);
    QMNode *targetNode = LNODE(4);
    [doc moveItems:@[nodeToMove1, nodeToMove2] toItem:targetNode inDirection:QMDirectionBottom];

    assertThat(sourceNode.children, hasSize(NUMBER_OF_GRAND_CHILD - 2));
    assertThat(sourceNode.children, isNot(hasItems(nodeToMove1, nodeToMove2, nil)));

    QMRootNode *parentOfTargetNode = rootNode;
    assertThat(parentOfTargetNode.leftChildren, hasItems(nodeToMove1, nodeToMove2, nil));
    assertThat([parentOfTargetNode objectInLeftChildrenAtIndex:4], is(targetNode));
    assertThat([parentOfTargetNode objectInLeftChildrenAtIndex:5], is(nodeToMove1));
    assertThat([parentOfTargetNode objectInLeftChildrenAtIndex:6], is(nodeToMove2));
}

- (void)testMoveItemsLeftToRootNode {
    QMNode *sourceNode = NODE(3);
    QMNode *nodeToMove1 = NODE(3, 0);
    QMNode *nodeToMove2 = NODE(3, 1);
    QMRootNode *targetNode= rootNode;
    [doc moveItems:@[nodeToMove1, nodeToMove2] toItem:targetNode inDirection:QMDirectionLeft];

    assertThat(sourceNode.children, hasSize(NUMBER_OF_GRAND_CHILD - 2));
    assertThat(sourceNode.children, isNot(hasItems(nodeToMove1, nodeToMove2, nil)));
    assertThat(targetNode.leftChildren, hasItems(nodeToMove1, nodeToMove2, nil));
    assertThat([targetNode objectInLeftChildrenAtIndex:NUMBER_OF_LEFT_CHILD], is(nodeToMove1));
    assertThat([targetNode objectInLeftChildrenAtIndex:NUMBER_OF_LEFT_CHILD + 1], is(nodeToMove2));
}

- (void)testMoveItemsRightToRootNode {
    QMNode *sourceNode = NODE(3);
    QMNode *nodeToMove1 = NODE(3, 0);
    QMNode *nodeToMove2 = NODE(3, 1);
    QMRootNode *targetNode= rootNode;
    [doc moveItems:@[nodeToMove1, nodeToMove2] toItem:targetNode inDirection:QMDirectionRight];

    assertThat(sourceNode.children, hasSize(NUMBER_OF_GRAND_CHILD - 2));
    assertThat(sourceNode.children, isNot(hasItems(nodeToMove1, nodeToMove2, nil)));
    assertThat([targetNode children], hasItems(nodeToMove1, nodeToMove2, nil));
    assertThat([targetNode objectInChildrenAtIndex:NUMBER_OF_CHILD], is(nodeToMove1));
    assertThat([targetNode objectInChildrenAtIndex:NUMBER_OF_CHILD + 1], is(nodeToMove2));
}

- (void)testMoveItemsTopAndBottomToRootNode {
    QMNode *sourceNode = NODE(3);
    QMNode *nodeToMove1 = NODE(3, 0);
    QMNode *nodeToMove2 = NODE(3, 1);
    QMRootNode *targetNode= rootNode;
    [doc moveItems:@[nodeToMove1, nodeToMove2] toItem:targetNode inDirection:QMDirectionTop];

    assertThat(sourceNode.children, hasSize(NUMBER_OF_GRAND_CHILD));
    assertThat(sourceNode.children, hasItems(nodeToMove1, nodeToMove2, nil));
    assertThat(targetNode.allChildren, isNot(hasItems(nodeToMove1, nodeToMove2, nil)));
    assertThat(@([targetNode countOfAllChildren]), is(@(NUMBER_OF_CHILD + NUMBER_OF_LEFT_CHILD)));

    [doc moveItems:@[nodeToMove1, nodeToMove2] toItem:targetNode inDirection:QMDirectionBottom];

    assertThat(sourceNode.children, hasSize(NUMBER_OF_GRAND_CHILD));
    assertThat(sourceNode.children, hasItems(nodeToMove1, nodeToMove2, nil));
    assertThat(targetNode.allChildren, isNot(hasItems(nodeToMove1, nodeToMove2, nil)));
    assertThat(@([targetNode countOfAllChildren]), is(@(NUMBER_OF_CHILD + NUMBER_OF_LEFT_CHILD)));
}

- (void)testAddNewChildNode {
    QMNode *old01 = NODE(0, 1);

    [doc addNewChildToItem:NODE(0) atIndex:1];

    assertThatUnsignedInteger([NODE(0) countOfChildren], equalToInt(NUMBER_OF_CHILD + 1));
    assertThat(NODE(0, 1), isNot(old01));
    assertThat([NODE(0, 1) undoManager], is(undoManager));
    assertThatBool([NODE(0, 1) isCreatedNewly], isTrue);

    QObserverInfo *strInfo = [[QObserverInfo alloc] initWithObserver:doc keyPath:qNodeStringValueKey];
    QObserverInfo *fontInfo = [[QObserverInfo alloc] initWithObserver:doc keyPath:qNodeFontKey];
    QObserverInfo *childrenInfo = [[QObserverInfo alloc] initWithObserver:doc keyPath:qNodeChildrenKey];
    QObserverInfo *foldingInfo = [[QObserverInfo alloc] initWithObserver:doc keyPath:qNodeFoldingKey];
    QObserverInfo *iconsInfo = [[QObserverInfo alloc] initWithObserver:doc keyPath:qNodeIconsKey];

    assertThat([NODE(0, 1) observerInfos], consistsOfInAnyOrder(strInfo, fontInfo, childrenInfo, foldingInfo, iconsInfo));
}

- (void)testAddNewLeftChildNode {
    QMNode *old1 = LNODE(1);

    [doc addNewLeftChildToItem:rootNode atIndex:1];

    assertThatUnsignedInteger([rootNode countOfLeftChildren], equalToInt(NUMBER_OF_LEFT_CHILD + 1));
    assertThat(LNODE(1), isNot(old1));
    assertThat([LNODE(1) undoManager], is(undoManager));
    assertThatBool([LNODE(1) isCreatedNewly], isTrue);
}

- (void)testAddNewNextSiblingNode {
    QMNode *old02 = NODE(0, 2);

    [doc addNewNextSiblingToItem:NODE(0, 1)];

    assertThatUnsignedInteger([NODE(0) countOfChildren], equalToInt(NUMBER_OF_GRAND_CHILD + 1));
    assertThat(NODE(0, 2), isNot(old02));
    assertThat([NODE(0, 2) undoManager], is(undoManager));
    assertThatBool([NODE(0, 2) isCreatedNewly], isTrue);

    QMNode *old02l = LNODE(0, 2);

    [doc addNewNextSiblingToItem:LNODE(0, 1)];

    assertThatUnsignedInteger([LNODE(0) countOfChildren], equalToInt(NUMBER_OF_LEFT_GRAND_CHILD + 1));
    assertThat(LNODE(0, 2), isNot(old02l));
    assertThat([LNODE(0, 2) undoManager], is(undoManager));
    assertThatBool([LNODE(0, 2) isCreatedNewly], isTrue);
}

/**
* @bug
*/
- (void)testAddNewNextSiblingNodeParentRootLeft {
    QMNode *old3 = LNODE(3);

    [doc addNewNextSiblingToItem:LNODE(2)];

    assertThatUnsignedInteger([rootNode countOfLeftChildren], equalToInt(NUMBER_OF_LEFT_CHILD + 1));
    assertThat(LNODE(3), isNot(old3));
    assertThat([LNODE(3) undoManager], is(undoManager));
    assertThatBool([LNODE(3) isCreatedNewly], isTrue);
}

/**
* @bug
*/
- (void)testAddNewPrevSiblingNodeParentRootLeft {
    QMNode *old2 = LNODE(2);

    [doc addNewPreviousSiblingToItem:LNODE(2)];

    assertThatUnsignedInteger([rootNode countOfLeftChildren], equalToInt(NUMBER_OF_LEFT_CHILD + 1));
    assertThat(LNODE(2), isNot(old2));
    assertThat([LNODE(2) undoManager], is(undoManager));
    assertThatBool([LNODE(2) isCreatedNewly], isTrue);
}

- (void)testAddNewPrevSiblingNode {
    QMNode *old01 = NODE(0, 1);

    [doc addNewPreviousSiblingToItem:NODE(0, 1)];

    assertThatUnsignedInteger([NODE(0) countOfChildren], equalToInt(NUMBER_OF_GRAND_CHILD + 1));
    assertThat(NODE(0, 1), isNot(old01));
    assertThat([NODE(0, 1) undoManager], is(undoManager));
    assertThatBool([NODE(0, 1) isCreatedNewly], isTrue);

    QMNode *old01l = LNODE(0, 1);

    [doc addNewPreviousSiblingToItem:LNODE(0, 1)];

    assertThatUnsignedInteger([LNODE(0) countOfChildren], equalToInt(NUMBER_OF_LEFT_GRAND_CHILD + 1));
    assertThat(LNODE(0, 1), isNot(old01l));
    assertThat([LNODE(0, 1) undoManager], is(undoManager));
    assertThatBool([LNODE(0, 1) isCreatedNewly], isTrue);
}

- (void)testNodeDao {
    NSFont *font = [NSFont boldSystemFontOfSize:20];

    doc = [[QMDocument alloc] initWithType:qMindmapUti error:NULL];
    [doc setInstanceVarTo:reader];

    rootNode.stringValue = @"root";
    rootNode.folded = YES;

    QMNode *child = NODE(0);
    child.stringValue = @"child";
    child.font = font;
    [child insertObject:@"icon1" inIconsAtIndex:0];

    QMNode *leftChild = LNODE(0);
    QMNode *otherLeftChild = LNODE(1);
    QMNode *grandLeftChild = LNODE(0, 1);

    [given([reader rootNodeForFileUrl:instanceOf(NSURL.class)]) willReturn:rootNode];
    [doc setFileURL:[self urlForResource:MINDMAP_FILE_NAME extension:MINDMAP_EXTENSION]];
    [doc readFromFileWrapper:[self fileWrapperForResource:MINDMAP_FILE_NAME extension:MINDMAP_EXTENSION] ofType:qMindmapUti error:NULL];

    assertThatInteger([doc numberOfChildrenOfNode:nil], equalToInt(NUMBER_OF_CHILD));
    assertThatInteger([doc numberOfLeftChildrenOfNode:nil], equalToInt(NUMBER_OF_LEFT_CHILD));
    assertThatInteger([doc numberOfChildrenOfNode:child], equalToInt(NUMBER_OF_GRAND_CHILD));
    assertThatInteger([doc numberOfChildrenOfNode:leftChild], equalToInt(NUMBER_OF_GRAND_CHILD));
    assertThatInteger([doc numberOfLeftChildrenOfNode:leftChild], equalToInt(0));
    assertThatInteger([doc numberOfChildrenOfNode:otherLeftChild], equalToInt(NUMBER_OF_LEFT_GRAND_CHILD));

    assertThat([doc child:0 ofNode:nil], equalTo(child));
    assertThat([doc leftChild:0 ofNode:nil], equalTo(leftChild));
    assertThat([doc leftChild:1 ofNode:nil], equalTo(otherLeftChild));

    assertThatBool([doc isNodeFolded:nil], isFalse);
    assertThatBool([doc isNodeLeaf:nil], isFalse);

    assertThatBool([doc isNodeLeaf:LNODE(0, 2)], isTrue);
    assertThatBool([doc isNodeLeaf:NODE(1, 6)], isTrue);

    assertThat([doc stringValueOfNode:nil], equalTo(@"root"));
    assertThat([doc stringValueOfNode:child], equalTo(@"child"));

    assertThat([doc fontOfNode:nil], nilValue());
    assertThat([doc fontOfNode:child], equalTo(font));

    assertThat([doc iconsOfNode:child], hasSize(1));
    assertThat([doc iconsOfNode:child], contains(equalTo(@"icon1"), nil));

    assertThatBool([doc isNodeLeft:nil], isFalse);
    assertThatBool([doc isNodeLeft:rootNode], isFalse);
    assertThatBool([doc isNodeLeft:child], isFalse);
    assertThatBool([doc isNodeLeft:leftChild], isTrue);
    assertThatBool([doc isNodeLeft:otherLeftChild], isTrue);
    assertThatBool([doc isNodeLeft:grandLeftChild], isTrue);
}

- (void)testNodeIdentifier {
    assertThat([doc identifierForItem:nil], is(rootNode));
    assertThat([doc identifierForItem:NODE(1)], is(NODE(1)));
    assertThat([doc identifierForItem:LNODE(4)], is(LNODE(4)));
}

- (void)testNodeSetStringValue {
    [doc setStringValue:@"new root node string" ofItem:rootNode];
    assertThat(rootNode.stringValue, is(@"new root node string"));

    [doc setStringValue:@"new right node string" ofItem:NODE(4, 1)];
    assertThat([NODE(4, 1) stringValue], is(@"new right node string"));

    [doc setStringValue:@"new left node string" ofItem:LNODE(4, 1)];
    assertThat([LNODE(4, 1) stringValue], is(@"new left node string"));
}

- (void)testAddIcon {
    [doc addIcon:@"icon1" toItem:NODE(1)];
    assertThat([NODE(1) icons], consistsOf(@"icon1"));

    [doc addIcon:@"icon2" toItem:NODE(1)];
    assertThat([NODE(1) icons], consistsOf(@"icon1", @"icon2"));
}

- (void)testDeleteIcon {
    [NODE(1) addObjectInIcons:@"icon1"];
    [NODE(1) addObjectInIcons:@"icon2"];
    [NODE(1) addObjectInIcons:@"icon3"];

    [doc deleteIconOfItem:NODE(1) atIndex:1];
    assertThat([NODE(1) icons], consistsOf(@"icon1", @"icon3"));

    [doc deleteIconOfItem:NODE(1) atIndex:0];
    assertThat([NODE(1) icons], consistsOf(@"icon3"));
}

- (void)testDeleteAllIcons {
    [NODE(1) addObjectInIcons:@"icon1"];
    [NODE(1) addObjectInIcons:@"icon2"];
    [NODE(1) addObjectInIcons:@"icon3"];

    [doc deleteAllIconsOfItem:NODE(1)];
    assertThat([NODE(1) icons], isEmpty());
}

- (void)testItemNewlyCreated {
    [NODE(1) setCreatedNewly:YES];
    assertThatBool([doc itemIsNewlyCreated:NODE(1)], isTrue);

    assertThatBool([doc itemIsNewlyCreated:NODE(3)], isFalse);
}

- (void)testNodeSetFont {
    NSFont *newFont = [NSFont boldSystemFontOfSize:50];

    [doc setFont:newFont ofItem:rootNode];
    assertThat(rootNode.font, is(newFont));

    [doc setFont:newFont ofItem:NODE(4, 1)];
    assertThat([NODE(4, 1) font], is(newFont));

    [doc setFont:newFont ofItem:LNODE(4, 1)];
    assertThat([LNODE(4, 1) font], is(newFont));

    newFont = [settings settingForKey:qSettingDefaultFont];
    [doc setFont:newFont ofItem:NODE(3)];
    assertThat([NODE(3) font], is(nilValue()));

    /**
    * @bug
    */
    [doc setFont:newFont ofItem:LNODE(4, 1)];
    assertThat([LNODE(4, 1) font], is(nilValue()));
}

- (void)testMarkAsNotNew {
    [NODE(1) setCreatedNewly:YES];

    [doc markAsNotNew:NODE(1)];
    assertThatBool([NODE(1) isCreatedNewly], isFalse);
}

- (void)testNodeDelete {
    NSUInteger oldCount = rootNode.countOfLeftChildren;
    QMNode *nodeToDel = LNODE(4);
    [doc deleteItem:nodeToDel];
    assertThat(rootNode.leftChildren, hasSize(oldCount - 1));
    assertThat(rootNode.leftChildren, isNot(hasItem(nodeToDel)));

    oldCount = rootNode.countOfChildren;
    nodeToDel = NODE(9);
    [doc deleteItem:nodeToDel];
    assertThat(rootNode.children, hasSize(oldCount - 1));
    assertThat(rootNode.children, isNot(hasItem(nodeToDel)));

    oldCount = [NODE(1) countOfChildren];
    nodeToDel = NODE(1, 5);
    [doc deleteItem:nodeToDel];
    assertThat([NODE(1) children], hasSize(oldCount - 1));
    assertThat([NODE(1) children], isNot(hasItem(nodeToDel)));

    oldCount = [LNODE(1) countOfChildren];
    nodeToDel = LNODE(1, 5);
    [doc deleteItem:nodeToDel];
    assertThat([LNODE(1) children], hasSize(oldCount - 1));
    assertThat([LNODE(1) children], isNot(hasItem(nodeToDel)));
}

- (void)testToggleFolding {
    [NODE(4) setFolded:NO];
    [doc toggleFoldingForItem:NODE(4)];
    assertThatBool([NODE(4) isFolded], isTrue);

    [doc toggleFoldingForItem:NODE(4)];
    assertThatBool([NODE(4) isFolded], isFalse);

    [doc toggleFoldingForItem:rootNode];
    assertThatBool([rootNode isFolded], isFalse);

    assertThatBool([NODE(5, 1) isFolded], isFalse);
    [doc toggleFoldingForItem:NODE(5, 1)];
    assertThatBool([NODE(5, 1) isFolded], isFalse);
}

- (void)testNewDoc {
    doc = [[QMDocument alloc] initWithType:qMindmapUti error:NULL];
    assertThat(doc, notNilValue());
    assertThat([doc instanceVarOfClass:[QMRootNode class]], isNot(nilValue()));
}

- (void)testMakeWindowControllers {
    doc = [[QMDocument alloc] initWithType:qMindmapUti error:NULL];
    [doc makeWindowControllers];

    assertThat(doc.windowController, notNilValue());
}

- (void)testWrongType {
    doc = [[QMDocument alloc] initWithType:@"fds" error:NULL];

    assertThat(doc, nilValue());
}

- (void)testOpenDoc {
    doc = [[QMDocument alloc] initWithType:qMindmapUti error:NULL];
    [doc setInstanceVarTo:reader];

    [given([reader rootNodeForFileUrl:anything()]) willReturn:rootNode];

    [doc readFromFileWrapper:[self fileWrapperForResource:MINDMAP_FILE_NAME extension:MINDMAP_EXTENSION] ofType:qMindmapUti error:NULL];

    assertThat(rootNode.undoManager, equalTo(doc.undoManager));
    assertThat([NODE(1) undoManager], equalTo(doc.undoManager));
    assertThat([LNODE(4, 1) undoManager], equalTo(doc.undoManager));
}

- (void)testOpenDocWithError {
    doc = [[QMDocument alloc] initWithType:qMindmapUti error:NULL];
    [doc setInstanceVarTo:reader];

    [given([reader rootNodeForFileUrl:anything()]) willReturn:nil];
    NSFileWrapper *const wrapper = [self fileWrapperForResource:@"document-test-fail-open" extension:MINDMAP_EXTENSION];

    assertThatBool([doc readFromFileWrapper:wrapper ofType:qMindmapUti error:NULL], isFalse);
}

- (void)testNewDocObserver {
    doc = [[QMDocument alloc] initWithType:qMindmapUti error:NULL];
    [doc setWindowController:controller];
    [doc setUndoManager:undoManager];

    QObserverInfo *strInfo = [[QObserverInfo alloc] initWithObserver:doc keyPath:qNodeStringValueKey];
    QObserverInfo *fontInfo = [[QObserverInfo alloc] initWithObserver:doc keyPath:qNodeFontKey];
    QObserverInfo *childrenInfo = [[QObserverInfo alloc] initWithObserver:doc keyPath:qNodeChildrenKey];
    QObserverInfo *leftChildrenInfo = [[QObserverInfo alloc] initWithObserver:doc keyPath:qNodeLeftChildrenKey];
    QObserverInfo *foldingInfo = [[QObserverInfo alloc] initWithObserver:doc keyPath:qNodeFoldingKey];
    QObserverInfo *iconsInfo = [[QObserverInfo alloc] initWithObserver:doc keyPath:qNodeIconsKey];

    id const docRootNode = [doc instanceVarOfClass:[QMRootNode class]];

    assertThat([docRootNode observerInfos], consistsOfInAnyOrder(strInfo, fontInfo, childrenInfo, leftChildrenInfo, foldingInfo, iconsInfo));

    [docRootNode setStringValue:@"change it!"];
    [verify(controller) updateCellWithIdentifier:docRootNode];
}

- (void)testOpenDocObserver {
    // in setUp we set this, but we need to start with an unspoiled rootNode.
    [rootNode removeObserver:doc];

    doc = [[QMDocument alloc] init];
    [doc setInstanceVarTo:reader];
    [doc setWindowController:controller];

    [given([reader rootNodeForFileUrl:anything()]) willReturn:rootNode];
    [doc readFromFileWrapper:[self fileWrapperForResource:MINDMAP_FILE_NAME extension:MINDMAP_EXTENSION] ofType:qMindmapUti error:NULL];

    QObserverInfo *strInfo = [[QObserverInfo alloc] initWithObserver:doc keyPath:qNodeStringValueKey];
    QObserverInfo *fontInfo = [[QObserverInfo alloc] initWithObserver:doc keyPath:qNodeFontKey];
    QObserverInfo *childrenInfo = [[QObserverInfo alloc] initWithObserver:doc keyPath:qNodeChildrenKey];
    QObserverInfo *leftChildrenInfo = [[QObserverInfo alloc] initWithObserver:doc keyPath:qNodeLeftChildrenKey];
    QObserverInfo *foldingInfo = [[QObserverInfo alloc] initWithObserver:doc keyPath:qNodeFoldingKey];
    QObserverInfo *iconsInfo = [[QObserverInfo alloc] initWithObserver:doc keyPath:qNodeIconsKey];

    assertThat(rootNode.observerInfos, consistsOfInAnyOrder(strInfo, fontInfo, childrenInfo, leftChildrenInfo, foldingInfo, iconsInfo));
    assertThat([NODE(1, 4) observerInfos], consistsOfInAnyOrder(strInfo, fontInfo, childrenInfo, foldingInfo, iconsInfo));
    assertThat([LNODE(5) observerInfos], consistsOfInAnyOrder(strInfo, fontInfo, childrenInfo, foldingInfo, iconsInfo));
}

- (void)testWriteDoc {
    doc = [[QMDocument alloc] initWithType:qMindmapUti error:NULL];
    [doc setInstanceVarTo:reader];
    [doc setInstanceVarTo:writer];

    [given([reader rootNodeForFileUrl:instanceOf(NSURL.class)]) willReturn:[[QMRootNode alloc] init]];
    [doc setFileURL:[self urlForResource:MINDMAP_FILE_NAME extension:MINDMAP_EXTENSION]];
    [doc readFromFileWrapper:[self fileWrapperForResource:MINDMAP_FILE_NAME extension:MINDMAP_EXTENSION] ofType:qMindmapUti error:NULL];

    [doc fileWrapperOfType:qMindmapUti error:NULL];
    [verify(writer) dataForRootNode:instanceOf(QMNode.class)];
}

- (void)testObserveNonExistingKey {
    [doc observeValueForKeyPath:@"nonExisting" ofObject:rootNode change:nil context:NULL];
    [verifyCount(controller, never()) updateCellWithIdentifier:rootNode];
}

- (void)testObserveNodeString {
    [doc observeValueForKeyPath:qNodeStringValueKey ofObject:rootNode change:nil context:NULL];
    [verify(controller) updateCellWithIdentifier:rootNode];
}

- (void)testObserveNodeFont {
    [doc observeValueForKeyPath:qNodeFontKey ofObject:rootNode change:nil context:NULL];
    [verify(controller) updateCellWithIdentifier:rootNode];
}

- (void)testObserveNodeIconInsertion {
    NSMutableDictionary *changeDict = [[NSMutableDictionary alloc] init];
    [changeDict setObject:[NSNumber numberWithUnsignedInteger:NSKeyValueChangeInsertion] forKey:NSKeyValueChangeKindKey];

    [doc observeValueForKeyPath:qNodeIconsKey ofObject:rootNode change:changeDict context:NULL];
    [verify(controller) updateCellWithIdentifier:rootNode];
}

- (void)testObserveNodeIconRemoval {
    NSMutableDictionary *changeDict = [[NSMutableDictionary alloc] init];
    [changeDict setObject:[NSNumber numberWithUnsignedInteger:NSKeyValueChangeRemoval] forKey:NSKeyValueChangeKindKey];

    [doc observeValueForKeyPath:qNodeIconsKey ofObject:rootNode change:changeDict context:NULL];
    [verify(controller) updateCellWithIdentifier:rootNode];
}

- (void)testObserveChildrenDeletion {
    NSMutableDictionary *changeDict = [[NSMutableDictionary alloc] init];
    [changeDict setObject:[NSNumber numberWithUnsignedInteger:NSKeyValueChangeRemoval] forKey:NSKeyValueChangeKindKey];

    [doc observeValueForKeyPath:qNodeChildrenKey ofObject:rootNode change:changeDict context:NULL];
    [verify(controller) updateCellForChildRemovalWithIdentifier:rootNode];

    [doc observeValueForKeyPath:qNodeLeftChildrenKey ofObject:rootNode change:changeDict context:NULL];
    [verify(controller) updateCellForLeftChildRemovalWithIdentifier:rootNode];
}

- (void)testObserveChildrenInsertion {
    QMNode *insertedNode = [[QMNode alloc] init];

    NSMutableDictionary *changeDict = [[NSMutableDictionary alloc] init];
    [changeDict setObject:[NSNumber numberWithUnsignedInteger:NSKeyValueChangeInsertion] forKey:NSKeyValueChangeKindKey];
    [changeDict setObject:[NSArray arrayWithObject:insertedNode] forKey:NSKeyValueChangeNewKey];

    [doc observeValueForKeyPath:qNodeChildrenKey ofObject:rootNode change:changeDict context:NULL];
    [verify(controller) updateCellForChildInsertionWithIdentifier:rootNode];

    [doc observeValueForKeyPath:qNodeLeftChildrenKey ofObject:rootNode change:changeDict context:NULL];
    [verify(controller) updateCellForLeftChildInsertionWithIdentifier:rootNode];
}

- (void)testDescendantOfNode {
    assertThat(@([doc item:NODE(4, 1) isDescendantOfItem:rootNode]), isYes);
    assertThat(@([doc item:LNODE(2, 1) isDescendantOfItem:rootNode]), isYes);
    assertThat(@([doc item:NODE(2, 1) isDescendantOfItem:NODE(2)]), isYes);
    assertThat(@([doc item:LNODE(5, 1) isDescendantOfItem:LNODE(5)]), isYes);

    assertThat(@([doc item:NODE(4, 1) isDescendantOfItem:LNODE(4)]), isNo);
    assertThat(@([doc item:LNODE(2, 1) isDescendantOfItem:NODE(2)]), isNo);
    assertThat(@([doc item:NODE(2, 1) isDescendantOfItem:NODE(3)]), isNo);
    assertThat(@([doc item:LNODE(5, 1) isDescendantOfItem:LNODE(1)]), isNo);
}

- (void)testObserveNewChildrenInsertion {
    QMNode *insertedNode = [[QMNode alloc] init];
    insertedNode.createdNewly = YES;

    NSMutableDictionary *changeDict = [[NSMutableDictionary alloc] init];
    [changeDict setObject:[NSNumber numberWithUnsignedInteger:NSKeyValueChangeInsertion] forKey:NSKeyValueChangeKindKey];
    [changeDict setObject:[NSArray arrayWithObject:insertedNode] forKey:NSKeyValueChangeNewKey];

    [doc observeValueForKeyPath:qNodeChildrenKey ofObject:rootNode change:changeDict context:NULL];
    [verify(controller) updateCellWithIdentifier:rootNode withNewChild:insertedNode];

    [doc observeValueForKeyPath:qNodeLeftChildrenKey ofObject:rootNode change:changeDict context:NULL];
    [verify(controller) updateCellWithIdentifier:rootNode withNewLeftChild:insertedNode];
}

- (void)testObserveFolding {
    QMNode *foldedNode = [[QMNode alloc] init];

    [doc observeValueForKeyPath:qNodeFoldingKey ofObject:foldedNode change:nil context:NULL];
    [verify(controller) updateCellFoldingWithIdentifier:foldedNode];
}

- (void)testCopyItemsToDescendant {
    QMNode *nodeToMove1 = NODE(3);
    QMNode *nodeToMove2 = NODE(5);
    QMNode *targetNode = NODE(3, 1);
    QMRootNode *sourceNode = rootNode;
    [doc copyItems:@[nodeToMove1, nodeToMove2] toItem:targetNode inDirection:QMDirectionLeft];

    assertThat(sourceNode.children, hasSize(NUMBER_OF_CHILD));
    assertThat(sourceNode.children, hasItems(nodeToMove1, nodeToMove2, nil));
    assertThat([targetNode children], isNot(hasItems(nodeToMove1, nodeToMove2, nil)));
}

- (void)testCopyItemsLeftToNonRootNode {
    QMNode *nodeToMove1 = NODE(3);
    QMNode *nodeToMove2 = NODE(5);
    QMNode *targetNode = LNODE(4);
    QMRootNode *sourceNode = rootNode;
    [doc copyItems:@[nodeToMove1, nodeToMove2] toItem:targetNode inDirection:QMDirectionLeft];

    assertThat(sourceNode.children, hasSize(NUMBER_OF_CHILD));
    assertThat([[targetNode objectInChildrenAtIndex:NUMBER_OF_LEFT_GRAND_CHILD] stringValue], is(nodeToMove1.stringValue));
    assertThat([[targetNode objectInChildrenAtIndex:NUMBER_OF_LEFT_GRAND_CHILD + 1] stringValue], is(nodeToMove2.stringValue));
}

- (void)testCopyItemsRightToNonRootNode {
    QMNode *nodeToMove1 = LNODE(3);
    QMNode *nodeToMove2 = LNODE(5);
    QMNode *targetNode = NODE(4);
    QMRootNode *sourceNode = rootNode;
    [doc copyItems:@[nodeToMove1, nodeToMove2] toItem:targetNode inDirection:QMDirectionRight];

    assertThat(sourceNode.leftChildren, hasSize(NUMBER_OF_LEFT_CHILD));
    assertThat(sourceNode.leftChildren, hasItems(nodeToMove1, nodeToMove2, nil));
    assertThat([[targetNode objectInChildrenAtIndex:NUMBER_OF_GRAND_CHILD] stringValue], is(nodeToMove1.stringValue));
    assertThat([[targetNode objectInChildrenAtIndex:NUMBER_OF_GRAND_CHILD + 1] stringValue], is(nodeToMove2.stringValue));
}

- (void)testCopyItemsTopToNonRootNode {
    QMRootNode *sourceNode = LNODE(3);
    QMNode *nodeToMove1 = LNODE(3, 0);
    QMNode *nodeToMove2 = LNODE(3, 1);
    QMNode *targetNode = NODE(4);
    [doc copyItems:@[nodeToMove1, nodeToMove2] toItem:targetNode inDirection:QMDirectionTop];

    assertThat(sourceNode.children, hasSize(NUMBER_OF_LEFT_GRAND_CHILD));
    assertThat(sourceNode.children, hasItems(nodeToMove1, nodeToMove2, nil));

    QMRootNode *parentOfTargetNode = rootNode;
    assertThat([[parentOfTargetNode objectInChildrenAtIndex:4] stringValue], is(nodeToMove1.stringValue));
    assertThat([[parentOfTargetNode objectInChildrenAtIndex:5] stringValue], is(nodeToMove2.stringValue));
    assertThat([[parentOfTargetNode objectInChildrenAtIndex:6] stringValue], is(targetNode.stringValue));
}

- (void)testCopyItemsBottomToNonRootNode {
    QMNode *sourceNode = NODE(3);
    QMNode *nodeToMove1 = NODE(3, 0);
    QMNode *nodeToMove2 = NODE(3, 1);
    QMNode *targetNode = LNODE(4);
    [doc copyItems:@[nodeToMove1, nodeToMove2] toItem:targetNode inDirection:QMDirectionBottom];

    assertThat(sourceNode.children, hasSize(NUMBER_OF_GRAND_CHILD));
    assertThat(sourceNode.children, hasItems(nodeToMove1, nodeToMove2, nil));

    QMRootNode *parentOfTargetNode = rootNode;
    assertThat([[parentOfTargetNode objectInLeftChildrenAtIndex:4] stringValue], is(targetNode.stringValue));
    assertThat([[parentOfTargetNode objectInLeftChildrenAtIndex:5] stringValue], is(nodeToMove1.stringValue));
    assertThat([[parentOfTargetNode objectInLeftChildrenAtIndex:6] stringValue], is(nodeToMove2.stringValue));
}

- (void)testCopyItemsLeftToRootNode {
    QMNode *sourceNode = NODE(3);
    QMNode *nodeToMove1 = NODE(3, 0);
    QMNode *nodeToMove2 = NODE(3, 1);
    QMRootNode *targetNode= rootNode;
    [doc copyItems:@[nodeToMove1, nodeToMove2] toItem:targetNode inDirection:QMDirectionLeft];

    assertThat(sourceNode.children, hasSize(NUMBER_OF_GRAND_CHILD));
    assertThat(sourceNode.children, hasItems(nodeToMove1, nodeToMove2, nil));
    assertThat([[targetNode objectInLeftChildrenAtIndex:NUMBER_OF_LEFT_CHILD] stringValue], is(nodeToMove1.stringValue));
    assertThat([[targetNode objectInLeftChildrenAtIndex:NUMBER_OF_LEFT_CHILD + 1] stringValue], is(nodeToMove2.stringValue));
}

- (void)testCopyItemsRightToRootNode {
    QMNode *sourceNode = NODE(3);
    QMNode *nodeToMove1 = NODE(3, 0);
    QMNode *nodeToMove2 = NODE(3, 1);
    QMRootNode *targetNode= rootNode;
    [doc copyItems:@[nodeToMove1, nodeToMove2] toItem:targetNode inDirection:QMDirectionRight];

    assertThat(sourceNode.children, hasSize(NUMBER_OF_GRAND_CHILD));
    assertThat(sourceNode.children, hasItems(nodeToMove1, nodeToMove2, nil));
    assertThat([[targetNode objectInChildrenAtIndex:NUMBER_OF_CHILD] stringValue], is(nodeToMove1.stringValue));
    assertThat([[targetNode objectInChildrenAtIndex:NUMBER_OF_CHILD + 1] stringValue], is(nodeToMove2.stringValue));
}

- (void)testCopyItemsTopAndBottomToRootNode {
    QMNode *sourceNode = NODE(3);
    QMNode *nodeToMove1 = NODE(3, 0);
    QMNode *nodeToMove2 = NODE(3, 1);
    QMRootNode *targetNode= rootNode;
    [doc copyItems:@[nodeToMove1, nodeToMove2] toItem:targetNode inDirection:QMDirectionTop];

    assertThat(sourceNode.children, hasSize(NUMBER_OF_GRAND_CHILD));
    assertThat(sourceNode.children, hasItems(nodeToMove1, nodeToMove2, nil));
    assertThat(targetNode.allChildren, isNot(hasItems(nodeToMove1, nodeToMove2, nil)));
    assertThat(@([targetNode countOfAllChildren]), is(@(NUMBER_OF_CHILD + NUMBER_OF_LEFT_CHILD)));

    [doc copyItems:@[nodeToMove1, nodeToMove2] toItem:targetNode inDirection:QMDirectionBottom];

    assertThat(sourceNode.children, hasSize(NUMBER_OF_GRAND_CHILD));
    assertThat(sourceNode.children, hasItems(nodeToMove1, nodeToMove2, nil));
    assertThat(targetNode.allChildren, isNot(hasItems(nodeToMove1, nodeToMove2, nil)));
    assertThat(@([targetNode countOfAllChildren]), is(@(NUMBER_OF_CHILD + NUMBER_OF_LEFT_CHILD)));
}

@end
