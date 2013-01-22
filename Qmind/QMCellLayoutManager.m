/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import "QMCellLayoutManager.h"
#import "QMAppSettings.h"
#import "QMRootCell.h"
#import "QMIcon.h"
#import <Qkit/Qkit.h>

@implementation QMCellLayoutManager

TB_BEAN
TB_AUTOWIRE_WITH_INSTANCE_VAR(settings, _settings)

#pragma mark Public
- (QMCellRegion)regionOfCell:(QMCell *)cell atPoint:(NSPoint)locationInView {
    if ([cell isRoot]) {
        if (NSPointInRect(locationInView, [self regionFrameOfCell:cell ofRegion:QMCellRegionEast])) {
            return QMCellRegionEast;
        }

        if (NSPointInRect(locationInView, [self regionFrameOfCell:cell ofRegion:QMCellRegionWest])) {
            return QMCellRegionWest;
        }
    }

    if (NSPointInRect(locationInView, [self regionFrameOfCell:cell ofRegion:QMCellRegionNorth])) {
        return QMCellRegionNorth;
    }

    if (NSPointInRect(locationInView, [self regionFrameOfCell:cell ofRegion:QMCellRegionSouth])) {
        return QMCellRegionSouth;
    }

    if (NSPointInRect(locationInView, [self regionFrameOfCell:cell ofRegion:QMCellRegionEast])) {
        return QMCellRegionEast;
    }

    if (NSPointInRect(locationInView, [self regionFrameOfCell:cell ofRegion:QMCellRegionWest])) {
        return QMCellRegionWest;
    }

    return QMCellRegionNone;
}

- (NSRect)regionFrameOfCell:(QMCell *)cell ofRegion:(QMCellRegion)region {
    NSSize size = cell.size;
    CGFloat width = size.width;
    CGFloat height = size.height;

    if ([cell isRoot]) {
        switch (region) {
            case QMCellRegionEast:
                return NewRect(cell.origin.x + width / 2, cell.origin.y, width / 2, height);
            case QMCellRegionWest:
                return NewRect(cell.origin.x, cell.origin.y, width / 2, height);
            default:
                return NSZeroRect;
        }
    }

    if ([cell isLeft]) {
        switch (region) {
            case QMCellRegionWest:
                return NewRectWithOrigin(cell.origin, width / 2, height);
            case QMCellRegionSouth:
                return NewRect(cell.origin.x + width / 2, cell.origin.y + height / 2, width / 2, height / 2);
            case QMCellRegionNorth:
                return NewRect(cell.origin.x + width / 2, cell.origin.y, width / 2, height / 2);
            default:
                return NSZeroRect;
        }
    }

    switch (region) {
        case QMCellRegionEast:
            return NewRect(cell.origin.x + width / 2, cell.origin.y, width / 2, height);
        case QMCellRegionSouth:
            return NewRect(cell.origin.x, cell.origin.y + height / 2, width / 2, height / 2);
        case QMCellRegionNorth:
            return NewRectWithOrigin(cell.origin, width / 2, height / 2);
        default:
            return NSZeroRect;
    }
}

- (void)computeGeometryAndLinesOfCell:(QMCell *)cell {
    [self computeOriginOfCell:cell];
    [self computeOriginOfChildrenFamilyOfCell:cell];
    if (cell.isRoot) {
        [self computeOriginOfLeftChildrenFamilyOfCell:cell];
    }

    [self computeIconsOriginOfCell:cell];
    [self computeTextOriginOfCell:cell];

    [self computeLinesOfCell:cell];
}

#pragma mark Private
- (NSPoint)lineStartPointForChildCell:(QMCell *)childCell {
    id parentCell = [childCell parent];
    NSPoint parentOrigin = [parentCell origin];
    NSSize parentSize = [parentCell size];

    if ([parentCell isRoot]) {
        return [parentCell middlePoint];
    }

    return NewPoint(parentOrigin.x + parentSize.width, parentOrigin.y + parentSize.height);
}

- (NSPoint)lineStartPointForLeftChildCell:(QMCell *)childCell {
    id parentCell = [childCell parent];
    NSPoint parentOrigin = [parentCell origin];
    NSSize parentSize = [parentCell size];

    if ([parentCell isRoot]) {
        return [parentCell middlePoint];
    }

    return NewPoint(parentOrigin.x, parentOrigin.y + parentSize.height);
}

- (void)addLineToChild:(QMCell *)childCell path:(NSBezierPath *)path {
    NSPoint origin = childCell.origin;
    NSSize size = childCell.size;

    CGFloat controlPoint1;
    CGFloat controlPoint2;

    NSPoint curveStartPoint;
    NSPoint curveEndPoint;

    controlPoint1 = [_settings floatForKey:qSettingBezierControlPoint2];
    controlPoint2 = [_settings floatForKey:qSettingBezierControlPoint1];

    if (childCell.isLeft) {

        curveStartPoint = [self lineStartPointForLeftChildCell:childCell];
        curveEndPoint = NewPoint(origin.x + size.width, origin.y + size.height);

        [path moveToPoint:curveStartPoint];
        [path curveToPoint:curveEndPoint
             controlPoint1:NewPoint(curveStartPoint.x - controlPoint1, curveStartPoint.y)
             controlPoint2:NewPoint(curveEndPoint.x + controlPoint2, curveEndPoint.y)];
    } else {

        curveStartPoint = [self lineStartPointForChildCell:childCell];
        curveEndPoint = NewPoint(origin.x, origin.y + size.height);

        [path moveToPoint:curveStartPoint];
        [path curveToPoint:curveEndPoint
             controlPoint1:NewPoint(curveStartPoint.x + controlPoint1, curveStartPoint.y)
             controlPoint2:NewPoint(curveEndPoint.x - controlPoint2, curveEndPoint.y)];
    }
}

- (void)addLineToOnlyChild:(QMCell *)childCell path:(NSBezierPath *)path {
    QMCell *parentCell = childCell.parent;

    NSPoint origin = childCell.origin;
    NSSize size = childCell.size;

    NSPoint parentOrigin = parentCell.origin;
    NSSize parentSize = parentCell.size;

    if (parentCell.isRoot) {
        [self addLineToChild:childCell path:path];
        return;
    }

    if (size.height != parentSize.height) {
        [self addLineToChild:childCell path:path];
        return;
    }

    NSPoint curveStartPoint;
    NSPoint curveEndPoint;

    if (childCell.isLeft) {
        curveStartPoint = NewPoint(origin.x + size.width, origin.y + size.height);
        curveEndPoint = NewPoint(parentOrigin.x, parentOrigin.y + parentSize.height);
    } else {
        curveStartPoint = [self lineStartPointForChildCell:childCell];
        curveEndPoint = NewPoint(origin.x, origin.y + size.height);
    }

    [path moveToPoint:curveStartPoint];

    CGFloat SingleChildDistanceX = [_settings floatForKey:qSettingInternodeHorizontalDistance] / 2 - 1.0;
    CGFloat SingleChildDistanceY = 5;
    CGFloat SingleChildControl = SingleChildDistanceX - 5.0;
    NSPoint curveMiddlePoint1 = NewPoint(curveStartPoint.x + SingleChildDistanceX, curveStartPoint.y - SingleChildDistanceY);
    NSPoint middleControlPoint1 = NewPoint(curveStartPoint.x + SingleChildControl, curveStartPoint.y);
    NSPoint middleControlPoint2 = NewPoint(curveMiddlePoint1.x - SingleChildControl, curveMiddlePoint1.y);

    [path curveToPoint:curveMiddlePoint1 controlPoint1:middleControlPoint1 controlPoint2:middleControlPoint2];

    NSPoint curveMiddlePoint2 = NewPoint(curveEndPoint.x - SingleChildDistanceX, curveEndPoint.y - SingleChildDistanceY);
    NSPoint middleControlPoint3 = NewPoint(curveMiddlePoint2.x + SingleChildControl, curveMiddlePoint2.y);
    NSPoint middleControlPoint4 = NewPoint(curveEndPoint.x - SingleChildControl, curveEndPoint.y);

    [path lineToPoint:curveMiddlePoint2];

    [path curveToPoint:curveEndPoint controlPoint1:middleControlPoint3 controlPoint2:middleControlPoint4];
}

- (void)addLinesToChildrenForCell:(QMCell *)cell path:(NSBezierPath *)path {
    NSArray *childCells = [cell allChildren];

    if (childCells.count == 1) {
        QMCell *childCell = [childCells lastObject];
        [self addLineToOnlyChild:childCell path:path];

        return;
    }

    for (QMCell *childCell in childCells) {
        [self addLineToChild:childCell path:path];
    }
}

- (void)computeLinesOfCell:(QMCell *)cell {
    NSBezierPath *path = [[NSBezierPath alloc] init];

    // line from left-bottom to right-bottom
    NSPoint origin = [cell origin];
    NSSize size = [cell size];
    BOOL cellIsFolded = [cell isFolded];
    CGFloat possibleFoldingMarkerRadius = cellIsFolded ? [_settings floatForKey:qSettingFoldingMarkerRadius] / 2 : 0;

    cell.line = nil;
    // TODO: why does the following line cause an error
    // cell.line = path;

    if (![cell isRoot]) {
        cell.line = path;

        [path setFlatness:1.0];
        [path setLineWidth:[_settings floatForKey:qSettingInternodeLineWidth]];

        if ([cell isLeft]) {
            [path moveToPoint:NewPoint(origin.x + possibleFoldingMarkerRadius, origin.y + size.height)];
            [path lineToPoint:NewPoint(origin.x + size.width, origin.y + size.height)];
        } else {
            [path moveToPoint:NewPoint(origin.x, origin.y + size.height)];
            [path lineToPoint:NewPoint(origin.x + size.width - possibleFoldingMarkerRadius, origin.y + size.height)];
        }
    }

    if ([cell isLeaf] || cellIsFolded) {
        return;
    }

    [self addLinesToChildrenForCell:cell path:path];
    cell.line = path;

    for (QMCell *childCell in [cell allChildren]) {
        [self computeLinesOfCell:childCell];
    }
}

- (void)computeIconsOriginOfCell:(QMCell *)cell {
    [cell.allChildren enumerateObjectsUsingBlock:^(QMCell *childCell, NSUInteger index, BOOL *stop) {
        [self computeIconsOriginOfCell:childCell];
    }];

    NSArray *icons = cell.icons;
    if ([icons count] == 0) {
        return;
    }

    NSPoint cellOrigin = cell.origin;
    NSSize cellSize = cell.size;
    CGFloat interIconDist = [_settings floatForKey:qSettingInterIconDistance];
    CGFloat iconTextDist = [_settings floatForKey:qSettingIconTextDistance];
    CGFloat horPadding = [_settings floatForKey:qSettingCellHorizontalPadding];
    CGFloat y = cellOrigin.y + cellSize.height / 2 - [icons[0] size].height / 2;

    if ([cell isRoot]) {
        [icons enumerateObjectsUsingBlock:^(QMIcon *icon, NSUInteger index, BOOL *stop) {
            if (index == 0) {
                icon.origin = NewPoint(cellOrigin.x + cellSize.width / 2 - (cell.iconSize.width + iconTextDist + cell.textSize.width) / 2, y);
                return;
            }

            icon.origin = NewPoint([icons[index - 1] origin].x + [icons[index - 1] size].width + interIconDist, y);
        }];

        return;
    }

    if ([cell isLeft]) {
        NSUInteger lastIndex = [icons count] - 1;
        [icons enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(QMIcon *icon, NSUInteger index, BOOL *stop) {
            if (index == lastIndex) {
                icon.origin = NewPoint(cellOrigin.x + cellSize.width - horPadding - icon.size.width, y);
                return;
            }

            icon.origin = NewPoint([icons[index + 1] origin].x - icon.size.width - interIconDist, y);
        }];

        return;
    }

    [icons enumerateObjectsUsingBlock:^(QMIcon *icon, NSUInteger index, BOOL *stop) {
        if (index == 0) {
            icon.origin = NewPoint(cellOrigin.x + [_settings floatForKey:qSettingCellHorizontalPadding], y);
            return;
        }

        icon.origin = NewPoint([icons[index - 1] origin].x + [icons[index - 1] size].width + interIconDist, y);
    }];
}

- (void)computeTextOriginOfCell:(QMCell *)cell {
    cell.textOrigin = [self textOriginOfCell:cell inFrame:cell.frame];

    if (cell.isLeaf || cell.isFolded) {
        return;
    }

    for (QMCell *childCell in cell.allChildren) {
        [self computeTextOriginOfCell:childCell];
    }
}

/**
* @param familyOrigin of self
* @param all sizes of self and its children
*/
- (void)computeOriginOfCell:(QMCell *)cell {
    CGFloat interNodeHorDist = [_settings floatForKey:qSettingInternodeHorizontalDistance];

    NSSize size = cell.size;
    NSSize familySize = cell.familySize;
    NSPoint familyOrigin = cell.familyOrigin;

    if ([cell isRoot]) {
        QMRootCell *rootCell = (QMRootCell *) cell;
        if (rootCell.countOfLeftChildren == 0) {
            if (size.height < familySize.height) {
                rootCell.origin = NewPoint(familyOrigin.x, familyOrigin.y + familySize.height / 2 - size.height / 2);
            } else {
                rootCell.origin = NewPoint(familyOrigin.x, familyOrigin.y);
            }
        } else {
            if (size.height < familySize.height) {
                rootCell.origin = NewPoint(familyOrigin.x + rootCell.leftChildrenFamilySize.width + interNodeHorDist, familyOrigin.y + familySize.height / 2 - size.height / 2);
            } else {
                rootCell.origin = NewPoint(familyOrigin.x + rootCell.leftChildrenFamilySize.width + interNodeHorDist, familyOrigin.y);
            }
        }

        return;
    }

    if ([cell isLeft]) {
        if (size.height < familySize.height) {
            cell.origin = NewPoint(cell.parent.origin.x - interNodeHorDist - size.width, familyOrigin.y + familySize.height / 2 - size.height / 2);
        } else {
            cell.origin = NewPoint(cell.parent.origin.x - interNodeHorDist - size.width, familyOrigin.y);
        }

        return;
    }

    if (size.height < familySize.height) {
        cell.origin = NewPoint(familyOrigin.x, familyOrigin.y + familySize.height / 2 - size.height / 2);
    } else {
        cell.origin = NewPoint(familyOrigin.x, familyOrigin.y);
    }
}

- (void)computeOriginOfLeftChildrenFamilyOfCell:(QMCell *)cell {
    NSArray *children;
    if (cell.isRoot) {
        children = [(QMRootCell *) cell leftChildren];
    } else {
        children = cell.children;
    }

    CGFloat vertDistance = [_settings floatForKey:qSettingInternodeVerticalDistance];

    NSPoint midPoint = cell.middlePoint;

    if (children.count == 1) {

        QMCell *childCell = [children objectAtIndex:0];

        childCell.familyOrigin = NewPoint(cell.familyOrigin.x, midPoint.y - childCell.familySize.height / 2);

        [self computeOriginOfCell:childCell];
        [self computeOriginOfLeftChildrenFamilyOfCell:childCell];

        return;
    }

    NSSize childrenFamilySize;
    if (cell.isRoot) {
        childrenFamilySize = [(QMRootCell *) cell leftChildrenFamilySize];
    } else {
        childrenFamilySize = cell.childrenFamilySize;
    }

    [children enumerateObjectsUsingBlock:^(QMCell *childCell, NSUInteger index, BOOL *stop) {
        if (index == 0) {
            childCell.familyOrigin = NewPoint(cell.familyOrigin.x, midPoint.y - childrenFamilySize.height / 2);
        } else {
            QMCell *prevCell = [children objectAtIndex:index - 1];
            childCell.familyOrigin = NewPoint(cell.familyOrigin.x, prevCell.familyOrigin.y + prevCell.familySize.height + vertDistance);
        }

        [self computeOriginOfCell:childCell];
        [self computeOriginOfLeftChildrenFamilyOfCell:childCell];
    }];
}

- (void)computeOriginOfChildrenFamilyOfCell:(QMCell *)cell {
    NSArray *children = cell.children;

    CGFloat horDistance = [_settings floatForKey:qSettingInternodeHorizontalDistance];
    CGFloat vertDistance = [_settings floatForKey:qSettingInternodeVerticalDistance];

    NSSize size = cell.size;
    NSPoint midPoint = cell.middlePoint;

    if (children.count == 1) {

        QMCell *childCell = [children objectAtIndex:0];

        childCell.familyOrigin = NewPoint(cell.origin.x + size.width + horDistance, midPoint.y - childCell.familySize.height / 2);

        [self computeOriginOfCell:childCell];
        [self computeOriginOfChildrenFamilyOfCell:childCell];

        return;
    }

    [children enumerateObjectsUsingBlock:^(QMCell *childCell, NSUInteger index, BOOL *stop) {
        if (index == 0) {
            childCell.familyOrigin = NewPoint(cell.origin.x + size.width + horDistance, midPoint.y - cell.childrenFamilySize.height / 2);
        } else {
            QMCell *prevCell = [children objectAtIndex:index - 1];
            childCell.familyOrigin = NewPoint(cell.origin.x + size.width + horDistance, prevCell.familyOrigin.y + prevCell.familySize.height + vertDistance);
        }

        [self computeOriginOfCell:childCell];
        [self computeOriginOfChildrenFamilyOfCell:childCell];
    }];
}

- (NSPoint)textOriginOfCell:(QMCell *)cell inFrame:(NSRect)frame {
    CGFloat horPadding = [_settings floatForKey:qSettingCellHorizontalPadding];
    CGFloat vertPadding = [_settings floatForKey:qSettingCellVerticalPadding];
    CGFloat iconTextDist = cell.countOfIcons > 0 ? [_settings floatForKey:qSettingIconTextDistance] : 0;

    NSSize iconSize = cell.iconSize;
    NSSize textSize = cell.textSize;
    NSSize size = cell.size;
    NSPoint origin = frame.origin;

    CGFloat dy = size.height - textSize.height;

    if ([cell isRoot]) {
        if ([cell.stringValue length] == 0) {
            return NewPoint(origin.x + horPadding, origin.y + vertPadding);
        } else {
            return NewPoint(cell.middlePoint.x - (iconSize.width + iconTextDist + cell.textSize.width) / 2 + iconSize.width + iconTextDist, origin.y + dy / 2);
        }
    }

    if ([cell isLeft]) {
        if ([cell.stringValue length] == 0) {
            return NewPoint(origin.x + horPadding, origin.y + vertPadding);
        } else {
            return NewPoint(origin.x + horPadding, origin.y + dy / 2);
        }
    }

    if ([cell.stringValue length] == 0) {
        return NewPoint(origin.x + horPadding, origin.y + vertPadding);
    } else {
        return NewPoint(origin.x + horPadding + iconSize.width + iconTextDist, origin.y + dy / 2);
    }
}

@end
