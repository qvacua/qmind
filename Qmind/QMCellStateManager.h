/**
 * Tae Won Ha
 * http://qvacua.com
 * https://bitbucket.org/qvacua
 *
 * See LICENSE
 */

#import <Cocoa/Cocoa.h>

@class QMCell;
@class QMCellSelector;

@interface QMCellStateManager : NSObject

@property QMCellSelector *cellSelector;

@property (strong) QMCell *dragTargetCell;
@property (strong) QMCell *mouseDownHitCell;
@property (readonly, strong) NSArray *selectedCells;
@property (readonly) NSArray *draggedCells;

- (BOOL)cellIsSelected:(QMCell *)cell;
- (BOOL)hasSelectedCells;
- (QMCell *)objectInSelectedCellsAtIndex:(NSUInteger)index;
- (void)addCellToSelection:(QMCell *)cellToAdd modifier:(NSUInteger)modifier;
- (void)removeCellFromSelection:(QMCell *)cellToRemove modifier:(int)modifier;
- (void)clearSelection;

- (void)clearCellsForDrag;

- (BOOL)cellIsBeingDragged:(QMCell *)targetCell;

@end
