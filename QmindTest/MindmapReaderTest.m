#import "QMRootNode.h"
#import "QMBaseTestCase.h"
#import "QMMindmapReader.h"

@interface MindmapReaderTest : QMBaseTestCase
@end

@implementation MindmapReaderTest {
    NSURL *testMindMapUrl;
    QMMindmapReader *reader;
}

- (void)setUp {
    [super setUp];

    testMindMapUrl = [[NSBundle bundleForClass:self.class] URLForResource:@"mindmap-reader-test" withExtension:@"mm"];
    reader = [[QMMindmapReader alloc] init];
}

- (void)testNonExistingUrl {
    assertThat([reader rootNodeForFileUrl:[NSURL URLWithString:@"file:///fdsfds"]], is(nilValue()));
}

- (void)testRead {
    QMRootNode *rootNode = [reader rootNodeForFileUrl:testMindMapUrl];

    assertThat(rootNode.allChildren, hasSize(8));
    assertThat(rootNode.leftChildren, hasSize(3));
    assertThat(rootNode.children, hasSize(5));

    assertThat(rootNode.stringValue, equalTo(@"test"));
    assertThat(rootNode.font, notNilValue());

    assertThat(rootNode.icons, hasSize(2));
    assertThat([rootNode objectInIconsAtIndex:0], equalTo(@"attach"));
    assertThat([rootNode objectInIconsAtIndex:1], equalTo(@"flag-pink"));

    assertThat(rootNode.unsupportedChildren, hasSize(1));
    assertThat([rootNode.unsupportedChildren objectAtIndex:0], containsString(@"<html>"));
    assertThat([rootNode.unsupportedChildren objectAtIndex:0], containsString(@"</html>"));
    assertThat([rootNode.unsupportedChildren objectAtIndex:0], containsString(@"note of root"));

    [self checkRightChildren:rootNode];
    [self checkLeftChildren:rootNode];
}

- (void)checkLeftChildren:(QMRootNode *)rootNode {
    NSArray *leftChildren = rootNode.leftChildren;

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

- (void)checkRightChildren:(QMRootNode *)rootNode {
    NSArray *rightChildren = rootNode.children;;

    // first child of the root
    QMNode *firstChild = [rightChildren objectAtIndex:0];
    assertThat(firstChild.stringValue, equalTo(@"a"));

    NSFont *firstFont = firstChild.font;
    assertThat(firstFont, notNilValue());

    assertThatUnsignedInteger(firstChild.unsupportedChildren.count, equalToInt(1));
    assertThat([firstChild.unsupportedChildren objectAtIndex:0], containsString(@"a <b>b c<u>d e</u> f g</b> h i"));

    assertThatUnsignedInteger([firstChild countOfChildren], equalToInt(3));
    assertThat([[firstChild objectInChildrenAtIndex:1] stringValue], equalTo(@"a2"));
    assertThatUnsignedInteger([[firstChild objectInChildrenAtIndex:1] countOfIcons], equalToInt(1));
    assertThat([[firstChild objectInChildrenAtIndex:1] objectInIconsAtIndex:0], equalTo(@"clanbomber"));

    // children of the first child
    QMNode *childOfA = [firstChild objectInChildrenAtIndex:0];
    QMNode *grandChildOfA = [childOfA objectInChildrenAtIndex:0];
    assertThat(grandChildOfA.stringValue, equalTo(@"a1a"));

    // second child of the root
    QMNode *secondChild = [rightChildren objectAtIndex:1];
    assertThat(secondChild.children, hasSize(4));
    assertThat(secondChild.stringValue, equalTo(@"b"));
    assertThat(secondChild.attributes, isNot(hasItem(@"POSITION")));
    assertThat(secondChild.icons, hasSize(3));
    assertThat(secondChild.icons, contains(equalTo(@"full-6"), equalTo(@"ksmiletris"), equalTo(@"idea"), nil));

    assertThatUnsignedInteger([secondChild countOfChildren], equalToInt(4));

    QMNode *thirdChild = [rootNode objectInChildrenAtIndex:2];
    assertThat(thirdChild.children, hasSize(3));
    assertThatBool([thirdChild isLeaf], isFalse);
    assertThat([[thirdChild objectInChildrenAtIndex:1] icons], hasSize(1));
    assertThat([[thirdChild objectInChildrenAtIndex:1] icons], contains(equalTo(@"kmail"), nil));

    assertThatBool([[rootNode objectInChildrenAtIndex:3] isLeaf], isTrue);

    QMNode *fifthChild = [rootNode objectInChildrenAtIndex:4];
    assertThatBool([fifthChild isLeaf], isFalse);
    assertThatBool([fifthChild isFolded], isTrue);
    assertThat(fifthChild.children, hasSize(2));
}

@end
