/**
 * Tae Won Ha
 * http://qvacua.com
 * https://bitbucket.org/qvacua
 *
 * See LICENSE
 */

#import "QMCell.h"
#import "QMMindmapView.h"
#import "QMTextLayoutManager.h"
#import <Qkit/Qkit.h>
#import "QMCellLayoutManager.h"
#import "QMCellDrawer.h"
#import "QMRootCell.h"
#import "QMCellSizeManager.h"
#import "QMIcon.h"

@implementation QMCell

TB_AUTOWIRE_WITH_INSTANCE_VAR(cellSizeManager, _cellSizeManager);
TB_AUTOWIRE_WITH_INSTANCE_VAR(cellLayoutManager, _cellLayoutManager)
TB_AUTOWIRE_WITH_INSTANCE_VAR(cellDrawer, _cellDrawer);
TB_AUTOWIRE_WITH_INSTANCE_VAR(textLayoutManager, _textLayoutManager);

@dynamic root;
@dynamic font;
@dynamic stringValue;
@dynamic familyFrame;
@dynamic frame;
@dynamic childrenFamilySize;
@dynamic middlePoint;
@dynamic leaf;
@dynamic size;
@dynamic iconSize;
@dynamic textSize;
@dynamic textFrame;
@dynamic folded;
@dynamic familySize;
@dynamic needsToRecomputeSize;
@synthesize view = _view;
@synthesize parent = _parent;
@synthesize children = _children;
@synthesize origin = _origin;
@synthesize familyOrigin = _familyOrigin;
@synthesize attributedString = _attributedString;
@synthesize line = _line;
@synthesize rangeOfStringValue = _rangeOfStringValue;
@synthesize icons = _icons;
@synthesize left = _left;
@synthesize textOrigin = _textOrigin;
@synthesize identifier = _identifier;
@synthesize dragRegion = _dragRegion;

#pragma mark Public
- (BOOL)needsToRecomputeSize {
    return _needsToRecomputeSize;
}

- (void)setNeedsToRecomputeSize:(BOOL)flag {
    if (_needsToRecomputeSize == flag) {
        return;
    }

    _needsToRecomputeSize = flag;

    if (flag == YES) {
        _parent.needsToRecomputeSize = YES;
    }
}

- (NSSize)familySize {
    return [self sizeOfKind:&_familySize];
}

- (BOOL)isFolded {
    return _folded;
}

- (void)setFolded:(BOOL)aFolded {
    if (aFolded == _folded) {
        return;
    }

    _folded = aFolded;
    self.needsToRecomputeSize = YES;
}

- (NSSize)size {
    return [self sizeOfKind:&_size];
}

- (NSSize)iconSize {
    return [self sizeOfKind:&_iconSize];
}

- (NSSize)textSize {
    return [self sizeOfKind:&_textSize];
}

- (NSRect)frame {
    return NewRectWithOriginAndSize(self.origin, self.size);
}

// TODO: test this for root cell
- (NSPoint)middlePoint {
    return NewPoint(self.origin.x + self.size.width / 2, self.origin.y + self.size.height / 2);
}

- (NSRect)textFrame {
    return NewRectWithOriginAndSize(self.textOrigin, self.textSize);
}

- (NSSize)childrenFamilySize {
    if (self.isLeaf || self.isFolded) {
        return NewSize(0.0, 0.0);
    }

    return [self sizeOfKind:&_childrenFamilySize];
}

- (NSRect)familyFrame {
    return NewRectWithOriginAndSize(self.familyOrigin, self.familySize);
}

- (BOOL)isRoot {
    return NO;
}

- (void)drawRect:(NSRect)dirtyRect {
    [_cellDrawer drawCell:self rect:dirtyRect];

    if (self.isLeaf || self.isFolded) {
        return;
    }

    for (QMCell *childCell in self.children) {
        [childCell drawRect:dirtyRect];
    }
}

- (void)addChild:(QMCell *)childCell left:(BOOL)cellIsLeft {
    [self addObjectInChildren:childCell];
}

- (void)removeChild:(QMCell *)childCell {
    const NSUInteger indexOfObject = [_children indexOfObject:childCell];
    [self removeObjectFromChildrenAtIndex:indexOfObject];
}

- (NSArray *)allChildren {
    return self.children;
}

- (NSUInteger)countOfAllChildren {
    return self.countOfChildren;
}

- (id)initWithView:(QMMindmapView *)view {
    if ((self = [super init])) {
        _view = view;
        _children = [[NSMutableArray alloc] initWithCapacity:3];
        _icons = [[NSMutableArray alloc] initWithCapacity:1];

        _folded = NO;

        TBContext *context = [TBContext sharedContext];
        // autowireSeed takes too long...
        _cellLayoutManager = [context beanWithClass:[QMCellLayoutManager class]];
        _cellDrawer = [context beanWithClass:[QMCellDrawer class]];
        _textLayoutManager = [context beanWithClass:[QMTextLayoutManager class]];
        _cellSizeManager = [context beanWithClass:[QMCellSizeManager class]];

        self.stringValue = @"";

        self.needsToRecomputeSize = YES;
    }

    return self;
}

- (NSFont *)font {
    return _font;
}

- (void)updateAttributedStringWithString:(NSString *)string {
    NSDictionary *attrDict;

    if (_font == nil) {
        attrDict = [_textLayoutManager stringAttributesDict];
    } else {
        attrDict = [_textLayoutManager stringAttributesDictWithFont:_font];
    }

    _attributedString = [[NSAttributedString alloc] initWithString:string attributes:attrDict];
    _rangeOfStringValue = [_textLayoutManager completeRangeOfAttributedString:_attributedString];

    self.needsToRecomputeSize = YES;
}

- (void)setFont:(NSFont *)aFont {
    _font = aFont;

    [self updateAttributedStringWithString:self.stringValue];
}

- (NSString *)stringValue {
    return _attributedString.string;
}

- (void)setStringValue:(NSString *)string {
    [self updateAttributedStringWithString:string];
}

- (BOOL)isLeaf {
    return _children.count == 0;
}

- (NSArray *)containingArray {
    if ([self isLeft] && [self.parent isRoot]) {
        return [(QMRootCell *) self.parent leftChildren];
    }

    return self.parent.children;
}

- (QMCell *)objectInChildrenAtIndex:(NSUInteger)index {
    return [_children objectAtIndex:index];
}

- (NSUInteger)countOfChildren {
    return _children.count;
}

- (void)insertObject:(QMCell *)childCell inChildrenAtIndex:(NSUInteger)index {
    childCell.parent = self;
    childCell.left = self.isLeft;
    [_children insertObject:childCell atIndex:index];

    self.needsToRecomputeSize = YES;
}

- (void)removeObjectFromChildrenAtIndex:(NSUInteger)index {
    QMCell *cellToDel = [_children objectAtIndex:index];
    cellToDel.parent = nil;
    cellToDel.left = NO;

    [_children removeObjectAtIndex:index];

    self.needsToRecomputeSize = YES;
}

- (void)addObjectInChildren:(QMCell *)childCell {
    [self insertObject:childCell inChildrenAtIndex:_children.count];
}

- (NSUInteger)indexOfChild:(QMCell *)childCell {
    return [_children indexOfObject:childCell];
}

- (NSUInteger)indexWithinParent {
    return [self.parent indexOfChild:self];
}

- (QMIcon *)objectInIconsAtIndex:(NSUInteger)index {
    return [_icons objectAtIndex:index];
}

- (NSUInteger)countOfIcons {
    return _icons.count;
}

- (void)insertObject:(QMIcon *)icon inIconsAtIndex:(NSUInteger)index {
    [_icons insertObject:icon atIndex:index];

    self.needsToRecomputeSize = YES;
}

- (void)removeObjectFromIconsAtIndex:(NSUInteger)index {
    [_icons removeObjectAtIndex:index];

    self.needsToRecomputeSize = YES;
}

- (NSImage *)image {
    NSPoint cellOrigin = self.origin;
    NSImage *image = [[NSImage alloc] initWithSize:self.size];

    [image lockFocusFlipped:YES];
    NSAffineTransform *translate = [NSAffineTransform transform];
    [translate translateXBy: -cellOrigin.x yBy: -cellOrigin.y];
    [translate concat];
    [_cellDrawer drawContentForCell:self rect:self.frame];
    [image unlockFocus];

//#ifdef DEBUG
//    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithData:[image TIFFRepresentation]];
//    NSData *data = [rep representationUsingType:NSPNGFileType properties: nil];
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
//    NSString *imgName = [[NSString alloc] initWithFormat:@"/tmp/drag-image-%@.png", [formatter stringFromDate:[NSDate date]]];
//    [data writeToFile:imgName atomically:NO];
//#endif

    return image;
}

- (void)addObjectInIcons:(QMIcon *)icon {
    [self insertObject:icon inIconsAtIndex:_icons.count];
}

// TODO: this gets called only by rootCell
- (void)computeGeometry {
    [_cellLayoutManager computeGeometryAndLinesOfCell:self];
}

- (NSString *)description {
    return self.stringValue.stringByCropping;
}

#pragma mark Private
- (NSSize)sizeOfKind:(NSSize *)sizeToCompute {
    if (!_needsToRecomputeSize) {
        return *sizeToCompute;
    }

    self.needsToRecomputeSize = NO;

    _iconSize = [_cellSizeManager sizeOfIconsOfCell:self];
    _textSize = [_cellSizeManager sizeOfTextOfCell:self];
    _childrenFamilySize = [_cellSizeManager sizeOfChildrenFamily:_children];
    _size = [_cellSizeManager sizeOfCell:self];
    _familySize = [_cellSizeManager sizeOfFamilyOfCell:self];

    return *sizeToCompute;
}

@end
