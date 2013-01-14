/**
 * Tae Won Ha
 * http://qvacua.com
 * https://bitbucket.org/qvacua
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

@interface MindmapViewEventsTest : QMCacaoTestCase
- (void)makeEventReturnModifier:(NSUInteger)modifier locationInWindow:(NSPoint)location;
@end

@implementation MindmapViewEventsTest {
    QMCellStateManager *stateManager;
    QMCellSelector *selector;
    QMCellEditor *editor;
    QMMindmapViewDataSourceImpl *dataSource;
    NSEvent *event;

    QMRootCell *rootCell;

    QMMindmapView *view;
}

- (void)setUp {
    [[TBContext sharedContext] initContext];

    stateManager = [[QMCellStateManager alloc] init];
    selector = mock(QMCellSelector.class);
    event = mock(NSEvent.class);
    editor = mock([QMCellEditor class]);
    dataSource = mock([QMMindmapViewDataSourceImpl class]);

    view = [[QMMindmapView alloc] initWithFrame:NewRect(0, 0, 640, 480)];
    [view setInstanceVarTo:selector];
    [view setInstanceVarTo:stateManager];
    [view setInstanceVarTo:editor];
    [view setInstanceVarTo:dataSource implementingProtocol:@protocol(QMMindmapViewDataSource)];
    [view setInstanceVarTo:[QMAppSettings sharedSettings]];

    rootCell = [self rootCellForTestWithView:view];

    [view setInstanceVarTo:rootCell];
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

    [view mouseDown:event];
    [view mouseUp:event];

    assertThat(stateManager.selectedCells, hasSize(0));
}

- (void)testSimpleSingleClick {
    [stateManager addCellToSelection:CELL(1) modifier:0];

    [given([event clickCount]) willReturnInteger:1];
    [self makeEventReturnModifier:0 locationInWindow:NewPoint(10, 20)];
    [[given([selector cellContainingPoint:NewPoint(10, 460) inCell:rootCell])
            withMatcher:equalToPoint(NewPoint(10, 460)) forArgument:0]
            willReturn:CELL(4)];

    [view mouseDown:event];
    assertThat(stateManager.mouseDownHitCell, is(CELL(4)));

    [view mouseUp:event];
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
    [view mouseUp:event];

    [verifyCount(dataSource, never()) mindmapView:view toggleFoldingForItem:anything()];
}

- (void)testSimpleDoubleClick {
    [given([event clickCount]) willReturnInteger:1];
    [stateManager addCellToSelection:CELL(4) modifier:0];
    [self makeEventReturnModifier:0 locationInWindow:NewPoint(10, 20)];

    [given([event clickCount]) willReturnInteger:2];
    [view mouseDown:event];

    [verify(dataSource) mindmapView:view toggleFoldingForItem:[CELL(4) identifier]];
}

- (void)testDoubleClickWithModifiers {
    [given([event clickCount]) willReturnInteger:2];
    [given([stateManager hasSelectedCells]) willReturnBool:YES];
    [given([stateManager selectedCells]) willReturn:[NSArray arrayWithObject:CELL(4)]];

    [self makeEventReturnModifier:NSCommandKeyMask locationInWindow:NewPoint(10, 20)];
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

    [view mouseDown:event];
    [verifyCount(dataSource, never()) mindmapView:view toggleFoldingForItem:[CELL(4) identifier]];
    [verifyCount(dataSource, never()) mindmapView:view toggleFoldingForItem:[CELL(6) identifier]];
}

- (void)makeEventReturnModifier:(NSUInteger)modifier locationInWindow:(NSPoint)location {
    [given([event modifierFlags]) willReturnUnsignedInteger:modifier];
    [given([event locationInWindow]) willReturnPoint:location];
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
    [view mouseDown:event];

    [view mouseUp:event];
    assertThat(stateManager.selectedCells, consistsOf(CELL(4)));
    // needed since we have overridden the setNeedsDisplay to set the frame size according to the new root family size
    [view setFrameSize:NewSize(640, 480)];

    [self makeEventReturnModifier:NSCommandKeyMask locationInWindow:NewPoint(10, 40)];
    [view mouseDown:event];
    [view mouseUp:event];
    assertThat(stateManager.selectedCells, consistsOf(CELL(4), CELL(8)));
    [view setFrameSize:NewSize(640, 480)];

    // trying to add CELL(8, 1)
    [self makeEventReturnModifier:NSCommandKeyMask locationInWindow:NewPoint(10, 60)];
    [view mouseDown:event];
    [view mouseUp:event];
    assertThat(stateManager.selectedCells, consistsOf(CELL(4), CELL(8)));
    [view setFrameSize:NewSize(640, 480)];

    // trying to add nil
    [self makeEventReturnModifier:NSCommandKeyMask locationInWindow:NewPoint(10, 80)];
    [view mouseDown:event];
    [view mouseUp:event];
    assertThat(stateManager.selectedCells, consistsOf(CELL(4), CELL(8)));
    [view setFrameSize:NewSize(640, 480)];

    // REMOVE
    [self makeEventReturnModifier:NSCommandKeyMask locationInWindow:NewPoint(10, 40)];
    [view mouseDown:event];
    [view mouseUp:event];
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
    [view mouseDown:event];
    [view mouseUp:event];
    // the only clear selection call
    assertThat(stateManager.selectedCells, consistsOf(LCELL(4)));
    [view setFrameSize:NewSize(640, 480)];

    [self makeEventReturnModifier:NSShiftKeyMask locationInWindow:NewPoint(10, 40)];
    [view mouseDown:event];
    [view mouseUp:event];
    assertThat(stateManager.selectedCells, consistsOf(LCELL(4), LCELL(5), LCELL(6), LCELL(7), LCELL(8)));
    // make sure that clearSelection does not get called anymore
    [view setFrameSize:NewSize(640, 480)];

    // trying to add LCELL(8, 1)
    [self makeEventReturnModifier:NSShiftKeyMask locationInWindow:NewPoint(10, 60)];
    [view mouseDown:event];
    [view mouseUp:event];
    assertThat(stateManager.selectedCells, consistsOf(LCELL(4), LCELL(5), LCELL(6), LCELL(7), LCELL(8)));
    [view setFrameSize:NewSize(640, 480)];

    // trying to add nil
    [self makeEventReturnModifier:NSShiftKeyMask locationInWindow:NewPoint(10, 80)];
    [view mouseDown:event];
    [view mouseUp:event];
    assertThat(stateManager.selectedCells, consistsOf(LCELL(4), LCELL(5), LCELL(6), LCELL(7), LCELL(8)));
    [view setFrameSize:NewSize(640, 480)];

    // REMOVE
    [self makeEventReturnModifier:NSShiftKeyMask locationInWindow:NewPoint(10, 40)];
    [view mouseDown:event];
    [view mouseUp:event];
    assertThat(stateManager.selectedCells, consistsOf(LCELL(4), LCELL(5), LCELL(6), LCELL(7)));
}

- (void)testMouseDragged {
    NSScrollView *scrollView = [[NSScrollView alloc] init];
    NSClipView *clipView = [[NSClipView alloc] init];

    [clipView setDocumentView:view];
    [scrollView setContentView:clipView];

    NSEvent *event = mock([NSEvent class]);
    [given([event deltaX]) willReturnFloat:-4];
    [given([event deltaY]) willReturnFloat:-2];

    NSPoint oldScrollPt = clipView.bounds.origin;
    [view mouseDragged:event];
    assertThatPoint(clipView.bounds.origin, isNot(equalToPoint(oldScrollPt)));
    assertThat([scrollView documentCursor], is([NSCursor closedHandCursor]));
}

- (void)untestMouseUp {
    NSScrollView *scrollView = [[NSScrollView alloc] init];
    NSClipView *clipView = [[NSClipView alloc] init];

    [clipView setDocumentView:view];
    [scrollView setContentView:clipView];

    NSEvent *event = mock([NSEvent class]);
    [given([event deltaX]) willReturnFloat:-4];
    [given([event deltaY]) willReturnFloat:-2];

    [view mouseDragged:event];
    [view mouseUp:nil];

    // sometimes [NSCursor arrowCursor] == nil for some reason
    // assertThat([scrollView documentCursor], is(nilValue()));
}

@end
