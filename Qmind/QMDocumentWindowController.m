/**
 * Tae Won Ha
 * http://qvacua.com
 * https://bitbucket.org/qvacua
 *
 * See LICENSE
 */

#import <TBCacao/TBCacao.h>
#import "QMDocumentWindowController.h"
#import "QMMindmapView.h"
#import "QMDocument.h"
#import "QMIconManager.h"
#import "QMAppSettings.h"
#import "QMCell.h"
#import "QMNode.h"
#import "QMMindmapViewDataSourceImpl.h"
#import "QMRootCell.h"
#import "QMIconsPaneView.h"
#import "QMIcon.h"

static CGFloat const kMinimumIconsPaneWidth = 48;
static CGFloat const kMaxIconsPaneWidth = 250;
static CGFloat const kPreferredMinMindmapViewWidth = 300;
static CGFloat const kAbsoluteMinMindmapViewWidth = 150;
static CGFloat const kMinIconGridWidth = 44;
static CGFloat const kMinIconGridHeight = 44;
static NSInteger const kViewMenuItemTag = 300;
static NSInteger const kIconsPaneMenuItemTag = 301;

@implementation QMDocumentWindowController {
    __weak QMAppSettings *_settings;

    __weak NSPasteboard *_pasteboard;

    __weak QMDocument *_doc;
    id<QMMindmapViewDataSource> _dataSource;
    __weak QMMindmapView *_mindmapView;
    __weak NSButton *_iconsPaneButton;
    __weak NSSplitView *_splitView;
    __weak QMIconsPaneView *_iconsPaneView;

    NSMutableArray *_availableIconsArray;
    __weak NSArrayController *_availableIconsArrayController;

    CGSize _oldClipviewSize;
    NSPoint _oldClipviewOrigin;
    NSPoint _oldCenterInView;
    CGFloat _lastIconsPaneWidth;
}

TB_MANUALWIRE_WITH_INSTANCE_VAR(settings, _settings)
TB_MANUALWIRE_WITH_INSTANCE_VAR(iconManager, _iconManager)

@synthesize mindmapView = _mindmapView;
@synthesize availableIconsArray = _availableIconsArray;
@synthesize availableIconsArrayController = _availableIconsArrayController;
@synthesize iconsPaneButton = _iconsPaneButton;
@synthesize splitView = _splitView;
@synthesize iconsPaneView = _iconsPaneView;

#pragma mark Public
- (void)reInitView {
    [_mindmapView initMindmapViewWithDataSource:_dataSource];
}

- (void)updateCellFoldingWithIdentifier:(id)identifier {
    [_mindmapView updateCellFoldingWithIdentifier:identifier];
}

- (void)updateCellWithIdentifier:(id)identifier {
    [_mindmapView updateCellWithIdentifier:identifier];
}

- (void)updateCellForChildRemovalWithIdentifier:(id)identifier {
    [_mindmapView updateCellFamilyForRemovalWithIdentifier:identifier];
}

- (void)updateCellForLeftChildRemovalWithIdentifier:(id)identifier {
    [_mindmapView updateLeftCellFamilyForRemovalWithIdentifier:identifier];
}

- (void)updateCellForChildInsertionWithIdentifier:(id)identifier {
    [_mindmapView updateCellFamilyForInsertionWithIdentifier:identifier];
}

- (void)updateCellForLeftChildInsertionWithIdentifier:(id)identifier {
    [_mindmapView updateLeftCellFamilyForInsertionWithIdentifier:identifier];
}

- (void)updateCellWithIdentifier:(id)identifier withNewChild:(id)childIdentifier {
    [_mindmapView updateCellFamily:identifier forNewCell:childIdentifier];
}

- (void)updateCellWithIdentifier:(id)identifier withNewLeftChild:(id)childIdentifier {
    [_mindmapView updateLeftCellFamily:identifier forNewCell:childIdentifier];
}

#pragma mark IBActions
- (IBAction)zoomByMode:(id)sender {
    int clickedSegment = [sender selectedSegment];

    switch (clickedSegment) {
        case 0:
            [self zoomOutView:sender];
            return;

        case 1:
            [self zoomToActualSize:sender];
            return;

        case 2:
            [self zoomInView:sender];
            return;
        default:
            return;
    }
}

- (IBAction)newChildNode:(id)sender {
    [_mindmapView insertChild];
}

- (IBAction)newLeftChildNode:(id)sender {
    [_mindmapView insertLeftChild];
}

- (IBAction)newNextSiblingNode:(id)sender {
    [_mindmapView insertNextSibling];
}

- (IBAction)newPreviousSiblingNode:(id)sender {
    [_mindmapView insertPreviousSibling];
}

- (IBAction)expandNodeAction:(id)sender {
    [_mindmapView toggleFoldingOfSelectedCell];
}

- (IBAction)collapseNodeAction:(id)sender {
    [_mindmapView toggleFoldingOfSelectedCell];
}

- (IBAction)deleteSelectedNodes:(id)sender {
    if (!_mindmapView.hasSelectedCells) {
        return;
    }

    NSArray *const selCells = _mindmapView.selectedCells;
    if ([selCells.lastObject isRoot]) {
        return;
    }

    NSMutableArray *itemArray = [[NSMutableArray alloc] initWithCapacity:selCells.count];
    for (QMCell *cell in selCells) {
        [itemArray addObject:cell.identifier];
    }

    [_mindmapView clearSelection];

    [_dataSource mindmapView:_mindmapView deleteItems:itemArray];
}

- (IBAction)clearSelection:(id)sender {
    [_mindmapView clearSelection];
}

- (IBAction)iconsPaneToggleAction:(id)sender {
    if (sender == _iconsPaneButton) {
        NSInteger state = [sender state];
        if (state == NSOnState) {
            [self setIconsPaneState:YES];
        } else {
            [self setIconsPaneState:NO];
        }

        return;
    }

    // show/hide icons pane menu item
    BOOL isIconsPaneCollapsed = [_splitView isSubviewCollapsed:[self iconsPane]];
    if (isIconsPaneCollapsed) {
        [self setIconsPaneState:YES];
        [sender setTitle:NSLocalizedString(@"ui.menu.iconspane.hide", @"Hide Icons Pane")];
    } else {
        [self setIconsPaneState:NO];
        [sender setTitle:NSLocalizedString(@"ui.menu.iconspane.show", @"Show Icons Pane")];
    }
}

- (IBAction)zoomToActualSize:(id)sender {
    [_mindmapView zoomToActualSize];
}

- (IBAction)zoomInView:(id)sender {
    [_mindmapView zoomByFactor:qZoomInStep];
}

- (IBAction)zoomOutView:(id)sender {
    [_mindmapView zoomByFactor:qZoomOutStep];
}

- (IBAction)cut:(id)sender {
    if ([_mindmapView hasSelectedCells] == NO) {
        return;
    }

    if ([[[_mindmapView selectedCells] lastObject] isRoot]) {
        return;
    }

    NSMutableArray *items = [[NSMutableArray alloc] init];

    for (QMCell *cell in [_mindmapView selectedCells]) {
        [items addObject:cell.identifier];
    }

    [self doInsideUndoGroup:NSLocalizedString(@"undo.node.cut", @"Undo Cut") usingBlock:^{
        [_doc cutItemsToPasteboard:items];
    }];
}

- (IBAction)copy:(id)sender {
    if ([_mindmapView hasSelectedCells] == NO) {
        return;
    }

    NSMutableArray *items = [[NSMutableArray alloc] init];

    for (QMCell *cell in [_mindmapView selectedCells]) {
        [items addObject:cell.identifier];
    }

    [_doc copyItemsToPasteboard:items];
}

- (IBAction)paste:(id)sender {
    NSArray *const selectedCells = [_mindmapView selectedCells];
    if ([selectedCells count] > 1) {
        return;
    }

    QMCell *selCell;
    if ([_mindmapView hasSelectedCells]) {
        selCell = [selectedCells lastObject];
    } else {
        selCell = [_mindmapView rootCell];
    }

    [_dataSource mindmapView:_mindmapView insertChildrenFromPasteboard:_pasteboard toItem:selCell.identifier];
}

- (IBAction)pasteLeft:(id)sender {
    NSArray *const selectedCells = [_mindmapView selectedCells];
    if ([selectedCells count] > 1) {
        return;
    }

    [_dataSource mindmapView:_mindmapView insertLeftChildrenFromPasteboard:_pasteboard toItem:_mindmapView.rootCell.identifier];
}

- (IBAction)pasteAsPreviousSibling:(id)sender {
    NSArray *const selectedCells = [_mindmapView selectedCells];
    if ([selectedCells count] > 1) {
        return;
    }

    [_dataSource mindmapView:_mindmapView insertPreviousSiblingsFromPasteboard:_pasteboard toItem:[[selectedCells lastObject] identifier]];
}

- (IBAction)pasteAsNextSibling:(id)sender {
    NSArray *const selectedCells = [_mindmapView selectedCells];
    if ([selectedCells count] > 1) {
        return;
    }

    [_dataSource mindmapView:_mindmapView insertNextSiblingsFromPasteboard:_pasteboard toItem:[[selectedCells lastObject] identifier]];
}

#pragma mark NSFontManagerResponderMethod
- (void)changeFont:(id)sender {
    if (![_mindmapView hasSelectedCells]) {
        return;
    }

    NSFont *const defaultFont = [_settings settingForKey:qSettingDefaultFont];
    NSFont *const newFont = [sender convertFont:defaultFont];

    NSMutableArray *itemsToChange = [[NSMutableArray alloc] initWithCapacity:[_mindmapView selectedCells].count];
    for (QMCell *cell in [_mindmapView selectedCells]) {
        if (![cell.font isEqual:newFont]) {
            [itemsToChange addObject:cell.identifier];
        }
    }

    [_dataSource mindmapView:_mindmapView setFont:newFont ofItems:itemsToChange];
}

#pragma mark NSWindowController
- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
        [[TBContext sharedContext] autowireSeed:self];
    }

    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];

    _doc = [self document];
    _pasteboard = [NSPasteboard pasteboardWithName:NSGeneralPboard];
    _dataSource = [[QMMindmapViewDataSourceImpl alloc] initWithDoc:_doc view:_mindmapView];

    [self initAvailableIcons];
    [_mindmapView initMindmapViewWithDataSource:_dataSource];

    [self setIconGridSize:NewSize(kMinIconGridWidth, kMinIconGridHeight)];
    [_splitView setPosition:[self maxDividerPosition] ofDividerAtIndex:0];
    [self adaptIconCollectionGridViewSize];
    [self updateIconsPaneSenderStatus];
}

#pragma mark NSSplitViewDelegate
- (BOOL)splitView:(NSSplitView *)splitView shouldHideDividerAtIndex:(NSInteger)dividerIndex {
    return YES;
}

- (void)splitViewWillResizeSubviews:(NSNotification *)notification {
    /**
    * We store the current width of the icons pane for later toggling of the pane.
    */
    [self storeCurrentWidthOfIconsPane];

    /**
    * In order not to scroll when window-resizing, we have to store the following before-resizing-values
    * - to mindmap view converted clip view bounds origin
    * - to mindmap view converted clip view frame size
    * - the old center point of the visible portion of the mindmap
    *
    * With the above three values combined with new origin and size, we can compute the new scroll point of the mindmap
    * such that it does not scroll when we resize the window,
    * cf. -updateCanvasWithOldClipViewOrigin:oldClipViewSize:oldCenterInView of QMMindmapView.
    *
    * This delegate method gets called when either the split view changed its size or the divider is shifted. It is
    * invoked before -splitView:resizeSubviewsWithOldSize:
    *
    * This delegate method does NOT get called when -adjustSubviews are manually called.
    */
    [self storeCurrentPositionValuesForMindmapView];
}

- (void)splitViewDidResizeSubviews:(NSNotification *)notification {
    /**
    * This delegate method gets called when either the split view changed its size or the divider is shifted. It is
    * invoked after -splitView:resizeSubviewsWithOldSize:
    *
    * This delegate method does NOT get called when -adjustSubviews are manually called.
    */
    [self updateMindmapViewCanvasSize];
    [self updateIconsPaneSenderStatus];
    [self adaptIconCollectionGridViewSize];
}

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview {
    return (subview == [splitView subviews][0]);
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    CGFloat computedMindmapViewMinWidth = [_splitView frame].size.width - [_splitView dividerThickness] - kMaxIconsPaneWidth;

    if (computedMindmapViewMinWidth < kPreferredMinMindmapViewWidth) {
        return proposedMinimumPosition + kAbsoluteMinMindmapViewWidth;
    }

    return computedMindmapViewMinWidth;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
    return proposedMaximumPosition - ([self minIconsPaneWidth]);
}

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
    return (subview == [splitView subviews][1]);
}

- (BOOL)splitView:(NSSplitView *)splitView shouldCollapseSubview:(NSView *)subview forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex {
    return (subview == [splitView subviews][1]);
}

#pragma mark NSUserInterfaceValidations
- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem {
    SEL const selector = [anItem action];

    if (selector == @selector(iconsPaneToggleAction:)) {
        return YES;
    }

    if (selector == @selector(zoomToActualSize:)) {
        return YES;
    }

    if (selector == @selector(zoomInView:)) {
        return YES;
    }

    if (selector == @selector(zoomOutView:)) {
        return YES;
    }

    NSArray *const selectedCells = [_mindmapView selectedCells];

    if (selector == @selector(cut:)) {
        if ([[selectedCells lastObject] isRoot]) {
            return NO;
        }

        if ([selectedCells count] > 0) {
            return YES;
        }
    }

    if (selector == @selector(copy:)) {
        if ([selectedCells count] > 0) {
            return YES;
        }
    }

    if (selector == @selector(paste:)) {
        if ([selectedCells count] > 1) {
            return NO;
        }

        NSArray *types = [_pasteboard types];
        if ([types containsObject:qNodeUti] || [types containsObject:NSStringPboardType]) {
            return YES;
        }

        return NO;
    }

    if (selector == @selector(pasteLeft:)) {
        if ([selectedCells count] > 1) {
            return NO;
        }

        NSArray *types = [_pasteboard types];
        if ([types containsObject:qNodeUti] || [types containsObject:NSStringPboardType]) {
            if ([selectedCells count] == 0) {
                return YES;
            }

            if ([[selectedCells lastObject] isRoot]) {
                return YES;
            }
        }

        return NO;
    }

    if (selector == @selector(pasteAsNextSibling:) || selector == @selector(pasteAsPreviousSibling:)) {
        if ([selectedCells count] != 1) {
            return NO;
        }

        NSArray *types = [_pasteboard types];
        if ([types containsObject:qNodeUti] || [types containsObject:NSStringPboardType]) {
            if ([[selectedCells lastObject] isRoot]) {
                return NO;
            }

            return YES;
        }
    }

    if (selector == @selector(newChildNode:)) {
        if ([selectedCells count] > 1) {
            return NO;
        }

        return YES;
    }

    if (selector == @selector(newLeftChildNode:)) {
        if (![_mindmapView hasSelectedCells]) {
            return YES;
        }

        if ([selectedCells lastObject] == _mindmapView.rootCell) {
            return YES;
        }

        return NO;
    }

    if (selector == @selector(newNextSiblingNode:) || selector == @selector(newPreviousSiblingNode:)) {
        if (![_mindmapView hasSelectedCells]) {
            return NO;
        }

        if ([selectedCells lastObject] == _mindmapView.rootCell) {
            return NO;
        }

        if ([selectedCells count] > 1) {
            return NO;
        }

        return YES;
    }

    if (selector == @selector(deleteSelectedNodes:)) {

        if ([_mindmapView rootCellSelected]) {
            return NO;
        }

        return [_mindmapView hasSelectedCells];
    }

    if (selector == @selector(expandNodeAction:)) {
        if ([_mindmapView rootCellSelected]) {
            return NO;
        }

        if ([_mindmapView hasSelectedCells] && [selectedCells count] == 1) {
            return [[selectedCells lastObject] isFolded];
        }
    }

    if (selector == @selector(collapseNodeAction:)) {
        if ([_mindmapView rootCellSelected]) {
            return NO;
        }

        if ([_mindmapView hasSelectedCells] && [selectedCells count] == 1) {
            return ![[selectedCells lastObject] isFolded];
        }
    }

    return NO;
}

#pragma mark Private
- (void)doInsideUndoGroup:(NSString *)undoGroupName usingBlock:(void (^)())block {
    NSUndoManager *const undoManager = [_doc undoManager];

    [undoManager beginUndoGrouping];
    [undoManager setActionName:undoGroupName];

    block();

    [undoManager endUndoGrouping];
}

- (void)initAvailableIcons {
    _availableIconsArray = [[NSMutableArray alloc] initWithCapacity:75];

    [_iconManager.iconCodes enumerateObjectsUsingBlock:^(NSString *code, NSUInteger index, BOOL* stop) {
        [_availableIconsArrayController addObject:[[QMIcon alloc] initWithCode:code]];
    }];

    [_availableIconsArrayController setSelectionIndexes:[NSIndexSet indexSet]];
}

- (void)updateIconsPaneSenderStatus {
    NSMenu *mainMenu = [[NSApplication sharedApplication] mainMenu];
    NSMenuItem *menuItem = [mainMenu itemWithTag:kViewMenuItemTag];
    NSMenuItem *iconsPaneMenuItem = [[menuItem submenu] itemWithTag:kIconsPaneMenuItemTag];

    if ([_splitView isSubviewCollapsed:[self iconsPane]]) {
        [_iconsPaneButton setState:NSOffState];
        [iconsPaneMenuItem setTitle:NSLocalizedString(@"ui.menu.iconspane.show", @"Show Icons Pane")];
        return;
    }

    [_iconsPaneButton setState:NSOnState];
    [iconsPaneMenuItem setTitle:NSLocalizedString(@"ui.menu.iconspane.hide", @"Hide Icons Pane")];
}

- (void)setIconsPaneState:(BOOL)show {
    NSView *pane = [self iconsPane];
    if (!show == [_splitView isSubviewCollapsed:pane]) {
        return;
    }

    [self storeCurrentPositionValuesForMindmapView];

    if (show) {
        CGFloat newMindmapViewWidth = [_splitView frame].size.width - _lastIconsPaneWidth - [_splitView dividerThickness];

        [pane setHidden:NO];
        [_splitView setPosition:newMindmapViewWidth ofDividerAtIndex:0];
    } else {
        [pane setHidden:YES];
    }

    [_splitView adjustSubviews];
    [self updateMindmapViewCanvasSize];
}

- (void)storeCurrentWidthOfIconsPane {
    CGFloat iconsPaneWidth = [[self iconsPane] frame].size.width;
    _lastIconsPaneWidth = iconsPaneWidth;
}

- (void)storeCurrentPositionValuesForMindmapView {
    NSClipView *clipView = _mindmapView.enclosingScrollView.contentView;
    _oldClipviewOrigin = [_mindmapView convertPoint:clipView.bounds.origin fromView:clipView];
    _oldClipviewSize = [_mindmapView convertSize:clipView.frame.size fromView:clipView];
    _oldCenterInView = [_mindmapView middlePointOfVisibleRect];
}

- (void)updateMindmapViewCanvasSize {
    [_mindmapView updateCanvasWithOldClipViewOrigin:_oldClipviewOrigin oldClipViewSize:_oldClipviewSize oldCenterInView:_oldCenterInView];
}

- (NSScrollView *)iconsPane {
    return [_splitView subviews][1];
}

- (void)setIconGridSize:(NSSize)size {
    [_iconsPaneView setMinItemSize:size];
    [_iconsPaneView setMaxItemSize:size];
}

- (void)adaptIconCollectionGridViewSize {
    /**
    * When we use the frame of _iconsPaneView, the width is narrower thant the visible width. Scrollbar bug?
    */
    CGFloat visibleWidth = ([_iconsPaneView visibleRect]).size.width;
    NSUInteger possibleNumberOfColumn = (NSUInteger) floor(visibleWidth / kMinIconGridWidth);
    CGFloat remainderWidth = visibleWidth - possibleNumberOfColumn * kMinIconGridWidth;
    CGFloat newWidth = kMinIconGridWidth + remainderWidth / possibleNumberOfColumn;

    NSSize size;
    if (remainderWidth > 0) {
        size = NewSize(newWidth, kMinIconGridHeight);
    } else {
        size = NewSize(kMinIconGridWidth, kMinIconGridHeight);
    }

    [_iconsPaneView setMaxItemSize:size];
    [_iconsPaneView setMaxNumberOfColumns:possibleNumberOfColumn];
}

- (CGFloat)minIconsPaneWidth {
    CGFloat scrollbarWidth = 0;
    if ([[[self iconsPane] verticalScroller] scrollerStyle] == NSScrollerStyleLegacy) {
        scrollbarWidth= [NSScroller scrollerWidthForControlSize:NSRegularControlSize scrollerStyle:NSScrollerStyleLegacy];
    }

    return kMinimumIconsPaneWidth + scrollbarWidth;
}

- (CGFloat)maxDividerPosition {
    return [_splitView frame].size.width - [self minIconsPaneWidth] - [_splitView dividerThickness];
}

@end

