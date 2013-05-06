#import "QMRootCell.h"
#import "QMMindmapView.h"/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <objc/message.h>
#import "QMBaseTestCase.h"
#import "QMRootNode.h"
#import "QMBaseTestCase+Util.h"
#import "QMCellPropertiesManager.h"
#import "QMMindmapViewDataSourceImpl.h"
#import "QMDocument.h"

@interface QMCellPropertiesManagerTest : QMBaseTestCase
@end

@implementation QMCellPropertiesManagerTest {
    QMRootNode *rootNode;

    QMDocument *doc;
    id <QMMindmapViewDataSource> dataSource;
    QMCellPropertiesManager *populator;
    QMMindmapView *view;

    QMRootCell *rootCell;
}

- (void)setUp {
    rootNode = [self rootNodeForTest];

    doc = [[QMDocument alloc] init];
    wireRootNodeOfDoc(doc, rootNode);
    [doc setUndoManager:mock([NSUndoManager class])];

    view = mock(QMMindmapView.class);
    dataSource = [[QMMindmapViewDataSourceImpl alloc] initWithDoc:doc view:view];
    [given([view dataSource]) willReturn:dataSource];

    populator = [[QMCellPropertiesManager alloc] initWithDataSource:view];
    rootCell = (QMRootCell *) [populator cellWithParent:nil itemOfParent:nil];
}

/**
* The following test tests all public methods of QMCellPropertiesManager
*
* @bug
* cell.view was nil
*/
- (void)testPopulateCells {
    assertThat(rootCell.view, is(view));

    BOOL (^checkCellAndNode)(QMCell *, QMNode *) = ^(QMCell *cell, QMNode *node) {
        assertThat(cell.identifier, is(node));
        assertThat(@(cell.isFolded), is(@(node.isFolded)));
        assertThat(@(cell.isLeaf), is(@(node.isLeaf)));
        assertThat(cell.stringValue, equalTo(node.stringValue));
        assertThat(cell.children, hasSize(node.children.count));
        assertThat(cell.icons, hasSize(node.icons.count));
        assertThat(cell.view, is(view));
        if (cell.font != nil) {
            assertThat(node.font, notNilValue());
        }

        return YES;
    };

    BOOL result = [self deepCompareStructureOfCell:rootCell
                                          withNode:rootNode
                            ignoringFoldedChildren:NO
                                        usingBlock:checkCellAndNode];

    assertThat(@(result), isYes);
}

@end
