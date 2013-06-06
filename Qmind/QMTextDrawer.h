/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Cocoa/Cocoa.h>

@protocol TBBean;

@interface QMTextDrawer : NSObject <TBBean>

- (void)drawAttributedString:(NSAttributedString *)attrStr inRect:(NSRect)frame range:(NSRange)range;

@end
