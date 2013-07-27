/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import "QMNode.h"
#import "DummyObserver.h"
#import "QMBaseTestCase+Util.h"

#define INITIAL_STRING_VALUE @"initial value"

@interface QMNodeTest : QMBaseTestCase
@end

@implementation QMNodeTest {
    QMNode *node;

    NSUndoManager *undoManager;
    DummyObserver *observer;

    QObserverInfo *strInfo;
    QObserverInfo *fontInfo;
    QObserverInfo *childrenInfo;
    QObserverInfo *foldingInfo;
    QObserverInfo *iconsInfo;
}

- (void)setUp {
    [super setUp];

    undoManager = [[NSUndoManager alloc] init];

    node = [[QMNode alloc] init];
    node.stringValue = INITIAL_STRING_VALUE;
    node.undoManager = undoManager;

    observer = [[DummyObserver alloc] init];
    strInfo = [[QObserverInfo alloc] initWithObserver:observer keyPath:qNodeStringValueKey];
    fontInfo = [[QObserverInfo alloc] initWithObserver:observer keyPath:qNodeFontKey];
    childrenInfo = [[QObserverInfo alloc] initWithObserver:observer keyPath:qNodeChildrenKey];
    foldingInfo = [[QObserverInfo alloc] initWithObserver:observer keyPath:qNodeFoldingKey];
    iconsInfo = [[QObserverInfo alloc] initWithObserver:observer keyPath:qNodeIconsKey];

    [node addObserver:observer forKeyPath:qNodeStringValueKey];
    [node addObserver:observer forKeyPath:qNodeFontKey];
    [node addObserver:observer forKeyPath:qNodeChildrenKey];
    [node addObserver:observer forKeyPath:qNodeFoldingKey];
    [node addObserver:observer forKeyPath:qNodeIconsKey];
}

- (void)testCopy {
    QMNode *child = [[QMNode alloc] init];
    child.stringValue = @"child";
    [child.unsupportedChildren addObject:@"jfd"];

    [node addObjectInIcons:@"icon"];
    [node addObjectInChildren:child];
    node.folded = YES;
    QMNode *copied = [node copy];

    assertThat(copied, isNot(node));
    assertThat(copied.icons, consistsOf(@"icon"));
    assertThat(copied.children, hasSize(1));
    assertThat(copied.stringValue, is(node.stringValue));
    assertThat(@([copied isFolded]), isYes);

    QMNode *copiedChild = [copied objectInChildrenAtIndex:0];
    assertThat(copiedChild, isNot(child));
    assertThat(copiedChild.stringValue, is(@"child"));
    assertThat(copiedChild.unsupportedChildren, consistsOf(@"jfd"));
}

- (void)testIsRoot {
    assertThat(@([node isRoot]), isNo);
}

- (void)testLink {
    QMNode *node = [[QMNode alloc] init];

    node.link = @"http://link";
    assertThat(node.link, is(@"http://link"));

    node.link = @"#ID_...";
    assertThat(node.link, is(@"#ID_..."));
}

- (void)testAttributes {
    QMNode *node1 = [[QMNode alloc] init];
    QMNode *node2 = [[QMNode alloc] init];

    node1.stringValue = @"test";
    assertThat(node1.attributes, atKey(qNodeTextAttributeKey, equalTo(@"test")));

    node2.folded = NO;
    assertThat(node2.attributes, isNot(hasKey(equalTo(qNodeFoldedAttributeKey))));

    node2.folded = YES;
    assertThat(node2.attributes, atKey(qNodeFoldedAttributeKey, equalTo(@"true")));
}

- (void)testLeaf {
    QMNode *childNode = [[QMNode alloc] init];
    [node addObjectInChildren:childNode];

    assertThat(@(node.isLeaf), isNo);
    assertThat(@(childNode.isLeaf), isYes);
}

- (void)testStringValue {
    NSString *testString = @"test string value";
    node.stringValue = testString;

    assertThat(node.stringValue, is(testString));
    assertThat(@(undoManager.canUndo), isYes);

    [undoManager undo];
    assertThat(node.stringValue, is(INITIAL_STRING_VALUE));
}

- (void)testKvoFilter {
    assertThat(@([QMNode automaticallyNotifiesObserversForKey:qNodeStringValueKey]), isYes);
    assertThat(@([QMNode automaticallyNotifiesObserversForKey:qNodeIconsKey]), isYes);
    assertThat(@([QMNode automaticallyNotifiesObserversForKey:qNodeChildrenKey]), isYes);
    assertThat(@([QMNode automaticallyNotifiesObserversForKey:qNodeFontKey]), isYes);
    assertThat(@([QMNode automaticallyNotifiesObserversForKey:qNodeFoldingKey]), isYes);

    assertThat(@([QMNode automaticallyNotifiesObserversForKey:@"parent"]), isNo);
    assertThat(@([QMNode automaticallyNotifiesObserversForKey:@"attributes"]), isNo);
    assertThat(@([QMNode automaticallyNotifiesObserversForKey:@"unsupportedChildren"]), isNo);
    assertThat(@([QMNode automaticallyNotifiesObserversForKey:@"allChildren"]), isNo);
}

- (void)testFont {
    NSFont *font = [NSFont boldSystemFontOfSize:20];
    node.font = font;

    assertThat(node.font, equalTo(font));
    assertThat(@(undoManager.canUndo), isYes);

    [undoManager undo];
    assertThat(node.font, nilValue());
}

- (void)testWritablePasteboardTypes {
    NSArray *typesForPasteboard = [node writableTypesForPasteboard:nil];

    assertThat(typesForPasteboard, hasSize(2));
    assertThat(typesForPasteboard[0], is(NSPasteboardTypeString));
    assertThat(typesForPasteboard[1], is(qNodeUti));
}

- (void)testWritePasteboardOptions {
    NSPasteboardWritingOptions nodeWriteOption = [node writingOptionsForType:qNodeUti pasteboard:nil];
    assertThat(@(nodeWriteOption), is(@(NSPasteboardWritingPromised)));

    NSPasteboardWritingOptions otherOption = [node writingOptionsForType:@"fds" pasteboard:nil];
    assertThat(@(otherOption), is(@(0)));
}

- (void)testPasteboardPropertyListForType {
    id plainText = [node pasteboardPropertyListForType:NSPasteboardTypeString];
    assertThat(plainText, is(INITIAL_STRING_VALUE));
    
    id nodeObj = [node pasteboardPropertyListForType:qNodeUti];
    assertThat(nodeObj, instanceOf([NSData class]));

    id noObj = [node pasteboardPropertyListForType:@"fdsfds"];
    assertThat(noObj, nilValue());
}

- (void)testReadableTypesForPasteboard {
    NSArray *typesForPasteboard = [QMNode readableTypesForPasteboard:nil];

    assertThat(typesForPasteboard, consistsOf(qNodeUti));
}

- (void)testReadingOptionsForType {
    NSPasteboardReadingOptions optionsForNodeUti = [QMNode readingOptionsForType:qNodeUti pasteboard:nil];
    assertThat(@(optionsForNodeUti), is(@(NSPasteboardReadingAsKeyedArchive)));

    NSPasteboardReadingOptions optionsForOther = [QMNode readingOptionsForType:@"fds" pasteboard:nil];
    assertThat(@(optionsForOther), is(@(NSPasteboardReadingAsData)));
}

- (void)testInit {
    QMNode *childNode = [[QMNode alloc] init];

    assertThat(childNode.font, nilValue());
    assertThat(childNode.children, hasSize(0));
    assertThat(childNode.icons, notNilValue());
    assertThat(@(childNode.isCreatedNewly), isNo);
}

- (void)testInitWithDict {
    NSString *string = @"text value";
    NSMutableDictionary *xmlDict = [[NSMutableDictionary alloc] init];
    [xmlDict setObject:string forKey:qNodeTextAttributeKey];
    [xmlDict setObject:@"true" forKey:qNodeFoldedAttributeKey];
    [xmlDict setObject:@"left" forKey:qNodePositionAttributeKey];

    QMNode *childNode = [[QMNode alloc] initWithAttributes:xmlDict];
    assertThat(childNode.font, nilValue());
    assertThat(childNode.stringValue, is(string));
    assertThat(@(childNode.folded), isYes);
    assertThat(childNode.children, hasSize(0));
    assertThat(@(childNode.isCreatedNewly), isNo);
}

- (void)testNSCoding {
    QMNode *parentNode = [[QMNode alloc] init];
    [parentNode addObjectInChildren:node];

    QMNode *childNode = [[QMNode alloc] init];
    childNode.stringValue = @"childnode";
    [childNode insertObject:@"childicon" inIconsAtIndex:0];

    [node addObjectInChildren:childNode];
    node.stringValue = @"kdkdkdk";
    node.folded = YES;
    node.font = [NSFont boldSystemFontOfSize:13];

    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [node encodeWithCoder:encoder];
    [encoder finishEncoding];

    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    QMNode *decodedNode = [[QMNode alloc] initWithCoder:decoder];
    [decoder finishDecoding];

    assertThat(decodedNode.parent, nilValue());
    assertThat(decodedNode.font, is([NSFont boldSystemFontOfSize:13]));
    assertThat(decodedNode.stringValue, is(@"kdkdkdk"));
    assertThat(@(decodedNode.folded), isYes);
    assertThat(decodedNode.children, hasSize(1));

    QMNode *decodedChild = [decodedNode.children objectAtIndex:0];
    assertThat([decodedChild stringValue], is(@"childnode"));
    assertThat(decodedChild.icons, consistsOf(@"childicon"));
}

- (void)testInsertIcon {
    [node insertObject:@"icon 1" inIconsAtIndex:0];
    [node insertObject:@"icon 2" inIconsAtIndex:0];

    assertThat(node.icons, consistsOf(@"icon 2", @"icon 1"));
}

- (void)testAddIcon {
    [node addObjectInIcons:@"icon 1"];
    [node addObjectInIcons:@"icon 2"];

    assertThat(node.icons, consistsOf(@"icon 1", @"icon 2"));
}

- (void)testIconAtIndex {
    node.undoManager = nil;
    [node addObjectInIcons:@"icon1"];
    [node addObjectInIcons:@"icon2"];

    node.undoManager = undoManager;
    [node addObjectInIcons:@"icon3"];

    assertThat(node.icons, consistsOf(@"icon1", @"icon2", @"icon3"));
    assertThat(@(undoManager.canUndo), isYes);

    [undoManager undo];
    assertThat(node.icons, consistsOf(@"icon1", @"icon2"));
}

- (void)testDeleteIcon {
    node.undoManager = nil;
    [node addObjectInIcons:@"icon1"];
    [node addObjectInIcons:@"icon2"];

    node.undoManager = undoManager;
    [node removeObjectFromIconsAtIndex:0];

    assertThat(node.icons, consistsOf(@"icon2"));
    assertThat(@(undoManager.canUndo), isYes);

    [undoManager undo];
    assertThat(node.icons, consistsOf(@"icon1", @"icon2"));
}

- (void)testAddChild {
    node.undoManager = nil;
    [node addObjectInChildren:[[QMNode alloc] init]];

    node.undoManager = undoManager;
    QMNode *childNode = [[QMNode alloc] init];
    [node addObjectInChildren:childNode];

    assertThat(node.children, hasSize(2));

    assertThat(childNode, is([node objectInChildrenAtIndex:1]));
    assertThat(childNode.parent, is(node));
    assertThat(childNode.observerInfos, consistsOfInAnyOrder(strInfo, fontInfo, childrenInfo, foldingInfo, iconsInfo));
    assertThat(childNode.undoManager, is(undoManager));

    assertThat(@(undoManager.canUndo), isYes);
    [undoManager undo];
    assertThat(node.children, hasSize(1));
}

- (void)testAllChildren {
    QMNode *childNode = [[QMNode alloc] init];
    [node addObjectInChildren:childNode];

    assertThat(node.allChildren, consistsOf(childNode));
}

- (void)testInsertChild {
    node.undoManager = nil;
    [node addObjectInChildren:[[QMNode alloc] init]];

    node.undoManager = undoManager;
    QMNode *childNode = [[QMNode alloc] init];
    [node insertObject:childNode inChildrenAtIndex:0];

    assertThat(node.children, hasSize(2));

    assertThat(childNode, is([node objectInChildrenAtIndex:0]));
    assertThat(childNode.parent, is(node));
    assertThat(childNode.observerInfos, consistsOfInAnyOrder(strInfo, fontInfo, childrenInfo, foldingInfo, iconsInfo));
    assertThat(childNode.undoManager, is(undoManager));

    assertThat(@(undoManager.canUndo), isYes);
    [undoManager undo];
    assertThat(node.children, hasSize(1));
}

- (void)testChildAtIndex {
    QMNode *childNode = [[QMNode alloc] init];
    [node addObjectInChildren:childNode];

    assertThat([node objectInChildrenAtIndex:0], is(childNode));
}

- (void)testDeleteChild {
    QMNode *childNode = [[QMNode alloc] init];

    node.undoManager = nil;
    [node insertObject:childNode inChildrenAtIndex:0];
    node.undoManager = undoManager;
    [node removeObjectFromChildrenAtIndex:0];

    assertThat(childNode.parent, nilValue());
    assertThat(node.children, hasSize(0));
    assertThat(childNode.observerInfos, hasSize(0));
    assertThat(@(undoManager.canUndo), isYes);

    [undoManager undo];
    assertThat(node.children, hasSize(1));
    assertThat(childNode, is([node objectInChildrenAtIndex:0]));
    assertThat(childNode.parent, is(node));
}

- (void)testSetUndoManager {
    QMRootNode *rootNode = [self rootNodeForTest];
    QMNode *parentNode = NODE(1);

    parentNode.undoManager = undoManager;

    assertThat(parentNode.undoManager, is(undoManager));
    assertThat([NODE(1, 5) undoManager], is(undoManager));
}

- (void)testAddObserver {
    QObserverInfo *const observerInfo = [[QObserverInfo alloc] initWithObserver:observer keyPath:qNodeStringValueKey];

    QMRootNode *rootNode = [self rootNodeForTest];
    QMNode *parentNode = NODE(1);

    [parentNode addObserver:observer forKeyPath:qNodeStringValueKey];

    assertThat(parentNode.observerInfos, consistsOf(observerInfo));
    assertThat([NODE(1, 4) observerInfos], consistsOf(observerInfo));
}

- (void)testRemoveObserver {
    QMRootNode *rootNode = [self rootNodeForTest];
    QMNode *parentNode = NODE(1);

    [parentNode addObserver:observer forKeyPath:qNodeStringValueKey];
    [parentNode removeObserver:observer];

    assertThat(parentNode.observerInfos, hasSize(0));
    assertThat([NODE(1, 4) observerInfos], hasSize(0));
}

- (void)testKvoForStringValue {
    [node addObserver:observer forKeyPath:qNodeStringValueKey];

    node.stringValue = @"new string";
    assertThat(observer.lastKeyPath, is(qNodeStringValueKey));
    assertThat(observer.lastObservedObj, is(node));

    [node removeObserver:observer];
}

- (void)testKvoForChildren {
    [node addObserver:observer forKeyPath:qNodeChildrenKey];
    QMNode *childNode = [[QMNode alloc] init];

    [node insertObject:childNode inChildrenAtIndex:0];
    assertThat(observer.lastObservedObj, is(node));
    assertThat(observer.lastKeyPath, is(qNodeChildrenKey));

    [node removeObserver:observer];

    observer = [[DummyObserver alloc] init];
    [node addObserver:observer forKeyPath:qNodeChildrenKey];
    [node removeObjectFromChildrenAtIndex:0];
    assertThat(observer.lastObservedObj, is(node));
    assertThat(observer.lastKeyPath, is(qNodeChildrenKey));

    [node removeObserver:observer];
}

@end
