/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Cocoa/Cocoa.h>
#import <TBCacao/TBCacao.h>

@class QMMindmapView;
@class QMTextDrawer;
@class QMCellLayoutManager;
@class QMCellDrawer;
@class QMTextLayoutManager;
@class QMCellSizeManager;
@class QMIcon;

typedef enum {
    QMCellRegionNone = 0,
    QMCellRegionEast,
    QMCellRegionWest,
    QMCellRegionSouth,
    QMCellRegionNorth,
} QMCellRegion;

@interface QMCell : NSObject {
    NSSize _size;
    NSSize _textSize;
    NSSize _iconSize;
    NSSize _familySize;
    NSSize _childrenFamilySize;
}

@property (weak) QMCellSizeManager *cellSizeManager;
@property (weak) QMCellLayoutManager *cellLayoutManager;
@property (weak) QMCellDrawer *cellDrawer;
@property (weak) QMTextLayoutManager *textLayoutManager;

/**
* The QMMindmapView containing the cell.
*/
@property (weak) QMMindmapView *view;

/**
* When a cell is dragged and is hovering over this cell, -dragRegion returns where the dragged cell is, ie E, W, S, N.
*/
@property QMCellRegion dragRegion;

/**
* The identifier for the node it refers to. If this were a database-based app, this would be the database ID. This is
* used to communicate with the datasource
*/
@property id identifier;

@property (weak) QMCell *parent;
@property (readonly) NSArray *children;

/**
* This is YES, when the cell is on the left side of the root cell.
*/
@property (getter=isLeft) BOOL left;

/**
* This is the textual value of the cell.
*/
@property (weak) NSString *stringValue;

/**
* A hyperlink (http://...) or internal link (#ID_...)
*/
@property (copy) NSURL *link;

/**
* The string enriched with the font information
*/
@property (readonly) NSAttributedString *attributedString;

/**
* Cached NSRange for the complete text. The computation of this value takes quite some time, thus caching.
*/
@property (readonly) NSRange rangeOfStringValue;

/**
* The used font of this cell. Can be nil, in which case we use the default font.
*/
@property NSFont *font;

/**
* This array contains the icons of the cell. It can be a NSString or an NSImage.
*/
@property (readonly, strong) NSArray *icons;

/**
* The line starting from the left-bottom corner of the cell and ending at the left-bottom corner of each child.
*/
@property NSBezierPath *line;

/**
* YES, if the cell has got no child.
*/
@property (readonly, getter=isLeaf) BOOL leaf;

/**
* YES, if the cell is in folded state.
*/
@property (getter=isFolded) BOOL folded;

/**
* YES, if the cell is root
*/
@property (readonly, getter=isRoot) BOOL root;

/**
* The frame of the cell including all icons and all margins. However, only the cell itself,
* not containing its child cells
*/
@property (readonly) NSRect frame;

/**
* The frame of the cell with all of its child cells.
*/
@property (readonly) NSRect familyFrame;

/**
* The origin of the cell only, i.e. without child cells. This is the origin of the cell containing all contents and margins.
*/
@property NSPoint origin;

/**
* The size of the cell only, i.e. without child cells. This is the origin of the cell containing all contents and margins.
*/
@property (readonly) NSSize size;

/**
* The origin of the cell with all of its child cells. This is different from cellOrigin since in most cases there will
* be child cells which all together is taller than the parent cell.
*/
@property NSPoint familyOrigin;

/**
* The size of the cell with all of its child cells.
*/
@property (readonly) NSSize familySize;

/**
* The size of all right child cells, not including the cell (being their parent) itself.
*/
@property (readonly) NSSize childrenFamilySize;

/**
* The middle point of the cell. (not containing the children)
*/
@property (readonly) NSPoint middlePoint;

/**
* The origin of the text for the cell without any margin
*/
@property NSPoint textOrigin;

/**
* The size of text only without any margin
*/
@property (readonly) NSSize textSize;

/**
* NSRect consisting of textOrigin and textSize
*/
@property (readonly) NSRect textFrame;

/**
* Size of icons only
*/
@property (readonly) NSSize iconSize;

@property BOOL needsToRecomputeSize;

/**
* Designated initializer. If parent is nil, then the cell will most probably be a root node or is being copied.
*/
- (id)initWithView:(QMMindmapView *)view;

/**
* Draws the cell and all of its children.
*/
- (void)drawRect:(NSRect)dirtyRect;

- (void)addChild:(QMCell *)childCell left:(BOOL)cellIsLeft;

/**
* Returns the index of the given child. It is safe to call this for left node (even on the root cell)
* since the root cell takes care of right and left children.
*/
- (NSUInteger)indexOfChild:(QMCell *)childCell;

/**
* Returns the index within the parent's array which contains this cell. When this cell is a left cell and a direct
* child of the root cell, the index is computed from the left children array of the root cell.
*/
- (NSUInteger)indexWithinParent;

/**
* Returns parent's children array which contains this cell. When this cell is a direct child of the root cell,
* the left children array is returned.
*/
- (NSArray *)containingArray;

- (NSArray *)allChildren;
- (NSUInteger)countOfAllChildren;

- (QMCell *)objectInChildrenAtIndex:(NSUInteger)index;
- (NSUInteger)countOfChildren;
- (void)addObjectInChildren:(QMCell *)childCell;
- (void)insertObject:(QMCell *)childCell inChildrenAtIndex:(NSUInteger)index;
- (void)removeObjectFromChildrenAtIndex:(NSUInteger)index;
- (void)removeChild:(QMCell *)childCell;

- (QMIcon *)objectInIconsAtIndex:(NSUInteger)index;
- (NSUInteger)countOfIcons;
- (void)addObjectInIcons:(QMIcon *)icon;
- (void)insertObject:(QMIcon *)icon inIconsAtIndex:(NSUInteger)index;
- (void)removeObjectFromIconsAtIndex:(NSUInteger)index;

/**
* The complete cell as an NSImage. Useful for example to generate the drag image
*/
- (NSImage *)image;

/**
* Computes the sizes and origins of the whole family. If invoking this for the root node, be aware that you first have
* to set its familyOrigin. Otherwise, the familyOrigin will be assumed to be (0, 0).
*/
- (void)computeGeometry;

@end
