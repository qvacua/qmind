/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import "QMBaseTestCase.h"
#import "QMRootNode.h"
#import "QMMindmapReader.h"
#import "QMCacaoTestCase.h"

@interface MindmapReaderTest : QMCacaoTestCase
@property(strong) QMRootNode *rootNode;
@end

@implementation MindmapReaderTest {
    NSURL *testMindmapUrl;
    NSURL *testNoIdMindmapUrl;
    QMMindmapReader *reader;
    QMRootNode *rootNode;
}

@synthesize rootNode;

- (void)setUp {
    [super setUp];

    testMindmapUrl = [[NSBundle bundleForClass:self.class] URLForResource:@"mindmap-reader-test" withExtension:@"mm"];
    testNoIdMindmapUrl = [[NSBundle bundleForClass:self.class] URLForResource:@"mindmap-reader-no-id-test" withExtension:@"mm"];
    reader = [self.context beanWithClass:[QMMindmapReader class]];
}

- (void)testNonExistingUrl {
    assertThat([reader rootNodeForFileUrl:[NSURL URLWithString:@"file:///fdsfds"]], is(nilValue()));
}

- (void)testReadNoId {
    rootNode = [reader rootNodeForFileUrl:testNoIdMindmapUrl];

    assertThat(rootNode.nodeId, startsWith(@"ID_"));
    assertThat([rootNode.children[1] nodeId], startsWith(@"ID_"));
    assertThat([rootNode.leftChildren[0] nodeId], startsWith(@"ID_"));
}

- (void)testRead {
    rootNode = [reader rootNodeForFileUrl:testMindmapUrl];

    assertThat(rootNode.allChildren, hasSize(8));
    assertThat(rootNode.leftChildren, hasSize(3));
    assertThat(rootNode.children, hasSize(5));

    assertThat(rootNode.stringValue, is(@"test"));
    assertThat(rootNode.font, notNilValue());

    assertThat(rootNode.icons, hasSize(2));
    assertThat([rootNode objectInIconsAtIndex:0], is(@"attach"));
    assertThat([rootNode objectInIconsAtIndex:1], is(@"flag-pink"));

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

- (void)checkRightChildren:(QMRootNode *)rootNode {
    NSArray *rightChildren = rootNode.children;;

    // first child of the root
    QMNode *firstChild = [rightChildren objectAtIndex:0];
    assertThat(firstChild.stringValue, is(@"a"));

    NSFont *firstFont = firstChild.font;
    assertThat(firstFont, notNilValue());

    assertThat(@(firstChild.unsupportedChildren.count), is(@(1)));
    assertThat([firstChild.unsupportedChildren objectAtIndex:0], containsString(@"a <b>b c<u>d e</u> f g</b> h i"));

    assertThat(@([firstChild countOfChildren]), is(@(3)));
    assertThat([[firstChild objectInChildrenAtIndex:1] stringValue], is(@"a2"));
    assertThat(@([[firstChild objectInChildrenAtIndex:1] countOfIcons]), is(@(1)));
    assertThat([[firstChild objectInChildrenAtIndex:1] objectInIconsAtIndex:0], is(@"clanbomber"));

    // children of the first child
    QMNode *childOfA = [firstChild objectInChildrenAtIndex:0];
    QMNode *grandChildOfA = [childOfA objectInChildrenAtIndex:0];
    assertThat(grandChildOfA.stringValue, is(@"a1a"));

    // second child of the root
    QMNode *secondChild = [rightChildren objectAtIndex:1];
    assertThat(secondChild.children, hasSize(4));
    assertThat(secondChild.stringValue, is(@"b"));
    assertThat(secondChild.attributes, isNot(hasItem(@"POSITION")));
    assertThat(secondChild.icons, consistsOf(@"full-6", @"ksmiletris", @"idea"));

    assertThat(@([secondChild countOfChildren]), is(@(4)));

    QMNode *thirdChild = [rootNode objectInChildrenAtIndex:2];
    assertThat(thirdChild.children, hasSize(3));
    assertThat(@([thirdChild isLeaf]), isNo);
    assertThat([[thirdChild objectInChildrenAtIndex:1] icons], consistsOf(@"kmail"));

    assertThat(@([[rootNode objectInChildrenAtIndex:3] isLeaf]), isYes);

    QMNode *fifthChild = [rootNode objectInChildrenAtIndex:4];
    assertThat(@([fifthChild isLeaf]), isNo);
    assertThat(@([fifthChild isFolded]), isYes);
    assertThat(fifthChild.children, hasSize(2));
}

@end
