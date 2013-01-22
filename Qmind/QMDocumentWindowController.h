/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Cocoa/Cocoa.h>
#import "QMMindmapViewDataSource.h"

static CGFloat const qZoomInStep = 1.1;
static CGFloat const qZoomOutStep = 0.9;

@class QMAppSettings;
@class QMDocument;
@class QMIconManager;
@class QMIconsPaneView;

@interface QMDocumentWindowController : NSWindowController <NSUserInterfaceValidations, NSWindowDelegate, NSSplitViewDelegate, NSCollectionViewDelegate>

@property (weak) QMAppSettings *settings;
@property (weak) QMIconManager *iconManager;

@property NSMutableArray *availableIconsArray;
@property (weak) IBOutlet QMMindmapView *mindmapView;
@property (weak) IBOutlet NSArrayController *availableIconsArrayController;
@property (weak) IBOutlet NSButton *iconsPaneButton;
@property (weak) IBOutlet NSSplitView *splitView;
@property (weak) IBOutlet QMIconsPaneView *iconsPaneView;

- (void)updateCellFoldingWithIdentifier:(id)identifier;

- (void)updateCellWithIdentifier:(id)identifier;

- (void)updateCellForChildRemovalWithIdentifier:(id)identifier;

- (void)updateCellForLeftChildRemovalWithIdentifier:(id)identifier;

- (void)updateCellForChildInsertionWithIdentifier:(id)identifier;

- (void)updateCellForLeftChildInsertionWithIdentifier:(id)identifier;

- (void)updateCellWithIdentifier:(id)identifier withNewChild:(id)childIdentifier;

- (void)updateCellWithIdentifier:(id)identifier withNewLeftChild:(id)childIdentifier;

- (IBAction)zoomByMode:(id)sender;

- (IBAction)zoomToActualSize:(id)sender;

- (IBAction)zoomInView:(id)sender;

- (IBAction)zoomOutView:(id)sender;

- (IBAction)cut:(id)sender;

- (IBAction)copy:(id)sender;

- (IBAction)paste:(id)sender;

- (IBAction)pasteLeft:(id)sender;

- (IBAction)pasteAsPreviousSibling:(id)sender;

- (IBAction)pasteAsNextSibling:(id)sender;

- (IBAction)newChildNode:(id)sender;

- (IBAction)newLeftChildNode:(id)sender;

- (IBAction)newNextSiblingNode:(id)sender;

- (IBAction)newPreviousSiblingNode:(id)sender;

- (IBAction)expandNodeAction:(id)sender;

- (IBAction)collapseNodeAction:(id)sender;

- (IBAction)deleteSelectedNodes:(id)sender;

- (IBAction)clearSelection:(id)sender;

- (IBAction)iconsPaneToggleAction:(id)sender;

- (void)reInitView;

@end
