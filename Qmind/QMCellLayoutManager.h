/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Cocoa/Cocoa.h>
#import "QMCell.h"

@class QMCell;
@class QMTextLayoutManager;
@class QMAppSettings;
@protocol TBBean;

@interface QMCellLayoutManager : NSObject <TBBean>

@property (weak) QMAppSettings *settings;

- (QMCellRegion)regionOfCell:(QMCell *)cell atPoint:(NSPoint)locationInView;
- (NSRect)regionFrameOfCell:(QMCell *)cell ofRegion:(QMCellRegion)region;

- (void)computeGeometryAndLinesOfCell:(QMCell *)cell;

@end
