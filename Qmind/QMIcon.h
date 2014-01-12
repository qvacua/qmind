/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Cocoa/Cocoa.h>
#import "QMTypes.h"

@class QMIconManager;
@class QMAppSettings;
@class QMTextDrawer;
@class QMTextLayoutManager;
@class QMFontManager;

@interface QMIcon : NSObject <NSCopying>

@property (weak) QMIconManager *iconManager;
@property (weak) QMAppSettings *settings;
@property (weak) QMTextDrawer *textDrawer;
@property (weak) QMTextLayoutManager *textLayoutManager;
@property (weak) QMFontManager *fontManager;
@property (assign) NSFontManager *systemFontManager;    // it is not allowed to weakly reference to NSFontManager?

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

@property (readonly) NSRect frame;

- (id)initWithCode:(NSString *)aCode;
- (id)initAsLink;
- (void)drawRect:(NSRect)dirtyRect;

@end
