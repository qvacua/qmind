/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import "QMCell.h"

@interface QMRootCell : QMCell

@property (readonly) NSArray *leftChildren;
@property (readonly, weak) NSArray *allChildren;

/**
* The size of all left child cells, not including the cell (being their parent) itself. Only relevant for the root cell
*/
@property (readonly) NSSize leftChildrenFamilySize;

/**
* Draws the cell and all of its children.
*/
- (void)drawRect:(NSRect)dirtyRect;
- (id)initWithView:(QMMindmapView *)view;

- (void)addChild:(QMCell *)childCell left:(BOOL)cellIsLeft;

- (void)removeChild:(QMCell *)childCell;
- (NSUInteger)countOfAllChildren;
- (NSUInteger)indexOfChild:(QMCell *)childCell;

- (QMCell *)objectInLeftChildrenAtIndex:(NSUInteger)index;
- (NSUInteger)countOfLeftChildren;
- (void)insertObject:(QMCell *)childCell inLeftChildrenAtIndex:(NSUInteger)index;
- (void)removeObjectFromLeftChildrenAtIndex:(NSUInteger)index;
- (void)addObjectInLeftChildren:(QMCell *)childCell;

@end
