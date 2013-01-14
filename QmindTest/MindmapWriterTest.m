#import "QMMindmapWriter.h"
#import "QMMindmapReader.h"
#import "QMRootNode.h"
#import "QMBaseTestCase+Util.h"

@interface MindmapWriterTest : QMBaseTestCase
@end

@implementation MindmapWriterTest {
    QMMindmapReader *reader;
    QMMindmapWriter *writer;

    QMRootNode *rootNode;
    NSString *tempFileName;
    NSURL *tempFileUrl;
}

- (void)setUp {
    [super setUp];

    NSURL *testMindMapUrl = [[NSBundle bundleForClass:self.class] URLForResource:@"mindmap-writer-test"
                                                                   withExtension:@"mm"];

    reader = [[QMMindmapReader alloc] init];
    writer = [[QMMindmapWriter alloc] init];

    rootNode = [reader rootNodeForFileUrl:testMindMapUrl];

    tempFileName = [NSString stringWithFormat:@"/tmp/QmindTest_%@", NSString.uuid];
    tempFileUrl = [NSURL fileURLWithPath:tempFileName];
}

- (void)tearDown {
    [super tearDown];

    [[NSFileManager defaultManager] removeItemAtURL:tempFileUrl error:NULL];
}

/**
* @Bug
*/
- (void)testDataFromNewDoc {
    rootNode = [self rootNodeForTest];

    NSData *data = [writer dataForRootNode:rootNode];
    [data writeToFile:tempFileName atomically:NO];

    QMRootNode *newRootNode = [reader rootNodeForFileUrl:tempFileUrl];
    assertThat(newRootNode.leftChildren, hasSize(NUMBER_OF_LEFT_CHILD));
}

- (void)testDataWrite {
    NSData *data = [writer dataForRootNode:rootNode];

    [data writeToFile:tempFileName atomically:NO];

    QMRootNode *newRootNode = [reader rootNodeForFileUrl:tempFileUrl];
    assertThat(newRootNode.stringValue, equalTo(@"test"));
    assertThat(newRootNode.font, notNilValue());

    assertThat(newRootNode.children, hasSize(3));
    assertThat(newRootNode.leftChildren, hasSize(3));

    assertThat(newRootNode.icons, hasSize(2));
    assertThat(newRootNode.icons, contains(equalTo(@"full-1"), equalTo(@"wizard"), nil));

    assertThat(newRootNode.unsupportedChildren, hasSize(1));
    assertThat([newRootNode.unsupportedChildren objectAtIndex:0], containsString(@"<html>"));
    assertThat([newRootNode.unsupportedChildren objectAtIndex:0], containsString(@"</html>"));
    assertThat([newRootNode.unsupportedChildren objectAtIndex:0], containsString(@"note of root"));

    [self checkRightChildren:newRootNode];
    [self checkLeftChildren:newRootNode];
}

- (void)checkLeftChildren:(QMRootNode *)aRootNode {
    NSArray *leftChildren = aRootNode.leftChildren;

    QMNode *firstChild = [leftChildren objectAtIndex:0];
    assertThat(firstChild.stringValue, equalTo(@"A"));
    assertThat(firstChild.children, hasSize(2));

    NSArray *childrenOfA = firstChild.children;
    QMNode *firstGrand = [childrenOfA objectAtIndex:0];
    assertThat(firstGrand.stringValue, equalTo(@"A1"));
    assertThat(firstGrand.children, hasSize(3));

    assertThat([[childrenOfA objectAtIndex:1] stringValue], equalTo(@"A2"));

    QMNode *secondChild = [leftChildren objectAtIndex:1];
    assertThat([secondChild stringValue], equalTo(@"B"));

    QMNode *thirdChild = [leftChildren objectAtIndex:2];
    assertThat([thirdChild stringValue], equalTo(@"C"));
    assertThat([thirdChild children], hasSize(2));
}

- (void)checkRightChildren:(QMRootNode *)newRootNode {
    QMNode *firstChild = [newRootNode objectInChildrenAtIndex:0];
    assertThat(firstChild.stringValue, equalTo(@"a"));
    assertThat(firstChild.children, hasSize(3));
    assertThat(firstChild.icons, hasSize(1));
    assertThat(firstChild.icons, contains(equalTo(@"full-2"), nil));

    assertThat(firstChild.font, notNilValue());

    QMNode *secondChild = [newRootNode objectInChildrenAtIndex:1];
    assertThatBool(secondChild.isFolded, isTrue);
    assertThat(secondChild.children, hasSize(4));

    NSMutableArray *unsupportedChildren = firstChild.unsupportedChildren;
    assertThat(unsupportedChildren, hasCount(equalToInt(1)));

    NSXMLNode *unsupportedElement = [unsupportedChildren objectAtIndex:0];
    assertThat(unsupportedElement, containsString(@"<head>"));
    assertThat(unsupportedElement, containsString(@"<b>"));
    assertThat(unsupportedElement, containsString(@"b c"));
    assertThat(unsupportedElement, containsString(@"f g"));
    assertThat(unsupportedElement, containsString(@"</u>"));
    assertThat(unsupportedElement, containsString(@"h i"));
    assertThat(unsupportedElement, containsString(@"</b>"));
    assertThat(unsupportedElement, containsString(@"</html>"));

    QMNode *firstGrandChild = [firstChild.children objectAtIndex:0];
    assertThat(firstGrandChild.stringValue, equalTo(@"a1"));
    assertThat(firstGrandChild.children, hasSize(2));
    assertThatBool(firstGrandChild.leaf, isFalse);
    assertThat(firstGrandChild.icons, hasSize(1));
    assertThat(firstGrandChild.icons, contains(equalTo(@"attach"), nil));
    assertThat([[firstGrandChild objectInChildrenAtIndex:1] icons], contains(equalTo(@"full-1"), nil));

    QMNode *secondGrandChild = [firstChild.children objectAtIndex:1];
    assertThat(secondGrandChild.stringValue, equalTo(@"a2"));
    assertThatBool(secondGrandChild.leaf, isTrue);

    QMNode *thirdChild = [newRootNode objectInChildrenAtIndex:2];
    assertThat(thirdChild.stringValue, equalTo(@"c"));
    assertThat(thirdChild.children, hasSize(3));
    assertThat([[thirdChild objectInChildrenAtIndex:1] icons], hasSize(4));
    assertThat([[thirdChild objectInChildrenAtIndex:1] icons],
               contains(equalTo(@"help"), equalTo(@"stop-sign"), equalTo(@"button_ok"), equalTo(@"stop-sign"), nil));
}

@end
