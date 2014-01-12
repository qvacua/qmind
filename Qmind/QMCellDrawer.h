/**
 * Tae Won Ha — @hataewon
 *
 * http://taewon.de
 * http://qvacua.com
 *
 * See LICENSE
 */

#import <Cocoa/Cocoa.h>
#import <TBCacao/TBCacao.h>


@class QMCell;
@class QMAppSettings;
@class QMTextLayoutManager;
@class QMCellLayoutManager;
@class QMTextDrawer;

@interface QMCellDrawer : NSObject <TBBean>

@property (weak) QMAppSettings *settings;
@property (weak) QMTextLayoutManager *textLayoutManager;
@property (weak) QMCellLayoutManager *cellLayoutManager;
@property (weak) QMTextDrawer *textDrawer;

- (void)drawCell:(QMCell *)cell rect:(NSRect)dirtyRect;
- (void)drawContentForCell:(QMCell *)cell rect:(NSRect)dirtyRect;

@end
