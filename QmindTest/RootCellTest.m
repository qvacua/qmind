#import "QMCellLayoutManager.h"
#import "QMMindmapView.h"
#import "QMCellDrawer.h"
#import "QMBaseTestCase.h"
#import "QMRootCell.h"
#import "QMTextLayoutManager.h"
#import "QMCellSizeManager.h"
#import <Qkit/Qkit.h>

@interface RootCellTest : QMBaseTestCase
@end

@implementation RootCellTest {
    QMMindmapView *view;

    QMRootCell *rootCell;
    QMCell *cell;
    QMCell *leftCell;
    QMCell *anotherCell;

    QMCellLayoutManager *cellLayoutManager;
    QMCellSizeManager *cellSizeManager;
    QMCellDrawer *cellDrawer;
    QMTextLayoutManager *textLayoutManager;
}

- (void)setUp {
    [super setUp];

    view = mock(QMMindmapView.class);
    cellLayoutManager = mock(QMCellLayoutManager.class);
    cellSizeManager = mock([QMCellSizeManager class]);
    cellDrawer = mock(QMCellDrawer.class);
    textLayoutManager = mock(QMTextLayoutManager.class);

    rootCell = [[QMRootCell alloc] initWithView:view];

    anotherCell = [[QMCell alloc] initWithView:view];
    anotherCell.stringValue = @"f";

    [rootCell addObjectInChildren:anotherCell];

    cell = [[QMCell alloc] initWithView:view];
    leftCell = [[QMCell alloc] initWithView:view];

    leftCell.stringValue = @"left cell";
    cell.stringValue = @"test cell";
    cell.folded = NO;

    [self wireCell:rootCell];
    [self wireCell:cell];
    [self wireCell:anotherCell];
    [self wireCell:leftCell];
}

- (void)testNeedsToRecomputeCell {
    rootCell.size;
    assertThat(@(rootCell.needsToRecomputeSize), isNo);

    [rootCell addObjectInLeftChildren:leftCell];
    assertThat(@(rootCell.needsToRecomputeSize), isYes);
    rootCell.size;
    assertThat(@(rootCell.needsToRecomputeSize), isNo);

    [rootCell removeObjectFromLeftChildrenAtIndex:0];
    assertThat(@(rootCell.needsToRecomputeSize), isYes);
    rootCell.size;
    assertThat(@(rootCell.needsToRecomputeSize), isNo);
}

- (void)testIndexOfCell {
    QMCell *leftCell2 = [leftCell copy];

    [rootCell addObjectInChildren:cell];
    [rootCell addObjectInLeftChildren:leftCell];
    [rootCell addObjectInLeftChildren:leftCell2];

    assertThatUnsignedInteger([rootCell indexOfChild:anotherCell], equalToInt(0));
    assertThatUnsignedInteger([rootCell indexOfChild:cell], equalToInt(1));
    assertThatUnsignedInteger([rootCell indexOfChild:leftCell], equalToInt(0));
    assertThatUnsignedInteger([rootCell indexOfChild:leftCell2], equalToInt(1));
}

- (void)testConvenienceChildMethods {
    QMCell *child1 = [[QMCell alloc] initWithView:view];
    QMCell *child2 = [[QMCell alloc] initWithView:view];

    [rootCell addChild:child1 left:YES];
    assertThat(rootCell.leftChildren, hasSize(1));
    assertThat(rootCell.leftChildren, consistsOf(child1));
    assertThatBool(child1.isLeft, isTrue);

    [rootCell addChild:child2 left:NO];
    assertThat(rootCell.children, hasSize(2));
    assertThat(rootCell.children, consistsOf(anotherCell, child2));
    assertThatBool(child2.isLeft, isFalse);
}

- (void)testRoot {
    assertThatBool(rootCell.isRoot, isTrue);
}

- (void)testLeaf {
    [rootCell removeObjectFromChildrenAtIndex:0];
    assertThatBool(rootCell.isLeaf, isTrue);

    [rootCell addObjectInLeftChildren:[[QMCell alloc] initWithView:nil]];
    assertThatBool(rootCell.isLeaf, isFalse);
}

- (void)testDraw {
    [rootCell addObjectInChildren:cell];
    [rootCell addObjectInLeftChildren:leftCell];

    [given([cellSizeManager sizeOfCell:rootCell]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfCell:cell]) willReturnSize:NewSize(11, 11)];
    [given([cellSizeManager sizeOfCell:leftCell]) willReturnSize:NewSize(12, 12)];

    [rootCell drawRect:rootCell.frame];
    [verifyCount(cellDrawer, times(1)) drawCell:rootCell rect:rootCell.frame];
    [verifyCount(cellDrawer, times(1)) drawCell:cell rect:rootCell.frame];
    [verifyCount(cellDrawer, times(1)) drawCell:leftCell rect:rootCell.frame];
}

- (void)testInitBasics {
    QMRootCell *newRootCell = [[QMRootCell alloc] initWithView:view];

    assertThat(newRootCell.leftChildren, hasSize(0));
    assertThatBool(newRootCell.isLeft, isFalse);
}

- (void)testKvcForLeftChildren {
    [rootCell insertObject:leftCell inLeftChildrenAtIndex:0];

    assertThat(leftCell.parent, equalTo(rootCell));
    assertThatBool(leftCell.isLeft, isTrue);
    assertThat([rootCell objectInLeftChildrenAtIndex:0], equalTo(leftCell));
    assertThatUnsignedInteger([rootCell countOfLeftChildren], equalToInt(1));

    QMCell *grandLeftChild = [[QMCell alloc] initWithView:view];
    [leftCell insertObject:grandLeftChild inChildrenAtIndex:0];
    assertThatBool(grandLeftChild.isLeft, isTrue);
    [leftCell removeObjectFromChildrenAtIndex:0];
    assertThatBool(grandLeftChild.isLeft, isFalse);

    [rootCell removeObjectFromLeftChildrenAtIndex:0];
    assertThatUnsignedInteger([rootCell countOfLeftChildren], equalToInt(0));
    assertThat(leftCell.parent, nilValue());
    assertThatBool(leftCell.isLeft, isFalse);

    [rootCell addObjectInLeftChildren:leftCell];
    assertThat(leftCell.parent, equalTo(rootCell));
    assertThatBool(leftCell.isLeft, isTrue);
    assertThatUnsignedInteger([rootCell countOfLeftChildren], equalToInt(1));
}

- (void)testAllChildren {
    [rootCell insertObject:cell inChildrenAtIndex:0];
    [rootCell insertObject:leftCell inLeftChildrenAtIndex:0];

    assertThat(rootCell.allChildren, hasSize(3));
    assertThat(rootCell.allChildren, containsInAnyOrder(equalTo(leftCell), equalTo(cell), equalTo(anotherCell), nil));
    assertThatUnsignedInteger([rootCell countOfAllChildren], equalToInt(3));
}

- (void)testTestLeftChildrenFamilySize {
    [given([cellSizeManager sizeOfChildrenFamily:rootCell.leftChildren]) willReturnSize:NewSize(13, 13)];

    [rootCell addObjectInLeftChildren:leftCell];
    assertThatSize(rootCell.leftChildrenFamilySize, equalToSize(NewSize(13, 13)));

    assertThat(@(rootCell.needsToRecomputeSize), isNo);
}

- (void)wireCell:(QMCell *)aCell {
    aCell.cellLayoutManager = cellLayoutManager;
    aCell.cellDrawer = cellDrawer;
    aCell.textLayoutManager = textLayoutManager;
    aCell.cellSizeManager = cellSizeManager;
}

@end
