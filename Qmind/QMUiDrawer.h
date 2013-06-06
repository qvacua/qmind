/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Cocoa/Cocoa.h>

@protocol TBBean;

@interface QMUiDrawer : NSObject <TBBean>

- (void)drawBadgeWithNumber:(NSUInteger)number atPoint:(NSPoint)location;

@end
