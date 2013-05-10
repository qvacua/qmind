/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Qkit/Qkit.h>
#import "QMRootCell.h"
#import "QMCellDrawer.h"
#import "QMCellSizeManager.h"

@interface QMRootCell ()

@property(readonly) NSMutableArray *mutableLeftChildren;

@end

@implementation QMRootCell {
    NSMutableArray *_leftChildren;
    NSSize _leftChildrenFamilySize;
}

@dynamic mutableLeftChildren;
@dynamic leftChildrenFamilySize;

- (QMCell *)objectInLeftChildrenAtIndex:(NSUInteger)index {
    return self.leftChildren[index];
}

- (NSUInteger)countOfLeftChildren {
    return self.leftChildren.count;
}

- (void)insertObject:(QMCell *)childCell inLeftChildrenAtIndex:(NSUInteger)index {
    childCell.parent = self;
    childCell.left = YES;
    [self.mutableLeftChildren insertObject:childCell atIndex:index];

    self.needsToRecomputeSize = YES;
}

- (void)removeObjectFromLeftChildrenAtIndex:(NSUInteger)index {
    QMCell *cellToDel = [self.leftChildren objectAtIndex:index];
    cellToDel.parent = nil;
    cellToDel.left = NO;

    [self.mutableLeftChildren removeObjectAtIndex:index];

    self.needsToRecomputeSize = YES;
}

- (void)addObjectInLeftChildren:(QMCell *)childCell {
    [self insertObject:childCell inLeftChildrenAtIndex:self.leftChildren.count];
}

- (NSSize)leftChildrenFamilySize {
    @synchronized (self) {
        if (self.leaf || self.folded) {
            return NewSize(0, 0);
        }

        return [self sizeOfKind:&_leftChildrenFamilySize];
    }
}

#pragma mark QMCell
- (BOOL)isRoot {
    return YES;
}

- (NSUInteger)indexWithinParent {
    return 0;
}

- (BOOL)isLeaf {
    if (self.children.count > 0) {
        return NO;
    }

    if (self.leftChildren.count > 0) {
        return NO;
    }

    return YES;
}

- (NSArray *)allChildren {
    return [self.children arrayByAddingObjectsFromArray:self.leftChildren];
}

- (void)drawRect:(NSRect)dirtyRect {
    [self.cellDrawer drawCell:self rect:dirtyRect];

    if (self.leaf || self.folded) {
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
        [self removeObjectFromLeftChildrenAtIndex:[self.leftChildren indexOfObject:childCell]];
        return;
    }

    [self removeObjectFromChildrenAtIndex:[self.children indexOfObject:childCell]];
}

- (NSUInteger)countOfAllChildren {
    return self.allChildren.count;
}

- (NSUInteger)indexOfChild:(QMCell *)childCell {
    if (childCell.isLeft) {
        return [self.leftChildren indexOfObject:childCell];
    }

    return [self.children indexOfObject:childCell];
}

#pragma mark Private
- (NSMutableArray *)mutableLeftChildren {
    @synchronized (self) {
        return _leftChildren;
    }
}

- (NSSize)sizeOfKind:(NSSize *)sizeToCompute {
    if (!self.needsToRecomputeSize) {
        return *sizeToCompute;
    }

    self.needsToRecomputeSize = NO;

    _iconSize = [self.cellSizeManager sizeOfIconsOfCell:self];
    _textSize = [self.cellSizeManager sizeOfTextOfCell:self];
    _size = [self.cellSizeManager sizeOfCell:self];
    _childrenFamilySize = [self.cellSizeManager sizeOfChildrenFamily:self.children];
    _leftChildrenFamilySize = [self.cellSizeManager sizeOfChildrenFamily:self.leftChildren];
    _familySize = [self.cellSizeManager sizeOfFamilyOfCell:self];

    return *sizeToCompute;
}

@end
