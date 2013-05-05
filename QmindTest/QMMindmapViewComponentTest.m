/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import "QMRootCell.h"
#import "QMBaseTestCase.h"
#import "QMNode.h"
#import "QMRootNode.h"
#import "QMBaseTestCase+Util.h"
#import "QMCellEditor.h"
#import "QMCellStateManager.h"
#import "QMDocumentWindowController.h"
#import "QMMindmapView.h"
#import "QMDocument.h"
#import "QMCacaoTestCase.h"
#import "QMMindmapViewDataSourceImpl.h"
#import "QMIcon.h"

@interface QMMindmapViewComponentTest : QMCacaoTestCase
@end

@implementation QMMindmapViewComponentTest {
    QMMindmapView *view;

    QMRootNode *rootNode;
    QMRootCell *rootCell;
    QMDocument *doc;
    QMDocumentWindowController *windowController;
    QMMindmapViewDataSourceImpl *dataSource;
    QMCellEditor *editor;
    QMCellStateManager *manager;
}

- (void)setUp {
    [super setUp];

    doc = [[QMDocument alloc] init];
    rootNode = [self rootNodeForTest];

    wireRootNodeOfDoc(doc, rootNode);
    [doc setUndoManager:mock([NSUndoManager class])];

    windowController = [[QMDocumentWindowController alloc] init];
    windowController.document = doc;
    [windowController setInstanceVarTo:doc];
    [windowController windowDidLoad];

    editor = mock([QMCellEditor class]);
    manager = mock([QMCellStateManager class]);
    view = [[QMMindmapView alloc] init];

    dataSource = [[QMMindmapViewDataSourceImpl alloc] initWithDoc:doc view:view];

    [windowController setInstanceVarTo:dataSource implementingProtocol:@protocol(QMMindmapViewDataSource)];

    [view initMindmapViewWithDataSource:dataSource];
    [view setInstanceVarTo:editor];
    [view setInstanceVarTo:manager];
    rootCell = view.rootCell;
}

- (void)testUpdateCellForIcons {
    [NODE(1) addObjectInIcons:@"password"];
    [NODE(1) addObjectInIcons:@"pencil"];
    [view initMindmapViewWithDataSource:dataSource];
    rootCell = view.rootCell;
    
    [NODE(1) addObjectInIcons:@"full-1"];
    [view updateCellWithIdentifier:NODE(1)];
    NSArray *icons = [CELL(1) icons];
    assertThat(icons, hasSize(3));

    QMIcon *icon1 = icons[0];
    assertThat([icon1 code], is(@"password"));
    QMIcon *icon2 = icons[1];
    assertThat([icon2 code], is(@"pencil"));
    QMIcon *icon3 = icons[2];
    assertThat([icon3 code], is(@"full-1"));
}

- (void)testUpdateCellFolding {
    [NODE(1) setFolded:YES];
    [view initMindmapViewWithDataSource:dataSource];
    rootCell = view.rootCell;

    NSSize oldFamilySize = [CELL(1) familySize];

    [NODE(1) setFolded:NO];
    [view updateCellFoldingWithIdentifier:NODE(1)];

    assertThat(@([CELL(1) isFolded]), isNo);
    assertThat([CELL(1) children], hasSize(NUMBER_OF_GRAND_CHILD));
    assertThatSize([CELL(1) familySize], biggerThanSize(oldFamilySize));

    // we cannot yet do things like
    // [verify(clipView) setBoundsOrigin:anyPoint()]...
}

- (void)testUpdateCellFamilyForNewCell {
    [view updateCellFamily:NODE(1) forNewCell:NODE(1, 6)];
    [verify(manager) clearSelection];
    [verify(manager) addCellToSelection:CELL(1, 6) modifier:0];
    [verify(editor) beginEditStringValueForCell:CELL(1, 6)];

    [view updateLeftCellFamily:LNODE(1) forNewCell:LNODE(1, 6)];
    [verifyCount(manager, times(2)) clearSelection];
    [verify(manager) addCellToSelection:LCELL(1, 6) modifier:0];
    [verify(editor) beginEditStringValueForCell:LCELL(1, 6)];
}

- (void)testUpdateRootCellFamilyForDeletionFromRoot {
    NSUInteger oldCount = [rootNode countOfChildren];
    NSPoint oldOrigin = [CELL(2) origin];
    [doc deleteItem:NODE(1)];

    // KVO here not working because doc->windowController and windowController->view are not properly set
    QMCell *delCell = CELL(1);
    [view updateCellFamilyForRemovalWithIdentifier:rootNode];
    rootCell = view.rootCell;
    assertThat(rootCell.children, hasSize(oldCount - 1));
    assertThat(rootCell.children, isNot(hasItem(delCell)));
    assertThatPoint([CELL(1) origin], isNot(equalToPoint(oldOrigin)));

    oldCount = [rootNode countOfLeftChildren];
    oldOrigin = [LCELL(6) origin];
    [doc deleteItem:LNODE(5)];

    // KVO here not working because doc->windowController and windowController->view are not properly set
    delCell = LCELL(5);
    [view updateLeftCellFamilyForRemovalWithIdentifier:rootNode];
    rootCell = view.rootCell;
    assertThat(rootCell.leftChildren, hasSize(oldCount - 1));
    assertThat(rootCell.leftChildren, isNot(hasItem(delCell)));
    assertThatPoint([[rootCell objectInLeftChildrenAtIndex:5] origin], isNot(equalToPoint(oldOrigin)));
}

- (void)testUpdateCellFamilyForRightDeletionToLeafRoot {
    [doc deleteItem:NODE(4)];

    // KVO here not working because doc->windowController and windowController->view are not properly set
    NSSize oldSize = rootCell.familySize;
    [view updateCellFamilyForRemovalWithIdentifier:rootNode];
    rootCell = view.rootCell;
    assertThat([rootCell children], hasSize(NUMBER_OF_CHILD - 1));
    assertThatSize([rootCell familySize], smallerThanSize(oldSize));
}

- (void)testUpdateCellFamilyForLeftDeletionToLeafRoot {
    [doc deleteItem:LNODE(2)];

    // KVO here not working because doc->windowController and windowController->view are not properly set
    NSSize oldSize = rootCell.familySize;
    [view updateLeftCellFamilyForRemovalWithIdentifier:rootNode];
    rootCell = view.rootCell;
    assertThat([rootCell leftChildren], hasSize(NUMBER_OF_LEFT_CHILD - 1));
    assertThatSize([rootCell familySize], smallerThanSize(oldSize));
}

- (void)testUpdateCellFamilyForDeletionToLeaf {
    [doc deleteItem:NODE(3, 1)];

    // KVO here not working because doc->windowController and windowController->view are not properly set
    NSSize oldSize = [CELL(3) familySize];
    [view updateCellFamilyForRemovalWithIdentifier:NODE(3)];
    rootCell = view.rootCell;
    assertThat([CELL(3) children], hasSize(NUMBER_OF_GRAND_CHILD - 1));
    assertThatSize([CELL(3) familySize], smallerThanSize(oldSize));

    [doc deleteItem:LNODE(2, 5)];

    // KVO here not working because doc->windowController and windowController->view are not properly set
    oldSize = [LCELL(2) familySize];
    [view updateCellFamilyForRemovalWithIdentifier:LNODE(2)];
    rootCell = view.rootCell;
    assertThat([LCELL(2) children], hasSize(NUMBER_OF_LEFT_GRAND_CHILD - 1));
    assertThatSize([LCELL(2) familySize], smallerThanSize(oldSize));
}

- (void)testUpdateCellFamilyForDeletion {
    NSUInteger oldCount = [NODE(1) countOfChildren];
    NSSize oldSize = [CELL(1) familySize];
    [doc deleteItem:NODE(1, 5)];

    // KVO here not working because doc->windowController and windowController->view are not properly set
    QMCell *delCell = CELL(1, 5);
    [view updateCellFamilyForRemovalWithIdentifier:NODE(1)];
    rootCell = view.rootCell;
    assertThat([CELL(1) children], hasSize(oldCount - 1));
    assertThat([CELL(1) children], isNot(hasItem(delCell)));
    assertThatSize([CELL(1) familySize], smallerThanSize(oldSize));

    oldCount = [LNODE(5) countOfChildren];
    oldSize = [LCELL(5) familySize];
    [doc deleteItem:LNODE(5, 4)];

    // KVO here not working because doc->windowController and windowController->view are not properly set
    delCell = LCELL(5, 4);
    [view updateCellFamilyForRemovalWithIdentifier:LNODE(5)];
    rootCell = view.rootCell;
    assertThat([LCELL(5) children], hasSize(oldCount - 1));
    assertThat([LCELL(5) children], isNot(hasItem(delCell)));
    assertThatSize([LCELL(5) familySize], smallerThanSize(oldSize));
}

- (void)testUpdateCellFamilyForRightInsertionForComplEmptyRoot {
    rootNode = [[QMRootNode alloc] init];
    rootNode.stringValue = @"empty root";
    wireRootNodeOfDoc(doc, rootNode);
    view = [[QMMindmapView alloc] init];
    [[TBContext sharedContext] autowireSeed:view];
    [view setHidden:YES];

    [view initMindmapViewWithDataSource:dataSource];
    rootCell = view.rootCell;

    // right side
    [rootNode insertObject:[[QMNode alloc] init] inChildrenAtIndex:0];

    // KVO here not working because doc->windowController and windowController->view are not properly set
    NSSize oldSize = [rootCell familySize];
    [view updateCellFamilyForInsertionWithIdentifier:rootNode];
    rootCell = view.rootCell;
    assertThat([rootCell children], hasSize(1));
    assertThat([rootCell leftChildren], hasSize(0));
    assertThatSize([rootCell familySize], biggerThanSize(oldSize));
}

- (void)testUpdateCellFamilyForLeftInsertionForComplEmptyRoot {
    rootNode = [[QMRootNode alloc] init];
    rootNode.stringValue = @"empty root";
    wireRootNodeOfDoc(doc, rootNode);
    view = [[QMMindmapView alloc] init];
    [view setHidden:YES];

    [view initMindmapViewWithDataSource:dataSource];
    rootCell = view.rootCell;

    // right side
    [rootNode insertObject:[[QMNode alloc] init] inLeftChildrenAtIndex:0];

    // KVO here not working because doc->windowController and windowController->view are not properly set
    NSSize oldSize = [rootCell familySize];
    [view updateLeftCellFamilyForInsertionWithIdentifier:rootNode];
    rootCell = view.rootCell;
    assertThat([rootCell leftChildren], hasSize(1));
    assertThat([rootCell children], hasSize(0));
    assertThatSize([rootCell familySize], biggerThanSize(oldSize));
}

- (void)testUpdateCellFamilyForInsertionForRoot {
    NSUInteger oldCount = [rootNode countOfChildren];
    NSPoint oldOrigin = [CELL(3) origin];
    [rootNode insertObject:[[QMNode alloc] init] inChildrenAtIndex:3];

    // KVO here not working because doc->windowController and windowController->view are not properly set
    [view updateCellFamilyForInsertionWithIdentifier:rootNode];
    rootCell = view.rootCell;
    assertThat([rootCell children], hasSize(oldCount + 1));
    assertThatPoint([CELL(4) origin], isNot(equalToPoint(oldOrigin)));

    oldCount = [rootNode countOfLeftChildren];
    oldOrigin = [LCELL(7) origin];
    [rootNode insertObject:[[QMNode alloc] init] inLeftChildrenAtIndex:7];

    // KVO here not working because doc->windowController and windowController->view are not properly set
    [view updateLeftCellFamilyForInsertionWithIdentifier:rootNode];
    rootCell = view.rootCell;
    assertThat([rootCell leftChildren], hasSize(oldCount + 1));
    assertThatPoint([LCELL(8) origin], isNot(equalToPoint(oldOrigin)));
}

/**
* @bug
*/
- (void)testWhetherLeftIsSetForRoot {
    rootNode = [[QMRootNode alloc] init];
    rootNode.stringValue = @"root";

    QMNode *childNode = [[QMNode alloc] init];
    childNode.stringValue = @"child";

    QMNode *grandChildNode1 = [[QMNode alloc] init];
    childNode.stringValue = @"grand child 1";

    QMNode *grandChildNode2 = [[QMNode alloc] init];
    childNode.stringValue = @"grand child 2";

    [childNode addObjectInChildren:grandChildNode1];
    [childNode addObjectInChildren:grandChildNode2];

    wireRootNodeOfDoc(doc, rootNode);

    view = [[QMMindmapView alloc] init];
    [view initMindmapViewWithDataSource:dataSource];
    rootCell = view.rootCell;

    [rootNode insertObject:childNode inLeftChildrenAtIndex:0];

    // KVO here not working because doc->windowController and windowController->view are not properly set
    [view updateLeftCellFamilyForInsertionWithIdentifier:rootNode];
    rootCell = view.rootCell;

    assertThat(@([LCELL(0) isLeft]), isYes);
    assertThat(@([LCELL(0, 0) isLeft]), isYes);
    assertThat(@([LCELL(0, 1) isLeft]), isYes);
}

/**
* @bug
*/
- (void)testWhetherLeftIsSet {
    rootNode = [[QMRootNode alloc] init];
    rootNode.stringValue = @"root";

    QMNode *zerothChild = [[QMNode alloc] init];
    zerothChild.stringValue = @"zero";

    QMNode *childNode = [[QMNode alloc] init];
    childNode.stringValue = @"child";

    QMNode *grandChildNode1 = [[QMNode alloc] init];
    childNode.stringValue = @"grand child 1";

    QMNode *grandChildNode2 = [[QMNode alloc] init];
    childNode.stringValue = @"grand child 2";

    [childNode addObjectInChildren:grandChildNode1];
    [childNode addObjectInChildren:grandChildNode2];

    [rootNode addObjectInLeftChildren:zerothChild];
    [zerothChild addObjectInChildren:childNode];

    wireRootNodeOfDoc(doc, rootNode);
    view = [[QMMindmapView alloc] init];
    [view setHidden:YES];
    
    [view initMindmapViewWithDataSource:dataSource];
    rootCell = view.rootCell;

    // KVO here not working because doc->windowController and windowController->view are not properly set
    [view updateCellFamilyForInsertionWithIdentifier:zerothChild];
    rootCell = view.rootCell;

    assertThat(@([LCELL(0, 0) isLeft]), isYes);
    assertThat(@([LCELL(0, 0, 0) isLeft]), isYes);
    assertThat(@([LCELL(0, 0, 1) isLeft]), isYes);
}

- (void)testUpdateCellFamilyForInsertion {
    // right child
    NSUInteger oldCount = [NODE(1) countOfChildren];
    NSSize oldSize = [CELL(1) familySize];
    [NODE(1) insertObject:[[QMNode alloc] init] inChildrenAtIndex:3];

    // KVO here not working because doc->windowController and windowController->view are not properly set
    [view updateCellFamilyForInsertionWithIdentifier:NODE(1)];
    rootCell = view.rootCell;
    assertThat([CELL(1) children], hasSize(oldCount + 1));
    assertThatSize([CELL(1) familySize], biggerThanSize(oldSize));

    // left child
    oldCount = [LNODE(5) countOfChildren];
    oldSize = [LCELL(5) familySize];
    [LNODE(5) insertObject:[[QMNode alloc] init] inChildrenAtIndex:3];

    // KVO here not working because doc->windowController and windowController->view are not properly set
    [view updateCellFamilyForInsertionWithIdentifier:LNODE(5)];
    rootCell = view.rootCell;
    assertThat([LCELL(5) children], hasSize(oldCount + 1));
    assertThatSize([LCELL(5) familySize], biggerThanSize(oldSize));
    assertThat(@([LCELL(5, 3) isLeft]), isYes);

    // left leaf + child
    oldSize = [LCELL(5, 8) familySize];
    [LNODE(5, 8) insertObject:[[QMNode alloc] init] inChildrenAtIndex:0];

    // KVO here not working because doc->windowController and windowController->view are not properly set
    [view updateCellFamilyForInsertionWithIdentifier:LNODE(5, 8)];
    rootCell = view.rootCell;
    assertThat([LCELL(5, 8) children], hasSize(1));
    assertThatSize([LCELL(5, 8) familySize], biggerThanSize(oldSize));
    assertThat(@([LCELL(5, 8, 0) isLeft]), isYes);

    // right leaf + child
    oldSize = [CELL(5, 8) familySize];
    [NODE(5, 8) insertObject:[[QMNode alloc] init] inChildrenAtIndex:0];

    // KVO here not working because doc->windowController and windowController->view are not properly set
    [view updateCellFamilyForInsertionWithIdentifier:NODE(5, 8)];
    rootCell = view.rootCell;
    assertThat([CELL(5, 8) children], hasSize(1));
    assertThatSize([CELL(5, 8) familySize], biggerThanSize(oldSize));
}

/**
* @bug
*/
- (void)testCellFamilyUpdateForInsertionOfLastNode {
    // right child
    NSUInteger oldCount = [NODE(1) countOfChildren];
    NSSize oldSize = [CELL(1) familySize];
    QMNode *node = NODE(1);
    [node insertObject:[[QMNode alloc] init] inChildrenAtIndex:[NODE(1) countOfChildren]];

    // KVO here not working because doc->windowController and windowController->view are not properly set
    [view updateCellFamilyForInsertionWithIdentifier:NODE(1)];
    rootCell = view.rootCell;
    assertThat([CELL(1) children], hasSize(oldCount + 1));
    assertThatSize([CELL(1) familySize], biggerThanSize(oldSize));

    // left child
    oldCount = [LNODE(5) countOfChildren];
    oldSize = [LCELL(5) familySize];
    [LNODE(5) insertObject:[[QMNode alloc] init] inChildrenAtIndex:[LNODE(5) countOfChildren]];

    // KVO here not working because doc->windowController and windowController->view are not properly set
    [view updateCellFamilyForInsertionWithIdentifier:LNODE(5)];
    rootCell = view.rootCell;
    assertThat([LCELL(5) children], hasSize(oldCount + 1));
    assertThatSize([LCELL(5) familySize], biggerThanSize(oldSize));

    // left leaf + child
    oldSize = [LCELL(5, 8) familySize];
    [LNODE(5, 8) insertObject:[[QMNode alloc] init] inChildrenAtIndex:0];
}

/**
* @bug
*/
- (void)testRootCellFamilyUpdateForInsertionOfLastNode {
    NSUInteger oldCount = [rootNode countOfChildren];
    NSPoint oldOrigin = [CELL(3) origin];
    [rootNode insertObject:[[QMNode alloc] init] inChildrenAtIndex:[rootNode countOfChildren]];

    // KVO here not working because doc->windowController and windowController->view are not properly set
    [view updateCellFamilyForInsertionWithIdentifier:rootNode];
    rootCell = view.rootCell;
    assertThat([rootCell children], hasSize(oldCount + 1));
    assertThatPoint([CELL(4) origin], isNot(equalToPoint(oldOrigin)));

    oldCount = [rootNode countOfLeftChildren];
    oldOrigin = [LCELL(7) origin];
    [rootNode insertObject:[[QMNode alloc] init] inLeftChildrenAtIndex:[rootNode countOfLeftChildren]];

    // KVO here not working because doc->windowController and windowController->view are not properly set
    [view updateLeftCellFamilyForInsertionWithIdentifier:rootNode];
    rootCell = view.rootCell;
    assertThat([rootCell leftChildren], hasSize(oldCount + 1));
    assertThatPoint([LCELL(8) origin], isNot(equalToPoint(oldOrigin)));
}

- (void)testInitAndPopulateCell {
    BOOL (^checkCellAndNode)(QMCell *, QMNode *) = ^(QMCell *cell, QMNode *node) {
        /**
         * The details are tested in QMCellPropertiesManagerTest.
         * Here we only test whether the cells are instantiated.
         */
        assertThat(cell.identifier, is(node));

        return YES;
    };

    BOOL result = [self deepCompareStructureOfCell:rootCell
                                          withNode:rootNode
                            ignoringFoldedChildren:NO usingBlock:checkCellAndNode];

    assertThat(@(result), isYes);
}

@end
