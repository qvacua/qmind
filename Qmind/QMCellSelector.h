/**
 * Tae Won Ha
 * http://qvacua.com
 * https://bitbucket.org/qvacua
 *
 * See LICENSE
 */

#import <Cocoa/Cocoa.h>

@class QMCell;

@interface QMCellSelector : NSObject

- (QMCell *)cellWithIdentifier:(id)identifier fromParentCell:(QMCell *)parentCell;

- (QMCell *)traverseCell:(QMCell *)parentCell usingBlock:(void (^)(QMCell *, BOOL *))block;

- (QMCell *)cellContainingPoint:(NSPoint)point inCell:(QMCell *)startingCell;

@end
