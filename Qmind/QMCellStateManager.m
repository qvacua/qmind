/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import "QMCellStateManager.h"
#import "QMCell.h"
#import "QMRootCell.h"
#import "QMCellSelector.h"
#import <Qkit/Qkit.h>

@implementation QMCellStateManager {
    NSMutableArray *_selectedCells;

    QMStack *_clickedCells;

    QMCell *_mouseDownHitCell;
    QMCell *_dragTargetCell;
    QMCellSelector *_cellSelector;
}

@dynamic draggedCells;
@synthesize selectedCells = _selectedCells;
@synthesize mouseDownHitCell = _mouseDownHitCell;
@synthesize dragTargetCell = _dragTargetCell;
@synthesize cellSelector = _cellSelector;

#pragma mark Public
- (NSArray *)draggedCells {
    if (_mouseDownHitCell == nil) {
        return _selectedCells;
    }

    if ([_selectedCells containsObject:_mouseDownHitCell]) {
        return _selectedCells;
    }

    return @[_mouseDownHitCell];
}

- (void)addCellToSelection:(QMCell *)cellToAdd modifier:(NSUInteger)modifier {
    if (modifier == 0) {
        [self clearSelection];
        [self addSingleCell:cellToAdd];
        return;
    }

    if (![self areParentsTheSame:cellToAdd]) {
        return;
    }

    if ([_selectedCells containsObject:cellToAdd]) {
        return;
    }

    if (modifier & NSCommandKeyMask & NSShiftKeyMask) {
        // both modifiers
        return;
    }

    if (modifier & NSCommandKeyMask) {
        [self addSingleCell:cellToAdd];
        return;
    }

    if (modifier & NSShiftKeyMask) {
        [self shiftAddCell:cellToAdd];
        return;
    }

    [self clearSelection];
    [self addSingleCell:cellToAdd];
}

- (void)removeCellFromSelection:(QMCell *)cellToRemove modifier:(NSUInteger)modifier {
    if (modifier & NSCommandKeyMask & NSShiftKeyMask) {
        // both modifiers
        return;
    }

    if (_selectedCells.count == 1) {
        [self removeSingleCell:cellToRemove];
        return;
    }

    if (modifier & NSCommandKeyMask) {
        [self removeSingleCell:cellToRemove];
        return;
    }

    if (modifier & NSShiftKeyMask) {
        [self shiftRemoveCell:cellToRemove];
        return;
    }

    [self removeSingleCell:cellToRemove];
}

- (BOOL)cellIsSelected:(QMCell *)cell {
    return [_selectedCells containsObject:cell];
}

- (BOOL)hasSelectedCells {
    return _selectedCells.count > 0;
}

- (QMCell *)objectInSelectedCellsAtIndex:(NSUInteger)index {
    return [_selectedCells objectAtIndex:index];
}

- (void)clearSelection {
    [_selectedCells removeAllObjects];
    [_clickedCells removeAllObjects];
}

- (void)clearCellsForDrag {
    _dragTargetCell = nil;
    _mouseDownHitCell = nil;
}

- (BOOL)cellIsBeingDragged:(QMCell *)targetCell {
    __block BOOL found = NO;
    NSArray *draggedCells = self.draggedCells;

    for (QMCell *draggedCell in draggedCells) {
        [_cellSelector traverseCell:draggedCell usingBlock:^(QMCell *cell, BOOL *stop) {
            if (cell == targetCell) {
                *stop = YES;
                found = YES;
            }
        }];

        if (found) {
            return YES;
        }
    }

    return NO;
}

#pragma mark NSObject
- (id)init {
    if ((self = [super init])) {
        _selectedCells = [[NSMutableArray alloc] initWithCapacity:5];
        _clickedCells = [[NSMutableArray alloc] initWithCapacity:5];

        _cellSelector = [[TBContext sharedContext] beanWithIdentifier:NSStringFromClass([QMCellSelector class])];
    }

    return self;
}

#pragma mark Private
- (BOOL)areParentsTheSame:(QMCell *)cellToCheck {
    if (_selectedCells.count == 0) {
        return YES;
    }

    QMCell *oneCell = _selectedCells.lastObject;
    if (oneCell.isLeft == cellToCheck.isLeft && oneCell.parent == cellToCheck.parent) {
        return YES;
    }

    return NO;
}

- (void)sortSelectedCells {
    [_selectedCells sortUsingComparator:^(QMCell *cell1, QMCell *cell2) {
        QMCell *parent = cell1.parent;
        NSUInteger index1 = [parent indexOfChild:cell1];
        NSUInteger index2 = [parent indexOfChild:cell2];

        if (index1 < index2) {
            return (NSComparisonResult) NSOrderedAscending;
        }

        if (index1 > index2) {
            return (NSComparisonResult) NSOrderedDescending;
        }

        return (NSComparisonResult) NSOrderedSame;
    }];
}

- (void)shiftAddCell:(QMCell *)cellToAdd {
    if (_selectedCells.count == 0) {
        [_selectedCells addObject:cellToAdd];
        [_clickedCells push:cellToAdd];
        return;
    }

    QMCell *parent = cellToAdd.parent;
    NSUInteger indexOfLastCell = [parent indexOfChild:[_clickedCells top]];
    NSUInteger indexOfCellToAdd = [parent indexOfChild:cellToAdd];
    NSUInteger initial;
    NSUInteger end;

    if (indexOfCellToAdd > indexOfLastCell) {
        initial = indexOfLastCell;
        end = indexOfCellToAdd;
    } else {
        initial = indexOfCellToAdd;
        end = indexOfLastCell;
    }

    if (cellToAdd.isLeft && parent.isRoot) {
        QMRootCell *root = (QMRootCell *)parent;
        for (NSUInteger i = initial; i <= end; i++) {
            QMCell *cell = [root objectInLeftChildrenAtIndex:i];
            if (![_selectedCells containsObject:cell]) {
                [_selectedCells addObject:cell];
            }
        }
    } else {
        for (NSUInteger i = initial; i <= end; i++) {
            QMCell *cell = [parent objectInChildrenAtIndex:i];
            if (![_selectedCells containsObject:cell]) {
                [_selectedCells addObject:cell];
            }
        }
    }

    [_clickedCells push:cellToAdd];
    [self sortSelectedCells];
}

- (void)addSingleCell:(QMCell *)cellToAdd {
    [_selectedCells addObject:cellToAdd];
    [_clickedCells push:cellToAdd];

    [self sortSelectedCells];
}

- (void)removeSingleCell:(QMCell *)cellToRemove {
    [_clickedCells removeObject:cellToRemove];
    [_selectedCells removeObject:cellToRemove];
}

- (void)shiftRemoveCell:(QMCell *)cellToRemove {
    QMCell *parent = cellToRemove.parent;
    NSUInteger indexOfLastCell = [parent indexOfChild:[_clickedCells top]];
    NSUInteger indexOfCellToAdd = [parent indexOfChild:cellToRemove];
    NSUInteger initial;
    NSUInteger end;

    if (indexOfCellToAdd > indexOfLastCell) {
        initial = indexOfLastCell;
        end = indexOfCellToAdd;
    } else {
        initial = indexOfCellToAdd;
        end = indexOfLastCell;
    }

    if (cellToRemove.isLeft && parent.isRoot) {
        QMRootCell *root = (QMRootCell *)parent;
        for (NSUInteger i = initial; i <= end; i++) {
            QMCell *cell = [root objectInLeftChildrenAtIndex:i];
            [_selectedCells removeObject:cell];
        }
    } else {
        for (NSUInteger i = initial; i <= end; i++) {
            QMCell *cell = [parent objectInChildrenAtIndex:i];
            [_selectedCells removeObject:cell];
        }
    }

    [_clickedCells removeObject:cellToRemove];
}

@end
