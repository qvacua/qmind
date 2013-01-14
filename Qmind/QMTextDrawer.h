/**
 * Tae Won Ha
 * http://qvacua.com
 * https://bitbucket.org/qvacua
 *
 * See LICENSE
 */

#import <Cocoa/Cocoa.h>

@class QMCell;
@class QMAppSettings;

@interface QMTextDrawer : NSObject

@property (weak) QMAppSettings *settings;

- (void)drawAttributedString:(NSAttributedString *)attrStr inRect:(NSRect)frame range:(NSRange)range;

@end
