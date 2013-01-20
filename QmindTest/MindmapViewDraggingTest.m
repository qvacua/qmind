/**
 * Tae Won Ha
 * http://qvacua.com
 * https://bitbucket.org/qvacua
 *
 * See LICENSE
 */

#import "QMBaseTestCase.h"
#import "QMMindmapView.h"
#import "QMCellSelector.h"
#import "QMCellEditor.h"
#import "QMCellStateManager.h"
#import "QMDocumentWindowController.h"
#import <Qkit/Qkit.h>
#import <TBCacao/TBCacao.h>
#import "QMBaseTestCase+Util.h"
#import "QMAppSettings.h"
#import "QMCellLayoutManager.h"
#import "QMCacaoTestCase.h"
#import "QMMindmapViewDataSourceImpl.h"
#import "QMNode.h"

@interface DummyDraggingInfo : NSObject <NSDraggingInfo> {
@public
    NSPoint dragLocation;
    __weak id dragSource;
    __weak NSPasteboard *pasteboard;
    NSDragOperation dragOperation;
}
@end

@implementation DummyDraggingInfo
- (NSWindow *)draggingDestinationWindow {
    return nil;
}

- (NSDragOperation)draggingSourceOperationMask {
    return dragOperation;
}

- (NSPoint)draggingLocation {
    return dragLocation;
}

- (NSPoint)draggedImageLocation {
    NSPoint result;
    return result;
}

- (NSImage *)draggedImage {
    return nil;
}

- (NSPasteboard *)draggingPasteboard {
    return pasteboard;
}

- (id)draggingSource {
    return dragSource;
}

- (NSInteger)draggingSequenceNumber {
    return 0;
}

- (void)slideDraggedImageTo:(NSPoint)screenPoint {

}

- (NSArray *)namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination {
    return nil;
}

- (void)enumerateDraggingItemsWithOptions:(NSDraggingItemEnumerationOptions)enumOpts forView:(NSView *)view classes:(NSArray *)classArray searchOptions:(NSDictionary *)searchOptions usingBlock:(void (^)(NSDraggingItem *, NSInteger, BOOL *))block {

}

@end

@interface MindmapViewDraggingTest : QMCacaoTestCase {
    QMMindmapView *view;

    QMCellStateManager *stateManager;
    QMCellSelector *selector;
    QMCellEditor *editor;
    QMDocumentWindowController *controller;
    QMMindmapViewDataSourceImpl *dataSource;
    NSPasteboard *pasteboard;

    QMRootCell *rootCell;
}

@end

@implementation MindmapViewDraggingTest {
    QMCellLayoutManager *cellLayoutManager;
    NSRect viewFrame;
    QMAppSettings *settings;
}

- (void)setUp {
    [super setUp];

    settings = [self.context beanWithClass:[QMAppSettings class]];

    stateManager = [[QMCellStateManager alloc] init];
    selector = mock([QMCellSelector class]);
    editor = mock([QMCellEditor class]);
    controller = mock([QMDocumentWindowController class]);
    dataSource = mock([QMMindmapViewDataSourceImpl class]);
    cellLayoutManager = mock([QMCellLayoutManager class]);
    pasteboard = mock([NSPasteboard class]);

    viewFrame = NewRect(0, 0, 640, 480);
    view = [[QMMindmapView alloc] initWithFrame:viewFrame];
    rootCell = [self rootCellForTestWithView:view];

    [view setInstanceVarTo:selector];
    [view setInstanceVarTo:stateManager];
    [view setInstanceVarTo:editor];
    [view setInstanceVarTo:rootCell];
    [view setInstanceVarTo:cellLayoutManager];
    [view setInstanceVarTo:dataSource implementingProtocol:@protocol(QMMindmapViewDataSource)];
    [view setInstanceVarTo:settings];
}

- (void)testDraggingUpdatedNoOldTargetCell {
    QMCell *newTargetCell = CELL(0);

    NSPoint point = NewPoint(11, 12);
    [[given([selector cellContainingPoint:NSZeroPoint inCell:rootCell]) withMatcher:equalToPoint(NewPointFlipping(point, viewFrame.size.height)) forArgument:0] willReturn:newTargetCell];

    DummyDraggingInfo *info = [[DummyDraggingInfo alloc] init];
    info->dragLocation = point;
    info->dragSource = view;

    [[given([cellLayoutManager regionOfCell:newTargetCell atPoint:NSZeroPoint]) withMatcher:equalToPoint(NewPointFlipping(point, viewFrame.size.height)) forArgument:1] willReturnUnsignedInteger:QMCellRegionEast];
    [view draggingUpdated:info];

    assertThat(@(newTargetCell.dragRegion), is(@(QMCellRegionEast)));
}

- (void)testDraggingUpdated {
    QMCell *oldTargetCell = CELL(0);

    NSPoint oldPoint = NewPoint(11, 12);
    [[given([selector cellContainingPoint:NSZeroPoint inCell:rootCell]) withMatcher:equalToPoint(NewPointFlipping(oldPoint, viewFrame.size.height)) forArgument:0] willReturn:oldTargetCell];

    DummyDraggingInfo *info = [[DummyDraggingInfo alloc] init];
    info->dragLocation = oldPoint;
    info->dragSource = view;

    [[given([cellLayoutManager regionOfCell:oldTargetCell atPoint:NSZeroPoint]) withMatcher:equalToPoint(NewPointFlipping(oldPoint, viewFrame.size.height)) forArgument:1] willReturnUnsignedInteger:QMCellRegionEast];
    [view draggingUpdated:info];
    
    QMCell *newTargetCell = CELL(1);
    NSPoint newPoint = NewPoint(99, 99);

    [[given([selector cellContainingPoint:NSZeroPoint inCell:rootCell]) withMatcher:equalToPoint(NewPointFlipping(newPoint, viewFrame.size.height)) forArgument:0] willReturn:newTargetCell];
    info->dragLocation = newPoint;

    [[given([cellLayoutManager regionOfCell:newTargetCell atPoint:NSZeroPoint]) withMatcher:equalToPoint(NewPointFlipping(newPoint, viewFrame.size.height)) forArgument:1] willReturnUnsignedInteger:QMCellRegionNorth];
    [view draggingUpdated:info];

    assertThat(@(oldTargetCell.dragRegion), is(@(QMCellRegionNone)));
    assertThat(@(newTargetCell.dragRegion), is(@(QMCellRegionNorth)));
}

- (void)testDraggingUpdatedWithNilNewTarget {
    QMCell *oldTargetCell = CELL(0);
    [oldTargetCell setInstanceVarTo:cellLayoutManager];

    NSPoint oldPoint = NewPoint(11, 12);
    [[given([selector cellContainingPoint:NewPoint(0, 0) inCell:rootCell]) withMatcher:equalToPoint(oldPoint) forArgument:0] willReturn:oldTargetCell];

    DummyDraggingInfo *info = [[DummyDraggingInfo alloc] init];
    info->dragLocation = oldPoint;
    info->dragSource = view;

    [[given([cellLayoutManager regionOfCell:oldTargetCell atPoint:NSZeroPoint]) withMatcher:equalToPoint(oldPoint) forArgument:1] willReturnUnsignedInteger:QMCellRegionEast];
    [view draggingUpdated:info];

    QMCell *newTargetCell = nil;
    NSPoint newPoint = NewPoint(99, 99);

    [[given([selector cellContainingPoint:NewPoint(0, 0) inCell:rootCell]) withMatcher:equalToPoint(newPoint) forArgument:0] willReturn:newTargetCell];
    info->dragLocation = newPoint;

    [[given([cellLayoutManager regionOfCell:newTargetCell atPoint:NSZeroPoint]) withMatcher:equalToPoint(newPoint) forArgument:1] willReturnUnsignedInteger:QMCellRegionNorth];
    assertThat(@([view draggingUpdated:info]), is(@(NSDragOperationNone)));

    assertThat(@(oldTargetCell.dragRegion), is(@(QMCellRegionNone)));
}

- (void)testDraggingEnded {
    stateManager.mouseDownHitCell = CELL(1);
    stateManager.dragTargetCell = CELL(4);
    [view draggingEnded:nil];

    assertThat(stateManager.mouseDownHitCell, nilValue());
    assertThat(stateManager.dragTargetCell, nilValue());
}

- (void)testPerformDragOperationNotAllowedType {
    DummyDraggingInfo *info = [[DummyDraggingInfo alloc] init];
    info->pasteboard = pasteboard;
    [given([pasteboard types]) willReturn:@[@"some type"]];

    assertThat(@([view performDragOperation:info]), isNo);
}

- (void)testPerformDragOperationNotAllowedSource {
    DummyDraggingInfo *info = [[DummyDraggingInfo alloc] init];
    info->pasteboard = pasteboard;
    info->dragSource = self;
    [given([pasteboard types]) willReturn:@[qNodeUti]];

    assertThat(@([view performDragOperation:info]), isNo);
}

- (void)testPerformDragOperationTargetIsDragged {
    DummyDraggingInfo *info = [[DummyDraggingInfo alloc] init];
    info->pasteboard = pasteboard;
    info->dragSource = view;
    [given([pasteboard types]) willReturn:@[qNodeUti]];

    [stateManager addCellToSelection:CELL(4) modifier:0];
    [stateManager addCellToSelection:CELL(6) modifier:NSCommandKeyMask];
    stateManager.mouseDownHitCell = CELL(6);
    stateManager.dragTargetCell = CELL(4);

    assertThat(@([view performDragOperation:info]), isNo);
}

- (void)testPerformDragOperationRootIsDragged {
    DummyDraggingInfo *info = [[DummyDraggingInfo alloc] init];
    info->pasteboard = pasteboard;
    info->dragSource = view;
    [given([pasteboard types]) willReturn:@[qNodeUti]];

    [stateManager addCellToSelection:CELL(4) modifier:0];
    [stateManager addCellToSelection:CELL(6) modifier:NSCommandKeyMask];
    stateManager.mouseDownHitCell = rootCell;
    stateManager.dragTargetCell = LCELL(4);

    assertThat(@([view performDragOperation:info]), isNo);
}

- (void)testPerformDragOperationMove {
    DummyDraggingInfo *info = [[DummyDraggingInfo alloc] init];
    info->pasteboard = pasteboard;
    info->dragSource = view;
    info->dragOperation = NSDragOperationMove | NSDragOperationCopy;
    [given([pasteboard types]) willReturn:@[qNodeUti]];

    [stateManager addCellToSelection:CELL(4) modifier:0];
    [stateManager addCellToSelection:CELL(6) modifier:NSCommandKeyMask];
    stateManager.mouseDownHitCell = CELL(6);
    stateManager.dragTargetCell = LCELL(3);
    [LCELL(3) setFolded:YES];
    [LCELL(3) setDragRegion:QMCellRegionSouth];

    assertThat(@([view performDragOperation:info]), isYes);
    [verify(dataSource) mindmapView:view toggleFoldingForItem:[LCELL(3) identifier]];
    [verify(dataSource) mindmapView:view moveItems:@[[CELL(4) identifier], [CELL(6) identifier]] toItem:[LCELL(3) identifier] inDirection:QMDirectionBottom];
    assertThat(@([LCELL(3) dragRegion]), is(@(QMCellRegionNone)));
}

- (void)testPerformDragOperationCopy {
    DummyDraggingInfo *info = [[DummyDraggingInfo alloc] init];
    info->pasteboard = pasteboard;
    info->dragSource = view;
    info->dragOperation = NSDragOperationCopy;
    [given([pasteboard types]) willReturn:@[qNodeUti]];

    [stateManager addCellToSelection:CELL(4) modifier:0];
    [stateManager addCellToSelection:CELL(6) modifier:NSCommandKeyMask];
    stateManager.mouseDownHitCell = CELL(6);
    stateManager.dragTargetCell = LCELL(3);
    [LCELL(3) setFolded:YES];
    [LCELL(3) setDragRegion:QMCellRegionNorth];

    assertThat(@([view performDragOperation:info]), isYes);
    [verify(dataSource) mindmapView:view toggleFoldingForItem:[LCELL(3) identifier]];
    [verify(dataSource) mindmapView:view copyItems:@[[CELL(4) identifier], [CELL(6) identifier]] toItem:[LCELL(3) identifier] inDirection:QMDirectionTop];
    assertThat(@([LCELL(3) dragRegion]), is(@(QMCellRegionNone)));
}

@end
