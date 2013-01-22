/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import "QMMindmapWriter.h"
#import "QMMindmapReader.h"
#import "QMRootNode.h"
#import "QMBaseTestCase+Util.h"
#import "QMCacaoTestCase.h"

@interface MindmapWriterTest : QMCacaoTestCase
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

    NSURL *testMindMapUrl = [[NSBundle bundleForClass:[self class]] URLForResource:@"mindmap-writer-test" withExtension:@"mm"];

    reader = [self.context beanWithClass:[QMMindmapReader class]];
    writer = [self.context beanWithClass:[QMMindmapWriter class]];

    rootNode = [reader rootNodeForFileUrl:testMindMapUrl];

    tempFileName = [NSString stringWithFormat:@"/tmp/QmindTest_%@", NSString.uuid];
    tempFileUrl = [NSURL fileURLWithPath:tempFileName];
}

- (void)tearDown {
    [super tearDown];

    [[NSFileManager defaultManager] removeItemAtURL:tempFileUrl error:NULL];
}

/**
* @bug
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
    assertThat(newRootNode.stringValue, is(@"test"));
    assertThat(newRootNode.font, notNilValue());

    assertThat(newRootNode.children, hasSize(3));
    assertThat(newRootNode.leftChildren, hasSize(3));

    assertThat(newRootNode.icons, hasSize(2));
    assertThat(newRootNode.icons, consistsOf(@"full-1", @"wizard"));

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
    assertThat(firstChild.stringValue, is(@"A"));
    assertThat(firstChild.children, hasSize(2));

    NSArray *childrenOfA = firstChild.children;
    QMNode *firstGrand = [childrenOfA objectAtIndex:0];
    assertThat(firstGrand.stringValue, is(@"A1"));
    assertThat(firstGrand.children, hasSize(3));

    assertThat([[childrenOfA objectAtIndex:1] stringValue], is(@"A2"));

    QMNode *secondChild = [leftChildren objectAtIndex:1];
    assertThat([secondChild stringValue], is(@"B"));

    QMNode *thirdChild = [leftChildren objectAtIndex:2];
    assertThat([thirdChild stringValue], is(@"C"));
    assertThat([thirdChild children], hasSize(2));
}

- (void)checkRightChildren:(QMRootNode *)newRootNode {
    QMNode *firstChild = [newRootNode objectInChildrenAtIndex:0];
    assertThat(firstChild.stringValue, is(@"a"));
    assertThat(firstChild.children, hasSize(3));
    assertThat(firstChild.icons, hasSize(1));
    assertThat(firstChild.icons, consistsOf(@"full-2"));

    assertThat(firstChild.font, notNilValue());

    QMNode *secondChild = [newRootNode objectInChildrenAtIndex:1];
    assertThat(@(secondChild.isFolded), isYes);
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
    assertThat(firstGrandChild.stringValue, is(@"a1"));
    assertThat(firstGrandChild.children, hasSize(2));
    assertThat(@(firstGrandChild.leaf), isNo);
    assertThat(firstGrandChild.icons, consistsOf(@"attach"));
    assertThat([[firstGrandChild objectInChildrenAtIndex:1] icons], consistsOf(@"full-1"));

    QMNode *secondGrandChild = [firstChild.children objectAtIndex:1];
    assertThat(secondGrandChild.stringValue, is(@"a2"));
    assertThat(@(secondGrandChild.leaf), isYes);

    QMNode *thirdChild = [newRootNode objectInChildrenAtIndex:2];
    assertThat(thirdChild.stringValue, is(@"c"));
    assertThat(thirdChild.children, hasSize(3));
    assertThat([[thirdChild objectInChildrenAtIndex:1] icons], consistsOf(@"help", @"stop-sign", @"button_ok", @"stop-sign"));
}

@end
