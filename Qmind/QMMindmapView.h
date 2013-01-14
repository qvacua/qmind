/**
 * Tae Won Ha
 * http://qvacua.com
 * https://bitbucket.org/qvacua
 *
 * See LICENSE
 */

#import <Cocoa/Cocoa.h>
#import "QMCellEditorDelegate.h"

@protocol QMMindmapViewDataSource;
@class QMCellDrawer;
@class QMRootCell;
@class QMCell;
@class QMCellStateManager;
@class QMCellSelector;
@class QMAppSettings;
@class QMCellEditor;
@class QMCellLayoutManager;
@class QMUiDrawer;

static const NSSize UNIT_SIZE = {1.0, 1.0};
static const CGFloat MIN_ZOOM_FACTOR = 0.01;
static const CGFloat MAX_ZOOM_FACTOR = 100.0;
static const CGFloat ZOOM_SCROLLWHEEL_STEP = 0.25;

static inline BOOL modifier_check(NSUInteger value, NSUInteger modifier) {
    return (value & modifier) == modifier;
}

@interface QMMindmapView : NSView <QMCellEditorDelegate, NSDraggingSource, NSDraggingDestination>

#pragma mark Properties
@property (weak, readonly) id<QMMindmapViewDataSource> dataSource;
@property (strong, readonly) QMRootCell *rootCell;

@property (weak) QMUiDrawer *uiDrawer;
@property (weak) QMCellSelector *cellSelector;
@property (weak) QMCellLayoutManager *cellLayoutManager;
@property (weak) QMAppSettings *settings;

#pragma mark Public
- (void)updateCanvasSize;

- (void)initMindmapViewWithDataSource:(id <QMMindmapViewDataSource>)aDataSource;

- (void)zoomToActualSize;
- (void)zoomByFactor:(CGFloat)factor;

- (void)insertChild;
- (void)insertLeftChild;
- (void)insertPreviousSibling;
- (void)insertNextSibling;

- (void)toggleFoldingOfSelectedCell;

- (BOOL)hasSelectedCells;
- (BOOL)cellIsSelected:(QMCell *)cell;
- (BOOL)cellIsCurrentlyEdited:(QMCell *)cell;

- (NSArray *)selectedCells;
- (void)clearSelection;
- (BOOL)rootCellSelected;

- (void)updateFontOfSelectedCellsToFont:(NSFont *)newFont;
- (void)updateCellWithIdentifier:(id)identifier;
- (void)updateCellFoldingWithIdentifier:(id)identifier;
- (void)updateCellFamilyForRemovalWithIdentifier:(id)identifier;
- (void)updateLeftCellFamilyForRemovalWithIdentifier:(id)identifier;
- (void)updateCellFamilyForInsertionWithIdentifier:(id)identifier;
- (void)updateLeftCellFamilyForInsertionWithIdentifier:(id)identifier;
- (void)updateCellFamily:(id)parentId forNewCell:(id)childId;
- (void)updateLeftCellFamily:(id)parentId forNewCell:(id)childId;

#pragma mark QMCellEditorDelegate
- (void)editingEndedWithString:(NSAttributedString *)newAttrStr forCell:(QMCell *)editedCell byChar:(unichar)character;
- (void)editingCancelledWithString:(NSAttributedString *)newAttrStr forCell:(QMCell *)editedCell;

#pragma mark NSDraggingSource
- (BOOL)ignoreModifierKeysForDraggingSession:(NSDraggingSession *)session;

#pragma mark NSDraggingDestination
- (NSDragOperation)draggingUpdated:(id < NSDraggingInfo >)sender;

#pragma mark NSResponder
- (void)keyDown:(NSEvent *)theEvent;
- (void)mouseDown:(NSEvent *)event;
- (void)mouseDragged:(NSEvent *)event;
- (void)mouseUp:(NSEvent *)event;
- (void)scrollWheel:(NSEvent *)event;
- (void)magnifyWithEvent:(NSEvent *)event;
- (BOOL)acceptsFirstResponder;
- (BOOL)becomeFirstResponder;

#pragma mark NSView
- (id)initWithFrame:(NSRect)frame;
- (void)drawRect:(NSRect)dirtyRect;
- (BOOL)isFlipped;

-(void)endEditing;

-(NSPoint)middlePointOfVisibleRect;

- (void)updateCanvasWithOldClipViewOrigin:(NSPoint)oldClipViewOrigin oldClipViewSize:(NSSize)oldClipViewSize oldCenterInView:(NSPoint)oldCenterInView;
@end
