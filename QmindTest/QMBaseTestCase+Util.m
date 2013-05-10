/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import "QMBaseTestCase+Util.h"
#import "QMRootCell.h"
#import "QMRootNode.h"
#import "QMMindmapView.h"
#import "QMDocument.h"
#import <objc/message.h>

id item_coord(id root, ...) {
    va_list coord;
    va_start(coord, root);
    int index = va_arg(coord, int);
    id item = root;
    while (index >= 0) {
        item = [item objectInChildrenAtIndex:(NSUInteger)index];
        index = va_arg(coord, int);
    }
    va_end(coord);

    return item;
}

id left_item_coord(id root, ...) {
    va_list coord;
    va_start(coord, root);
    int index = va_arg(coord, int);
    id item = [root objectInLeftChildrenAtIndex:(NSUInteger)index];

    index = va_arg(coord, int);
    if (index < 0) {
        return item;
    }

    while (index >= 0) {
        item = [item objectInChildrenAtIndex:(NSUInteger)index];
        index = va_arg(coord, int);
    }
    va_end(coord);

    return item;
}

void wireRootNodeOfDoc(QMDocument *doc, QMRootNode *rootNode) {
    QMRootNode *oldRootNode = [doc instanceVarOfClass:[QMRootNode class]];
    [oldRootNode removeObserver:doc];

    [doc setInstanceVarTo:rootNode];

    objc_msgSend(doc, @selector(initRootNodeProperties));
}

@interface QMCell (Copying) <NSCopying>
- (id)copy;
- (id)copyWithZone:(NSZone *)zone;
@end

@implementation QMCell (Copying)
- (id)copy {
    return [self copyWithZone:nil];
}
- (id)copyWithZone:(NSZone *)zone {
    QMCell *cell = [[QMCell alloc] initWithView:self.view];
    cell.stringValue = self.stringValue;
    cell.font = self.font;
    cell.folded = self.folded;

    for (QMCell *child in self.children) {
        [cell addObjectInChildren:child];
    }

    for (id icon in self.icons) {
        [cell addObjectInIcons:icon];
    }

    return cell;
}
@end

static inline id copy_item(id source, NSString *str) {
    id item = [source copy];
    [item setStringValue:str];

    return item;
}

@implementation QMBaseTestCase (Util)

- (NSURL *)urlForResource:(NSString *)fileNameWoExt extension:(NSString *)extension {
    return [[NSBundle bundleForClass:self.class] URLForResource:fileNameWoExt withExtension:extension];
}

- (NSFileWrapper *)fileWrapperForResource:(NSString *)fileNameWoExt extension:(NSString *)extension {
    return [[NSFileWrapper alloc] initWithPath:[[self urlForResource:fileNameWoExt extension:extension] path]];
}

- (QMRootNode *)rootNodeForTest {
    QMRootNode *rootNode = [[QMRootNode alloc] init];
    rootNode.stringValue = @"root node";

    QMNode *nodeTemplate = [[QMNode alloc] init];

    for (int i = 0; i < NUMBER_OF_CHILD; i++) {
        QMNode *childNode = copy_item(nodeTemplate, [NSString stringWithFormat:@"%d. right node", i]);
        [rootNode addObjectInChildren:childNode];

        for (int j = 0; j < NUMBER_OF_GRAND_CHILD; j++) {
            QMNode *grandChild = copy_item(nodeTemplate, [NSString stringWithFormat:@"%d.%d. right node", i, j]);
            [childNode addObjectInChildren:grandChild];
        }
    }

    for (int i = 0; i < NUMBER_OF_LEFT_CHILD; i++) {
        QMNode *childNode = copy_item(nodeTemplate, [NSString stringWithFormat:@"%d. left node", i]);
        [rootNode addObjectInLeftChildren:childNode];

        for (int j = 0; j < NUMBER_OF_LEFT_GRAND_CHILD; j++) {
            QMNode *grandChild = copy_item(nodeTemplate, [NSString stringWithFormat:@"%d.%d. left node", i, j]);
            [childNode addObjectInChildren:grandChild];
        }
    }

    return rootNode;
}

- (QMRootCell *)rootCellForTestWithView:(QMMindmapView *)view {
    QMRootCell *rootCell = [[QMRootCell alloc] initWithView:view];
    rootCell.stringValue = @"root cell";
    rootCell.identifier = [[NSObject alloc] init];

    QMCell *cellTemplate = [[QMCell alloc] initWithView:view];

    for (int i = 0; i < 10; i++) {
        QMCell *childCell = copy_item(cellTemplate, [NSString stringWithFormat:@"%d. right cell", i]);
        childCell.identifier = [[NSObject alloc] init];
        [rootCell addObjectInChildren:childCell];

        for (int j = 0; j < 10; j++) {
            QMCell *grandChild = copy_item(cellTemplate, [NSString stringWithFormat:@"%d.%d. right cell", i, j]);
            grandChild.identifier = [[NSObject alloc] init];
            [childCell addObjectInChildren:grandChild];
        }
    }

    for (int i = 0; i < 10; i++) {
        QMCell *childCell = copy_item(cellTemplate, [NSString stringWithFormat:@"%d. left cell", i]);
        childCell.identifier = [[NSObject alloc] init];
        [rootCell addObjectInLeftChildren:childCell];

        for (int j = 0; j < 10; j++) {
            QMCell *grandChild = copy_item(cellTemplate, [NSString stringWithFormat:@"%d.%d. left cell", i, j]);
            grandChild.identifier = [[NSObject alloc] init];
            [childCell addObjectInChildren:grandChild];
        }
    }

    return rootCell;
}

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
