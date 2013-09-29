/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
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

-(void)drawContentForCell:(QMCell *)cell rect:(NSRect)dirtyRect;
@end
