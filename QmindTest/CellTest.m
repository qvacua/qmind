/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Qkit/Qkit.h>
#import "QMCellDrawer.h"
#import "QMTextLayoutManager.h"
#import "QMMindmapView.h"
#import "QMCellLayoutManager.h"
#import "QMRootCell.h"
#import "QMCellSizeManager.h"
#import "QMBaseTestCase.h"
#import "QMIcon.h"

@interface CellTest : QMBaseTestCase @end

@implementation CellTest {
    QMMindmapView *view;

    QMCell *parentCell;
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

    parentCell = [[QMCell alloc] initWithView:view];
    anotherCell = [[QMCell alloc] initWithView:view];
    anotherCell.stringValue = @"f";

    [parentCell addObjectInChildren:anotherCell];

    cell = [[QMCell alloc] initWithView:view];
    leftCell = [[QMCell alloc] initWithView:view];

    leftCell.stringValue = @"left cell";
    cell.stringValue = @"test cell";
    cell.folded = NO;

    cellLayoutManager = mock(QMCellLayoutManager.class);
    cellDrawer = mock(QMCellDrawer.class);
    textLayoutManager = mock(QMTextLayoutManager.class);
    cellSizeManager = mock([QMCellSizeManager class]);

    [self wireCell:parentCell];
    [self wireCell:cell];
    [self wireCell:leftCell];
    [self wireCell:anotherCell];
}

- (void)testNeedsToRecomputePropagation {
    [parentCell addObjectInChildren:cell];
    QMCell *grandChild = [[QMCell alloc] initWithView:view];
    [cell addObjectInChildren:grandChild];

    parentCell.size;
    cell.size;
    grandChild.size;
    assertThat(@(cell.needsToRecomputeSize), isNo);
    assertThat(@(grandChild.needsToRecomputeSize), isNo);

    grandChild.needsToRecomputeSize = YES;

    assertThat(@(grandChild.needsToRecomputeSize), isYes);
    assertThat(@(cell.needsToRecomputeSize), isYes);
    assertThat(@(grandChild.needsToRecomputeSize), isYes);
}

- (void)testNeedsToRecomputeCell {
    cell.size;
    assertThat(@(cell.needsToRecomputeSize), isNo);

    cell.stringValue = @"new value";
    assertThat(@(cell.needsToRecomputeSize), isYes);
    cell.size;
    assertThat(@(cell.needsToRecomputeSize), isNo);

    cell.font = [NSFont menuBarFontOfSize:111];
    assertThat(@(cell.needsToRecomputeSize), isYes);
    cell.size;
    assertThat(@(cell.needsToRecomputeSize), isNo);

    [cell addObjectInIcons:@"1"];
    assertThat(@(cell.needsToRecomputeSize), isYes);
    cell.size;
    assertThat(@(cell.needsToRecomputeSize), isNo);

    [cell removeObjectFromIconsAtIndex:0];
    assertThat(@(cell.needsToRecomputeSize), isYes);
    cell.size;
    assertThat(@(cell.needsToRecomputeSize), isNo);

    [cell addObjectInChildren:anotherCell];
    assertThat(@(cell.needsToRecomputeSize), isYes);
    cell.size;
    assertThat(@(cell.needsToRecomputeSize), isNo);

    [cell removeObjectFromChildrenAtIndex:0];
    assertThat(@(cell.needsToRecomputeSize), isYes);
    cell.size;
    assertThat(@(cell.needsToRecomputeSize), isNo);

    cell.folded = !cell.folded;
    assertThat(@(cell.needsToRecomputeSize), isYes);
    cell.size;
}

- (void)testIndexWithinParent {
    QMCell *child1 = [[QMCell alloc] initWithView:view];
    QMCell *child2 = [[QMCell alloc] initWithView:view];

    [cell addObjectInChildren:child1];
    [cell addObjectInChildren:child2];

    assertThat(@([child2 indexWithinParent]), is(@(1)));
}

- (void)testIndexWithinRoot {
    QMCell *child1 = [[QMCell alloc] initWithView:view];
    QMCell *child2 = [[QMCell alloc] initWithView:view];

    QMRootCell *rootCell = [[QMRootCell alloc] initWithView:view];
    [rootCell addObjectInLeftChildren:child1];
    [rootCell addObjectInLeftChildren:child2];

    assertThat(@([child2 indexWithinParent]), is(@(1)));
}

- (void)testContainingArrayForRightCell {
    QMCell *child1 = [[QMCell alloc] initWithView:view];
    [cell addObjectInChildren:child1];

    assertThat([child1 containingArray], is(cell.children));
}

- (void)testContainingArrayForLeftCell {
    QMCell *child1 = [[QMCell alloc] initWithView:view];

    QMRootCell *rootCell = [[QMRootCell alloc] initWithView:view];
    [rootCell addObjectInLeftChildren:child1];

    assertThat([child1 containingArray], is(rootCell.leftChildren));
}

- (void)testIndexOfChild {
    QMCell *child1 = [[QMCell alloc] initWithView:view];
    QMCell *child2 = [[QMCell alloc] initWithView:view];

    [cell addObjectInChildren:child1];
    [cell addObjectInChildren:child2];

    assertThat(@([cell indexOfChild:child1]), is(@(0)));
    assertThat(@([cell indexOfChild:child2]), is(@(1)));
}

- (void)testConvenienceChildMethods {
    QMCell *child1 = [[QMCell alloc] initWithView:view];
    QMCell *child2 = [[QMCell alloc] initWithView:view];

    [cell addChild:child1 left:YES];
    assertThat(cell.children, hasSize(1));
    assertThat(cell.children, consistsOf(child1));
    assertThat(@(child1.isLeft), isNo);

    [cell addChild:child2 left:NO];
    assertThat(cell.children, hasSize(2));
    assertThat(cell.children, consistsOf(child1, child2));
    assertThat(@(child2.isLeft), isNo);

    [cell removeChild:child1];
    assertThat(cell.children, hasSize(1));
    assertThat(cell.children, consistsOf(child2));
    assertThat(@(child2.isLeft), isNo);

    leftCell.left = YES;
    [leftCell addChild:child1 left:YES];
    assertThat(leftCell.children, hasSize(1));
    assertThat(leftCell.children, consistsOf(child1));
    assertThat(@(child1.isLeft), isYes);

    [leftCell addChild:child2 left:NO];
    assertThat(leftCell.children, hasSize(2));
    assertThat(leftCell.children, consistsOf(child1, child2));
    assertThat(@(child2.isLeft), isYes);

    [leftCell removeChild:child2];
    assertThat(leftCell.children, hasSize(1));
    assertThat(leftCell.children, consistsOf(child1));
    assertThat(@(child1.isLeft), isYes);
}

- (void)testIsRoot {
    assertThat(@(parentCell.isRoot), isNo);
}

- (void)testRecompute {
    cell.size;
    [verify(cellSizeManager) sizeOfCell:cell];

    cell.stringValue = @"new text";
    cell.size;
    [verifyCount(cellSizeManager, times(2)) sizeOfCell:cell];

    cell.font = [NSFont boldSystemFontOfSize:50];
    cell.size;
    [verifyCount(cellSizeManager, times(3)) sizeOfCell:cell];

    [cell insertObject:@"icon" inIconsAtIndex:0];
    cell.size;
    [verifyCount(cellSizeManager, times(4)) sizeOfCell:cell];

    [cell removeObjectFromIconsAtIndex:0];
    cell.size;
    [verifyCount(cellSizeManager, times(5)) sizeOfCell:cell];
}

- (void)testFont {
    assertThat(cell.font, nilValue());

    NSFont *font = [NSFont boldSystemFontOfSize:20];

    NSMutableDictionary *attrDict = [NSMutableDictionary dictionary];
    [attrDict setObject:font forKey:NSFontAttributeName];
    [given([textLayoutManager stringAttributesDictWithFont:font]) willReturn:attrDict];
    cell.font = font;
    [verify(textLayoutManager) stringAttributesDictWithFont:font];
    assertThat([cell.attributedString attributesAtIndex:0 effectiveRange:NULL],
    atKey(NSFontAttributeName, equalTo(font)));

    font = [NSFont systemFontOfSize:50];
    [attrDict setObject:font forKey:NSFontAttributeName];
    [given([textLayoutManager stringAttributesDict]) willReturn:attrDict];
    cell.font = nil;
    [verify(textLayoutManager) stringAttributesDict];
    assertThat([cell.attributedString attributesAtIndex:0 effectiveRange:NULL],
    atKey(NSFontAttributeName, equalTo(font)));
}

- (void)testStringValue {
    NSFont *font = [NSFont systemFontOfSize:50];
    NSMutableDictionary *attrDict = [NSMutableDictionary dictionary];
    attrDict[NSFontAttributeName] = font;
    [given([textLayoutManager stringAttributesDict]) willReturn:attrDict];

    cell.stringValue = @"my string";
    [verifyCount(textLayoutManager, times(1)) stringAttributesDict];
    assertThat(cell.stringValue, equalTo(@"my string"));
    assertThat(cell.attributedString.string, equalTo(@"my string"));
    assertThat([cell.attributedString attributesAtIndex:0 effectiveRange:NULL],
    atKey(NSFontAttributeName, equalTo(font)));

    font = [NSFont boldSystemFontOfSize:20];
    [attrDict setObject:font forKey:NSFontAttributeName];
    [given([textLayoutManager stringAttributesDictWithFont:font]) willReturn:attrDict];
    cell.font = font;
    [verify(textLayoutManager) stringAttributesDictWithFont:font];
    assertThat([cell.attributedString attributesAtIndex:0 effectiveRange:NULL],
    atKey(NSFontAttributeName, equalTo(font)));

    textLayoutManager = mock(QMTextLayoutManager.class);
    [cell setInstanceVarTo:textLayoutManager];
    [given([textLayoutManager stringAttributesDictWithFont:font]) willReturn:attrDict];
    cell.stringValue = @"new string";
    [verify(textLayoutManager) stringAttributesDictWithFont:font];
    assertThat([cell.attributedString attributesAtIndex:0 effectiveRange:NULL],
    atKey(NSFontAttributeName, equalTo(font)));
}

- (void)testRangeCache {
    [given([textLayoutManager completeRangeOfAttributedString:instanceOf(NSAttributedString.class)])
            willReturnRange:NSMakeRange(30, 50)];
    cell.stringValue = @"fdsfa";
    [verify(textLayoutManager) completeRangeOfAttributedString:cell.attributedString];
    assertThatRange(cell.rangeOfStringValue, equalToRange(NSMakeRange(30, 50)));
}

- (void)testDraw {
    [parentCell insertObject:cell inChildrenAtIndex:0];

    [given([cellSizeManager sizeOfCell:parentCell]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfCell:cell]) willReturnSize:NewSize(11, 11)];

    [parentCell drawRect:parentCell.frame];
    [verifyCount(cellDrawer, times(1)) drawCell:parentCell rect:parentCell.frame];
    [verifyCount(cellDrawer, times(1)) drawCell:cell rect:parentCell.frame];
}

- (void)testDrawFolded {
    [given([cellSizeManager sizeOfCell:parentCell]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfCell:cell]) willReturnSize:NewSize(10, 10)];
    parentCell.folded = YES;

    [parentCell drawRect:parentCell.frame];
    [verifyCount(cellDrawer, times(1)) drawCell:parentCell rect:parentCell.frame];
    [verifyCount(cellDrawer, times(0)) drawCell:cell rect:parentCell.frame];
}

- (void)testInitAndBasics {
    cell = [[QMCell alloc] initWithView:view];
    [parentCell addObjectInChildren:cell];
    assertThat(cell.stringValue, equalTo(@""));

    cell.stringValue = @"test";
    cell.folded = YES;

    assertThat(parentCell.children, hasSize(2));

    assertThat(@(cell.isLeft), isNo);
    assertThat(cell.view, equalTo(view));
    assertThat(cell.parent, equalTo(parentCell));
    assertThat(cell.children, isNot(nilValue()));
    assertThat(cell.children, is(empty()));
    assertThat(cell.stringValue, equalTo(@"test"));
    assertThat(@(cell.isLeaf), isYes);
    assertThat(@(cell.isFolded), isYes);
}

- (void)testInitAndBasicsLeft {
    cell = [[QMCell alloc] initWithView:view];

    parentCell.left = YES;
    [parentCell addObjectInChildren:cell];
    assertThat(cell.stringValue, equalTo(@""));

    cell.stringValue = @"test";
    cell.folded = YES;

    assertThat(parentCell.children, hasSize(2));

    assertThat(@(cell.isLeft), isYes);
    assertThat(cell.view, equalTo(view));
    assertThat(cell.parent, equalTo(parentCell));
    assertThat(cell.children, isNot(nilValue()));
    assertThat(cell.children, is(empty()));
    assertThat(cell.stringValue, equalTo(@"test"));
    assertThat(@(cell.isLeaf), isYes);
    assertThat(@(cell.isFolded), isYes);

    QMCell *grandChild = [[QMCell alloc] initWithView:view];
    [cell insertObject:grandChild inChildrenAtIndex:0];
    assertThat(@(grandChild.isLeft), isYes);
    assertThat(cell.children, hasSize(1));
    assertThat(cell.children, contains(equalTo(grandChild), nil));
}

- (void)testKvcForChildren {
    [parentCell insertObject:cell inChildrenAtIndex:0];

    assertThat(cell.parent, equalTo(parentCell));
    assertThat(@(cell.isLeft), isNo);
    assertThat([parentCell objectInChildrenAtIndex:0], equalTo(cell));
    assertThat(@([parentCell countOfChildren]), is(@(2)));

    [parentCell removeObjectFromChildrenAtIndex:0];
    assertThat(@([parentCell countOfChildren]), is(@(1)));
    assertThat(cell.parent, nilValue());
}

- (void)testAllChildren {
    [parentCell insertObject:cell inChildrenAtIndex:0];
    assertThat(parentCell.allChildren, equalTo(parentCell.children));
    assertThat(@(parentCell.countOfAllChildren), is(@(2)));
}

- (void)testKvcForIcons {
    assertThat(cell.icons, hasSize(0));
    assertThat(@(cell.countOfIcons), is(@(0)));

    QMIcon *unicode = [[QMIcon alloc] initWithCode:@"unicode"];
    QMIcon *monocode = [[QMIcon alloc] initWithCode:@"monocode"];

    [cell insertObject:unicode inIconsAtIndex:0];
    [cell insertObject:monocode inIconsAtIndex:0];

    assertThat(cell.icons, hasSize(2));
    assertThat(@(cell.countOfIcons), is(@(2)));
    assertThat(cell.icons, consistsOf(monocode, unicode));

    assertThat([cell objectInIconsAtIndex:0], is(monocode));
    assertThat([cell objectInIconsAtIndex:1], is(unicode));

    [cell removeObjectFromIconsAtIndex:0];
    assertThat(cell.icons, hasSize(1));
    assertThat(cell.icons, consistsOf(unicode));

    QMIcon *jo = [[QMIcon alloc] initWithCode:@"jo"];
    [cell addObjectInIcons:jo];
    assertThat(cell.icons, hasSize(2));
    assertThat(cell.icons, consistsOf(unicode, jo));
}

- (void)testComputeGeometry {
    [cell computeGeometry];
    [verify(cellLayoutManager) computeGeometryAndLinesOfCell:cell];
}

- (void)testFrame {
    assertThatRect(cell.frame, equalToRect(NewRectWithOriginAndSize(cell.origin, cell.size)));
    assertThatRect(cell.familyFrame, equalToRect(NewRectWithOriginAndSize(cell.familyOrigin, cell.familySize)));
}

- (void)testMiddlePoint {
    assertThatPoint(cell.middlePoint, equalToPoint(NewPoint(cell.familyOrigin.x + cell.size.width / 2, cell.familyOrigin.y + cell.familySize.height / 2)));
}

- (void)testSize {
    [given([cellSizeManager sizeOfCell:cell]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfIconsOfCell:cell]) willReturnSize:NewSize(11, 11)];
    [given([cellSizeManager sizeOfTextOfCell:cell]) willReturnSize:NewSize(12, 12)];

    assertThatSize(cell.size, equalToSize(NewSize(10, 10)));
    assertThatSize(cell.iconSize, equalToSize(NewSize(11, 11)));
    assertThatSize(cell.textSize, equalToSize(NewSize(12, 12)));

    assertThat(@(cell.needsToRecomputeSize), isNo);
}

- (void)testTextFrame {
    [given([cellSizeManager sizeOfTextOfCell:cell]) willReturnSize:NewSize(3, 4)];
    cell.textOrigin = NewPoint(1, 2);
    assertThatRect(cell.textFrame, equalToRect(NewRect(1, 2, 3, 4)));
}

- (void)testIconSize {
    [given([cellSizeManager sizeOfCell:cell]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfIconsOfCell:cell]) willReturnSize:NewSize(11, 11)];
    [given([cellSizeManager sizeOfTextOfCell:cell]) willReturnSize:NewSize(12, 12)];

    assertThatSize(cell.size, equalToSize(NewSize(10, 10)));
    assertThatSize(cell.iconSize, equalToSize(NewSize(11, 11)));
    assertThatSize(cell.textSize, equalToSize(NewSize(12, 12)));

    assertThat(@(cell.needsToRecomputeSize), isNo);
}

- (void)testTestSizes {
    [given([cellSizeManager sizeOfCell:cell]) willReturnSize:NewSize(10, 10)];
    [given([cellSizeManager sizeOfIconsOfCell:cell]) willReturnSize:NewSize(11, 11)];
    [given([cellSizeManager sizeOfTextOfCell:cell]) willReturnSize:NewSize(12, 12)];
    [given([cellSizeManager sizeOfChildrenFamily:cell.children]) willReturnSize:NewSize(13, 13)];
    [given([cellSizeManager sizeOfFamilyOfCell:cell]) willReturnSize:NewSize(14, 14)];

    assertThatSize(cell.size, equalToSize(NewSize(10, 10)));
    assertThatSize(cell.iconSize, equalToSize(NewSize(11, 11)));
    assertThatSize(cell.textSize, equalToSize(NewSize(12, 12)));

    [cell addObjectInChildren:anotherCell];
    cell.folded = NO;
    assertThatSize(cell.childrenFamilySize, equalToSize(NewSize(13, 13)));
    assertThatSize(cell.familySize, equalToSize(NewSize(14, 14)));

    assertThat(@(cell.needsToRecomputeSize), isNo);
}

- (void)testChildrenFamilySize {
    [parentCell insertObject:cell inChildrenAtIndex:0];
    parentCell.folded = YES;

    assertThatSize(parentCell.childrenFamilySize, equalToSize(NewSize(0, 0)));
    assertThatSize(cell.childrenFamilySize, equalToSize(NewSize(0, 0)));

    parentCell.folded = NO;
    [given([cellSizeManager sizeOfChildrenFamily:parentCell.children]) willReturnSize:NewSize(10, 10)];
    assertThatSize(parentCell.childrenFamilySize, equalToSize(NewSize(10, 10)));
}

- (void)wireCell:(QMCell *)aCell {
    aCell.cellLayoutManager = cellLayoutManager;
    aCell.cellDrawer = cellDrawer;
    aCell.textLayoutManager = textLayoutManager;
    aCell.cellSizeManager = cellSizeManager;
}

@end
