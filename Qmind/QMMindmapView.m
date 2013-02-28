/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Qkit/Qkit.h>
#import <TBCacao/TBCacao.h>
#import "QMMindmapView.h"
#import "QMMindmapViewDataSource.h"
#import "QMCell.h"
#import "QMRootCell.h"
#import "QMCellStateManager.h"
#import "QMCellSelector.h"
#import "QMAppSettings.h"
#import "QMCellEditor.h"
#import "QMUiDrawer.h"
#import "QMCellLayoutManager.h"
#import "QMNode.h"
#import "QMIcon.h"
#import "DummyView.h"

static const CGFloat qZoomScrollWheelStep = 0.25;

static unsigned int const qPageUpKeyCode = 0xF72C;
static unsigned int const qPageDownKeyCode = 0xF72D;

static const NSSize qSizeOfBadge = {24., 24.};
static const NSSize qSizeOfBadgeCircle = {20., 20.};

static inline CGFloat area(NSRect rect) {
    return rect.size.width * rect.size.height;
}

static inline BOOL sign(CGFloat x) {
    return (BOOL) ((x > 0) - (x < 0));
}

static inline BOOL modifier_check(NSUInteger value, NSUInteger modifier) {
    return (value & modifier) == modifier;
}

@implementation QMMindmapView {
    QMCellEditor *_cellEditor;
    QMCellStateManager *_cellStateManager;

    BOOL _dragging;
    BOOL _keepMouseTrackOn;

    NSUInteger _mouseDownModifier;
    NSSize _newScale;
}

TB_MANUALWIRE_WITH_INSTANCE_VAR(cellSelector, _cellSelector)
TB_MANUALWIRE_WITH_INSTANCE_VAR(cellLayoutManager, _cellLayoutManager)
TB_MANUALWIRE_WITH_INSTANCE_VAR(settings, _settings)
TB_MANUALWIRE_WITH_INSTANCE_VAR(uiDrawer, _uiDrawer)

@synthesize dataSource = _dataSource;
@synthesize rootCell = _rootCell;
@synthesize newScale = _newScale;

#pragma mark Public
- (void)endEditing {
    if ([_cellEditor isEditing]) {
        [_cellEditor endEditing];
    }
}

- (NSPoint)middlePointOfVisibleRect {
    NSRect visibleRect = [self visibleRect];
    CGPoint origin = visibleRect.origin;
    CGSize size = visibleRect.size;

    return NewPoint(origin.x + size.width / 2, origin.y + size.height / 2);
}

- (void)insertChild {
    NSArray *const selCells = [_cellStateManager selectedCells];
    if ([selCells count] > 1) {
        return;
    }

    QMCell *selCell;
    if (![_cellStateManager hasSelectedCells]) {
        selCell = _rootCell;
    } else {
        selCell = [selCells lastObject];
    }

    if ([selCell isFolded]) {
        [self toggleFoldingOfSelectedCell];
    }
    [_dataSource mindmapView:self addNewChildToItem:selCell.identifier atIndex:[selCell countOfChildren]];
}

- (void)insertLeftChild {
    NSArray *const selCells = [_cellStateManager selectedCells];
    if ([selCells count] > 1) {
        return;
    }

    if (![_cellStateManager hasSelectedCells]) {
        [_dataSource mindmapView:self addNewLeftChildToItem:_rootCell.identifier atIndex:[_rootCell countOfLeftChildren]];
        return;
    }

    QMCell *const selCell = [selCells lastObject];
    if ([selCell isRoot]) {
        [_dataSource mindmapView:self addNewLeftChildToItem:_rootCell.identifier atIndex:[_rootCell countOfLeftChildren]];
    } else {
        if ([selCell isFolded]) {
            [self toggleFoldingOfSelectedCell];
        }
        [_dataSource mindmapView:self addNewChildToItem:selCell.identifier atIndex:[selCell countOfChildren]];
    }
}

- (void)insertPreviousSibling {
    if (![_cellStateManager hasSelectedCells]) {
        return;
    }

    NSArray *const selCells = [_cellStateManager selectedCells];
    if ([selCells count] > 1) {
        return;
    }

    QMCell *selCell = [selCells lastObject];
    if ([selCell isRoot]) {
        return;
    }

    [_dataSource mindmapView:self addNewPreviousSiblingToItem:selCell.identifier];
}

- (void)insertNextSibling {
    if (![_cellStateManager hasSelectedCells]) {
        return;
    }

    NSArray *const selCells = [_cellStateManager selectedCells];
    if ([selCells count] > 1) {
        return;
    }

    QMCell *selCell = [selCells lastObject];
    if ([selCell isRoot]) {
        return;
    }

    [_dataSource mindmapView:self addNewNextSiblingToItem:selCell.identifier];
}

- (NSArray *)selectedCells {
    return _cellStateManager.selectedCells;
}

- (void)clearSelection {
    [_cellStateManager clearSelection];
}

- (BOOL)rootCellSelected {
    if (![_cellStateManager hasSelectedCells]) {
        return NO;
    }

    if ([[[_cellStateManager selectedCells] lastObject] identifier] == _rootCell.identifier) {
        return YES;
    }

    return NO;
}

- (void)zoomToActualSize {
    CGFloat currentScale = ([self convertSize:qUnitSize toView:nil]).width;
    [self zoomByFactor:1. / currentScale withFixedPoint:[self middlePointOfVisibleRect]];
}

- (void)updateCanvasSize {
    if (_cellEditor.isEditing) {
        [_cellEditor endEditing];
    }

    [self setFrameSize:[self scaledBoundsSizeWithParentSize:self.superview.frame.size]];
    [self setNeedsDisplay:YES];
}

- (void)updateCanvasWithOldClipViewOrigin:(NSPoint)oldClipViewOrigin oldClipViewSize:(NSSize)oldClipViewSize oldCenterInView:(NSPoint)oldCenterInView {
    NSPoint oldMapOrigin = [self rootCellOriginForParentSize:oldClipViewSize];
    NSSize oldDist = NewSize(oldCenterInView.x - oldClipViewOrigin.x, oldCenterInView.y - oldClipViewOrigin.y);

    [self updateCanvasSize];

    NSClipView *clipView = self.enclosingScrollView.contentView;
    NSSize newParentSize = [self convertSize:clipView.frame.size fromView:clipView];
    NSPoint newMapOrigin = [self rootCellOriginForParentSize:newParentSize];

    NSSize deltaMapOrigin = NewSize(oldMapOrigin.x - newMapOrigin.x, oldMapOrigin.y - newMapOrigin.y);
    NSPoint newScrollPt = NewPoint(oldCenterInView.x - deltaMapOrigin.width - oldDist.width, oldCenterInView.y - deltaMapOrigin.height - oldDist.height);

    [self scrollPoint:newScrollPt];
    [self setNeedsDisplay:YES];
}

- (void)zoomByFactor:(CGFloat)factor {
    [self zoomByFactor:factor withFixedPoint:[self middlePointOfVisibleRect]];
}

- (void)updateFontOfSelectedCellsToFont:(NSFont *)newFont {
    if (!_cellStateManager.hasSelectedCells) {
        return;
    }

    for (QMCell *cell in _cellStateManager.selectedCells) {
        cell.font = newFont;
    }

    [self updateCanvasSize];
    [self setNeedsDisplay:YES];
}

- (void)toggleFoldingOfSelectedCell {
    [_dataSource mindmapView:self toggleFoldingForItem:[[_cellStateManager selectedCells][0] identifier]];
}

- (BOOL)hasSelectedCells {
    return _cellStateManager.hasSelectedCells;
}

- (BOOL)cellIsSelected:(QMCell *)cell {
    return [_cellStateManager cellIsSelected:cell];
}

- (BOOL)cellIsCurrentlyEdited:(QMCell *)cell {
    return _cellEditor.currentlyEditedCell == cell;
}

- (void)updateCellWithIdentifier:(id)identifier {
    QMCell *cellToUpdate = [_cellSelector cellWithIdentifier:identifier fromParentCell:_rootCell];

    NSString *const stringValueOfItem = [_dataSource mindmapView:self stringValueOfItem:identifier];
    if (![cellToUpdate.stringValue isEqualToString:stringValueOfItem]) {
        cellToUpdate.stringValue = stringValueOfItem;
    }

    NSFont *const fontOfItem = [_dataSource mindmapView:self fontOfItem:identifier];
    if (![cellToUpdate.font isEqual:fontOfItem]) {
        cellToUpdate.font = fontOfItem;
    }

    NSUInteger countOfOldIcons = [cellToUpdate.icons count];
    for (int i = 0; i < countOfOldIcons; i++) {
        [cellToUpdate removeObjectFromIconsAtIndex:0];
    }
    [self fillIconsOfCell:cellToUpdate];

    [self updateCanvasSize];
    [self setNeedsDisplay:YES];
}

- (void)updateCellFoldingWithIdentifier:(id)identifier {
    QMCell *cellToUpdate = [_cellSelector cellWithIdentifier:identifier fromParentCell:_rootCell];
    BOOL folded = [_dataSource mindmapView:self isItemFolded:identifier];
    [cellToUpdate setFolded:folded];

    NSRect visibleRect = [self visibleRect];
    BOOL cellVisible = NO;
    if (NSIntersectsRect(visibleRect, cellToUpdate.frame)) {
        cellVisible = YES;
    }

    if (cellVisible) {
        NSPoint cellOrigin = cellToUpdate.origin;
        NSPoint visibleOrigin = visibleRect.origin;
        NSSize distFromVisibleRect = NewSize(cellOrigin.x - visibleOrigin.x, cellOrigin.y - visibleOrigin.y);

        [self updateCanvasSize];
        QMCell *const newCell = [_cellSelector cellWithIdentifier:identifier fromParentCell:_rootCell];

        NSPoint newCellOrigin = newCell.origin;
        NSPoint newVisibleRectOrigin = NewPoint(newCellOrigin.x - distFromVisibleRect.width, newCellOrigin.y - distFromVisibleRect.height);

        // [self scrollPoint:newVisibleRectOrigin] animates the scrolling, we don't want that
        NSPoint newVisibleRectOriginInClipView = [self convertPoint:newVisibleRectOrigin toView:self.superview];
        [self.enclosingScrollView.contentView setBoundsOrigin:newVisibleRectOriginInClipView];
        [self setNeedsDisplay:YES];

        return;
    }

    [self updateCanvasSize];
    QMCell *const newCell = [_cellSelector cellWithIdentifier:identifier fromParentCell:_rootCell];

    [self scrollRectToVisible:newCell.familyFrame];
    [self scrollRectToVisible:newCell.frame];

    [self setNeedsDisplay:YES];
}

- (void)updateCellFamilyForRemovalWithIdentifier:(id)identifier {
    log4Debug(@"jo");
    NSArray *idArray = [self allChildrenIdentifierOfIdentifier:identifier];

    QMCell *parentCell = [_cellSelector cellWithIdentifier:identifier fromParentCell:_rootCell];
    QMCell *cellToDel;
    if (idArray.count == 0) {
        cellToDel = parentCell.children.lastObject;
    } else {
        for (QMCell *cell in parentCell.children) {
            if (![idArray containsObject:cell.identifier]) {
                cellToDel = cell;
                break;
            }
        }
    }

    [parentCell removeChild:cellToDel];

    [self updateCanvasSize];
    [self setNeedsDisplay:YES];
}

- (void)updateLeftCellFamilyForRemovalWithIdentifier:(id)identifier {
    log4Debug(@"jo");
    NSArray *idArray = [self leftChildrenIdentifierOfRootCell];

    QMCell *cellToDel;
    if (idArray.count == 0) {
        cellToDel = [_rootCell.leftChildren lastObject];
    } else {
        for (QMCell *cell in _rootCell.leftChildren) {
            if (![idArray containsObject:cell.identifier]) {
                cellToDel = cell;
                break;
            }
        }
    }

    [_rootCell removeChild:cellToDel];

    [self updateCanvasSize];
    [self setNeedsDisplay:YES];
}

/*
This should have been tested property, but since we know that it uses updateCellFamilyForInsertionWithIdentifier,
we only test the begin edit part. We are being to lazy here...
 */
- (void)updateCellFamily:(id)parentId forNewCell:(id)childId {
    [self updateCellFamilyForInsertionWithIdentifier:parentId];
    QMCell *cellToEdit = [_cellSelector cellWithIdentifier:childId fromParentCell:_rootCell];

    [_cellStateManager clearSelection];
    [_cellStateManager addCellToSelection:cellToEdit modifier:0];
    [self editCell:cellToEdit];
}

/*
This should have been tested property, but since we know that it uses updateCellFamilyForInsertionWithIdentifier,
we only test the begin edit part... We are being to lazy here...
 */
- (void)updateLeftCellFamily:(id)parentId forNewCell:(id)childId {
    [self updateLeftCellFamilyForInsertionWithIdentifier:parentId];
    QMCell *cellToEdit = [_cellSelector cellWithIdentifier:childId fromParentCell:_rootCell];

    [_cellStateManager clearSelection];
    [_cellStateManager addCellToSelection:cellToEdit modifier:0];
    [self editCell:cellToEdit];
}

- (void)updateCellFamilyForInsertionWithIdentifier:(id)parentId {
    NSArray *idArray = [self leftChildrenIdentifierOfIdentifier:parentId];
    QMCell *parentCell = [_cellSelector cellWithIdentifier:parentId fromParentCell:_rootCell];
    NSUInteger maxIndex = [idArray count] - 1;

    __block NSUInteger indexToInsert;
    __block id itemToInsert;

    if (parentCell.countOfChildren == 0) {
        indexToInsert = 0;
        itemToInsert = [idArray lastObject];
    } else {
        [idArray enumerateObjectsUsingBlock:^(id item, NSUInteger index, BOOL *stop) {
            if (index == maxIndex) {
                indexToInsert = index;
                itemToInsert = item;
                *stop = YES;
                return;
            }

            if ([[parentCell objectInChildrenAtIndex:index] identifier] != item) {
                indexToInsert = index;
                itemToInsert = item;
                *stop = YES;
                return;
            }
        }];
    }

    const BOOL parentIsLeft = [_dataSource mindmapView:self isItemLeft:parentId];

    QMCell *cellToInsert = [[QMCell alloc] initWithView:self];
    cellToInsert.left = parentIsLeft;
    [self fillCellPropertiesWithIdentifier:itemToInsert cell:cellToInsert];
    [self fillAllChildrenWithIdentifier:itemToInsert cell:cellToInsert];

    [parentCell insertObject:cellToInsert inChildrenAtIndex:indexToInsert];

    [self updateCanvasSize];
    [self setNeedsDisplay:YES];
}

- (void)updateLeftCellFamilyForInsertionWithIdentifier:(id)identifier {
    NSArray *leftIdArray = [self leftChildrenIdentifierOfRootCell];

    NSUInteger maxIndex = [leftIdArray count] - 1;

    __block NSUInteger indexToInsert;
    __block id itemToInsert;

    if (_rootCell.countOfChildren == 0) {
        indexToInsert = 0;
        itemToInsert = [leftIdArray lastObject];
    } else {
        [leftIdArray enumerateObjectsUsingBlock:^(id item, NSUInteger index, BOOL *stop) {
            if (index == maxIndex) {
                indexToInsert = index;
                itemToInsert = item;
                *stop = YES;
                return;
            }

            if ([[_rootCell objectInLeftChildrenAtIndex:index] identifier] != item) {
                indexToInsert = index;
                itemToInsert = item;
                *stop = YES;
                return;
            }
        }];
    }

    QMCell *cellToInsert = [[QMCell alloc] initWithView:self];
    cellToInsert.left = YES;

    [self fillCellPropertiesWithIdentifier:itemToInsert cell:cellToInsert];
    [self fillAllChildrenWithIdentifier:itemToInsert cell:cellToInsert];

    [_rootCell insertObject:cellToInsert inLeftChildrenAtIndex:indexToInsert];

    [self updateCanvasSize];
    [self setNeedsDisplay:YES];
}

- (void)initMindmapViewWithDataSource:(id <QMMindmapViewDataSource>)aDataSource {
    _dataSource = aDataSource;

    [self populateCellWithParent:nil item:nil];
    [self registerForDraggedTypes:@[qNodeUti]];

    NSSize parentSize = self.superview.frame.size;

    [self setFrameSize:[self scaledBoundsSizeWithParentSize:parentSize]];
    [self scrollToCenter];
    [self setNeedsDisplay:YES];
}

#pragma mark QMCellEditorDelegate
- (void)editingEndedWithString:(NSAttributedString *)newAttrStr forCell:(QMCell *)editedCell byChar:(unichar)character {
    id identifier = editedCell.identifier;

    [_dataSource mindmapView:self editingEndedForItem:identifier];

    NSString *const newString = [newAttrStr string];
    NSFont *const newFont = [newAttrStr fontOfTheBeginning];
    NSFont *oldFont = editedCell.font;

    BOOL stringModified = ![newString isEqualToString:editedCell.stringValue];
    BOOL fontModified;

    if (oldFont == nil) {
        fontModified = ![newFont isEqual:[_settings settingForKey:qSettingDefaultFont]];
    } else {
        fontModified = ![newFont isEqual:oldFont];
    }

    if (stringModified) {
        [_dataSource mindmapView:self setStringValue:newString ofItem:identifier];
    }

    if (fontModified) {
        [_dataSource mindmapView:self setFont:newFont ofItems:[[NSArray alloc] initWithObjects:identifier, nil]];
    }
}

- (void)editingCancelledWithString:(NSAttributedString *)newAttrStr forCell:(QMCell *)editedCell {
    [_cellStateManager clearSelection];

    [_dataSource mindmapView:self editingCancelledForItem:editedCell.identifier withAttrString:newAttrStr];
}

#pragma mark NSDraggingSource
- (BOOL)ignoreModifierKeysForDraggingSession:(NSDraggingSession *)session {
    return NO;
}

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context {
    return NSDragOperationEvery;
}

#pragma mark NSDraggingDestination
- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender {
    NSPoint currentMousePosition = [self convertPoint:[sender draggingLocation] fromView:nil];

    QMCell *oldDragTargetCell = _cellStateManager.dragTargetCell;
    QMCell *newDragTargetCell = [_cellSelector cellContainingPoint:currentMousePosition inCell:_rootCell];

    if (oldDragTargetCell != newDragTargetCell) {
        oldDragTargetCell.dragRegion = QMCellRegionNone;

        // We don't do the following, since we scroll during dragging
        //[self displayRect:oldDragTargetCell.nodeCellFrame];
        [self setNeedsDisplay:YES];
    }

    _cellStateManager.dragTargetCell = newDragTargetCell;
    if (newDragTargetCell != nil && ![_cellStateManager cellIsBeingDragged:newDragTargetCell]) {
        newDragTargetCell.dragRegion = [_cellLayoutManager regionOfCell:newDragTargetCell atPoint:currentMousePosition];
        [self displayRect:NewRectWithOriginAndSize(newDragTargetCell.origin, newDragTargetCell.size)];
    }

    return [sender draggingSourceOperationMask];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender {
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    NSPasteboard *pasteboard = [sender draggingPasteboard];

    // As of now we only accept our own Node as drag & drop item
    if ([[pasteboard types] containsObject:qNodeUti] == NO) {
        return NO;
    }

    if ([sender draggingSource] != self) {
        return NO;
    }

    // we are in the same view, the only supported mode as of now
    QMCell *dragTargetCell = _cellStateManager.dragTargetCell;
    if (dragTargetCell == nil) {
        return NO;
    }

    if ([_cellStateManager cellIsBeingDragged:dragTargetCell]) {
        return NO;
    }

    if ([_cellStateManager cellIsBeingDragged:_rootCell]) {
        return NO;
    }

    NSArray *draggedCells = _cellStateManager.draggedCells;
    NSMutableArray *draggedItems = [[NSMutableArray alloc] initWithCapacity:[draggedCells count]];
    for (QMCell *cell in draggedCells) {
        [draggedItems addObject:cell.identifier];
    }

    if ([dragTargetCell isFolded]) {
        [_dataSource mindmapView:self toggleFoldingForItem:dragTargetCell.identifier];
    }

    BOOL isCopying = [self dragIsCopying:[sender draggingSourceOperationMask]];
    if (isCopying) {
        [_dataSource mindmapView:self copyItems:draggedItems toItem:dragTargetCell.identifier inDirection:[self directionFromCellRegion:dragTargetCell.dragRegion]];
    } else {
        [_dataSource mindmapView:self moveItems:draggedItems toItem:dragTargetCell.identifier inDirection:[self directionFromCellRegion:dragTargetCell.dragRegion]];
    }

    dragTargetCell.dragRegion = QMCellRegionNone;
    [self setNeedsDisplay:YES];

    return YES;
}

- (void)draggingEnded:(id <NSDraggingInfo>)sender {
    /**
    * As described in -doMouseUp:, we get out of the mouse-track loop when a drag session is started. Therefore, we have
    * to end the mouse-track loop by setting _keepMouseTrackOn.
    */

    [self clearMouseTrackLoopFlags];

    [_cellStateManager clearCellsForDrag];
}

#pragma mark NSResponder
- (void)keyDown:(NSEvent *)theEvent {
    // [super keyDown:] cause the app to beep since the super does not implement it

    NSArray *selectedCells = [_cellStateManager selectedCells];
    if ([selectedCells count] > 1) {
        return;
    }

    unichar keyChar = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
    NSUInteger modifierFlags = [theEvent modifierFlags];
    BOOL commandKey = modifier_check(modifierFlags, NSCommandKeyMask);
    BOOL shiftKey = modifier_check(modifierFlags, NSShiftKeyMask);

    if (keyChar == qPageUpKeyCode || keyChar == qPageDownKeyCode) {
        [self scrollViewOnePageAccordingToKey:keyChar];
        return;
    }

    if (modifierFlags & NSNumericPadKeyMask) {
        [self interpretKeyEvents:@[theEvent]];
        return;
    }

    BOOL hasSelectedCells = [_cellStateManager hasSelectedCells];
    QMCell *selCell = hasSelectedCells ? [selectedCells lastObject] : _rootCell;
    id selIdentifier = selCell.identifier;

    if ([[_settings settingForKey:qSettingNewChildNodeChars] characterIsMember:keyChar]) {
        [self insertChild];
        return;
    }

    if ([[_settings settingForKey:qSettingNewLeftChildNodeChars] characterIsMember:keyChar]) {
        [self insertLeftChild];
        return;
    }

    if (!hasSelectedCells) {
        return;
    }

    if ([[_settings settingForKey:qSettingEditSelectedNodeChars] characterIsMember:keyChar]
            && !commandKey
            && !shiftKey) {

        [self editCell:selCell];

        return;
    }

    if (selCell.isRoot) {
        return;
    }

    if ([[_settings settingForKey:qSettingFoldingChars] characterIsMember:keyChar]) {
        [_dataSource mindmapView:self toggleFoldingForItem:selIdentifier];
        return;
    }

    if ([[_settings settingForKey:qSettingNewSiblingNodeChars] characterIsMember:keyChar]) {

        if (!commandKey) {
            return;
        }

        if (shiftKey) {
            [self insertPreviousSibling];
            return;
        }

        [self insertNextSibling];
        return;
    }
}

- (void)mouseDown:(NSEvent *)event {
    /**
    * We're using the mouse-track loop approach to handle mouse dragging and mouse up events
    * because of the issue #6:
    *
    * https://github.com/qvacua/qmind/issues/6
    */

    /**
    * Single click event always precede the double click event, i.e. when the user double-clicks, then:
    *
    * - mouseDown event with clickCount = 1
    * - mouseDown event with clickCount = 2
    */

    NSInteger clickCount = [event clickCount];
    NSPoint clickLocation = [self convertPoint:[event locationInWindow] fromView:nil];
    NSUInteger modifier = [event modifierFlags];

    /**
    * DUMMY code to track down the bug...
    */
    logPoint4Debug(@"location in view", clickLocation);

    logSize4Debug(@"current scale of the parent view:", [self convertSize:NewSize(1, 1) toView:nil]);
    DummyView *v = [[DummyView alloc] initWithFrame:NewRect(1000, 500, 100, 100)];
    logRect4Debug(@"frame before adding:", [v frame]);
    logSize4Debug(@"scale before adding", [v convertSize:NewSize(1,1) toView:nil]);
    [self addSubview:v];
    logSize4Debug(@"scale adding", [v convertSize:NewSize(1,1) toView:nil]);
    logRect4Debug(@"frame after adding:", [v frame]);

    return;

    if (clickCount == 1) {

        [self handleSingleMouseDown:clickLocation modifier:modifier];

    } else if (clickCount == 2) {
        if (modifier_check(modifier, NSCommandKeyMask) || modifier_check(modifier, NSShiftKeyMask)) {
            return;
        }

        if (![_cellStateManager hasSelectedCells]) {
            return;
        }

        NSArray *selCells = [_cellStateManager selectedCells];
        if ([selCells count] > 1) {
            return;
        }

        [_dataSource mindmapView:self toggleFoldingForItem:[selCells.lastObject identifier]];
    }

    NSEvent *currentEvent;
    _keepMouseTrackOn = YES;
    while (_keepMouseTrackOn) {
        currentEvent = [self.window nextEventMatchingMask:NSLeftMouseUpMask | NSLeftMouseDraggedMask];

        switch ([currentEvent type]) {
            case NSLeftMouseDragged:
                [self doMouseDragged:currentEvent];
                break;

            case NSLeftMouseUp:
                [[self enclosingScrollView] setDocumentCursor:[NSCursor arrowCursor]];
                [self doMouseUp:currentEvent];

                [self clearMouseTrackLoopFlags];
                break;

            default:
                break;
        }
    }
}

- (void)scrollWheel:(NSEvent *)event {
    NSUInteger modifierFlags = [event modifierFlags];
    BOOL commandKey = modifier_check(modifierFlags, NSCommandKeyMask);

    if (!commandKey) {
        [super scrollWheel:event];
        return;
    }

    if ([_cellEditor isEditing]) {
        return;
    }

    CGFloat factor = 1.0 + sign([event deltaY]) * qZoomScrollWheelStep;
    NSPoint locInView = [self convertPoint:[event locationInWindow] fromView:nil];

    [self zoomByFactor:factor withFixedPoint:locInView];
}

- (void)magnifyWithEvent:(NSEvent *)event {
    if ([_cellEditor isEditing]) {
        return;
    }

    CGFloat factor = 1.0 + [event magnification];
    NSPoint locInView = [self convertPoint:[event locationInWindow] fromView:nil];

    [self zoomByFactor:factor withFixedPoint:locInView];
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (BOOL)becomeFirstResponder {
    return YES;
}

- (void)moveRight:(id)sender {
    NSArray *selectedCells = [_cellStateManager selectedCells];
    if ([selectedCells count] != 1) {
        return;
    }

    QMCell *selCell = selectedCells[0];
    if ([selCell isLeft]) {
        [self replaceSelectionWithCellAndRedisplay:selCell.parent];
        return;
    }

    if ([selCell isLeaf]) {
        return;
    }

    if ([selCell isFolded]) {
        [_dataSource mindmapView:self toggleFoldingForItem:selCell.identifier];
    }

    NSArray *children = selCell.children;
    if ([selCell countOfChildren] == 1) {
        [self replaceSelectionWithCellAndRedisplay:children[0]];
        return;
    }

    QMCell *chosenChildCell = [self verticallyNearestCellFromCells:children withCell:selCell];
    [self replaceSelectionWithCellAndRedisplay:chosenChildCell];
}

- (void)moveLeft:(id)sender {
    NSArray *selectedCells = [_cellStateManager selectedCells];
    if ([selectedCells count] != 1) {
        return;
    }

    QMCell *selCell = selectedCells[0];
    BOOL selCellIsRoot = [selCell isRoot];
    NSArray *children = selCellIsRoot ? _rootCell.leftChildren : selCell.children;

    if ([selCell isLeft] || selCellIsRoot) {
        if ([children count] == 0) {
            return;
        }

        if ([selCell isFolded]) {
            [_dataSource mindmapView:self toggleFoldingForItem:selCell.identifier];
        }

        if ([children count] == 1) {
            [self replaceSelectionWithCellAndRedisplay:children[0]];
            return;
        }

        QMCell *chosenChildCell = [self verticallyNearestCellFromCells:children withCell:selCell];
        [self replaceSelectionWithCellAndRedisplay:chosenChildCell];
        return;
    }

    [self replaceSelectionWithCellAndRedisplay:selCell.parent];
}

- (void)moveDown:(id)sender {
    NSUInteger (^nextLevelIndexOperation)(NSUInteger) = ^(NSUInteger givenIndex) {
        return givenIndex + 1;
    };

    QMCell *(^positionOfCell)(NSArray *) = ^(NSArray *cells) {
        return [cells lastObject];
    };

    QMCell *(^cellSelector)(NSArray *) = ^(NSArray *cells) {
        return cells[0];
    };

    [self moveUpOrDownUsingLevelIndexOperation:nextLevelIndexOperation positionOfCell:positionOfCell cellSelector:cellSelector];
}

- (void)moveUp:(id)sender {
    NSUInteger (^nextLevelIndexOperation)(NSUInteger) = ^(NSUInteger givenIndex) {
        return givenIndex - 1;
    };

    QMCell *(^positionOfCell)(NSArray *) = ^(NSArray *cells) {
        return cells[0];
    };

    QMCell *(^cellSelector)(NSArray *) = ^(NSArray *cells) {
        return [cells lastObject];
    };

    [self moveUpOrDownUsingLevelIndexOperation:nextLevelIndexOperation positionOfCell:positionOfCell cellSelector:cellSelector];
}

#pragma mark NSView
- (id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [[TBContext sharedContext] autowireSeed:self];

        _cellStateManager = [[QMCellStateManager alloc] init];
        _cellEditor = [[QMCellEditor alloc] init];
        _cellEditor.view = self;
        _cellEditor.delegate = self;
    }

    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    [_rootCell drawRect:dirtyRect];
}

- (BOOL)isFlipped {
    return YES;
}

#pragma mark Private
- (void)clearMouseTrackLoopFlags {
    _dragging = NO;
    _keepMouseTrackOn = NO;
}

- (void)doMouseDragged:(NSEvent *)event {
    // drag scrolling
    QMCell *mouseDownHitCell = _cellStateManager.mouseDownHitCell;

    if (mouseDownHitCell == nil) {
        log4Debug(@"starting to drag scroll");
        [[self enclosingScrollView] setDocumentCursor:[NSCursor closedHandCursor]];
        [self dragScrollViewWithEvent:event];

        return;
    }

    // already dragging cells
    if (_dragging) {
        [[self superview] autoscroll:event];
        return;
    }

    // starting to dragging cells
    log4Debug(@"starting to drag a cell");
    _dragging = YES;

    /**
    * The user can drag:
    * - selected cells
    * - a non-selected cell
    */
    NSArray *selCells = [_cellStateManager selectedCells];
    NSMutableArray *toBeDraggedCells = [[NSMutableArray alloc] init];
    if ([selCells containsObject:mouseDownHitCell]) {
        [toBeDraggedCells addObjectsFromArray:selCells];
    } else {
        [toBeDraggedCells addObject:mouseDownHitCell];
    }

    [_dataSource mindmapView:self prepareDragAndDropWithCells:toBeDraggedCells];

    NSPoint origin = [self convertPoint:NewPoint(mouseDownHitCell.origin.x, mouseDownHitCell.origin.y + mouseDownHitCell.size.height)
                               fromView:self];

    [self dragImage:[self dragImageForHitCell:mouseDownHitCell numberOfSelectedCells:[toBeDraggedCells count]]
                 at:origin
             offset:NSZeroSize
              event:event
         pasteboard:[NSPasteboard pasteboardWithName:NSDragPboard]
             source:self
          slideBack:YES];
}

- (void)doMouseUp:(NSEvent *)event {
    /**
    * NOTE: -mouseUp does not get invoked when a drag and drop session is initiated in -mouseDragged:,
    * even when we use the mouse-track loop approach, after a drag session started and ended.
    */

    NSInteger clickCount = [event clickCount];

    if (clickCount == 1) {
        [self handleSingleMouseUp];
    }

    _cellStateManager.mouseDownHitCell = nil;
}

- (QMDirection)directionFromCellRegion:(QMCellRegion)cellRegion {
    switch (cellRegion) {
        case QMCellRegionNone:
            return QMDirectionNone;
        case QMCellRegionEast:
            return QMDirectionRight;
        case QMCellRegionWest:
            return QMDirectionLeft;
        case QMCellRegionSouth:
            return QMDirectionBottom;
        case QMCellRegionNorth:
            return QMDirectionTop;
    }

    return QMDirectionNone;
}

- (BOOL)dragIsCopying:(NSDragOperation)dragOperationMask {
    // strangely, when no modifier key is pressed, ie moving, NSDragOperationCopy and NSDragOperationMove are set
    // if copying, ie option pressed, only NSDragOperationCopy is set
    if (dragOperationMask & NSDragOperationCopy && dragOperationMask & NSDragOperationMove) {
        return NO;
    }

    return YES;
}

- (void)dragScrollViewWithEvent:(NSEvent *)theEvent {
    const CGFloat dx = [theEvent deltaX];
    const CGFloat dy = [theEvent deltaY];

    NSClipView *const clipView = [[self enclosingScrollView] contentView];

    NSPoint oldScrollPt = [clipView bounds].origin;
    NSPoint newScrollPt = NewPoint(oldScrollPt.x - dx, oldScrollPt.y - dy);

    [clipView setBoundsOrigin:newScrollPt];
}

- (NSImage *)dragImageForHitCell:(QMCell *)hitCell numberOfSelectedCells:(NSUInteger)numberOfSelCells {
    NSImage *hitCellImg = [hitCell image];

    CGFloat margin = 2.5;
    CGFloat width = qSizeOfBadge.width + hitCell.size.width + margin;
    CGFloat height = MAX(qSizeOfBadge.height, hitCell.size.height);
    NSSize sizeOfFinalImg = NewSize(width, height);

    NSImage *badgeImg = [[NSImage alloc] initWithSize:sizeOfFinalImg];
    [badgeImg lockFocusFlipped:NO];

    [hitCellImg drawAtPoint:NewPoint(qSizeOfBadge.width + margin, sizeOfFinalImg.height - [hitCellImg size].height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:0.65];
    [_uiDrawer drawBadgeWithNumber:numberOfSelCells atPoint:NewPoint(4, height - 4 - qSizeOfBadge.height)];

    NSDictionary *fontAttr = @{
            NSFontAttributeName : [NSFont fontWithName:@"Helvetica" size:12],
            NSForegroundColorAttributeName : [NSColor whiteColor]
    };
    NSString *numberStr = numberOfSelCells > 9 ? @"..." : [@(numberOfSelCells) stringValue];
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:numberStr attributes:fontAttr];
    [str drawAtPoint:NewPoint(11, height - 4 - qSizeOfBadge.height + 3)];

    [badgeImg unlockFocus];

#ifdef DEBUG
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithData:[badgeImg TIFFRepresentation]];
    NSData *data = [rep representationUsingType:NSPNGFileType properties:nil];
    [data writeToFile:@"/tmp/img.png" atomically:NO];
#endif

    return badgeImg;
}

- (void)handleSingleMouseDown:(NSPoint)clickLocation modifier:(NSUInteger)modifier {
    _mouseDownModifier = modifier;
    QMCell *mouseDownHitCell = [_cellSelector cellContainingPoint:clickLocation inCell:_rootCell];
    _cellStateManager.mouseDownHitCell = mouseDownHitCell;

    [self setNeedsDisplay:YES];
}

- (void)handleSingleMouseUp {
    BOOL mouseDownCommandKey = modifier_check(_mouseDownModifier, NSCommandKeyMask);;
    BOOL mouseDownShiftKey = modifier_check(_mouseDownModifier, NSShiftKeyMask);;

    QMCell *mouseDownHitCell = _cellStateManager.mouseDownHitCell;
    if (mouseDownHitCell == nil) {
        /**
        * Even if there is no modifier pressed, we get here modifier == 256. Thus, we check whether we have the
        * relevant modifiers not pressed.
        */
        if (!mouseDownShiftKey && !mouseDownCommandKey) {
            [_cellStateManager clearSelection];
            [self setNeedsDisplay:YES];
        }

        return;
    }

    if (mouseDownShiftKey || mouseDownCommandKey) {
        if ([_cellStateManager cellIsSelected:mouseDownHitCell]) {
            [_cellStateManager removeCellFromSelection:mouseDownHitCell modifier:_mouseDownModifier];
            [self setNeedsDisplay:YES];

            return;
        }

        [_cellStateManager addCellToSelection:mouseDownHitCell modifier:_mouseDownModifier];
        [self setNeedsDisplay:YES];

        return;
    }

    // No relevant modifier keys pressed
    [_cellStateManager clearSelection];
    [_cellStateManager addCellToSelection:mouseDownHitCell modifier:0];

    [self setNeedsDisplay:YES];
}

- (NSPoint)rootCellOriginForParentSize:(NSSize)parentSize {
    return NewPoint(parentSize.width, parentSize.height);
}

- (void)zoomByFactor:(CGFloat)factor withFixedPoint:(NSPoint)locInView {
    if ([_cellEditor isEditing]) {
        return;
    }

    NSSize oldScale = [self convertSize:qUnitSize toView:nil];
    _newScale = NSMakeSize(oldScale.width * factor, oldScale.height * factor);

    if (_newScale.width < qMinZoomFactor) {
        return;
    }

    if (_newScale.width > qMaxZoomFactor) {
        return;
    }

    NSClipView *clipView = self.enclosingScrollView.contentView;
    NSSize clipViewFrameSize = clipView.frame.size;

    NSSize oldParentSize = [self convertSize:clipViewFrameSize fromView:clipView];
    NSPoint oldMapOrigin = [self rootCellOriginForParentSize:oldParentSize];

    NSPoint oldScrollPtInClipView = clipView.bounds.origin;
    NSPoint oldScrollPt = [self convertPoint:oldScrollPtInClipView fromView:clipView];
    NSSize oldDist = NewSize(locInView.x - oldScrollPt.x, locInView.y - oldScrollPt.y);

    [self resetScaling];
    [self scaleUnitSquareToSize:_newScale];

    NSSize newParentSize = [self convertSize:clipViewFrameSize fromView:clipView];
    NSPoint newMapOrigin = [self rootCellOriginForParentSize:newParentSize];
    NSSize deltaMapOrigin = NewSize(oldMapOrigin.x - newMapOrigin.x, oldMapOrigin.y - newMapOrigin.y);

    NSPoint newScrollPt = NewPoint(locInView.x - deltaMapOrigin.width - oldDist.width / factor, locInView.y - deltaMapOrigin.height - oldDist.height / factor);

    [self updateCanvasSize];
    [self scrollPoint:newScrollPt];
    [self setNeedsDisplay:YES];
}

- (void)resetScaling {
    [self scaleUnitSquareToSize:[self convertSize:qUnitSize fromView:nil]];
}

- (NSSize)scaledBoundsSizeWithParentSize:(NSSize)unconvertedParentSize {
    NSSize rootFamilySize = _rootCell.familySize;

    NSSize parentSize = [self convertSize:unconvertedParentSize fromView:nil];
    NSSize newBoundsSize = NewSize(rootFamilySize.width + 2 * parentSize.width, rootFamilySize.height + 2 * parentSize.height);
    NSPoint newMapOrigin = [self rootCellOriginForParentSize:parentSize];
    NSSize newBoundsSizeInParent = [self convertSize:newBoundsSize toView:nil];

    // TODO: maybe we only have to shift the origins of all cells and their lines.
    _rootCell.familyOrigin = newMapOrigin;
    [_rootCell computeGeometry];

    return newBoundsSizeInParent;
}

- (NSArray *)allChildrenIdentifierOfIdentifier:(id)identifier {
    NSMutableArray *idArray = [[NSMutableArray alloc] init];
    BOOL parentIsRoot = (identifier == _rootCell.identifier);

    if (parentIsRoot) {
        NSUInteger countOfChildren = (NSUInteger) [_dataSource mindmapView:self numberOfChildrenOfItem:nil];
        for (int i = 0; i < countOfChildren; i++) {
            [idArray addObject:[_dataSource mindmapView:self child:i ofItem:nil]];
        }

        NSUInteger countOfLeftChildren = (NSUInteger) [_dataSource mindmapView:self numberOfLeftChildrenOfItem:nil];
        for (int i = 0; i < countOfLeftChildren; i++) {
            [idArray addObject:[_dataSource mindmapView:self leftChild:i ofItem:nil]];
        }
    } else {
        NSUInteger countOfChildren = (NSUInteger) [_dataSource mindmapView:self numberOfChildrenOfItem:identifier];
        for (int i = 0; i < countOfChildren; i++) {
            [idArray addObject:[_dataSource mindmapView:self child:i ofItem:identifier]];
        }
    }

    return idArray;
}

- (NSArray *)leftChildrenIdentifierOfIdentifier:(id)identifier {
    NSMutableArray *idArray = [[NSMutableArray alloc] init];

    NSUInteger countOfChildren = (NSUInteger) [_dataSource mindmapView:self numberOfChildrenOfItem:identifier];
    for (int i = 0; i < countOfChildren; i++) {
        [idArray addObject:[_dataSource mindmapView:self child:i ofItem:identifier]];
    }

    return idArray;
}

- (NSArray *)leftChildrenIdentifierOfRootCell {
    NSMutableArray *idArray = [[NSMutableArray alloc] init];

    NSUInteger countOfChildren = (NSUInteger) [_dataSource mindmapView:self numberOfLeftChildrenOfItem:nil];
    for (int i = 0; i < countOfChildren; i++) {
        [idArray addObject:[_dataSource mindmapView:self leftChild:i ofItem:nil]];
    }

    return idArray;
}

- (void)editCell:(QMCell *)cellToEdit {
    [_cellEditor beginEditStringValueForCell:cellToEdit];
}

- (void)fillCellPropertiesWithIdentifier:(id)givenItem cell:(QMCell *)cell {
    cell.identifier = [_dataSource mindmapView:self identifierForItem:givenItem];
    cell.stringValue = [_dataSource mindmapView:self stringValueOfItem:givenItem];
    cell.font = [_dataSource mindmapView:self fontOfItem:givenItem];
    cell.folded = [_dataSource mindmapView:self isItemFolded:givenItem];

    [self fillIconsOfCell:cell];
}

- (void)fillIconsOfCell:(QMCell *)cell {
    NSArray *iconsOfItem = [_dataSource mindmapView:self iconsOfItem:cell.identifier];
    for (id icon in iconsOfItem) {
        [cell insertObject:icon inIconsAtIndex:cell.icons.count];
    }
}

- (void)fillAllChildrenWithIdentifier:(id)givenItem cell:(QMCell *)cell {
    NSInteger childrenCount = [_dataSource mindmapView:self numberOfChildrenOfItem:givenItem];
    for (NSUInteger i = 0; i < childrenCount; i++) {
        id childItem = [_dataSource mindmapView:self child:i ofItem:givenItem];
        [self populateCellWithParent:cell item:childItem];
    }

    if (cell.isRoot) {
        NSInteger leftChildrenCount = [_dataSource mindmapView:self numberOfLeftChildrenOfItem:givenItem];
        for (NSUInteger i = 0; i < leftChildrenCount; i++) {
            id childItem = [_dataSource mindmapView:self leftChild:i ofItem:givenItem];
            [self populateCellWithParent:cell item:childItem];
        }
    }
}

- (void)populateCellWithParent:(QMCell *)parentCell item:(id)itemOfParent {
    QMCell *cell;

    if (itemOfParent == nil) {
        _rootCell = [[QMRootCell alloc] initWithView:self];
        cell = _rootCell;
    } else {
        cell = [[QMCell alloc] initWithView:self];

        if (parentCell.isRoot) {
            BOOL isItemLeft = [_dataSource mindmapView:self isItemLeft:itemOfParent];
            if (isItemLeft) {
                [(QMRootCell *) parentCell addObjectInLeftChildren:cell];
            } else {
                [parentCell addObjectInChildren:cell];
            }
        } else {
            [parentCell addObjectInChildren:cell];
        }
    }

    [self fillCellPropertiesWithIdentifier:itemOfParent cell:cell];
    [self fillAllChildrenWithIdentifier:itemOfParent cell:cell];
}

- (void)scrollToCenter {
    NSClipView *const clipView = self.enclosingScrollView.contentView;
    NSSize parentSize = clipView.frame.size;
    NSSize parentSizeInView = [self convertSize:parentSize fromView:nil];

    NSPoint rootOrigin = _rootCell.origin;
    NSSize rootSize = _rootCell.size;

    NSPoint scrollPt = NewPoint(rootOrigin.x - parentSizeInView.width / 2 + rootSize.width / 2, rootOrigin.y - parentSizeInView.height / 2 + rootSize.height / 2);
    [self scrollPoint:scrollPt];
}

- (void)scrollViewOnePageAccordingToKey:(unichar)keyChar {
    const NSRect visibleRect = [self visibleRect];
    const CGFloat verticalBuffer = 3 * [[self enclosingScrollView] verticalLineScroll];

    if (keyChar == qPageUpKeyCode) {
        [self scrollRectToVisible:NSOffsetRect(visibleRect, 0, -visibleRect.size.height + verticalBuffer)];
        return;
    }

    if (keyChar == qPageDownKeyCode) {
        [self scrollRectToVisible:NSOffsetRect(visibleRect, 0, visibleRect.size.height - verticalBuffer)];
        return;
    }
}

- (void)replaceSelectionWithCellAndRedisplay:(QMCell *)cell {
    [_cellStateManager clearSelection];
    [_cellStateManager addCellToSelection:cell modifier:0];
    [self scrollToMakeVisibleCell:cell];
    [self setNeedsDisplay:YES];
}

- (QMCell *)verticallyNearestCellFromCells:(NSArray *)cellsToChooseFrom withCell:(QMCell *)cellToCompare {
    QMCell *chosenChildCell = cellsToChooseFrom[0];
    CGFloat midYToCompare = cellToCompare.middlePoint.y;
    CGFloat minVertDist = MAX_CGFLOAT;

    for (QMCell *childCell in cellsToChooseFrom) {
        CGFloat vertDist = ABS(childCell.middlePoint.y - midYToCompare);
        if (vertDist < minVertDist) {
            minVertDist = vertDist;
            chosenChildCell = childCell;
        }
    }

    return chosenChildCell;
}

- (void)moveUpOrDownUsingLevelIndexOperation:(NSUInteger (^)(NSUInteger))nextLevelIndexOperation
                              positionOfCell:(QMCell * (^)(NSArray *))positionOfCell
                                cellSelector:(QMCell * (^)(NSArray *))cellSelector {

    NSArray *selectedCells = [_cellStateManager selectedCells];
    if ([selectedCells count] != 1) {
        return;
    }

    QMCell *selCell = selectedCells[0];
    if ([selCell isRoot]) {
        return;
    }

    // case 1
    NSArray *containingArray = [selCell containingArray];
    if (positionOfCell(containingArray) != selCell) {
        [self replaceSelectionWithCellAndRedisplay:containingArray[nextLevelIndexOperation([selCell indexWithinParent])]];
        return;
    }

    QMCell *cellIterator = selCell.parent;
    QMCell *nextLevelRootCell = nil;
    while (cellIterator != _rootCell && nextLevelRootCell == nil) {
        if (positionOfCell([cellIterator containingArray]) == cellIterator) {
            cellIterator = cellIterator.parent;
            continue;
        }

        NSUInteger indexOfCell = [cellIterator indexWithinParent];
        nextLevelRootCell = [cellIterator containingArray][nextLevelIndexOperation(indexOfCell)];
    }

    // case 5
    if (cellIterator == _rootCell || nextLevelRootCell == nil) {
        return;
    }

    // case 2
    if ([nextLevelRootCell isFolded] || [nextLevelRootCell isLeaf]) {
        [self replaceSelectionWithCellAndRedisplay:nextLevelRootCell];
    }

    // case 3 and 4
    NSMutableArray *candidates = [[NSMutableArray alloc] init];
    cellIterator = nextLevelRootCell;
    do {
        [candidates addObject:cellIterator];
        if ([cellIterator isFolded] || [cellIterator isLeaf]) {
            break;
        } else {
            cellIterator = cellSelector(cellIterator.children);
        }
    } while (1);

    NSArray *possiblyOverlappingCandidates = [self horizontallyMostOverlappingCellFromCells:candidates withCell:selCell];
    if ([possiblyOverlappingCandidates count] > 0) {
        [candidates removeAllObjects];
        [candidates addObjectsFromArray:possiblyOverlappingCandidates];
    }

    QMCell *chosenCell = [self horizontallyNearestCellFromCells:candidates withCell:selCell];
    [self replaceSelectionWithCellAndRedisplay:chosenCell];
}

- (NSArray *)horizontallyMostOverlappingCellFromCells:(NSArray *)candidates withCell:(QMCell *)cellToCompare {
    NSMutableArray *result = [[NSMutableArray alloc] init];

    NSRect sourceFrame = cellToCompare.frame;
    CGFloat maxArea = 0;
    for (QMCell *candidate in candidates) {
        NSRect shiftedCandidateFrame = candidate.frame;
        shiftedCandidateFrame.origin.y = sourceFrame.origin.y;
        NSRect intersectionRect = NSIntersectionRect(shiftedCandidateFrame, sourceFrame);

        if (NSEqualRects(NSZeroRect, intersectionRect)) {
            continue;
        }

        CGFloat currentArea = area(intersectionRect);
        if (currentArea > maxArea) {
            maxArea = currentArea;
            [result removeAllObjects];
            [result addObject:candidate];
            continue;
        }

        if (currentArea == maxArea) {
            [result addObject:candidate];
        }
    }

    return result;
}

- (QMCell *)horizontallyNearestCellFromCells:(NSArray *)candidates withCell:(QMCell *)cellToCompare {
    CGFloat minDist = MAX_CGFLOAT;

    QMCell *chosenCell = candidates[0];
    for (QMCell *candidate in candidates) {
        CGFloat dist = [self horizontalDistanceFromCell:cellToCompare toCell:candidate];
        if (dist < minDist) {
            minDist = dist;
            chosenCell = candidate;
        }
    }

    return chosenCell;
}

- (CGFloat)horizontalDistanceFromCell:(QMCell *)sourceCell toCell:(QMCell *)targetCell {
    CGFloat sourceBegin = sourceCell.origin.x;
    CGFloat sourceEnd = sourceCell.origin.x + sourceCell.size.width;

    CGFloat targetBegin = targetCell.origin.x;
    CGFloat targetEnd = targetCell.origin.x + targetCell.size.width;

    CGFloat result = ABS(sourceBegin - targetBegin);
    result = MIN(result, ABS(sourceBegin - targetEnd));
    result = MIN(result, ABS(sourceEnd - targetBegin));
    return MIN(result, ABS(sourceEnd - targetEnd));
}

- (void)scrollToMakeVisibleCell:(QMCell *)cell {
    if (NSIntersectsRect([self visibleRect], cell.frame)) {
        return;
    }

    [self scrollRectToVisible:NewRectWithOrigin(cell.origin, 50, 50)];
}

@end
