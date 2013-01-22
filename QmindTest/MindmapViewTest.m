/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import "QMCellSelector.h"
#import "QMCellStateManager.h"
#import <Qkit/Qkit.h>
#import "QMBaseTestCase+Util.h"
#import "QMCellEditor.h"
#import "QMRootCell.h"
#import "QMAppSettings.h"
#import "QMDocumentWindowController.h"
#import "QMMindmapView.h"
#import "QMCacaoTestCase.h"
#import "QMMindmapViewDataSourceImpl.h"
#import "QMCellLayoutManager.h"
#import "QMCellSizeManager.h"

static NSSize const CELL_SIZE = {100, 20};

@interface MindmapViewTest : QMCacaoTestCase
@end

@implementation MindmapViewTest {
    QMMindmapView *view;

    QMCellStateManager *stateManager;
    QMCellSelector *selector;
    QMCellEditor *editor;
    QMDocumentWindowController *controller;
    QMMindmapViewDataSourceImpl *dataSource;
    NSWindow *window;
    QMCellLayoutManager *cellLayoutManager;
    QMCellSizeManager *cellSizeManager;

    QMRootCell *rootCell;
}

- (void)setUp {
    [super setUp];

    stateManager = [[QMCellStateManager alloc] init];
    selector = mock(QMCellSelector.class);
    editor = mock([QMCellEditor class]);
    controller = mock([QMDocumentWindowController class]);
    dataSource = mockProtocol(@protocol(QMMindmapViewDataSource));
    window = mock([NSWindow class]);
    cellLayoutManager = mock([QMCellLayoutManager class]);
    cellSizeManager = mock([QMCellSizeManager class]);

    view = [[QMMindmapView alloc] initWithFrame:NewRect(0, 0, 640, 480)];
    rootCell = [self rootCellForTestWithView:view];

    [view setInstanceVarTo:window];
    [view setInstanceVarTo:selector];
    [view setInstanceVarTo:stateManager];
    [view setInstanceVarTo:editor];
    [view setInstanceVarTo:rootCell];
    [view setInstanceVarTo:dataSource implementingProtocol:@protocol(QMMindmapViewDataSource)];
}

- (void)testRootCellSelected {
    [stateManager addCellToSelection:rootCell modifier:0];
    assertThatBool(view.rootCellSelected, isTrue);

    [stateManager addCellToSelection:CELL(5) modifier:0];
    assertThatBool(view.rootCellSelected, isFalse);

    [stateManager clearSelection];
    assertThatBool(view.rootCellSelected, isFalse);
}

- (void)testSelectedCells {
    [stateManager addCellToSelection:CELL(1) modifier:0];
    [stateManager addCellToSelection:CELL(5) modifier:NSCommandKeyMask];
    assertThat([view selectedCells], consistsOf(CELL(1), CELL(5)));
}

- (void)testToggleFoldingOfSelectedCell {
    [stateManager addCellToSelection:CELL(4) modifier:0];
    [view toggleFoldingOfSelectedCell];
    [verify(dataSource) mindmapView:view toggleFoldingForItem:[CELL(4) identifier]];
}

- (void)testChangeFontOfSelectedCells {
    rootCell.familyOrigin = NewPoint(10, 10);
    [CELL(1, 5) setFont:[NSFont systemFontOfSize:10]];
    [CELL(1, 8) setFont:[NSFont systemFontOfSize:10]];
    [stateManager addCellToSelection:CELL(1) modifier:0];
    [stateManager addCellToSelection:CELL(5) modifier:NSCommandKeyMask];
    NSSize oldSize = [CELL(1) size];
    NSPoint oldPointOfChild = [CELL(1, 5) origin];

    NSFont *const newFont = [NSFont boldSystemFontOfSize:50];
    [view updateFontOfSelectedCellsToFont:newFont];

    assertThat([CELL(1) font], is(newFont));
    assertThat([CELL(5) font], is(newFont));

    assertThatSize([CELL(1) size], isNot(equalToSize(oldSize)));
    assertThatPoint([CELL(1, 5) origin], isNot(equalToPoint(oldPointOfChild)));
}

- (void)testHasSelectedCells {
    [stateManager addCellToSelection:CELL(1) modifier:0];
    assertThatBool([view hasSelectedCells], isTrue);

    [stateManager clearSelection];
    assertThatBool([view hasSelectedCells], isFalse);
}

- (void)testClearSelection {
    [stateManager addCellToSelection:CELL(1) modifier:0];
    [view clearSelection];

    assertThat(stateManager.selectedCells, hasSize(0));
}

- (void)testUpdateCell {
    rootCell.familyOrigin = NewPoint(10, 10);
    NSString *const newStr = @"new string of fifth right cell";
    NSSize oldSize = [CELL(5) size];
    NSPoint oldOriginOfChild = NewPoint(10, 10);

    [given([selector cellWithIdentifier:[CELL(5) identifier] fromParentCell:rootCell]) willReturn:CELL(5)];
    [given([dataSource mindmapView:view stringValueOfItem:[CELL(5) identifier]]) willReturn:newStr];

    [view updateCellWithIdentifier:[CELL(5) identifier]];

    assertThat([CELL(5) stringValue], is(newStr));
    assertThatSize(oldSize, isNot(equalToSize([CELL(5) size])));
    assertThatPoint(oldOriginOfChild, isNot(equalToPoint([CELL(5, 4) origin])));
}

- (void)testUpdateCellFamily {
    // to cumbersome to mock the datasource. doing the test in the component test case
}

- (void)testZoom {
    rootCell.cellSizeManager = cellSizeManager;
    [given([cellSizeManager sizeOfFamilyOfCell:rootCell]) willReturnSize:NewSize(1, 1)];

    NSSize zoomedFrameSize;

    [view zoomToActualSize];
    zoomedFrameSize = view.frame.size;
    assertThatFloat(zoomedFrameSize.width, closeTo(1, 0.0001));
    assertThatFloat(zoomedFrameSize.height, closeTo(1, 0.0001));
    assertThatFloat(1, equalToFloat([view convertSize:UNIT_SIZE toView:nil].width));

    [view zoomByFactor:MIN_ZOOM_FACTOR - 0.01];
    assertThatFloat(1, equalToFloat([view convertSize:UNIT_SIZE toView:nil].width));
    zoomedFrameSize = view.frame.size;
    assertThatFloat(zoomedFrameSize.width, closeTo(1, 0.0001));
    assertThatFloat(zoomedFrameSize.height, closeTo(1, 0.0001));
    assertThatFloat(1, equalToFloat([view convertSize:UNIT_SIZE toView:nil].width));

    [view zoomToActualSize];

    [view zoomByFactor:MAX_ZOOM_FACTOR + 0.0001];
    zoomedFrameSize = view.frame.size;
    assertThatFloat(zoomedFrameSize.width, closeTo(1, 0.0001));
    assertThatFloat(zoomedFrameSize.height, closeTo(1, 0.0001));
    assertThatFloat(1, equalToFloat([view convertSize:UNIT_SIZE toView:nil].width));
}

- (void)testCellIsSelected {
    [stateManager addCellToSelection:CELL(3) modifier:0];

    assertThatBool([view cellIsSelected:CELL(3)], isTrue);
    assertThatBool([view cellIsSelected:CELL(9)], isFalse);
}

- (void)testCellIsCurrentlyEdited {
    [given([editor currentlyEditedCell]) willReturn:CELL(4)];
    assertThatBool([view cellIsCurrentlyEdited:CELL(4)], isTrue);

    [given([editor currentlyEditedCell]) willReturn:nil];
    assertThatBool([view cellIsCurrentlyEdited:CELL(4)], isFalse);
}

- (void)testCellEditingEnd {
    QMAppSettings *settings = [self.context beanWithClass:[QMAppSettings class]];
    NSMutableDictionary *const paragraphStyle = [[NSMutableDictionary alloc] initWithDictionary:[settings settingForKey:qSettingDefaultStringAttributeDict]];

    NSAttributedString *oldString = [[NSAttributedString alloc] initWithString:[CELL(3) stringValue] attributes:paragraphStyle];

    [view editingEndedWithString:oldString forCell:CELL(3) byChar:NULL];

    assertThat([CELL(3) stringValue], is([oldString string]));
    assertThat([CELL(3) font], is(nilValue()));
    [verify(dataSource) mindmapView:view editingEndedForItem:[CELL(3) identifier]];
    [verifyCount(dataSource, never()) mindmapView:view setStringValue:[oldString string] ofItem:[CELL(3) identifier]];
    [verifyCount(dataSource, never()) mindmapView:view setFont:anything() ofItems:consistsOf([CELL(3) identifier])];

    NSSize oldSize = [CELL(5) size];
    NSPoint oldPointOfChild = [CELL(5, 1) origin];
    oldString = [[NSAttributedString alloc] initWithString:[CELL(5) stringValue] attributes:paragraphStyle];
    NSAttributedString *newString = [[NSAttributedString alloc] initWithString:@"test new str" attributes:paragraphStyle];

    [view editingEndedWithString:newString forCell:CELL(5) byChar:NULL];

    assertThat([CELL(5) stringValue], is([oldString string]));
    assertThat([CELL(5) font], is(nilValue()));
    assertThatSize(oldSize, equalToSize([CELL(5) size]));
    assertThatPoint(oldPointOfChild, equalToPoint([CELL(5, 1) origin]));
    [verify(dataSource) mindmapView:view editingEndedForItem:[CELL(5) identifier]];
    [verify(dataSource) mindmapView:view setStringValue:@"test new str" ofItem:[CELL(5) identifier]];
    [verifyCount(dataSource, never()) mindmapView:view setFont:anything() ofItems:consistsOf([CELL(5) identifier])];

    oldString = [[NSAttributedString alloc] initWithString:[CELL(6) stringValue] attributes:paragraphStyle];
    NSFont *const newFont = [NSFont labelFontOfSize:50];
    [paragraphStyle setObject:newFont forKey:NSFontAttributeName];
    newString = [[NSAttributedString alloc] initWithString:@"font str" attributes:paragraphStyle];

    [view editingEndedWithString:newString forCell:CELL(6) byChar:NULL];

    assertThat([CELL(6) stringValue], is([oldString string]));
    assertThat([CELL(6) font], is(nilValue()));
    [verify(dataSource) mindmapView:view editingEndedForItem:[CELL(6) identifier]];
    [verify(dataSource) mindmapView:view setStringValue:[newString string] ofItem:[CELL(6) identifier]];
    [verify(dataSource) mindmapView:view setFont:newFont ofItems:consistsOf([CELL(6) identifier])];

    [CELL(7) setFont:[NSFont systemFontOfSize:15]];
    oldString = [[NSAttributedString alloc] initWithString:[CELL(7) stringValue] attributes:paragraphStyle];

    [view editingEndedWithString:newString forCell:CELL(7) byChar:NULL];

    assertThat([CELL(7) stringValue], is([oldString string]));
    assertThat([CELL(7) font], is([NSFont systemFontOfSize:15]));
    [verify(dataSource) mindmapView:view editingEndedForItem:[CELL(7) identifier]];
    [verify(dataSource) mindmapView:view setStringValue:[newString string] ofItem:[CELL(7) identifier]];
    [verify(dataSource) mindmapView:view setFont:newFont ofItems:consistsOf([CELL(7) identifier])];

}

- (void)testCellCancelledEditing {
    [stateManager addCellToSelection:CELL(3) modifier:0];

    NSObject *obj = [[NSObject alloc] init];
    [CELL(3) setIdentifier:obj];

    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"fds"];
    [view editingCancelledWithString:str forCell:CELL(3)];

    assertThat(stateManager.selectedCells, hasSize(0));
    [verify(dataSource) mindmapView:view editingCancelledForItem:[CELL(3) identifier] withAttrString:str];
}

- (void)testNoZoomWhenEditing {
    NSSize oldSize = view.frame.size;
    NSEvent *event = mock([NSEvent class]);

    [given([event modifierFlags]) willReturnUnsignedInteger:NSCommandKeyMask];
    [given([event deltaY]) willReturnFloat:1];
    [given([event magnification]) willReturnFloat:2];
    [given([event locationInWindow]) willReturnPoint:NewPoint(10, 10)];
    [given([editor isEditing]) willReturnBool:YES];

    [view scrollWheel:event];
    assertThatSize(view.frame.size, equalToSize(oldSize));

    [view magnifyWithEvent:event];
    assertThatSize(view.frame.size, equalToSize(oldSize));
}

- (void)testNewChildToRoot {
    // no cell selected
    [view insertChild];
    [verify(dataSource) mindmapView:view addNewChildToItem:rootCell.identifier atIndex:rootCell.children.count];

    [stateManager addCellToSelection:rootCell modifier:0];
    [view insertChild];
    [verifyCount(dataSource, times(2)) mindmapView:view addNewChildToItem:rootCell.identifier atIndex:rootCell.children.count];
}

- (void)testNewChildToNonRoot {
    [CELL(4) setFolded:YES];
    [stateManager addCellToSelection:CELL(4) modifier:0];
    [view insertChild];
    [verify(dataSource) mindmapView:view toggleFoldingForItem:[CELL(4) identifier]];
    [verify(dataSource) mindmapView:view addNewChildToItem:[CELL(4) identifier] atIndex:[[CELL(4) children] count]];

    [LCELL(4) setFolded:NO];
    [stateManager addCellToSelection:LCELL(4) modifier:0];
    [view insertChild];
    [verifyCount(dataSource, never()) mindmapView:view toggleFoldingForItem:[LCELL(4) identifier]];
    [verify(dataSource) mindmapView:view addNewChildToItem:[LCELL(4) identifier] atIndex:[[LCELL(4) children] count]];
}

- (void)testNewLeftChildToRoot {
    // no cell selected
    [view insertLeftChild];
    [verify(dataSource) mindmapView:view addNewLeftChildToItem:rootCell.identifier atIndex:rootCell.leftChildren.count];

    [stateManager addCellToSelection:rootCell modifier:0];
    [view insertLeftChild];
    [verifyCount(dataSource, times(2)) mindmapView:view addNewLeftChildToItem:rootCell.identifier atIndex:rootCell.leftChildren.count];
}

- (void)testNewLeftChildToNonRoot {
    [CELL(4) setFolded:YES];
    [stateManager addCellToSelection:CELL(4) modifier:0];
    [view insertLeftChild];
    [verify(dataSource) mindmapView:view toggleFoldingForItem:[CELL(4) identifier]];
    [verify(dataSource) mindmapView:view addNewChildToItem:[CELL(4) identifier] atIndex:[[CELL(4) children] count]];

    [LCELL(4) setFolded:NO];
    [stateManager addCellToSelection:LCELL(4) modifier:0];
    [view insertLeftChild];
    [verifyCount(dataSource, never()) mindmapView:view toggleFoldingForItem:[LCELL(4) identifier]];
    [verify(dataSource) mindmapView:view addNewChildToItem:[LCELL(4) identifier] atIndex:[[LCELL(4) children] count]];
}

- (void)testNewPrevSibling {
    [view insertPreviousSibling];
    [verifyCount(dataSource, never()) mindmapView:view addNewPreviousSiblingToItem:anything()];

    [stateManager addCellToSelection:CELL(4) modifier:0];
    [stateManager addCellToSelection:CELL(5) modifier:NSCommandKeyMask];
    [verifyCount(dataSource, never()) mindmapView:view addNewPreviousSiblingToItem:anything()];

    [stateManager addCellToSelection:CELL(4) modifier:0];
    [view insertPreviousSibling];
    [verify(dataSource) mindmapView:view addNewPreviousSiblingToItem:[CELL(4) identifier]];

    [stateManager addCellToSelection:LCELL(4) modifier:0];
    [view insertPreviousSibling];
    [verify(dataSource) mindmapView:view addNewPreviousSiblingToItem:[LCELL(4) identifier]];
}

- (void)testNewNextSibling {
    [view insertNextSibling];
    [verifyCount(dataSource, never()) mindmapView:view addNewNextSiblingToItem:anything()];

    [stateManager addCellToSelection:CELL(4) modifier:0];
    [stateManager addCellToSelection:CELL(5) modifier:NSCommandKeyMask];
    [verifyCount(dataSource, never()) mindmapView:view addNewNextSiblingToItem:anything()];

    [stateManager addCellToSelection:CELL(4) modifier:0];
    [view insertNextSibling];
    [verify(dataSource) mindmapView:view addNewNextSiblingToItem:[CELL(4) identifier]];

    [stateManager addCellToSelection:LCELL(4) modifier:0];
    [view insertNextSibling];
    [verify(dataSource) mindmapView:view addNewNextSiblingToItem:[LCELL(4) identifier]];
}

- (void)testMoveNonSelectedCell {
    [view moveRight:self];
    assertThat(@([stateManager hasSelectedCells]), isNo);

    [view moveLeft:self];
    assertThat(@([stateManager hasSelectedCells]), isNo);

    [view moveDown:self];
    assertThat(@([stateManager hasSelectedCells]), isNo);

    [view moveUp:self];
    assertThat(@([stateManager hasSelectedCells]), isNo);
}

- (void)testMoveRightToRightLeaf {
    [stateManager addCellToSelection:CELL(4, 4) modifier:0];
    [view moveRight:self];

    assertThat([stateManager selectedCells], consistsOf(CELL(4, 4)));
}

- (void)testMoveRightOnRightCell {
    [CELL(4) setFolded:YES];
    [self prepareCell:CELL(4) origin:NewPoint(0, 400) size:NewSize(100, 100)];
    [self prepareCell:CELL(4, 0) origin:NewPoint(150, 0) size:NewSize(100, 100)];
    [self prepareCell:CELL(4, 1) origin:NewPoint(150, 350) size:NewSize(100, 100)];
    [self prepareCell:CELL(4, 2) origin:NewPoint(150, 450) size:NewSize(100, 100)];

    for (int i = 3; i < NUMBER_OF_GRAND_CHILD; i++) {
        [self prepareCell:CELL(4, i) origin:NewPoint(150, 500 + i * 100) size:NewSize(25, 25)];
    }

    [stateManager addCellToSelection:CELL(4) modifier:0];
    [view moveRight:self];

    [verify(dataSource) mindmapView:view toggleFoldingForItem:[CELL(4) identifier]];
    assertThat([stateManager selectedCells], consistsOf(CELL(4, 1)));
}

- (void)testMoveRightOnRightCellNoOverlappingChild {
    [CELL(4) setFolded:YES];
    [self prepareCell:CELL(4) origin:NewPoint(0, 400) size:NewSize(100, 100)];
    [self prepareCell:CELL(4, 0) origin:NewPoint(150, 0) size:NewSize(100, 25)];
    [self prepareCell:CELL(4, 1) origin:NewPoint(150, 510) size:NewSize(100, 100)];
    [self prepareCell:CELL(4, 2) origin:NewPoint(150, 700) size:NewSize(100, 100)];

    for (int i = 3; i < NUMBER_OF_GRAND_CHILD; i++) {
        [self prepareCell:CELL(4, i) origin:NewPoint(150, 800 + i * 100) size:NewSize(25, 25)];
    }

    [stateManager addCellToSelection:CELL(4) modifier:0];
    [view moveRight:self];

    [verify(dataSource) mindmapView:view toggleFoldingForItem:[CELL(4) identifier]];
    assertThat([stateManager selectedCells], consistsOf(CELL(4, 1)));
}

- (void)testMoveRightOnLeftCell {
    [stateManager addCellToSelection:LCELL(4, 1) modifier:0];
    [view moveRight:self];

    assertThat([stateManager selectedCells], consistsOf(LCELL(4)));
}

- (void)testMoveRightOnRootCell {
    [self prepareCell:rootCell origin:NewPoint(0, 400) size:NewSize(100, 100)];
    [self prepareCell:CELL(0) origin:NewPoint(150, 0) size:NewSize(100, 100)];
    [self prepareCell:CELL(1) origin:NewPoint(150, 350) size:NewSize(100, 100)];
    [self prepareCell:CELL(2) origin:NewPoint(150, 450) size:NewSize(100, 100)];
    for (int i = 3; i < NUMBER_OF_GRAND_CHILD; i++) {
        [self prepareCell:CELL(i) origin:NewPoint(150, 500 + i * 100) size:NewSize(25, 25)];
    }

    [stateManager addCellToSelection:rootCell modifier:0];
    [view moveRight:self];

    assertThat([stateManager selectedCells], consistsOf(CELL(1)));
}

- (void)testMoveLeftToLeftLeaf {
    [stateManager addCellToSelection:LCELL(4, 4) modifier:0];
    [view moveLeft:self];

    assertThat([stateManager selectedCells], consistsOf(LCELL(4, 4)));
}

- (void)testMoveLeftOnRightCell {
    [stateManager addCellToSelection:CELL(4, 1) modifier:0];
    [view moveLeft:self];

    assertThat([stateManager selectedCells], consistsOf(CELL(4)));
}

- (void)testMoveLeftOnLeftCell {
    [LCELL(4) setFolded:YES];
    [self prepareCell:LCELL(4) origin:NewPoint(500, 400) size:NewSize(100, 100)];
    [self prepareCell:LCELL(4, 0) origin:NewPoint(150, 0) size:NewSize(100, 100)];
    [self prepareCell:LCELL(4, 1) origin:NewPoint(150, 350) size:NewSize(100, 100)];
    [self prepareCell:LCELL(4, 2) origin:NewPoint(150, 450) size:NewSize(100, 100)];

    for (int i = 3; i < NUMBER_OF_GRAND_CHILD; i++) {
        [self prepareCell:LCELL(4, i) origin:NewPoint(150, 500 + i * 100) size:NewSize(25, 25)];
    }

    [stateManager addCellToSelection:LCELL(4) modifier:0];
    [view moveLeft:self];

    [verify(dataSource) mindmapView:view toggleFoldingForItem:[LCELL(4) identifier]];
    assertThat([stateManager selectedCells], consistsOf(LCELL(4, 1)));
}

- (void)testMoveLeftOnRootCell {
    [self prepareCell:rootCell origin:NewPoint(500, 400) size:NewSize(100, 100)];
    [self prepareCell:LCELL(0) origin:NewPoint(150, 0) size:NewSize(100, 100)];
    [self prepareCell:LCELL(1) origin:NewPoint(150, 350) size:NewSize(100, 100)];
    [self prepareCell:LCELL(2) origin:NewPoint(150, 450) size:NewSize(100, 100)];

    for (int i = 3; i < NUMBER_OF_GRAND_CHILD; i++) {
        [self prepareCell:LCELL(i) origin:NewPoint(150, 500 + i * 100) size:NewSize(25, 25)];
    }

    [stateManager addCellToSelection:rootCell modifier:0];
    [view moveLeft:self];

    assertThat([stateManager selectedCells], consistsOf(LCELL(1)));
}

- (void)testCenterInView {
    // TODO: how can i set visible rect?
}

#pragma mark See Meta/Cell Test Cases.graffle
- (void)testMoveUp1 {
    [stateManager addCellToSelection:CELL(3, 3) modifier:0];
    [view moveUp:self];

    assertThat([stateManager selectedCells], consistsOf(CELL(3, 2)));
}

- (void)testMoveUp2Leaf {
    [CELL(3, 3) addObjectInChildren:[[QMCell alloc] initWithView:view]];
    [CELL(3, 3, 0) addObjectInChildren:[[QMCell alloc] initWithView:view]];

    [self prepareCell:CELL(3, 3, 0, 0) origin:NewPoint(900, 320) size:CELL_SIZE];
    [self prepareCell:CELL(3, 3, 0) origin:NewPoint(700, 320) size:CELL_SIZE];
    [self prepareCell:CELL(3, 3) origin:NewPoint(500, 320) size:CELL_SIZE];
    [self prepareCell:CELL(3, 2) origin:NewPoint(500, 260) size:CELL_SIZE];

    [stateManager addCellToSelection:CELL(3, 3, 0, 0) modifier:0];
    [view moveUp:self];

    assertThat([stateManager selectedCells], consistsOf(CELL(3, 2)));
}

- (void)testMoveUp2Folded {
    [CELL(3, 3) addObjectInChildren:[[QMCell alloc] initWithView:view]];
    [CELL(3, 3, 0) addObjectInChildren:[[QMCell alloc] initWithView:view]];
    [CELL(3, 2) addObjectInChildren:[[QMCell alloc] initWithView:view]];
    [CELL(3, 2) setFolded:YES];

    [self prepareCell:CELL(3, 3, 0, 0) origin:NewPoint(900, 320) size:CELL_SIZE];
    [self prepareCell:CELL(3, 3, 0) origin:NewPoint(700, 320) size:CELL_SIZE];
    [self prepareCell:CELL(3, 3) origin:NewPoint(500, 320) size:CELL_SIZE];
    [self prepareCell:CELL(3, 2) origin:NewPoint(500, 260) size:CELL_SIZE];
    [self prepareCell:CELL(3, 2, 0) origin:NewPoint(700, 260) size:CELL_SIZE];

    [stateManager addCellToSelection:CELL(3, 3, 0, 0) modifier:0];
    [view moveUp:self];

    assertThat([stateManager selectedCells], consistsOf(CELL(3, 2)));
}

- (void)testMoveUp3 {
    [CELL(3, 3) addObjectInChildren:[[QMCell alloc] initWithView:view]];
    [CELL(3, 3, 0) addObjectInChildren:[[QMCell alloc] initWithView:view]];
    [CELL(3, 2) addObjectInChildren:[[QMCell alloc] initWithView:view]];

    [self prepareCell:CELL(3, 3, 0, 0) origin:NewPoint(900, 320) size:CELL_SIZE];
    [self prepareCell:CELL(3, 3, 0) origin:NewPoint(700, 320) size:CELL_SIZE];
    [self prepareCell:CELL(3, 3) origin:NewPoint(500, 320) size:CELL_SIZE];
    [self prepareCell:CELL(3, 2) origin:NewPoint(500, 260) size:NewSize(390, 20)];
    [self prepareCell:CELL(3, 2, 0) origin:NewPoint(1070, 260) size:CELL_SIZE];

    [stateManager addCellToSelection:CELL(3, 3, 0, 0) modifier:0];
    [view moveUp:self];

    assertThat([stateManager selectedCells], consistsOf(CELL(3, 2)));
}

- (void)testMoveUp4 {
    [CELL(3, 3) addObjectInChildren:[[QMCell alloc] initWithView:view]];
    [CELL(3, 3, 0) addObjectInChildren:[[QMCell alloc] initWithView:view]];
    [CELL(3, 2) addObjectInChildren:[[QMCell alloc] initWithView:view]];
    [CELL(3, 2) addObjectInChildren:[[QMCell alloc] initWithView:view]];

    [self prepareCell:CELL(3, 3, 0, 0) origin:NewPoint(900, 350) size:CELL_SIZE];
    [self prepareCell:CELL(3, 3, 0) origin:NewPoint(700, 350) size:CELL_SIZE];
    [self prepareCell:CELL(3, 3) origin:NewPoint(500, 300) size:CELL_SIZE];
    [self prepareCell:CELL(3, 2) origin:NewPoint(500, 230) size:CELL_SIZE];
    [self prepareCell:CELL(3, 2, 0) origin:NewPoint(930, 240) size:CELL_SIZE];
    [self prepareCell:CELL(3, 2, 1) origin:NewPoint(930, 260) size:CELL_SIZE];

    [stateManager addCellToSelection:CELL(3, 3, 0, 0) modifier:0];
    [view moveUp:self];

    assertThat([stateManager selectedCells], consistsOf(CELL(3, 2, 1)));
}

- (void)testMoveUp5 {
    [self prepareCell:CELL(0) origin:NewPoint(500, 260) size:CELL_SIZE];
    [self prepareCell:CELL(0, 0) origin:NewPoint(500, 260) size:CELL_SIZE];

    [stateManager addCellToSelection:CELL(0, 0) modifier:0];
    [view moveUp:self];

    assertThat([stateManager selectedCells], consistsOf(CELL(0, 0)));
}

- (void)testMoveUp6 {
    [CELL(3, 3) addObjectInChildren:[[QMCell alloc] initWithView:view]];
    [CELL(3, 3, 0) addObjectInChildren:[[QMCell alloc] initWithView:view]];
    [CELL(3, 2) addObjectInChildren:[[QMCell alloc] initWithView:view]];

    [self prepareCell:CELL(3, 3, 0, 0) origin:NewPoint(900, 260) size:CELL_SIZE];
    [self prepareCell:CELL(3, 3, 0) origin:NewPoint(700, 260) size:CELL_SIZE];
    [self prepareCell:CELL(3, 3) origin:NewPoint(500, 260) size:CELL_SIZE];
    [self prepareCell:CELL(3, 2) origin:NewPoint(500, 320) size:NewSize(390, 20)];
    [self prepareCell:CELL(3, 2, 0) origin:NewPoint(950, 320) size:NewSize(180, 20)];

    [stateManager addCellToSelection:CELL(3, 3, 0, 0) modifier:0];
    [view moveUp:self];

    assertThat([stateManager selectedCells], consistsOf(CELL(3, 2, 0)));
}

- (void)testMoveDown1 {
    [stateManager addCellToSelection:CELL(3, 2) modifier:0];
    [view moveDown:self];

    assertThat([stateManager selectedCells], consistsOf(CELL(3, 3)));
}

- (void)testMoveDown2Leaf {
    [CELL(3, 2) addObjectInChildren:[[QMCell alloc] initWithView:view]];
    [CELL(3, 2, 0) addObjectInChildren:[[QMCell alloc] initWithView:view]];

    [self prepareCell:CELL(3, 2, 0, 0) origin:NewPoint(900, 260) size:CELL_SIZE];
    [self prepareCell:CELL(3, 2, 0) origin:NewPoint(700, 260) size:CELL_SIZE];
    [self prepareCell:CELL(3, 2) origin:NewPoint(500, 260) size:CELL_SIZE];
    [self prepareCell:CELL(3, 3) origin:NewPoint(500, 320) size:CELL_SIZE];

    [stateManager addCellToSelection:CELL(3, 2, 0, 0) modifier:0];
    [view moveDown:self];

    assertThat([stateManager selectedCells], consistsOf(CELL(3, 3)));
}

- (void)testMoveDown2Folded {
    [CELL(3, 2) addObjectInChildren:[[QMCell alloc] initWithView:view]];
    [CELL(3, 2, 0) addObjectInChildren:[[QMCell alloc] initWithView:view]];
    [CELL(3, 3) addObjectInChildren:[[QMCell alloc] initWithView:view]];
    [CELL(3, 3) setFolded:YES];

    [self prepareCell:CELL(3, 2, 0, 0) origin:NewPoint(900, 260) size:CELL_SIZE];
    [self prepareCell:CELL(3, 2, 0) origin:NewPoint(700, 260) size:CELL_SIZE];
    [self prepareCell:CELL(3, 2) origin:NewPoint(500, 260) size:CELL_SIZE];
    [self prepareCell:CELL(3, 3) origin:NewPoint(500, 320) size:CELL_SIZE];
    [self prepareCell:CELL(3, 3, 0) origin:NewPoint(700, 320) size:CELL_SIZE];

    [stateManager addCellToSelection:CELL(3, 2, 0, 0) modifier:0];
    [view moveDown:self];

    assertThat([stateManager selectedCells], consistsOf(CELL(3, 3)));
}

- (void)testMoveDown3 {
    [CELL(3, 2) addObjectInChildren:[[QMCell alloc] initWithView:view]];
    [CELL(3, 2, 0) addObjectInChildren:[[QMCell alloc] initWithView:view]];
    [CELL(3, 3) addObjectInChildren:[[QMCell alloc] initWithView:view]];

    [self prepareCell:CELL(3, 2, 0, 0) origin:NewPoint(900, 260) size:CELL_SIZE];
    [self prepareCell:CELL(3, 2, 0) origin:NewPoint(700, 260) size:CELL_SIZE];
    [self prepareCell:CELL(3, 2) origin:NewPoint(500, 260) size:CELL_SIZE];
    [self prepareCell:CELL(3, 3) origin:NewPoint(500, 320) size:NewSize(390, 20)];
    [self prepareCell:CELL(3, 3, 0) origin:NewPoint(1070, 320) size:CELL_SIZE];

    [stateManager addCellToSelection:CELL(3, 2, 0, 0) modifier:0];
    [view moveDown:self];

    assertThat([stateManager selectedCells], consistsOf(CELL(3, 3)));
}

- (void)testMoveDown4 {
    [CELL(3, 2) addObjectInChildren:[[QMCell alloc] initWithView:view]];
    [CELL(3, 2, 0) addObjectInChildren:[[QMCell alloc] initWithView:view]];
    [CELL(3, 3) addObjectInChildren:[[QMCell alloc] initWithView:view]];
    [CELL(3, 3) addObjectInChildren:[[QMCell alloc] initWithView:view]];

    [self prepareCell:CELL(3, 2, 0, 0) origin:NewPoint(900, 260) size:CELL_SIZE];
    [self prepareCell:CELL(3, 2, 0) origin:NewPoint(700, 260) size:CELL_SIZE];
    [self prepareCell:CELL(3, 2) origin:NewPoint(500, 260) size:CELL_SIZE];
    [self prepareCell:CELL(3, 3) origin:NewPoint(500, 320) size:CELL_SIZE];
    [self prepareCell:CELL(3, 3, 0) origin:NewPoint(930, 300) size:CELL_SIZE];
    [self prepareCell:CELL(3, 3, 1) origin:NewPoint(930, 320) size:CELL_SIZE];

    [stateManager addCellToSelection:CELL(3, 2, 0, 0) modifier:0];
    [view moveDown:self];

    assertThat([stateManager selectedCells], consistsOf(CELL(3, 3, 0)));
}

- (void)testMoveDown5 {
    [self prepareCell:CELL(NUMBER_OF_CHILD - 1) origin:NewPoint(500, 260) size:CELL_SIZE];
    [self prepareCell:CELL(NUMBER_OF_CHILD - 1, NUMBER_OF_GRAND_CHILD - 1) origin:NewPoint(500, 260) size:CELL_SIZE];

    [stateManager addCellToSelection:CELL(NUMBER_OF_CHILD - 1, NUMBER_OF_GRAND_CHILD - 1) modifier:0];
    [view moveDown:self];

    assertThat([stateManager selectedCells], consistsOf(CELL(NUMBER_OF_CHILD - 1, NUMBER_OF_GRAND_CHILD - 1)));
}

- (void)testMoveDown6 {
    [CELL(3, 2) addObjectInChildren:[[QMCell alloc] initWithView:view]];
    [CELL(3, 2, 0) addObjectInChildren:[[QMCell alloc] initWithView:view]];
    [CELL(3, 3) addObjectInChildren:[[QMCell alloc] initWithView:view]];

    [self prepareCell:CELL(3, 2, 0, 0) origin:NewPoint(900, 260) size:CELL_SIZE];
    [self prepareCell:CELL(3, 2, 0) origin:NewPoint(700, 260) size:CELL_SIZE];
    [self prepareCell:CELL(3, 2) origin:NewPoint(500, 260) size:CELL_SIZE];
    [self prepareCell:CELL(3, 3) origin:NewPoint(500, 320) size:NewSize(390, 20)];
    [self prepareCell:CELL(3, 3, 0) origin:NewPoint(950, 320) size:NewSize(190, 20)];

    [stateManager addCellToSelection:CELL(3, 2, 0, 0) modifier:0];
    [view moveDown:self];

    assertThat([stateManager selectedCells], consistsOf(CELL(3, 3, 0)));
}

- (void)testMoveUpOrDownOnRootCell {
    [stateManager addCellToSelection:rootCell modifier:0];

    [view moveUp:self];
    assertThat([stateManager selectedCells], consistsOf(rootCell));

    [view moveDown:self];
    assertThat([stateManager selectedCells], consistsOf(rootCell));
}

#pragma mark Private
- (void)prepareCell:(QMCell *)cell origin:(NSPoint)origin size:(NSSize)size {
    [cell setInstanceVarTo:cellSizeManager];
    [cell setOrigin:origin];
    [given([cellSizeManager sizeOfCell:cell]) willReturnSize:size];
}

@end
