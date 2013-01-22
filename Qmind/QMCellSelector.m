/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import "QMCellSelector.h"
#import "QMCell.h"
#import <Qkit/Qkit.h>

@implementation QMCellSelector

TB_BEAN

- (QMCell *)cellWithIdentifier:(id)identifier fromParentCell:(QMCell *)parentCell {
    QMCell *result = [self traverseCell:parentCell usingBlock:^(QMCell *cell, BOOL *stop) {
        if (cell.identifier == identifier) {
            *stop = YES;
        }
    }];

    return result;
}

- (QMCell *)traverseCell:(QMCell *)parentCell usingBlock:(void (^)(QMCell *cell , BOOL *stop))block {
    // pre-order traversal

    BOOL stop = NO;

    QMStack *nodeStack = [[NSMutableArray allocWithZone:nil] initWithCapacity:15];
    [nodeStack push:parentCell];

    __weak QMCell *currentCell;
    while (nodeStack.count > 0) {
        currentCell = [nodeStack pop];

        if (currentCell.isLeaf == NO && currentCell.isFolded == NO) {
            [nodeStack pushArray:currentCell.allChildren];
        }

        block(currentCell, &stop);

        if (stop) {
            return currentCell;
        }
    }

    return nil;
}

- (QMCell *)cellContainingPoint:(NSPoint)point inCell:(QMCell *)startingCell {
    QMCell *result = [self traverseCell:startingCell usingBlock:^(QMCell *cell, BOOL *stop) {
        if (NSPointInRect(point, cell.frame)) {
            *stop = YES;
        }
    }];

    return result;
}

@end
