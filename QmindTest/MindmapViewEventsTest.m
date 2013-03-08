/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import "QMBaseTestCase.h"
#import <Qkit/Qkit.h>
#import <TBCacao/TBCacao.h>
#import "QMCellStateManager.h"
#import "QMRootCell.h"
#import "QMCellSelector.h"
#import "QMBaseTestCase+Util.h"
#import "QMCellEditor.h"
#import "QMAppSettings.h"
#import "QMMindmapView.h"
#import "QMCacaoTestCase.h"
#import "QMMindmapViewDataSourceImpl.h"
#import "QMIcon.h"
#import "QMIconsPaneView.h"

@interface MindmapViewEventsTest : QMCacaoTestCase
@end

@implementation MindmapViewEventsTest {
    QMCellStateManager *stateManager;
    QMCellSelector *selector;
    QMCellEditor *editor;
    QMMindmapViewDataSourceImpl *dataSource;
    NSWindow *window;
    NSEvent *event;
    NSEvent *nextEvent;
    NSMenu *menu;

    QMRootCell *rootCell;

    QMMindmapView *view;
}

- (void)setUp {
    [super setUp];

    stateManager = [[QMCellStateManager alloc] init];
    selector = mock(QMCellSelector.class);
    event = mock(NSEvent.class);
    editor = mock([QMCellEditor class]);
    dataSource = mock([QMMindmapViewDataSourceImpl class]);
    window = mock([NSWindow class]);
    nextEvent = mock([NSEvent class]);
    menu = mock([NSMenu class]);

    view = [[QMMindmapView alloc] initWithFrame:NewRect(0, 0, 640, 480)];
    [view setMenu:menu];
    [view setInstanceVarTo:selector];
    [view setInstanceVarTo:stateManager];
    [view setInstanceVarTo:editor];
    [view setInstanceVarTo:dataSource implementingProtocol:@protocol(QMMindmapViewDataSource)];
    [view setInstanceVarTo:[self.context beanWithClass:[QMAppSettings class]]];
    [view setInstanceVarTo:window];

    rootCell = [self rootCellForTestWithView:view];

    [view setInstanceVarTo:rootCell];
}

- (void)testMenuForEventNotRightMouseDown {
    [given([event type]) willReturnUnsignedInteger:NSRightMouseDown + 1];

    assertThat([view menuForEvent:event], is(nilValue()));
}

- (void)testMenuForEventNoCellHit {
    [given([event type]) willReturnUnsignedInteger:NSRightMouseDown];
    [[given([selector cellContainingPoint:NewPoint(1, 2) inCell:anything()]) withMatcher:anything() forArgument:0] willReturn:nil];

    assertThat([view menuForEvent:event], is(nilValue()));
}

- (void)testMenuForEventHitText {
    [given([event type]) willReturnUnsignedInteger:NSRightMouseDown];
    [given([event locationInWindow]) willReturnPoint:NewPoint(3, 4)];
    [CELL(1) setTextOrigin:NewPoint(0, 470)];
    [[given([selector cellContainingPoint:NewPoint(1, 2) inCell:anything()]) withMatcher:anything() forArgument:0] willReturn:CELL(1)];

    assertThat([view menuForEvent:event], is(nilValue()));
}

- (void)testMenuForEventNoIcon {
    [given([event type]) willReturnUnsignedInteger:NSRightMouseDown];
    [given([event locationInWindow]) willReturnPoint:NewPoint(3, 4)];
    [CELL(1) setTextOrigin:NewPoint(100, 100)];
    [[given([selector cellContainingPoint:NewPoint(1, 2) inCell:anything()]) withMatcher:anything() forArgument:0] willReturn:CELL(1)];

    assertThat([view menuForEvent:event], is(nilValue()));
}

- (void)testMenuForEventNoIconHit {
    [given([event type]) willReturnUnsignedInteger:NSRightMouseDown];
    [given([event locationInWindow]) willReturnPoint:NewPoint(3, 4)];
    [CELL(1) setTextOrigin:NewPoint(100, 100)];
    [[given([selector cellContainingPoint:NewPoint(1, 2) inCell:anything()]) withMatcher:anything() forArgument:0] willReturn:CELL(1)];

    QMIcon *icon = [[QMIcon alloc] initWithCode:@"icon"];
    [CELL(1) addObjectInIcons:icon];
    icon.origin = NewPoint(100, 100);

    assertThat([view menuForEvent:event], is(nilValue()));
}

- (void)testMenuForEvent {
    [given([event type]) willReturnUnsignedInteger:NSRightMouseDown];
    [given([event locationInWindow]) willReturnPoint:NewPoint(3, 4)];
    [CELL(1) setTextOrigin:NewPoint(100, 100)];
    [[given([selector cellContainingPoint:NewPoint(1, 2) inCell:anything()]) withMatcher:anything() forArgument:0] willReturn:CELL(1)];

    QMIcon *icon = [[QMIcon alloc] initWithCode:@"icon"];
    [CELL(1) addObjectInIcons:icon];
    icon.origin = NewPoint(2, 470);

    assertThat([view menuForEvent:event], is(menu));
}

- (void)testMenuForEventDeleteIconAction {
    QMIcon *icon1 = [[QMIcon alloc] initWithCode:@"folder"];
    QMIcon *icon2 = [[QMIcon alloc] initWithCode:@"edit"];
    QMIcon *icon3 = [[QMIcon alloc] initWithCode:@"password"];

    QMCell *cell = CELL(1);
    [cell addObjectInIcons:icon1];
    [cell addObjectInIcons:icon2];
    [cell addObjectInIcons:icon3];

    NSMenuItem *menuItem = [[NSMenuItem alloc] init];
    [menuItem setTag:qDeleteIconMenuItemTag];

    NSMenu *menu = [[NSMenu alloc] init];
    [menu addItem:menuItem];
    [view setMenu:menu];

    [given([event type]) willReturnUnsignedInteger:NSRightMouseDown];
    [given([event locationInWindow]) willReturnPoint:NewPoint(3, 4)];

    [cell setTextOrigin:NewPoint(100, 100)];
    icon2.origin = NewPoint(2, 470);
    [[given([selector cellContainingPoint:NewPoint(1, 2) inCell:anything()]) withMatcher:anything() forArgument:0] willReturn:cell];

    [view menuForEvent:event];

    void (^blockAction)(id) = [menuItem blockAction];
    blockAction(self);

    [verify(dataSource) mindmapView:view deleteIconOfItem:cell.identifier atIndex:1];
}

- (void)testKeyDownForFolding {
    unichar key[] = { 0x20 };
    NSString *string = [NSString stringWithCharacters:key length:1];
    [given([event charactersIgnoringModifiers]) willReturn:string];
    [given([event modifierFlags]) willReturnUnsignedInteger:0];

    [view keyDown:event];
    [verifyCount(dataSource, never()) mindmapView:view toggleFoldingForItem:anything()];

    [stateManager addCellToSelection:rootCell modifier:0];
    [view keyDown:event];
    [verifyCount(dataSource, never()) mindmapView:view toggleFoldingForItem:anything()];

    [stateManager addCellToSelection:CELL(1) modifier:0];
    [stateManager addCellToSelection:CELL(2) modifier:NSCommandKeyMask];
    [view keyDown:event];
    [verifyCount(dataSource, never()) mindmapView:view toggleFoldingForItem:anything()];

    [stateManager addCellToSelection:CELL(4) modifier:0];
    [view keyDown:event];
    [verify(dataSource) mindmapView:view toggleFoldingForItem:[CELL(4) identifier]];
}

- (void)testKeyDownForNewChildNode {
    unichar key[] = {NSTabCharacter};
    NSString *string = [NSString stringWithCharacters:key length:1];
    [given([event charactersIgnoringModifiers]) willReturn:string];
    [given([event modifierFlags]) willReturnUnsignedInteger:0];

    [view keyDown:event];
    [verify(dataSource) mindmapView:view addNewChildToItem:rootCell.identifier atIndex:[rootCell countOfChildren]];

    [stateManager addCellToSelection:rootCell modifier:0];
    [view keyDown:event];
    [verifyCount(dataSource, times(2)) mindmapView:view
                                 addNewChildToItem:rootCell.identifier
                                           atIndex:[rootCell countOfChildren]];

    [stateManager addCellToSelection:CELL(4) modifier:0];
    [view keyDown:event];
    [verify(dataSource) mindmapView:view addNewChildToItem:[CELL(4) identifier] atIndex:[CELL(4) countOfChildren]];

    [stateManager addCellToSelection:LCELL(4) modifier:0];
    [view keyDown:event];
    [verify(dataSource) mindmapView:view addNewChildToItem:[LCELL(4) identifier] atIndex:[LCELL(4) countOfChildren]];

    [stateManager addCellToSelection:CELL(4) modifier:0];
    [stateManager addCellToSelection:CELL(5) modifier:NSCommandKeyMask];
    [view keyDown:event];
    [verifyCount(dataSource, times(1)) mindmapView:view addNewChildToItem:[CELL(4) identifier]
                                           atIndex:[CELL(4) countOfChildren]];
    [verifyCount(dataSource, never()) mindmapView:view addNewChildToItem:[CELL(5) identifier]
                                          atIndex:[CELL(5) countOfChildren]];
}

- (void)testKeyDownForNewLeftChildNode {
    unichar key[] = {NSBackTabCharacter};
    NSString *string = [NSString stringWithCharacters:key length:1];
    [given([event charactersIgnoringModifiers]) willReturn:string];
    [given([event modifierFlags]) willReturnUnsignedInteger:0];

    [view keyDown:event];
    [verify(dataSource) mindmapView:view addNewLeftChildToItem:rootCell.identifier
                            atIndex:[rootCell countOfLeftChildren]];

    [stateManager addCellToSelection:rootCell modifier:0];
    [view keyDown:event];
    [verifyCount(dataSource, times(2)) mindmapView:view addNewLeftChildToItem:rootCell.identifier
                                           atIndex:[rootCell countOfLeftChildren]];

    [stateManager addCellToSelection:CELL(4) modifier:0];
    [view keyDown:event];
    [verify(dataSource) mindmapView:view addNewChildToItem:[CELL(4) identifier] atIndex:[CELL(4) countOfChildren]];

    [stateManager addCellToSelection:LCELL(4) modifier:0];
    [view keyDown:event];
    [verify(dataSource) mindmapView:view addNewChildToItem:[LCELL(4) identifier] atIndex:[LCELL(4) countOfChildren]];

    [stateManager addCellToSelection:CELL(4) modifier:0];
    [stateManager addCellToSelection:CELL(5) modifier:NSCommandKeyMask];
    [view keyDown:event];
    [verifyCount(dataSource, times(1)) mindmapView:view addNewChildToItem:[LCELL(4) identifier]
                                           atIndex:[LCELL(4) countOfChildren]];
    [verifyCount(dataSource, never()) mindmapView:view addNewChildToItem:[LCELL(5) identifier]
                                          atIndex:[LCELL(5) countOfChildren]];
}

- (void)testKeyDownForNextSibling {
    unichar key[] = {NSCarriageReturnCharacter};
    NSString *string = [NSString stringWithCharacters:key length:1];
    [given([event charactersIgnoringModifiers]) willReturn:string];
    [given([event modifierFlags]) willReturnUnsignedInteger:NSCommandKeyMask];

    [view keyDown:event];
    [verifyCount(dataSource, never()) mindmapView:view addNewNextSiblingToItem:rootCell.identifier];

    [stateManager addCellToSelection:rootCell modifier:0];
    [view keyDown:event];
    [verifyCount(dataSource, never()) mindmapView:view addNewNextSiblingToItem:rootCell.identifier];

    [stateManager addCellToSelection:CELL(4) modifier:0];
    [view keyDown:event];
    [verify(dataSource) mindmapView:view addNewNextSiblingToItem:[CELL(4) identifier]];

    [stateManager addCellToSelection:LCELL(4) modifier:0];
    [view keyDown:event];
    [verify(dataSource) mindmapView:view addNewNextSiblingToItem:[LCELL(4) identifier]];

    [stateManager addCellToSelection:CELL(4) modifier:0];
    [stateManager addCellToSelection:CELL(5) modifier:0];
    [view keyDown:event];
    [verifyCount(dataSource, times(1)) mindmapView:view addNewNextSiblingToItem:[LCELL(4) identifier]];
    [verifyCount(dataSource, never()) mindmapView:view addNewNextSiblingToItem:[LCELL(5) identifier]];
}

- (void)testKeyDownForPrevSibling {
    unichar key[] = {NSCarriageReturnCharacter};
    NSString *string = [NSString stringWithCharacters:key length:1];
    [given([event charactersIgnoringModifiers]) willReturn:string];
    [given([event modifierFlags]) willReturnUnsignedInteger:NSCommandKeyMask | NSShiftKeyMask];

    [view keyDown:event];
    [verifyCount(dataSource, never()) mindmapView:view addNewPreviousSiblingToItem:rootCell.identifier];

    [stateManager addCellToSelection:rootCell modifier:0];
    [view keyDown:event];
    [verifyCount(dataSource, never()) mindmapView:view addNewPreviousSiblingToItem:rootCell.identifier];

    [stateManager addCellToSelection:CELL(4) modifier:0];
    [view keyDown:event];
    [verify(dataSource) mindmapView:view addNewPreviousSiblingToItem:[CELL(4) identifier]];

    [stateManager addCellToSelection:LCELL(4) modifier:0];
    [view keyDown:event];
    [verify(dataSource) mindmapView:view addNewPreviousSiblingToItem:[LCELL(4) identifier]];

    [stateManager addCellToSelection:CELL(4) modifier:0];
    [stateManager addCellToSelection:CELL(5) modifier:0];
    [view keyDown:event];
    [verifyCount(dataSource, times(1)) mindmapView:view addNewPreviousSiblingToItem:[LCELL(4) identifier]];
    [verifyCount(dataSource, never()) mindmapView:view addNewPreviousSiblingToItem:[LCELL(5) identifier]];
}

- (void)testKeyDownForEdit {
    unichar key[] = {NSCarriageReturnCharacter};
    NSString *string = [NSString stringWithCharacters:key length:1];

    [given([event charactersIgnoringModifiers]) willReturn:string];
    [stateManager addCellToSelection:CELL(5) modifier:0];

    [view keyDown:event];

    [verify(editor) beginEditStringValueForCell:CELL(5)];
}

- (void)testSimpleSingleClickNoSelect {
    [given([event clickCount]) willReturnInteger:1];
    [self makeEventReturnModifier:0 locationInWindow:NewPoint(10, 20)];
    [[given([selector cellContainingPoint:NewPoint(10, 460) inCell:rootCell])
            withMatcher:equalToPoint(NewPoint(10, 460)) forArgument:0]
            willReturn:nil];

    [self makeWindowReturnNextEventWithType:NSLeftMouseUp clickCount:1];
    [view mouseDown:event];

    assertThat(stateManager.selectedCells, hasSize(0));
}

- (void)testSimpleSingleClick {
    [stateManager addCellToSelection:CELL(1) modifier:0];

    [given([event clickCount]) willReturnInteger:1];
    [self makeEventReturnModifier:0 locationInWindow:NewPoint(10, 20)];
    [[given([selector cellContainingPoint:NewPoint(10, 460) inCell:rootCell])
            withMatcher:equalToPoint(NewPoint(10, 460)) forArgument:0]
            willReturn:CELL(4)];
    [self makeWindowReturnNextEventWithType:NSLeftMouseUp clickCount:1];

    [view mouseDown:event];

    assertThat(stateManager.selectedCells, consistsOf(CELL(4)));
    assertThat(stateManager.mouseDownHitCell, nilValue());
}

- (void)testSimpleDoubleClickNoSelect {
    [given([event clickCount]) willReturnInteger:1];
    [given([stateManager hasSelectedCells]) willReturnBool:NO];
    [given([stateManager selectedCells]) willReturn:[NSArray array]];
    [self makeEventReturnModifier:0 locationInWindow:NewPoint(10, 20)];

    [given([event clickCount]) willReturnInteger:2];
    [view mouseDown:event];

    [verifyCount(dataSource, never()) mindmapView:view toggleFoldingForItem:anything()];
}

- (void)testSimpleDoubleClick {
    [given([event clickCount]) willReturnInteger:1];
    [stateManager addCellToSelection:CELL(4) modifier:0];
    [self makeEventReturnModifier:0 locationInWindow:NewPoint(10, 20)];

    [given([event clickCount]) willReturnInteger:2];
    [self makeWindowReturnNextEventWithType:NSLeftMouseUp clickCount:2];

    [view mouseDown:event];

    [verify(dataSource) mindmapView:view toggleFoldingForItem:[CELL(4) identifier]];
}

- (void)testDoubleClickWithModifiers {
    [given([event clickCount]) willReturnInteger:2];
    [given([stateManager hasSelectedCells]) willReturnBool:YES];
    [given([stateManager selectedCells]) willReturn:[NSArray arrayWithObject:CELL(4)]];

    [self makeEventReturnModifier:NSCommandKeyMask locationInWindow:NewPoint(10, 20)];
    [self makeWindowReturnNextEventWithType:NSLeftMouseUp clickCount:2];
    [view mouseDown:event];
    [verifyCount(dataSource, never()) mindmapView:view toggleFoldingForItem:[CELL(4) identifier]];

    [self makeEventReturnModifier:NSShiftKeyMask locationInWindow:NewPoint(10, 20)];
    [view mouseDown:event];
    [verifyCount(dataSource, never()) mindmapView:view toggleFoldingForItem:[CELL(4) identifier]];
}

- (void)testDoubleClickWithMultipleSelection {
    [given([event clickCount]) willReturnInteger:2];
    [self makeEventReturnModifier:0 locationInWindow:NewPoint(10, 20)];
    [given([stateManager hasSelectedCells]) willReturnBool:YES];
    [given([stateManager selectedCells]) willReturn:[NSArray arrayWithObjects:CELL(4), CELL(6), nil]];

    [self makeWindowReturnNextEventWithType:NSLeftMouseUp clickCount:2];
    [view mouseDown:event];
    [verifyCount(dataSource, never()) mindmapView:view toggleFoldingForItem:[CELL(4) identifier]];
    [verifyCount(dataSource, never()) mindmapView:view toggleFoldingForItem:[CELL(6) identifier]];
}

- (void)testCommandClick {
    [stateManager addCellToSelection:CELL(1) modifier:0];

    [given([event clickCount]) willReturnInteger:1];

    [[given([selector cellContainingPoint:NewPoint(10, 460) inCell:rootCell])
            withMatcher:equalToPoint(NewPoint(10, 460)) forArgument:0]
            willReturn:CELL(4)];
    [[given([selector cellContainingPoint:NewPoint(10, 440) inCell:rootCell])
            withMatcher:equalToPoint(NewPoint(10, 440)) forArgument:0]
            willReturn:CELL(8)];
    [[given([selector cellContainingPoint:NewPoint(10, 420) inCell:rootCell])
            withMatcher:equalToPoint(NewPoint(10, 420)) forArgument:0]
            willReturn:CELL(8, 1)];
    [[given([selector cellContainingPoint:NewPoint(10, 400) inCell:rootCell])
            withMatcher:equalToPoint(NewPoint(10, 400)) forArgument:0]
            willReturn:nil];

    // ADD
    [self makeEventReturnModifier:0 locationInWindow:NewPoint(10, 20)];
    [self makeWindowReturnNextEventWithType:NSLeftMouseUp clickCount:1];
    [view mouseDown:event];

    assertThat(stateManager.selectedCells, consistsOf(CELL(4)));
    // needed since we have overridden the setNeedsDisplay to set the frame size according to the new root family size
    [view setFrameSize:NewSize(640, 480)];

    [self makeEventReturnModifier:NSCommandKeyMask locationInWindow:NewPoint(10, 40)];
    [view mouseDown:event];
    assertThat(stateManager.selectedCells, consistsOf(CELL(4), CELL(8)));
    [view setFrameSize:NewSize(640, 480)];

    // trying to add CELL(8, 1)
    [self makeEventReturnModifier:NSCommandKeyMask locationInWindow:NewPoint(10, 60)];
    [view mouseDown:event];
    assertThat(stateManager.selectedCells, consistsOf(CELL(4), CELL(8)));
    [view setFrameSize:NewSize(640, 480)];

    // trying to add nil
    [self makeEventReturnModifier:NSCommandKeyMask locationInWindow:NewPoint(10, 80)];
    [view mouseDown:event];
    assertThat(stateManager.selectedCells, consistsOf(CELL(4), CELL(8)));
    [view setFrameSize:NewSize(640, 480)];

    // REMOVE
    [self makeEventReturnModifier:NSCommandKeyMask locationInWindow:NewPoint(10, 40)];
    [view mouseDown:event];
    assertThat(stateManager.selectedCells, consistsOf(CELL(4)));
}

- (void)testShiftClick {
    [given([event clickCount]) willReturnInteger:1];

    [[given([selector cellContainingPoint:NewPoint(10, 460) inCell:rootCell])
            withMatcher:equalToPoint(NewPoint(10, 460)) forArgument:0]
            willReturn:LCELL(4)];
    [[given([selector cellContainingPoint:NewPoint(10, 440) inCell:rootCell])
            withMatcher:equalToPoint(NewPoint(10, 440)) forArgument:0]
            willReturn:LCELL(8)];
    [[given([selector cellContainingPoint:NewPoint(10, 420) inCell:rootCell])
            withMatcher:equalToPoint(NewPoint(10, 420)) forArgument:0]
            willReturn:LCELL(8, 1)];
    [[given([selector cellContainingPoint:NewPoint(10, 400) inCell:rootCell])
            withMatcher:equalToPoint(NewPoint(10, 400)) forArgument:0]
            willReturn:nil];

    // ADD
    [self makeEventReturnModifier:0 locationInWindow:NewPoint(10, 20)];
    [self makeWindowReturnNextEventWithType:NSLeftMouseUp clickCount:1];
    [view mouseDown:event];
    // the only clear selection call
    assertThat(stateManager.selectedCells, consistsOf(LCELL(4)));
    [view setFrameSize:NewSize(640, 480)];

    [self makeEventReturnModifier:NSShiftKeyMask locationInWindow:NewPoint(10, 40)];
    [view mouseDown:event];
    assertThat(stateManager.selectedCells, consistsOf(LCELL(4), LCELL(5), LCELL(6), LCELL(7), LCELL(8)));
    // make sure that clearSelection does not get called anymore
    [view setFrameSize:NewSize(640, 480)];

    // trying to add LCELL(8, 1)
    [self makeEventReturnModifier:NSShiftKeyMask locationInWindow:NewPoint(10, 60)];
    [view mouseDown:event];
    assertThat(stateManager.selectedCells, consistsOf(LCELL(4), LCELL(5), LCELL(6), LCELL(7), LCELL(8)));
    [view setFrameSize:NewSize(640, 480)];

    // trying to add nil
    [self makeEventReturnModifier:NSShiftKeyMask locationInWindow:NewPoint(10, 80)];
    [view mouseDown:event];
    assertThat(stateManager.selectedCells, consistsOf(LCELL(4), LCELL(5), LCELL(6), LCELL(7), LCELL(8)));
    [view setFrameSize:NewSize(640, 480)];

    // REMOVE
    [self makeEventReturnModifier:NSShiftKeyMask locationInWindow:NewPoint(10, 40)];
    [view mouseDown:event];
    assertThat(stateManager.selectedCells, consistsOf(LCELL(4), LCELL(5), LCELL(6), LCELL(7)));
}

#pragma mark Private
- (void)makeEventReturnModifier:(NSUInteger)modifier locationInWindow:(NSPoint)location {
    [given([event modifierFlags]) willReturnUnsignedInteger:modifier];
    [given([event locationInWindow]) willReturnPoint:location];
}

- (void)makeWindowReturnNextEventWithType:(NSEventType)type clickCount:(NSInteger)clickCount {
    [given([nextEvent type]) willReturnUnsignedInteger:type];
    [given([nextEvent clickCount]) willReturnInteger:clickCount];
    [given([window nextEventMatchingMask:NSLeftMouseUpMask | NSLeftMouseDraggedMask]) willReturn:nextEvent];
}

@end
