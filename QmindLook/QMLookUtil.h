/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Cocoa/Cocoa.h>

static NSPoint qMindmapOrigin = {10, 10};

@class QMRootCell;

@interface QMLookUtil : NSObject

+ (QMRootCell *)rootCellForUrl:(NSURL *)url;

@end
