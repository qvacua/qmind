/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Cocoa/Cocoa.h>

@class QMCell;
@protocol TBBean;

@interface QMCellSelector : NSObject <TBBean>

- (QMCell *)cellWithIdentifier:(id)identifier fromParentCell:(QMCell *)parentCell;

- (QMCell *)traverseCell:(QMCell *)parentCell usingBlock:(void (^)(QMCell *, BOOL *))block;

- (QMCell *)cellContainingPoint:(NSPoint)point inCell:(QMCell *)startingCell;

@end
