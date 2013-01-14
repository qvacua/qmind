/**
 * Tae Won Ha
 * http://qvacua.com
 * https://bitbucket.org/qvacua
 *
 * See LICENSE
 */

#import <Cocoa/Cocoa.h>
#import "QMTypes.h"

@class QMIconManager;
@class QMAppSettings;
@class QMTextDrawer;
@class QMTextLayoutManager;

@interface QMIcon : NSObject <NSCopying>

@property (weak) QMIconManager *iconManager;
@property (weak) QMAppSettings *settings;
@property (weak) QMTextDrawer *textDrawer;
@property (weak) QMTextLayoutManager *textLayoutManager;

@property (readonly) QMIconKind kind;
@property (readonly) NSString *code;
@property (readonly) NSString *unicode;
@property (readonly) NSImage *image;

/**
* NSCollectionViewItem flips the image...
*/
@property (readonly) NSImage *flippedImage;
@property NSPoint origin;

/**
* The default size after init is set by QMAppSettings
*/
@property NSSize size;

- (id)initWithCode:(NSString *)aCode;
- (void)drawRect:(NSRect)dirtyRect;

@end
