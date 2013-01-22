/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import "QMRootCell.h"
#import <Qkit/Qkit.h>
#import "QMCellDrawer.h"
#import "QMCellSizeManager.h"

@implementation QMRootCell

@dynamic leftChildrenFamilySize;
@synthesize leftChildren = _leftChildren;

- (BOOL)isRoot {
    return YES;
}

- (NSUInteger)indexWithinParent {
    return 0;
}

- (BOOL)isLeaf {
    if (_children.count > 0) {
        return NO;
    }

    if (_leftChildren.count > 0) {
        return NO;
    }

    return YES;
}

- (NSArray *)allChildren {
    return [_children arrayByAddingObjectsFromArray:_leftChildren];
}

- (void)drawRect:(NSRect)dirtyRect {
    [_cellDrawer drawCell:self rect:dirtyRect];

    if (self.isLeaf || self.isFolded) {
        return;
    }

    for (QMCell *childCell in self.allChildren) {
        [childCell drawRect:dirtyRect];
    }
}

- (id)initWithView:(QMMindmapView *)view {
    if ((self = [super initWithView:view])) {
        _leftChildren = [[NSMutableArray alloc] initWithCapacity:2];
    }

    return self;
}

- (void)addChild:(QMCell *)childCell left:(BOOL)cellIsLeft {
    if (cellIsLeft) {
        [self addObjectInLeftChildren:childCell];
        return;
    }

    [self addObjectInChildren:childCell];
}

- (void)removeChild:(QMCell *)childCell {
    if (childCell.isLeft) {
        [self removeObjectFromLeftChildrenAtIndex:[_leftChildren indexOfObject:childCell]];
        return;
    }

    [self removeObjectFromChildrenAtIndex:[_children indexOfObject:childCell]];
}

- (NSUInteger)countOfAllChildren {
    return self.allChildren.count;
}

- (NSUInteger)indexOfChild:(QMCell *)childCell {
    if (childCell.isLeft) {
        return [_leftChildren indexOfObject:childCell];
    }

    return [_children indexOfObject:childCell];
}

- (QMCell *)objectInLeftChildrenAtIndex:(NSUInteger)index {
    return [_leftChildren objectAtIndex:index];
}

- (NSUInteger)countOfLeftChildren {
    return _leftChildren.count;
}

- (void)insertObject:(QMCell *)childCell inLeftChildrenAtIndex:(NSUInteger)index {
    childCell.parent = self;
    childCell.left = YES;
    [_leftChildren insertObject:childCell atIndex:index];

    _needsToRecomputeSize = YES;
}

- (void)removeObjectFromLeftChildrenAtIndex:(NSUInteger)index {
    QMCell *cellToDel = [_leftChildren objectAtIndex:index];
    cellToDel.parent = nil;
    cellToDel.left = NO;

    [_leftChildren removeObjectAtIndex:index];

    _needsToRecomputeSize = YES;
}

- (void)addObjectInLeftChildren:(QMCell *)childCell {
    [self insertObject:childCell inLeftChildrenAtIndex:_leftChildren.count];
}

- (NSSize)leftChildrenFamilySize {
    if (self.isLeaf || self.isFolded) {
        return NewSize(0.0, 0.0);
    }

    return [self sizeOfKind:&_leftChildrenFamilySize];
}

#pragma mark Private
- (NSSize)sizeOfKind:(NSSize *)sizeToCompute {
    if (!_needsToRecomputeSize) {
        return *sizeToCompute;
    }

    _needsToRecomputeSize = NO;

    _iconSize = [_cellSizeManager sizeOfIconsOfCell:self];
    _textSize = [_cellSizeManager sizeOfTextOfCell:self];
    _size = [_cellSizeManager sizeOfCell:self];
    _childrenFamilySize = [_cellSizeManager sizeOfChildrenFamily:_children];
    _leftChildrenFamilySize = [_cellSizeManager sizeOfChildrenFamily:_leftChildren];
    _familySize = [_cellSizeManager sizeOfFamilyOfCell:self];

    return *sizeToCompute;
}

@end
