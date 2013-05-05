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

@interface QMCellPopulator : NSObject

- (id)initWithDataSource:(id <QMMindmapViewDataSource>)dataSource;

- (QMCell *)cellWithParent:(QMCell *)parentCell itemOfParent:(id)itemOfParent;
@end
