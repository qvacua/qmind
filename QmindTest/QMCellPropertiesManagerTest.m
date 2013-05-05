/**
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

    QMRootCell *rootCell;
}

- (void)setUp {
    rootNode = [self rootNodeForTest];

    doc = [[QMDocument alloc] init];
    wireRootNodeOfDoc(doc, rootNode);
    [doc setUndoManager:mock([NSUndoManager class])];

    dataSource = [[QMMindmapViewDataSourceImpl alloc] initWithDoc:doc view:nil];

    populator = [[QMCellPropertiesManager alloc] initWithDataSource:dataSource];
    rootCell = (QMRootCell *) [populator cellWithParent:nil itemOfParent:nil];
}

/**
* The following test tests all public methods of QMCellPropertiesManager
*/
- (void)testPopulateCells {
    BOOL (^checkCellAndNode)(QMCell *, QMNode *) = ^(QMCell *cell, QMNode *node) {
        assertThat(cell.identifier, is(node));
        assertThat(@(cell.isFolded), is(@(node.isFolded)));
        assertThat(@(cell.isLeaf), is(@(node.isLeaf)));
        assertThat(cell.stringValue, equalTo(node.stringValue));
        assertThat(cell.children, hasSize(node.children.count));
        assertThat(cell.icons, hasSize(node.icons.count));
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
