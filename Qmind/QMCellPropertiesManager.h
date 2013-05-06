/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Cocoa/Cocoa.h>

@protocol QMMindmapViewDataSource;
@class QMCell;
@class QMMindmapView;

@interface QMCellPropertiesManager : NSObject

/**
* Init for Quick Look plugin for which we don't need the view.
*/
- (id)initWithDataSource:(id <QMMindmapViewDataSource>)dataSource;

/**
* Designated initializer for Qmind App.
*/
- (id)initWithMindmapView:(QMMindmapView *)view;

- (QMCell *)cellWithParent:(QMCell *)parentCell itemOfParent:(id)itemOfParent;
- (void)fillCellPropertiesWithIdentifier:(id)givenItem cell:(QMCell *)cell;
- (void)fillIconsOfCell:(QMCell *)cell;
- (void)fillAllChildrenWithIdentifier:(id)givenItem cell:(QMCell *)cell;

@end
