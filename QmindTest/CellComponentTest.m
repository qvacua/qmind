/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import "QMCacaoTestCase.h"
#import "QMMindmapView.h"
#import "QMCell.h"
#import "QMRootCell.h"
#import "QMBaseTestCase+Util.h"

@interface CellComponentTest : QMCacaoTestCase
@end

@implementation CellComponentTest {
    QMMindmapView *view;

    QMRootCell *rootCell;
}

- (void)setUp {
    [super setUp];

    view = mock(QMMindmapView.class);
    rootCell = [self rootCellForTestWithView:view];
}

/**
* @bug
*/
- (void)testRightCellsPropagateRecomputeFamilySizeUptoRoot {
    QMCell *leaf1 = [[QMCell alloc] initWithView:view];
    QMCell *leaf2 = [[QMCell alloc] initWithView:view];
    leaf1.stringValue = @"leaf 1";
    leaf2.stringValue = @"leaf 2";

    [CELL(1, 1) addObjectInChildren:leaf1];
    [CELL(1, 1) addObjectInChildren:leaf2];

    NSSize oldSize = rootCell.familySize;
    [CELL(1, 1) setFolded:YES];

    assertThat(@(rootCell.needsToRecomputeSize), isYes);
    assertThat(@([CELL(1) needsToRecomputeSize]), isYes);

    NSSize newSize = rootCell.familySize;
    assertThatSize(newSize, isNot(equalToSize(oldSize)));
    assertThat(@(newSize.height), lessThanFloat(oldSize.height));
}

/**
* @bug
*/
- (void)testLeftCellsPropagateRecomputeFamilySizeUptoRoot {
    QMCell *leaf1 = [[QMCell alloc] initWithView:view];
    QMCell *leaf2 = [[QMCell alloc] initWithView:view];
    leaf1.stringValue = @"leaf 1";
    leaf2.stringValue = @"leaf 2";

    [LCELL(1, 1) addObjectInChildren:leaf1];
    [LCELL(1, 1) addObjectInChildren:leaf2];

    NSSize oldSize = rootCell.familySize;
    [LCELL(1, 1) setFolded:YES];

    assertThat(@(rootCell.needsToRecomputeSize), isYes);
    assertThat(@([LCELL(1) needsToRecomputeSize]), isYes);

    NSSize newSize = rootCell.familySize;
    assertThatSize(newSize, isNot(equalToSize(oldSize)));
    assertThat(@(newSize.height), lessThanFloat(oldSize.height));
}

@end
