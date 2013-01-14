#import <TBCacao/TBCacao.h>
#import "QMBaseTestCase.h"
#import "QMCellStateManager.h"
#import "QMRootCell.h"
#import "QMBaseTestCase+Util.h"
#import "QMMindmapView.h"
#import "QMCacaoTestCase.h"

@interface CellStateManagerTest : QMCacaoTestCase
@end

@implementation CellStateManagerTest {
    QMCellStateManager *stateManager;
    NSArray *selCells;

    QMRootCell *rootCell;
}

- (void)setUp {
    [[TBContext sharedContext] initContext];

    stateManager = [[QMCellStateManager alloc] init];
    selCells = stateManager.selectedCells;

    rootCell = [self rootCellForTestWithView:mock([QMMindmapView class])];
}

- (void)testClearCellsForDrag {
    stateManager.mouseDownHitCell = CELL(1);
    stateManager.dragTargetCell = CELL(4);

    [stateManager clearCellsForDrag];
    assertThat(stateManager.mouseDownHitCell, nilValue());
    assertThat(stateManager.dragTargetCell, nilValue());
    assertThat(stateManager.draggedCells, hasSize(0));
}

- (void)testCellIsBeingDragged {
    stateManager.mouseDownHitCell = CELL(1);
    [stateManager addCellToSelection:CELL(1) modifier:0];
    [stateManager addCellToSelection:CELL(3) modifier:NSCommandKeyMask];

    assertThat(@([stateManager cellIsBeingDragged:CELL(1)]), is(@(YES)));
    assertThat(@([stateManager cellIsBeingDragged:CELL(1)]), is(@(YES)));
    for (QMCell *cell in [CELL(1) children]) {
        assertThat(@([stateManager cellIsBeingDragged:cell]), is(@(YES)));
    }
    for (QMCell *cell in [CELL(3) children]) {
        assertThat(@([stateManager cellIsBeingDragged:cell]), is(@(YES)));
    }
}

- (void)testDraggedCells {
    stateManager.mouseDownHitCell = CELL(1);
    [stateManager addCellToSelection:CELL(1) modifier:0];
    [stateManager addCellToSelection:CELL(2) modifier:NSCommandKeyMask];
    [stateManager addCellToSelection:CELL(6) modifier:NSCommandKeyMask];
    assertThat(stateManager.draggedCells, consistsOf(CELL(1), CELL(2), CELL(6)));

    stateManager.mouseDownHitCell = CELL(3);
    assertThat(stateManager.draggedCells, consistsOf(CELL(3)));
}

- (void)testCellSelected {
    [stateManager addCellToSelection:CELL(0) modifier:0];

    assertThatBool([stateManager cellIsSelected:CELL(0)], isTrue);
    assertThatBool([stateManager cellIsSelected:CELL(8)], isFalse);
}

- (void)testSimpleAddCellToSelection {
    [stateManager addCellToSelection:CELL(0) modifier:0];

    assertThat(stateManager.selectedCells, consistsOf(CELL(0)));
}

- (void)testAddCellWithoutModifierReplacingSelection {
    [stateManager addCellToSelection:rootCell modifier:0];

    [stateManager addCellToSelection:CELL(1) modifier:0];
    assertThat(stateManager.selectedCells, consistsOf(CELL(1)));
}

- (void)testCommandAddCellToSelectionAndOrder {
    [stateManager addCellToSelection:CELL(0, 1) modifier:NSCommandKeyMask];
    assertThat(selCells, hasSize(1));
    assertThat(selCells, consistsOf(CELL(0, 1)));

    [stateManager addCellToSelection:CELL(1) modifier:NSCommandKeyMask];
    assertThat(selCells, hasSize(1));
    assertThat(selCells, consistsOf(CELL(0, 1)));

    [stateManager addCellToSelection:CELL(0, 6) modifier:NSCommandKeyMask];
    assertThat(selCells, hasSize(2));
    assertThat(selCells, consistsOf(CELL(0, 1), CELL(0, 6)));

    [stateManager addCellToSelection:CELL(0, 3) modifier:NSCommandKeyMask];
    assertThat(selCells, hasSize(3));
    assertThat(selCells, consistsOf(CELL(0, 1), CELL(0, 3), CELL(0, 6)));
}

- (void)testShiftClickMultipleCellInRowSelect {
    [stateManager addCellToSelection:CELL(1) modifier:NSShiftKeyMask];
    assertThat(selCells, hasSize(1));
    assertThat(selCells, consistsOf(CELL(1)));

    [stateManager addCellToSelection:CELL(1, 2) modifier:NSShiftKeyMask];
    assertThat(selCells, hasSize(1));
    assertThat(selCells, consistsOf(CELL(1)));

    [stateManager addCellToSelection:CELL(5) modifier:NSShiftKeyMask];
    assertThat(selCells, hasSize(5));
    assertThat(selCells, consistsOf(CELL(1), CELL(2), CELL(3), CELL(4), CELL(5)));
}

- (void)testClickMultipleCellOrdering {
    [stateManager addCellToSelection:CELL(0) modifier:0];
    assertThat(selCells, hasSize(1));
    assertThat(selCells, consistsOf(CELL(0)));

    [stateManager addCellToSelection:CELL(6) modifier:NSCommandKeyMask];
    assertThat(selCells, hasSize(2));
    assertThat(selCells, consistsOf(CELL(0), CELL(6)));

    [stateManager addCellToSelection:CELL(2) modifier:NSCommandKeyMask];
    assertThat(selCells, hasSize(3));
    assertThat(selCells, consistsOf(CELL(0), CELL(2), CELL(6)));

    [stateManager addCellToSelection:CELL(4) modifier:NSShiftKeyMask];
    assertThat(selCells, hasSize(5));
    assertThat(selCells, consistsOf(CELL(0), CELL(2), CELL(3), CELL(4), CELL(6)));
}

- (void)testClickMultipleCellReverseOrdering {
    [stateManager addCellToSelection:CELL(0) modifier:0];
    assertThat(selCells, hasSize(1));
    assertThat(selCells, consistsOf(CELL(0)));

    [stateManager addCellToSelection:CELL(6) modifier:NSCommandKeyMask];
    assertThat(selCells, hasSize(2));
    assertThat(selCells, consistsOf(CELL(0), CELL(6)));

    [stateManager addCellToSelection:CELL(4) modifier:NSCommandKeyMask];
    assertThat(selCells, hasSize(3));
    assertThat(selCells, consistsOf(CELL(0), CELL(4), CELL(6)));

    [stateManager addCellToSelection:CELL(1) modifier:NSShiftKeyMask];
    assertThat(selCells, hasSize(6));
    assertThat(selCells, consistsOf(CELL(0), CELL(1), CELL(2), CELL(3), CELL(4), CELL(6)));
}

- (void)testClickMultipleCellReverseOrderingMultipleShift {
    [stateManager addCellToSelection:CELL(9) modifier:0];
    [stateManager addCellToSelection:CELL(6) modifier:NSCommandKeyMask];
    [stateManager addCellToSelection:CELL(8) modifier:NSShiftKeyMask];
    [stateManager addCellToSelection:CELL(3) modifier:NSShiftKeyMask];

    assertThat(selCells, hasSize(7));
    assertThat(selCells, consistsOf(CELL(3), CELL(4), CELL(5), CELL(6), CELL(7), CELL(8), CELL(9)));
}

- (void)testSimpleRemoveOneCell {
    [stateManager addCellToSelection:CELL(0) modifier:0];
    assertThat(selCells, hasSize(1));
    assertThat(selCells, consistsOf(CELL(0)));

    [stateManager removeCellFromSelection:CELL(0) modifier:0];
    assertThat(selCells, hasSize(0));
}

- (void)testCommandRemoveCellFromMultiSelection {
    [stateManager addCellToSelection:CELL(9) modifier:0];
    [stateManager addCellToSelection:CELL(6) modifier:NSCommandKeyMask];
    [stateManager addCellToSelection:CELL(3) modifier:NSCommandKeyMask];
    [stateManager addCellToSelection:CELL(1) modifier:NSCommandKeyMask];
    assertThat(selCells, hasSize(4));
    assertThat(selCells, consistsOf(CELL(1), CELL(3), CELL(6), CELL(9)));

    [stateManager removeCellFromSelection:CELL(6) modifier:NSCommandKeyMask];
    assertThat(selCells, hasSize(3));
    assertThat(selCells, consistsOf(CELL(1), CELL(3), CELL(9)));
}

- (void)testShiftRemoveCellFromMultiSelection {
    [stateManager addCellToSelection:CELL(9) modifier:0];
    [stateManager addCellToSelection:CELL(6) modifier:NSCommandKeyMask];
    [stateManager addCellToSelection:CELL(8) modifier:NSShiftKeyMask];
    [stateManager addCellToSelection:CELL(3) modifier:NSShiftKeyMask];

    assertThat(selCells, hasSize(7));
    assertThat(selCells, consistsOf(CELL(3), CELL(4), CELL(5), CELL(6), CELL(7), CELL(8), CELL(9)));

    [stateManager removeCellFromSelection:CELL(7) modifier:NSShiftKeyMask];
    assertThat(selCells, hasSize(2));
    assertThat(selCells, consistsOf(CELL(8), CELL(9)));
}

- (void)testThereAreSelectedCells {
    assertThatBool([stateManager hasSelectedCells], isFalse);

    [stateManager addCellToSelection:CELL(0) modifier:0];
    assertThatBool([stateManager hasSelectedCells], isTrue);

    [stateManager clearSelection];
    assertThatBool([stateManager hasSelectedCells], isFalse);
}

- (void)testSelectRemoveSelect {
    [stateManager addCellToSelection:CELL(2) modifier:0];
    assertThat(stateManager.selectedCells, hasSize(1));
    assertThat(stateManager.selectedCells, consistsOf(CELL(2)));
    [stateManager clearSelection];
    assertThat(stateManager.selectedCells, hasSize(0));

    [stateManager addCellToSelection:CELL(4) modifier:NSShiftKeyMask];
    assertThat(stateManager.selectedCells, hasSize(1));
    assertThat(stateManager.selectedCells, consistsOf(CELL(4)));
    [stateManager clearSelection];
    assertThat(stateManager.selectedCells, hasSize(0));

    [stateManager addCellToSelection:CELL(6) modifier:NSCommandKeyMask];
    assertThat(stateManager.selectedCells, hasSize(1));
    assertThat(stateManager.selectedCells, consistsOf(CELL(6)));
}

- (void)testClearSelection {
    [stateManager addCellToSelection:CELL(0) modifier:0];
    [stateManager addCellToSelection:CELL(4) modifier:NSCommandKeyMask];
    assertThat(selCells, hasSize(2));

    [stateManager clearSelection];
    assertThat(selCells, hasSize(0));

    // since we are remembering the last cell selected
    [stateManager addCellToSelection:CELL(8) modifier:NSShiftKeyMask];
    assertThat(selCells, hasSize(1));
    assertThat(selCells, consistsOf(CELL(8)));
}

@end
