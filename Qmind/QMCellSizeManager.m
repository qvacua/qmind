/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Qkit/Qkit.h>
#import "QMCellSizeManager.h"
#import "QMCell.h"
#import "QMTextLayoutManager.h"
#import "QMAppSettings.h"
#import "QMRootCell.h"

@implementation QMCellSizeManager

TB_BEAN
TB_AUTOWIRE(textLayoutManager)
TB_AUTOWIRE(settings)

#pragma mark Public
- (NSSize)sizeOfCell:(QMCell *)cell {
    NSSize textSize = cell.textSize;
    NSSize iconSize = cell.iconSize;

    NSSize result = textSize;

    NSUInteger countOfIcons = cell.countOfIcons;
    BOOL trivialStringValue = [cell.stringValue length] == 0;
    if (countOfIcons > 0) {
        result.width += iconSize.width + (trivialStringValue ? 0 : [_settings floatForKey:qSettingIconTextDistance]);

        if (iconSize.height > result.height) {
            result.height = iconSize.height;
        }
    }

    if (trivialStringValue && countOfIcons == 0) {
        result.width = [_settings floatForKey:qSettingNodeMinWidth];
        result.height = [_settings floatForKey:qSettingNodeMinHeight];
    }

    result.width += 2 * [_settings floatForKey:qSettingCellHorizontalPadding];
    result.height += 2 * [_settings floatForKey:qSettingCellVerticalPadding];

    if (cell.isRoot) {
        return [self sizeOfRootEllipse:result];
    }

    return result;
}

- (NSSize)sizeOfIconsOfCell:(QMCell *)cell {
    NSUInteger countOfIcons = cell.countOfIcons;
    if (countOfIcons == 0) {
        return NewSize(0, 0);
    }

    const CGFloat iconDrawSize = [_settings floatForKey:qSettingIconDrawSize];
    const CGFloat interIconDist = [_settings floatForKey:qSettingInterIconDistance];

    CGFloat iconWidth = countOfIcons * (iconDrawSize + interIconDist) - interIconDist;

    return NewSize(iconWidth, iconDrawSize);
}

- (NSSize)sizeOfTextOfCell:(QMCell *)cell {
    if ([cell isRoot]) {
        return [_textLayoutManager sizeOfAttributedString:cell.attributedString maxWidth:[_settings floatForKey:qSettingMaxRootCellTextWidth]];
    }

    return [_textLayoutManager sizeOfAttributedString:cell.attributedString maxWidth:[_settings floatForKey:qSettingMaxTextNodeWidth]];
}

- (NSSize)sizeOfChildrenFamily:(NSArray *)children {
    if ([children count] == 0) {
        return NewSize(0, 0);
    }

    CGFloat vertDistance = [_settings floatForKey:qSettingInternodeVerticalDistance];
    NSSize result = NewSize(0, (children.count - 1) * vertDistance);

    for (QMCell *child in children) {
        NSSize childFamilySize = child.familySize;

        result.width = MAX(result.width, childFamilySize.width);
        result.height += childFamilySize.height;
    }

    return result;
}

- (NSSize)sizeOfFamilyOfCell:(QMCell *)cell {
    NSSize size = cell.size;

    if ([cell isLeaf] || [cell isFolded]) {
        return size;
    }

    // RIGHT CHILDREN
    CGFloat interNodeHorDistance = [_settings floatForKey:qSettingInternodeHorizontalDistance];

    CGFloat familyWidth = size.width;
    CGFloat familyHeight = 0.0;

    NSSize result = NewSize(familyWidth, familyHeight);
    NSArray *children = cell.children;
    if (children.count > 0) {
        NSSize childrenSize = cell.childrenFamilySize;
        familyWidth += interNodeHorDistance + childrenSize.width;
        familyHeight = MAX(size.height, childrenSize.height);

        result = NewSize(familyWidth, familyHeight);
    }

    // ROOT CELL, i.e. we have to process left children
    if ([cell isRoot]) {
        QMRootCell *rootCell = (QMRootCell *) cell;
        NSArray *leftChildren = rootCell.leftChildren;

        if (leftChildren.count == 0) {
            return result;
        }

        NSSize leftChildrenSize = rootCell.leftChildrenFamilySize;
        familyWidth += interNodeHorDistance + leftChildrenSize.width;

        const CGFloat heightToCompare = MAX(size.height, familyHeight);
        familyHeight = MAX(heightToCompare, leftChildrenSize.height);
    }

    result = NewSize(familyWidth, familyHeight);
    return result;
}

#pragma mark Private
- (NSSize)sizeOfRootEllipse:(NSSize)sizeOfCell {
    double x0 = sizeOfCell.width / 2;
    double y0 = sizeOfCell.height / 2;
    double s = y0 / x0;
    double a = sqrt(pow(x0, 2.0) + (pow(x0, 4.0 / 3.0) * pow(y0, 2.0 / 3.0)) / pow(s, 2.0 / 3.0));
    double b = sqrt(pow(a, 2.0) * pow(y0, 2.0) / (pow(a, 2.0) - pow(x0, 2.0)));

    return NewSize((CGFloat) (2 * a), (CGFloat) (2 * b));
}

@end
