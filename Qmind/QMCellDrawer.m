/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import "QMCellDrawer.h"
#import "QMTextDrawer.h"
#import "QMCell.h"
#import "QMAppSettings.h"
#import <Qkit/Qkit.h>
#import "QMTextLayoutManager.h"
#import "QMMindmapView.h"
#import "QMCellLayoutManager.h"
#import "QMIcon.h"

@implementation QMCellDrawer

TB_BEAN
TB_AUTOWIRE_WITH_INSTANCE_VAR(textLayoutManager, _textLayoutManager)
TB_AUTOWIRE_WITH_INSTANCE_VAR(cellLayoutManager, _cellLayoutManager)
TB_AUTOWIRE_WITH_INSTANCE_VAR(textDrawer, _textDrawer)
TB_AUTOWIRE_WITH_INSTANCE_VAR(settings, _settings)

#pragma mark Public
- (void)drawContentForCell:(QMCell *)cell rect:(NSRect)dirtyRect {
    if ([cell isRoot]) {
        [self drawRootEllipseForFrame:cell.frame];
    }

    [_textDrawer drawAttributedString:cell.attributedString inRect:cell.textFrame range:cell.rangeOfStringValue];
    [self drawIconsForCell:cell rect:dirtyRect];
}

- (void)drawCell:(QMCell *)cell rect:(NSRect)dirtyRect {
    [self drawLineForCell:cell dirtyRect:dirtyRect];

    [self drawRegionForCell:cell];

    if (!NSIntersectsRect(dirtyRect, cell.frame)) {
        return;
    }

    [self drawContentForCell:cell rect:dirtyRect];

    if ([cell.view cellIsCurrentlyEdited:cell]) {
        return;
    }

    [self drawMetaInfoForCell:cell];
}

#pragma mark Private
- (void)drawRegionForCell:(QMCell *)cell {
    if (cell.dragRegion == QMCellRegionNone) {
        return;
    }

    // TODO: beautify
    [[NSColor grayColor] set];
    NSRectFill([_cellLayoutManager regionFrameOfCell:cell ofRegion:cell.dragRegion]);
}

- (void)drawFoldingMarkerOfCell:(QMCell *)cell {
    if ([cell isLeaf]) {
        return;
    }

    NSPoint origin = cell.origin;
    NSSize size = cell.size;

    CGFloat foldingMarkerRadius = [_settings floatForKey:qSettingFoldingMarkerRadius];
    NSBezierPath *path;

    if (cell.isLeft) {
        path = [NSBezierPath bezierPathWithOvalInRect:NewRect(
                origin.x - foldingMarkerRadius / 2,
                origin.y + size.height - foldingMarkerRadius / 2,
                foldingMarkerRadius,
                foldingMarkerRadius
        )];
    } else {
        path = [NSBezierPath bezierPathWithOvalInRect:NewRect(
                origin.x + size.width - foldingMarkerRadius / 2,
                origin.y + size.height - foldingMarkerRadius / 2,
                foldingMarkerRadius,
                foldingMarkerRadius
        )];
    }

    [[NSColor grayColor] set];
    [path setFlatness:1.0];
    [path setLineWidth:[_settings floatForKey:qSettingFoldingMarkerLineWidth]];

    [path stroke];
}

- (void)drawIconsForCell:(QMCell *)cell rect:(NSRect)dirtyRect {
    [cell.icons enumerateObjectsUsingBlock:^(QMIcon *icon, NSUInteger index, BOOL *stop) {
        [icon drawRect:dirtyRect];
    }];
}

- (void)drawRootEllipseForFrame:(NSRect)frame {
    NSBezierPath *ellipse = [NSBezierPath bezierPathWithOvalInRect:frame];

    [ellipse setLineWidth:1];
    [ellipse setFlatness:1];

    [[NSColor whiteColor] set];
    [ellipse fill];

    [[NSColor grayColor] set];
    [ellipse stroke];
}

- (NSBezierPath *)focusRingPathForCell:(QMCell *)cell {
    NSRect frame = cell.frame;

    if (cell.isRoot) {
        CGFloat focusRingMargin = [_settings floatForKey:qSettingNodeFocusRingMargin];
        NSRect outsetRect = NewRectExpanding(frame, focusRingMargin, focusRingMargin);

        return [NSBezierPath bezierPathWithOvalInRect:outsetRect];
    }

    CGFloat focusRingMargin = [_settings floatForKey:qSettingNodeFocusRingMargin];
    CGFloat borderRadius = [_settings floatForKey:qSettingNodeFocusRingBorderRadius];
    NSRect outsetRect = NewRectExpanding(frame, focusRingMargin, focusRingMargin);

    return [NSBezierPath bezierPathWithRoundedRect:outsetRect xRadius:borderRadius yRadius:borderRadius];
}

- (void)drawFocusRingForCell:(QMCell *)cell {
    NSBezierPath *path = [self focusRingPathForCell:cell];

    [NSGraphicsContext saveGraphicsState];

    [[NSColor selectedTextBackgroundColor] set];
    NSSetFocusRingStyle(NSFocusRingOnly);
    [path fill];

    [NSGraphicsContext restoreGraphicsState];
}

- (void)drawMetaInfoForCell:(QMCell *)cell {
    if (cell.isFolded) {
        [self drawFoldingMarkerOfCell:cell];
    }

    if ([cell.view cellIsSelected:cell]) {
        [self drawFocusRingForCell:cell];
    }
}

- (void)drawLineForCell:(QMCell *)cell dirtyRect:(NSRect)dirtyRect {
    if (cell.line == nil) {
        return;
    }

    // if we only have a horizontal line, then the bounds has got 0 height. thus, no intersection.
    NSRect lineRect = NewRectExpanding(cell.line.bounds, 1, 1);

    if (NSIntersectsRect(dirtyRect, lineRect)) {
        [[NSColor grayColor] set];
        [cell.line stroke];
    }
}

@end
