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
#import "QMCellPopulator.h"
#import "QMMindmapViewDataSourceImpl.h"
#import "QMDocument.h"

@interface QMCellPopulatorTest : QMBaseTestCase
@end

@implementation QMCellPopulatorTest {
    QMRootNode *rootNode;

    QMDocument *doc;
    id <QMMindmapViewDataSource> dataSource;
    QMCellPopulator *populator;

    QMRootCell *rootCell;
}

- (void)setUp {
    rootNode = [self rootNodeForTest];

    doc = [[QMDocument alloc] init];
    wireRootNodeOfDoc(doc, rootNode);
    [doc setUndoManager:mock([NSUndoManager class])];

    dataSource = [[QMMindmapViewDataSourceImpl alloc] initWithDoc:doc view:nil];

    populator = [[QMCellPopulator alloc] initWithDataSource:dataSource];
    rootCell = (QMRootCell *) [populator cellWithParent:nil itemOfParent:nil];
}

- (void)testInitAndPopulateCell {
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

#pragma mark Private
- (BOOL)deepCompareStructureOfCell:(id)cell
                          withNode:(id)node
            ignoringFoldedChildren:(BOOL)ignoreFolded
                        usingBlock:(BOOL (^)(QMCell *, QMNode *))compare {

    if (compare(cell, node) == NO) {
        return NO;
    }

    if ([cell isFolded] && ignoreFolded) {
        return YES;
    }

    NSArray *sourceChildCells;
    NSArray *targetChildCells;

    if ([cell isRoot]) {
        sourceChildCells = [[cell children] arrayByAddingObjectsFromArray:[cell leftChildren]];
        targetChildCells = [[node children] arrayByAddingObjectsFromArray:[node leftChildren]];
    } else {
        sourceChildCells = [cell children];
        targetChildCells = [node children];
    }

    id childCell;
    id childNode;

    for (NSUInteger i = 0; i < [sourceChildCells count]; i++) {
        childCell = [sourceChildCells objectAtIndex:i];
        childNode = [targetChildCells objectAtIndex:i];

        BOOL resultOfChildren = [self deepCompareStructureOfCell:childCell
                                                        withNode:childNode
                                          ignoringFoldedChildren:ignoreFolded
                                                      usingBlock:compare];

        if (resultOfChildren == NO) {
            return NO;
        }
    }

    return YES;
}

@end
