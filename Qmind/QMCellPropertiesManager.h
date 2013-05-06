/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Cocoa/Cocoa.h>

@class QMCell;
@class QMMindmapView;

@interface QMCellPropertiesManager : NSObject

- (id)initWithDataSource:(QMMindmapView *)view;
- (QMCell *)cellWithParent:(QMCell *)parentCell itemOfParent:(id)itemOfParent;
- (void)fillCellPropertiesWithIdentifier:(id)givenItem cell:(QMCell *)cell;
- (void)fillIconsOfCell:(QMCell *)cell;
- (void)fillAllChildrenWithIdentifier:(id)givenItem cell:(QMCell *)cell;

@end
