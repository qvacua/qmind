/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import "QMBaseTestCase.h"
#import "QMRootNode.h"
#import "QMBaseTestCase+Util.h"
#import "DummyObserver.h"

#define INITIAL_STRING_VALUE @"initial value"

@interface RootNodeTest : QMBaseTestCase
@end

@implementation RootNodeTest {
    QMRootNode *rootNode;

    NSUndoManager *undoManager;

    BOOL insertChildKvo;
    BOOL removeChildKvo;

    DummyObserver *observer;

    QObserverInfo *strInfo;
    QObserverInfo *fontInfo;
    QObserverInfo *childrenInfo;
    QObserverInfo *leftChildrenInfo;
}

- (void)setUp {
    [super setUp];

    undoManager = [[NSUndoManager alloc] init];

    rootNode = [[QMRootNode alloc] init];
    rootNode.stringValue = INITIAL_STRING_VALUE;
    rootNode.undoManager = undoManager;

    insertChildKvo = NO;
    removeChildKvo = NO;

    observer = [[DummyObserver alloc] init];
    strInfo = [[QObserverInfo alloc] initWithObserver:observer keyPath:qNodeStringValueKey];
    fontInfo = [[QObserverInfo alloc] initWithObserver:observer keyPath:qNodeFontKey];
    childrenInfo = [[QObserverInfo alloc] initWithObserver:observer keyPath:qNodeChildrenKey];
    leftChildrenInfo = [[QObserverInfo alloc] initWithObserver:observer keyPath:qNodeLeftChildrenKey];

    [rootNode addObserver:observer forKeyPath:qNodeStringValueKey];
    [rootNode addObserver:observer forKeyPath:qNodeFontKey];
    [rootNode addObserver:observer forKeyPath:qNodeChildrenKey];
}

- (void)testNode {
    [rootNode addObjectInIcons:@"root icon"];
    [rootNode.unsupportedChildren addObject:@"jdf"];

    QMNode *rightChild = [[QMNode alloc] init];
    rightChild.stringValue = @"right child";
    [rightChild addObjectInIcons:@"1. child icon"];
    [rightChild addObjectInIcons:@"2. child icon"];

    QMNode *rightGrandChild = [[QMNode alloc] init];
    rightGrandChild.stringValue = @"right grand child";

    [rightChild addObjectInChildren:rightGrandChild];
    [rightChild setFolded:YES];
    [rightChild setFont:[NSFont labelFontOfSize:30]];

    QMNode *leftChild = [[QMNode alloc] init];
    leftChild.stringValue = @"left child";
    [leftChild addObjectInIcons:@"1. left child icon"];

    [rootNode addObjectInChildren:rightChild];
    [rootNode addObjectInLeftChildren:leftChild];

    QMNode *rootAsNode = [rootNode node];
    assertThat(rootAsNode.stringValue, is(rootNode.stringValue));
    assertThat(rootAsNode.icons, consistsOf(@"root icon"));
    assertThat(rootAsNode.unsupportedChildren, consistsOf(@"jdf"));

    QMNode *const copiedChild1 = [rootAsNode objectInChildrenAtIndex:0];
    assertThat(copiedChild1, isNot(rightChild));
    assertThat(copiedChild1.stringValue, is(rightChild.stringValue));
    assertThat(copiedChild1.unsupportedChildren, hasSize(rightChild.unsupportedChildren.count));
    assertThat(copiedChild1.icons, hasSize(2));
    assertThat(copiedChild1.children, hasSize(1));
    assertThat(copiedChild1.font, is([NSFont labelFontOfSize:30]));

    QMNode *const copiedGrandChild = [copiedChild1 objectInChildrenAtIndex:0];
    assertThat(copiedGrandChild, isNot(rightGrandChild));
    assertThat(copiedGrandChild.stringValue, is(rightGrandChild.stringValue));

    QMNode *const copiedChild2 = [rootAsNode objectInChildrenAtIndex:1];
    assertThat(copiedChild2, isNot(leftChild));
    assertThat(copiedChild2.stringValue, is(leftChild.stringValue));
    assertThat(copiedChild2.unsupportedChildren, hasSize(leftChild.unsupportedChildren.count));
    assertThat(copiedChild2.icons, hasSize(1));
}

- (void)testSetUndoManager {
    rootNode = [self rootNodeForTest];

    rootNode.undoManager = undoManager;

    assertThat(rootNode.undoManager, is(undoManager));
    assertThat([NODE(1, 5) undoManager], is(undoManager));
    assertThat([LNODE(8, 4) undoManager], is(undoManager));
}

- (void)testAddObserver {
    rootNode = [self rootNodeForTest];

    [rootNode addObserver:observer forKeyPath:qNodeStringValueKey];
    [rootNode addObserver:observer forKeyPath:qNodeChildrenKey];
    [rootNode addObserver:observer forKeyPath:qNodeLeftChildrenKey];

    assertThat(rootNode.observerInfos, hasSize(3));
    assertThat(rootNode.observerInfos, consistsOfInAnyOrder(strInfo, childrenInfo, leftChildrenInfo));

    assertThat([NODE(1, 4) observerInfos], hasSize(2));
    assertThat([NODE(1, 4) observerInfos], consistsOfInAnyOrder(strInfo, childrenInfo));
    assertThat([LNODE(1, 4) observerInfos], hasSize(2));
    assertThat([LNODE(1, 4) observerInfos], consistsOfInAnyOrder(strInfo, childrenInfo));
}

- (void)testRemoveObserver {
    rootNode = [self rootNodeForTest];

    [rootNode addObserver:observer forKeyPath:qNodeStringValueKey];
    [rootNode removeObserver:observer];

    assertThat(rootNode.observerInfos, hasSize(0));
    assertThat([NODE(1, 4) observerInfos], hasSize(0));
    assertThat([LNODE(1, 4) observerInfos], hasSize(0));
}

- (void)testKvoFilter {
    assertThat(@([QMRootNode automaticallyNotifiesObserversForKey:qNodeLeftChildrenKey]), isYes);
}

- (void)testIsRoot {
    assertThat(@(rootNode.isRoot), isYes);
}

- (void)testAttributes {
    assertThat(rootNode.attributes, isNot(hasKey(is(qNodePositionAttributeKey))));
}

- (void)testLeaf {
    assertThat(@(rootNode.isLeaf), isYes);

    [rootNode addObjectInLeftChildren:[[QMNode alloc] init]];
    assertThat(@(rootNode.isLeaf), isNo);

    [rootNode removeObjectFromLeftChildrenAtIndex:0];
    [rootNode addObjectInChildren:[[QMNode alloc] init]];
    assertThat(@(rootNode.isLeaf), isNo);
}

- (void)testInit {
    assertThat(rootNode.font, nilValue());
    assertThat(rootNode.children, hasSize(0));
    assertThat(rootNode.leftChildren, hasSize(0));
    assertThat(rootNode.icons, notNilValue());
}

- (void)testFolded {
    assertThat(@(rootNode.folded), isNo);
    rootNode.folded = YES;
    assertThat(@(rootNode.folded), isNo);
}

- (void)testInitWithDict {
    NSString *string = @"text value";
    NSMutableDictionary *xmlDict = [[NSMutableDictionary alloc] init];
    [xmlDict setObject:string forKey:qNodeTextAttributeKey];
    [xmlDict setObject:@"true" forKey:qNodeFoldedAttributeKey];
    [xmlDict setObject:@"left" forKey:qNodePositionAttributeKey];

    QMRootNode *node = [[QMRootNode alloc] initWithAttributes:xmlDict];
    assertThat(node.font, nilValue());
    assertThat(node.stringValue, is(string));
    assertThat(@(node.folded), isNo);
    assertThat(node.children, hasSize(0));
    assertThat(rootNode.leftChildren, hasSize(0));
}

- (void)testNSCoding {
    QMNode *childNode = [[QMNode alloc] init];
    childNode.stringValue = @"childnode";
    [childNode insertObject:@"childicon" inIconsAtIndex:0];

    QMNode *leftChildNode = [[QMNode alloc] init];
    leftChildNode.stringValue = @"leftchildnode";
    [leftChildNode insertObject:@"leftchildicon" inIconsAtIndex:0];

    [rootNode addObjectInChildren:childNode];
    [rootNode addObjectInLeftChildren:leftChildNode];

    rootNode.stringValue = @"kdkdkdk";
    rootNode.folded = YES;
    rootNode.font = [NSFont boldSystemFontOfSize:13];

    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [rootNode encodeWithCoder:encoder];
    [encoder finishEncoding];

    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    QMRootNode *decodedNode = [[QMRootNode alloc] initWithCoder:decoder];
    [decoder finishDecoding];

    assertThat(decodedNode.parent, nilValue());
    assertThat(decodedNode.font, is([NSFont boldSystemFontOfSize:13]));
    assertThat(decodedNode.stringValue, is(@"kdkdkdk"));
    assertThat(@(decodedNode.folded), isNo);
    assertThat(decodedNode.children, hasSize(1));
    assertThat(decodedNode.leftChildren, hasSize(1));

    QMNode *decodedChild = [decodedNode.children objectAtIndex:0];
    assertThat([decodedChild stringValue], is(@"childnode"));
    assertThat(decodedChild.icons, hasSize(1));
    assertThat(decodedChild.icons, consistsOf(@"childicon"));

    QMNode *decodedLeftChild = [decodedNode.leftChildren objectAtIndex:0];
    assertThat([decodedLeftChild stringValue], is(@"leftchildnode"));
    assertThat(decodedLeftChild.icons, hasSize(1));
    assertThat(decodedLeftChild.icons, consistsOf(@"leftchildicon"));
}

- (void)testAllChildren {
    QMNode *node1 = [[QMNode alloc] init];
    QMNode *node2 = [[QMNode alloc] init];

    [rootNode addObjectInChildren:node1];
    [rootNode addObjectInLeftChildren:node2];

    assertThat(rootNode.allChildren, hasSize(2));
    assertThat(@([rootNode countOfAllChildren]), is(@(2)));
    assertThat(rootNode.allChildren, consistsOf(node1, node2));
}

- (void)testCopy {
    QMNode *node1 = [[QMNode alloc] init];
    QMNode *node2 = [[QMNode alloc] init];

    node1.stringValue = @"first";

    [rootNode addObjectInChildren:node1];
    [rootNode addObjectInLeftChildren:node2];

    QMNode *copy = [rootNode copy];

    assertThat(copy.children, hasSize(2));
    assertThat([[copy objectInChildrenAtIndex:0] stringValue], is(@"first"));
}

- (void)testAddLeftChild {
    rootNode.undoManager = nil;
    [rootNode addObjectInLeftChildren:[[QMNode alloc] init]];

    rootNode.undoManager = undoManager;
    QMNode *childNode = [[QMNode alloc] init];
    [rootNode addObjectInLeftChildren:childNode];

    assertThat(rootNode.leftChildren, hasSize(2));

    assertThat(childNode, is([rootNode.leftChildren objectAtIndex:1]));
    assertThat(childNode.parent, is(rootNode));
    assertThat(childNode.observerInfos, consistsOfInAnyOrder(strInfo, fontInfo, childrenInfo));
    assertThat(childNode.undoManager, is(undoManager));

    assertThat(@(undoManager.canUndo), isYes);
    [undoManager undo];
    assertThat(rootNode.leftChildren, hasSize(1));
}

- (void)testInsertLeftChild {
    rootNode.undoManager = nil;
    [rootNode addObjectInLeftChildren:[[QMNode alloc] init]];

    rootNode.undoManager = undoManager;
    QMNode *childNode = [[QMNode alloc] init];
    [rootNode insertObject:childNode inLeftChildrenAtIndex:0];

    assertThat(rootNode.leftChildren, hasSize(2));

    assertThat(childNode, is([rootNode.leftChildren objectAtIndex:0]));
    assertThat(childNode.parent, is(rootNode));
    assertThat(childNode.observerInfos, consistsOfInAnyOrder(strInfo, fontInfo, childrenInfo));
    assertThat(childNode.undoManager, is(undoManager));

    assertThat(@(undoManager.canUndo), isYes);
    [undoManager undo];
    assertThat(rootNode.leftChildren, hasSize(1));
}

- (void)testLeftChildAtIndex {
    QMNode *childNode = [[QMNode alloc] init];
    [rootNode addObjectInLeftChildren:childNode];

    assertThat([rootNode objectInLeftChildrenAtIndex:0], is(childNode));
}

- (void)testDeleteLeftChild {
    QMNode *childNode = [[QMNode alloc] init];

    rootNode.undoManager = nil;
    [rootNode insertObject:childNode inLeftChildrenAtIndex:0];
    rootNode.undoManager = undoManager;
    [rootNode removeObjectFromLeftChildrenAtIndex:0];

    assertThat(childNode.parent, nilValue());
    assertThat(rootNode.leftChildren, hasSize(0));
    assertThat(childNode.observerInfos, hasSize(0));
    assertThat(@(undoManager.canUndo), isYes);

    [undoManager undo];
    assertThat(rootNode.leftChildren, hasSize(1));
    assertThat(childNode, is([rootNode.leftChildren objectAtIndex:0]));
    assertThat(childNode.parent, is(rootNode));
}

- (void)testKvoForChildren {
    [rootNode addObserver:self forKeyPath:@"leftChildren"];
    QMNode *childNode = [[QMNode alloc] init];

    [rootNode insertObject:childNode inLeftChildrenAtIndex:0];
    assertThat(@(insertChildKvo), isYes);

    [rootNode removeObjectFromLeftChildrenAtIndex:0];
    assertThat(@(removeChildKvo), isYes);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([[change objectForKey:NSKeyValueChangeKindKey] intValue] == NSKeyValueChangeInsertion) {
        insertChildKvo = YES;
    }

    if ([[change objectForKey:NSKeyValueChangeKindKey] intValue] == NSKeyValueChangeRemoval) {
        removeChildKvo = YES;
    }
}

@end
