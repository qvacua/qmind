/**
 * Tae Won Ha
 * http://qvacua.com
 * https://bitbucket.org/qvacua
 *
 * See LICENSE
 */

#import "QMBaseTestCase+Util.h"
#import "QMCellSelector.h"
#import "QMRootCell.h"
#import <Qkit/Qkit.h>
#import "QMMindmapView.h"
#import "QMCacaoTestCase.h"

@interface CellSelectorTest : QMCacaoTestCase @end

@implementation CellSelectorTest {
    QMCellSelector *selector;
    QMRootCell *rootCell;
}

- (void)setUp {
    [super setUp];

    selector = [self.context beanWithIdentifier:[[QMCellSelector class] description]];
    rootCell = [self rootCellForTestWithView:mock([QMMindmapView class])];
}

- (void)testCellContainingPointRoot {
    [self assertCellContainingPoint:rootCell origin:NewPoint(10, 20)];
}

- (void)testCellContainingPointChild {
    QMCell *leftChild = [rootCell objectInLeftChildrenAtIndex:1];

    [self assertCellContainingPoint:leftChild origin:NewPoint(1000, 2000)];
}

- (void)testCellContainingPointGrandChild {
    QMCell *child = [rootCell objectInChildrenAtIndex:0];
    QMCell *grandChild = [child objectInChildrenAtIndex:0];

    [self assertCellContainingPoint:grandChild origin:NewPoint(1000, 2000)];
}

- (void)testCellWithIdentifier {
    id obj1 = [[NSObject alloc] init];
    id obj2 = [[NSObject alloc] init];

    [CELL(1, 4) setIdentifier:obj1];
    [LCELL(4, 8) setIdentifier:obj2];

    assertThat([selector cellWithIdentifier:obj1 fromParentCell:rootCell], is(CELL(1, 4)));
    assertThat([selector cellWithIdentifier:obj2 fromParentCell:rootCell], is(LCELL(4, 8)));
}

- (void)assertCellContainingPoint:(QMCell *)cell origin:(NSPoint)origin {
    cell.origin = origin;
    NSSize size = cell.size;

    assertThat([selector cellContainingPoint:origin inCell:rootCell], is(cell));
    assertThat([selector cellContainingPoint:NewPoint(origin.x + size.width - 0.5, origin.y + size.height - 0.5) inCell:rootCell], is(cell));
}

@end
